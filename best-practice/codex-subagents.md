# 모범 사례: Subagents

Subagents는 Codex가 특화된 에이전트를 병렬로 띄워 복잡하고 병렬성이 높은 작업을 처리하게 해줍니다. 예를 들어 코드베이스 탐색이나 다단계 기능 계획을 나눠 수행한 뒤, 결과를 하나의 응답으로 모을 수 있습니다.

subagent workflow를 사용하면 작업 성격에 맞게 서로 다른 모델 설정과 지시를 가진 custom agent도 정의할 수 있습니다.

## 언제 Subagents를 사용할까

Subagents는 다음과 같은 작업에 적합합니다.
- **Highly parallel** — multiple independent review or exploration threads
- **Domain-specialized** — different tasks need different models, tools, or instructions
- **Large-scope** — reviewing a full PR across security, quality, tests, etc.

Codex는 사용자가 명시적으로 요청할 때만 subagent를 띄웁니다. 각 subagent는 자체적으로 모델과 도구를 사용하므로, subagent workflow는 단일 agent 실행보다 더 많은 토큰을 소비합니다.

## 일반적인 워크플로우

Codex는 오케스트레이션을 담당합니다. subagent를 띄우고, 후속 지시를 전달하고, 결과를 기다리고, 스레드를 닫습니다. 여러 에이전트가 동시에 실행될 때는 모든 결과가 준비될 때까지 기다렸다가 통합 응답을 반환합니다.

**프로젝트에서 이런 프롬프트를 시도해볼 수 있습니다.**

```
I would like to review the following points on the current PR (this branch vs main).
Spawn one agent per point, wait for all of them, and summarize the result for each point.
1. Security issue
2. Code quality
3. Bugs
4. Race conditions
5. Test flakiness
6. Maintainability of the code
```

## Subagents 관리

- CLI의 `/agent`를 사용해 활성 agent thread 사이를 전환하고 진행 중인 작업을 확인합니다
- 실행 중인 subagent의 방향을 조정하거나, 중지하거나, 완료된 thread를 닫으라고 Codex에 직접 지시할 수 있습니다

## 승인과 샌드박스 제어

Subagents는 현재 샌드박스 정책을 상속합니다.

- 대화형 CLI 세션에서는 비활성 thread에서 승인 요청이 올라올 수 있습니다. 오버레이에 소스 thread 라벨이 표시되며, 승인/거부 전에 `o`로 해당 thread를 열 수 있습니다
- 비대화형 흐름에서는 새 승인이 필요한 동작이 실패하고, Codex가 그 오류를 부모 workflow에 전달합니다
- custom agent 파일에 다른 기본값이 있어도, Codex는 자식 agent를 만들 때 부모 turn의 실시간 runtime override(sandbox, `/approvals` 변경, `--yolo`)를 다시 적용합니다
- custom agent별로 샌드박스 설정을 따로 재정의할 수도 있습니다. 예: 특정 agent만 read-only

## Built-in Agents

Codex에는 세 가지 built-in agent가 포함됩니다.

| 에이전트 | 용도 |
|-------|---------|
| `default` | 범용 fallback |
| `worker` | 구현과 수정 중심의 실행 담당 |
| `explorer` | 읽기 중심 코드베이스 탐색 |

## Custom Agents

custom agent는 독립 TOML 파일로 정의합니다.
- `~/.codex/agents/` — personal agents
- `.codex/agents/` — project-scoped agents

각 파일은 하나의 agent를 정의하며, 일반 Codex 세션 설정과 동일한 항목을 재정의할 수 있습니다.

### 필수 필드

모든 custom agent는 다음을 반드시 정의해야 합니다.

| 필드 | 타입 | 목적 |
|-------|------|---------|
| `name` | string | Codex가 spawn할 때 사용하는 agent 이름 |
| `description` | string | Codex가 언제 이 agent를 써야 하는지 |
| `developer_instructions` | string | 핵심 행동 지침 |

### 선택 필드

다음 항목은 생략하면 부모 세션에서 상속됩니다.

- `nickname_candidates` — spawn된 인스턴스에 표시할 별명
- `model` — 모델 override
- `model_reasoning_effort` — 추론 effort 수준
- `sandbox_mode` — 샌드박스 override. 예: `read-only`
- `mcp_servers` — MCP 서버 연결
- `skills.config` — skill 설정

### 전역 Subagent 설정

`config.toml`의 `[agents]` 아래에서 설정합니다.

| 필드 | 기본값 | 목적 |
|-------|---------|---------|
| `agents.max_threads` | 6 | 동시에 열 수 있는 agent thread 상한 |
| `agents.max_depth` | 1 | spawn된 agent의 중첩 깊이 (root = 0) |
| `agents.job_max_runtime_seconds` | 1800 | CSV 작업에서 worker별 기본 timeout |

### 표시용 별명

같은 agent 인스턴스를 많이 실행할 때 읽기 쉬운 라벨을 위해 `nickname_candidates`를 사용합니다.

```toml
name = "reviewer"
description = "PR reviewer focused on correctness, security, and missing tests."
developer_instructions = """
Review code like an owner.
Prioritize correctness, security, behavior regressions, and missing test coverage.
"""
nickname_candidates = ["Atlas", "Delta", "Echo"]
```

별명은 표시용일 뿐이며, Codex는 여전히 `name`으로 agent를 식별합니다.

### Custom Agents 모범 사례

좋은 custom agent는 **좁고 분명한 의견**을 가집니다.
- 각 agent에 명확한 단일 역할을 부여합니다
- 해당 역할에 맞는 도구 표면만 제공합니다
- 인접한 작업으로 번지지 않도록 지시를 작성합니다
- custom agent 이름이 built-in과 같으면(예: `explorer`) custom agent가 우선합니다

## 예시: PR 리뷰 패턴

리뷰를 세 개의 집중된 agent로 나눕니다.

**프로젝트 설정 (`.codex/config.toml`):**
```toml
[agents]
max_threads = 6
max_depth = 1
```

**`.codex/agents/pr-explorer.toml`:**
```toml
name = "pr_explorer"
description = "Read-only codebase explorer for gathering evidence before changes are proposed."
model = "gpt-5.3-codex-spark"
model_reasoning_effort = "medium"
sandbox_mode = "read-only"
developer_instructions = """
Stay in exploration mode.
Trace the real execution path, cite files and symbols, and avoid proposing fixes
unless the parent agent asks for them.
Prefer fast search and targeted file reads over broad scans.
"""
```

**`.codex/agents/reviewer.toml`:**
```toml
name = "reviewer"
description = "PR reviewer focused on correctness, security, and missing tests."
model = "gpt-5.4"
model_reasoning_effort = "high"
sandbox_mode = "read-only"
developer_instructions = """
Review code like an owner.
Prioritize correctness, security, behavior regressions, and missing test coverage.
Lead with concrete findings, include reproduction steps when possible,
and avoid style-only comments unless they hide a real bug.
"""
```

**`.codex/agents/docs-researcher.toml`:**
```toml
name = "docs_researcher"
description = "Documentation specialist that uses the docs MCP server to verify APIs and framework behavior."
model = "gpt-5.3-codex-spark"
model_reasoning_effort = "medium"
sandbox_mode = "read-only"
developer_instructions = """
Use the docs MCP server to confirm APIs, options, and version-specific behavior.
Return concise answers with links or exact references when available.
Do not make code changes.
"""

[mcp_servers.openaiDeveloperDocs]
url = "https://developers.openai.com/mcp"
```

**프롬프트:**
```
Review this branch against main. Have pr_explorer map the affected code paths,
reviewer find real risks, and docs_researcher verify the framework APIs
that the patch relies on.
```

## 예시: 프론트엔드 통합 디버깅

UI 회귀와 cross-stack 버그를 위한 세 agent 예시입니다.

**`.codex/agents/code-mapper.toml`:**
```toml
name = "code_mapper"
description = "Read-only codebase explorer for locating relevant frontend and backend code paths."
model = "gpt-5.3-codex-spark"
model_reasoning_effort = "medium"
sandbox_mode = "read-only"
developer_instructions = """
Map the code that owns the failing UI flow.
Identify entry points, state transitions, and likely files before the worker starts editing.
"""
```

**`.codex/agents/browser-debugger.toml`:**
```toml
name = "browser_debugger"
description = "UI debugger that uses browser tooling to reproduce issues and capture evidence."
model = "gpt-5.4"
model_reasoning_effort = "high"
sandbox_mode = "workspace-write"
developer_instructions = """
Reproduce the issue in the browser, capture exact steps, and report what the UI actually does.
Use browser tooling for screenshots, console output, and network evidence.
Do not edit application code.
"""

[mcp_servers.chrome_devtools]
url = "http://localhost:3000/mcp"
startup_timeout_sec = 20
```

**`.codex/agents/ui-fixer.toml`:**
```toml
name = "ui_fixer"
description = "Implementation-focused agent for small, targeted fixes after the issue is understood."
model = "gpt-5.3-codex-spark"
model_reasoning_effort = "medium"
developer_instructions = """
Own the fix once the issue is reproduced.
Make the smallest defensible change, keep unrelated files untouched,
and validate only the behavior you changed.
"""

[[skills.config]]
path = "/Users/me/.agents/skills/docs-editor/SKILL.md"
enabled = false
```

**Prompt:**
```
Investigate why the settings modal fails to save. Have browser_debugger reproduce it,
code_mapper trace the responsible code path, and ui_fixer implement the smallest fix
once the failure mode is clear.
```

## CSV 배치 처리 (Experimental)

하나의 작업 항목이 한 행에 대응되는 유사 작업이 많을 때는 `spawn_agents_on_csv`를 사용합니다. Codex는 CSV를 읽고, 행마다 worker를 띄우고, 배치가 끝날 때까지 기다린 뒤, 결과를 합쳐 내보냅니다.

**적합한 경우:**
- Reviewing one file, package, or service per row
- Checking lists of incidents, PRs, or migration targets
- Generating structured summaries for many similar inputs

**파라미터:**

| 파라미터 | 목적 |
|-----------|---------|
| `csv_path` | Source CSV |
| `instruction` | Worker prompt template with `{column_name}` placeholders |
| `id_column` | Column for stable item IDs |
| `output_schema` | JSON object shape each worker must return |
| `output_csv_path` | Export path |
| `max_concurrency` | Parallel worker limit |
| `max_runtime_seconds` | Per-worker timeout |

각 worker는 반드시 `report_agent_job_result`를 정확히 한 번 호출해야 합니다. 보고 없이 종료되면 Codex는 해당 행을 오류로 표시합니다.

**예시 프롬프트:**
```
Create /tmp/components.csv with columns path,owner and one row per frontend component.

Then call spawn_agents_on_csv with:
- csv_path: /tmp/components.csv
- id_column: path
- instruction: "Review {path} owned by {owner}. Return JSON with keys path, risk,
  summary, and follow_up via report_agent_job_result."
- output_csv_path: /tmp/components-review.csv
- output_schema: an object with required string fields path, risk, summary, and follow_up
```
