# codex-cli-best-practice
practice makes codex perfect

![updated with Codex CLI](https://img.shields.io/badge/updated_with_Codex_CLI-v0.118.0%20(Apr%2003%2C%202026%2011%3A04%20PM%20PKT)-white?style=flat&labelColor=555) <a href="https://github.com/shanraisshan/codex-cli-best-practice/stargazers"><img src="https://img.shields.io/github/stars/shanraisshan/codex-cli-best-practice?style=flat&label=%E2%98%85&labelColor=555&color=white" alt="GitHub Stars"></a>

[![Best Practice](!/tags/best-practice.svg)](best-practice/) [![Implemented](!/tags/implemented.svg)](.codex/) [![Orchestration Workflow](!/tags/orchestration-workflow.svg)](orchestration-workflow/orchestration-workflow.md) [![Codex](!/tags/codex.svg)](https://developers.openai.com/codex/overview) [![Community](!/tags/community.svg)](#-팁과-트릭) ![아래 배지를 클릭하면 실제 출처를 볼 수 있습니다](!/tags/click-badges.svg)<br>
<img src="!/tags/a.svg" height="14"> = Agents · <img src="!/tags/c.svg" height="14"> = Commands · <img src="!/tags/s.svg" height="14"> = Skills

<p align="center">
  <img src="!/codex-jumping.svg" alt="점프하는 Codex CLI 마스코트" width="120" height="100">
</p>

## 🧠 개념

| 기능 | 위치 | 설명 |
|---------|----------|-------------|
| <img src="!/tags/c.svg" height="14"> [**Commands**](https://developers.openai.com/codex/cli/slash-commands) | `interactive session / slash popup` | 세션 제어용 built-in slash command입니다. 예: `/plan`, `/fast`, `/fork`, `/review`, `/status`, `/mcp`, `/agent`, `/apps`, `/model`, `/permissions` |
| <img src="!/tags/a.svg" height="14"> [**Subagents**](https://developers.openai.com/codex/subagents) | [`.codex/agents/<name>.toml`](.codex/agents/) | [![Best Practice](!/tags/best-practice.svg)](best-practice/codex-subagents.md) [![Implemented](!/tags/implemented.svg)](.codex/agents/) 전용 TOML 역할 설정, 병렬 subagent orchestration, CSV 배치 처리를 갖는 custom agent입니다. 전역 설정은 `[agents]` 아래에 있으며 `max_threads`, `max_depth`, `job_max_runtime_seconds`를 포함합니다. Built-in은 `default`, `worker`, `explorer`입니다 |
| <img src="!/tags/s.svg" height="14"> [**Skills**](https://developers.openai.com/codex/skills) | [`.agents/skills/<name>/SKILL.md`](.agents/skills/) | [![Best Practice](!/tags/best-practice.svg)](best-practice/codex-skills.md) [![Implemented](!/tags/implemented.svg)](.agents/skills/) [Reference](docs/SKILLS.md) 필수 `name` + `description` 메타데이터를 갖는 재사용 가능한 instruction package입니다. `scripts/`, `references/`, `assets/`, 선택적 `agents/openai.yaml`로 progressive disclosure를 구성할 수 있습니다. `/skills`나 `$skill-name`으로 명시 호출하거나, description 매칭으로 암묵 호출할 수 있습니다. Built-in 예시는 `$plan`, `$skill-creator`, `$skill-installer`이며 [Plugins](https://developers.openai.com/codex/plugins)로 배포할 수 있습니다 |
| [**Plugins**](https://developers.openai.com/codex/plugins) | `.codex-plugin/plugin.json` | skills, app integrations, MCP servers를 묶어 배포하는 번들입니다. 로컬/개인용 [marketplace](https://developers.openai.com/codex/plugins/build) 시스템을 사용하며 built-in은 `$plugin-creator`입니다. `/plugins` 또는 Codex App에서 탐색할 수 있습니다 |
| [**Workflows**](https://developers.openai.com/codex/workflows/) | [`.codex/agents/weather-agent.toml`](.codex/agents/weather-agent.toml) | [![Orchestration Workflow](!/tags/orchestration-workflow.svg)](orchestration-workflow/orchestration-workflow.md) 코드베이스 설명, 버그 수정, 테스트 작성, 스크린샷 기반 프로토타이핑, UI 반복, cloud 위임, 코드 리뷰, 문서 업데이트 같은 end-to-end 사용 패턴입니다 |
| [**MCP Servers**](https://developers.openai.com/codex/mcp) | `config.toml` → `[mcp_servers.*]` | [![Best Practice](!/tags/best-practice.svg)](best-practice/codex-mcp.md) [![Implemented](!/tags/implemented.svg)](.codex/config.toml) 외부 도구 연결을 위한 Model Context Protocol입니다. STDIO와 Streamable HTTP 서버를 지원하고 OAuth를 사용할 수 있습니다(`codex mcp login`). `codex mcp-server`로 MCP **server** 역할도 수행하며 `codex()`와 `codex-reply()` 도구를 노출합니다. CLI 관리 명령은 `codex mcp add|get|list|login|logout|remove`입니다 |
| [**Config**](https://developers.openai.com/codex/config-basic) | [`.codex/config.toml`](.codex/config.toml) | [![Best Practice](!/tags/best-practice.svg)](best-practice/codex-config.md) [![Implemented](!/tags/implemented.svg)](.codex/config.toml) TOML 기반 layered config 시스템입니다. [Profiles](https://developers.openai.com/codex/config-basic), [Sandbox](https://developers.openai.com/codex/cli/features), [Approval Policy](https://developers.openai.com/codex/cli/features), [Advanced](https://developers.openai.com/codex/config-advanced) 설정(`[features]`, `[otel]`, `[shell_environment_policy]`, `[tui]`, model providers, granular approvals`)을 포함합니다. 프로젝트 config용 [Trust](https://developers.openai.com/codex/config-basic) 시스템, `developer_instructions`, custom system prompt용 `model_instructions_file`도 지원합니다 |
| [**Rules**](https://developers.openai.com/codex/rules) | `.codex/rules/` | `prefix_rule()` 기반의 Starlark 명령 실행 정책입니다. `allow`, `prompt`, `forbidden` 결정을 exact-prefix matching으로 정의하며 `codex execpolicy check`로 테스트할 수 있습니다. rules는 granular `approval_policy`와 사용자 승인 관리와 함께 동작합니다 |
| [**AGENTS.md**](https://developers.openai.com/codex/guides/agents-md) | [`AGENTS.md`](AGENTS.md) | [![Best Practice](!/tags/best-practice.svg)](best-practice/codex-agents-md.md) Codex CLI의 프로젝트 수준 컨텍스트 문서입니다. 현재 작업 디렉토리에서 repo root까지 계층적으로 탐색하며 `project_doc_max_bytes` 기준 32 KiB 제한이 있습니다. 개인 오버라이드는 `AGENTS.override.md`를 사용합니다 |
| [**Hooks**](https://developers.openai.com/codex/hooks) ![beta](!/tags/beta.svg) | [`.codex/hooks.json`](.codex/) | [![Best Practice](!/tags/best-practice.svg)](best-practice/codex-hooks.md) [![Implemented](!/tags/implemented.svg)](https://github.com/shanraisshan/codex-cli-hooks) agentic loop에 주입되는 사용자 정의 셸 스크립트입니다. 로깅, 보안 스캔, 검증, 자동화에 사용하며 `codex_hooks = true` feature flag가 필요합니다 |
| [**Speed**](https://developers.openai.com/codex/speed) | `config.toml` → `service_tier` | gpt-5.4에서 Fast Mode를 쓰면 속도는 1.5배, 크레딧 사용량은 2배입니다. `/fast on|off|status`로 전환할 수 있고, Pro 구독자는 GPT-5.3-Codex-Spark로 매우 빠른 반복 작업을 할 수 있습니다 |
| [**Code Review**](https://developers.openai.com/codex/cli/features) | `/review` | 브랜치, 커밋 전 변경사항, 특정 커밋을 리뷰합니다. `config.toml`의 `review_model`로 설정할 수 있고 custom review instructions도 지원합니다 |
| **AI Terms** | | [![Best Practice](!/tags/best-practice.svg)](https://github.com/shanraisshan/claude-code-codex-cursor-gemini/blob/main/reports/ai-terms.md) Agentic Engineering · Context Engineering · Vibe Coding |
| [**Best Practices**](https://developers.openai.com/codex/learn/best-practices) | | 공식 best practices 문서입니다. [Prompt Engineering](https://platform.openai.com/docs/guides/prompt-engineering), [Codex Guides](https://developers.openai.com/codex/overview)도 함께 참고할 수 있습니다 |

<p align="center">
  <img src="!/codex-jumping.svg" alt="section divider" width="60" height="50">
</p>

[![Orchestration Workflow](!/tags/orchestration-workflow-hd.svg)](orchestration-workflow/orchestration-workflow.md)

[orchestration-workflow](orchestration-workflow/orchestration-workflow.md)에서 <img src="!/tags/a.svg" height="14"> **Agent** → <img src="!/tags/s.svg" height="14"> **Skill** 패턴의 구현 상세를 확인할 수 있습니다. 에이전트가 Open-Meteo에서 기온을 가져오고 SVG creator skill을 호출합니다.

<p align="center">
  <img src="!/orchestration-workflow-diagram.svg" alt="Orchestration Workflow: Agent → Skill → Output" width="100%">
</p>

![How to Use](!/tags/how-to-use.svg)

```bash
codex
> Fetch the current weather for Dubai in Celsius and create the SVG weather card output using the repo.
```

> **참고:** 이 워크플로우는 [Claude Code Best Practice](https://github.com/shanraisshan/claude-code-best-practice)의 orchestration workflow와 100% 일치하지는 않습니다. Codex CLI는 아직 custom commands(`.codex/commands/`)를 지원하지 않으므로 전체 <img src="!/tags/c.svg" height="14"> **Command** → <img src="!/tags/a.svg" height="14"> **Agent** → <img src="!/tags/s.svg" height="14"> **Skill** 패턴은 구현할 수 없습니다. Codex App Server 문서에는 실험적인 `tool/requestUserInput`가 있고 codex-cli 0.115.0에는 개발 중인 feature flag 뒤에 내부 `request_user_input` 기능이 있지만, 둘 다 아직 공개되지 않았습니다.

<p align="center">
  <img src="!/codex-jumping.svg" alt="section divider" width="60" height="50">
</p>

## ⚙️ 개발 워크플로우

모든 주요 워크플로우는 같은 아키텍처 패턴으로 수렴합니다. **Research → Plan → Execute → Review → Ship**

| 이름 | ★ | 차별점 | Plan | <img src="!/tags/a.svg" height="14"> | <img src="!/tags/s.svg" height="14"> |
|------|---|------------|------|---|---|
| [Superpowers](https://github.com/obra/superpowers) | 134k | ![TDD-first](https://img.shields.io/badge/TDD--first-ddf4ff) ![Iron Laws](https://img.shields.io/badge/Iron_Laws-ddf4ff) ![agent-agnostic](https://img.shields.io/badge/agent--agnostic-ddf4ff) | <img src="!/tags/s.svg" height="14"> [writing-plans](https://github.com/obra/superpowers/tree/main/skills/writing-plans) | 5 | 14 |
| [Spec Kit](https://github.com/github/spec-kit) | 85k | ![spec-driven](https://img.shields.io/badge/spec--driven-ddf4ff) ![constitution](https://img.shields.io/badge/constitution-ddf4ff) ![--ai-skills](https://img.shields.io/badge/----ai--skills-ddf4ff) | <img src="!/tags/s.svg" height="14"> [$speckit-plan](https://github.com/github/spec-kit) | 0 | 0 |
| [gstack](https://github.com/garrytan/gstack) | 63k | ![role personas](https://img.shields.io/badge/role_personas-ddf4ff) ![/codex review](https://img.shields.io/badge/%2Fcodex_review-ddf4ff) ![parallel sprints](https://img.shields.io/badge/parallel_sprints-ddf4ff) | <img src="!/tags/s.svg" height="14"> [autoplan](https://github.com/garrytan/gstack/tree/main/autoplan) | 0 | 31 |
| [Get Shit Done](https://github.com/gsd-build/get-shit-done) | 47k | ![fresh 200K contexts](https://img.shields.io/badge/fresh_200K_contexts-ddf4ff) ![wave execution](https://img.shields.io/badge/wave_execution-ddf4ff) ![--codex flag](https://img.shields.io/badge/----codex_flag-ddf4ff) | <img src="!/tags/a.svg" height="14"> [gsd-planner](https://github.com/gsd-build/get-shit-done/blob/main/agents/gsd-planner.md) | 21 | 0 |
| [oh-my-codex](https://github.com/Yeachan-Heo/oh-my-codex) | 23k | ![teams orchestration](https://img.shields.io/badge/teams_orchestration-ddf4ff) ![tmux workers](https://img.shields.io/badge/tmux_workers-ddf4ff) ![omc team N:codex](https://img.shields.io/badge/omc_team_N%3Acodex-ddf4ff) | <img src="!/tags/s.svg" height="14"> [ralplan](https://github.com/Yeachan-Heo/oh-my-codex/tree/main/skills/ralplan) | 19 | 36 |
| [Compound Engineering](https://github.com/EveryInc/compound-engineering-plugin) | 13k | ![Compound Learning](https://img.shields.io/badge/Compound_Learning-ddf4ff) ![Multi-Platform CLI](https://img.shields.io/badge/Multi--Platform_CLI-ddf4ff) ![install --to codex](https://img.shields.io/badge/install_----to_codex-ddf4ff) | <img src="!/tags/s.svg" height="14"> [ce-plan](https://github.com/EveryInc/compound-engineering-plugin/tree/main/plugins/compound-engineering/skills/ce-plan) | 49 | 42 |

### 기타
- [Cross-Model (Claude Code + Codex) Workflow](https://github.com/shanraisshan/claude-code-best-practice/blob/main/development-workflows/cross-model-workflow/cross-model-workflow.md) [![Implemented](!/tags/implemented.svg)](https://github.com/shanraisshan/claude-code-best-practice/blob/main/development-workflows/cross-model-workflow/cross-model-workflow.md)

<p align="center">
  <img src="!/codex-jumping.svg" alt="section divider" width="60" height="50">
</p>

## 💡 팁과 트릭 (47)

[Prompting](#tips-prompting) · [Planning](#tips-planning) · [AGENTS.md](#tips-agentsmd) · [Agents](#tips-agents) · [Skills](#tips-skills) · [Hooks](#tips-hooks) · [Workflows](#tips-workflows) · [Advanced](#tips-workflows-advanced) · [Git / PR](#tips-git-pr) · [Debugging](#tips-debugging) · [Utilities](#tips-utilities) · [Daily](#tips-daily)

![Community](!/tags/community.svg)

<a id="tips-prompting"></a>■ **Prompting (3)**

| Tip |
|-----|
| Codex에게 도전 과제를 줍니다. 예: "prove to me this works"라고 하고 main과 현재 브랜치 diff를 보게 합니다 |
| 평범한 수정이 나왔으면 "knowing everything you know now, scrap this and implement the elegant solution"처럼 다시 시킵니다 |
| 대부분의 버그는 Codex가 스스로 고칠 수 있습니다. 버그를 붙여 넣고 "fix"라고만 하고, 구현 방법까지 세세하게 통제하지 않습니다 |

<a id="tips-planning"></a>■ **Planning (4)**

| Tip |
|-----|
| 명시적 계획이 필요하면 [/plan](https://developers.openai.com/codex/cli/slash-commands)을 사용합니다. 다단계 작업에서는 Codex가 자동으로 계획할 수도 있습니다 |
| 각 phase에 unit, automation, integration 테스트를 둔 단계별 gated plan을 항상 만듭니다 |
| 두 번째 Codex를 띄우거나 [cross-model](https://github.com/shanraisshan/claude-code-best-practice/blob/main/development-workflows/cross-model-workflow/cross-model-workflow.md) 방식을 사용해 staff engineer처럼 계획을 리뷰하게 합니다 |
| 작업을 넘기기 전에 상세 spec을 쓰고 모호함을 줄입니다. 구체적일수록 출력 품질이 좋아집니다 |

<a id="tips-agentsmd"></a>■ **AGENTS.md (5)**

| Tip |
|-----|
| [AGENTS.md](https://developers.openai.com/codex/guides/agents-md)는 간결하게 유지합니다. 150줄은 유용한 경험칙이고 실제 제한은 바이트 기반인 32 KiB입니다 |
| 팀에 영향을 주지 않는 개인 선호는 [AGENTS.override.md](https://developers.openai.com/codex/rules)로 관리합니다 |
| 어떤 개발자든 Codex를 켜고 "run the tests"라고 했을 때 바로 동작해야 합니다. 안 된다면 AGENTS.md에 필수 setup/build/test 명령이 빠진 것입니다 |
| 코드베이스를 깔끔하게 유지하고 마이그레이션은 끝까지 완료합니다. 중간 상태의 프레임워크는 모델이 잘못된 패턴을 선택하게 만듭니다 |
| harness가 강제해야 할 동작은 [config.toml](https://developers.openai.com/codex/config-basic)에 둡니다. approval policy, sandbox, model처럼 결정적인 설정은 AGENTS.md에 넣지 않습니다 |

<a id="tips-agents"></a><img src="!/tags/a.svg" height="14"> **Agents (3)**

| Tip |
|-----|
| 일반적인 qa, backend engineer 대신 기능별 [sub-agents](https://developers.openai.com/codex/subagents)와 [skills](https://developers.openai.com/codex/skills)를 둡니다 |
| 문제에 더 많은 계산량을 투입하려면 [multi-agent](https://developers.openai.com/codex/multi-agent/)를 사용합니다. 메인 컨텍스트를 깔끔하고 집중된 상태로 유지하기 위해 작업을 분리합니다 |
| test time compute를 사용합니다. 별도 컨텍스트 창이 결과를 더 좋게 만들고, 한 agent가 버그를 만들면 다른 agent가 그 버그를 찾을 수 있습니다 |

<a id="tips-skills"></a><img src="!/tags/s.svg" height="14"> **Skills (7)**

| Tip |
|-----|
| auto-discovery를 위해 `name`, `description`이 명확한 [skills](https://developers.openai.com/codex/skills)를 사용합니다 |
| skills는 파일이 아니라 폴더입니다. [progressive disclosure](https://developers.openai.com/codex/skills)를 위해 `references/`, `scripts/`, `examples/` 하위 디렉토리를 사용합니다 |
| 모든 skill에 Gotchas 섹션을 둡니다. 가장 신호가 높은 내용이고, 시간이 지나며 Codex의 실패 지점을 계속 추가할 수 있습니다 |
| skill의 description 필드는 요약이 아니라 trigger입니다. 모델 입장에서 "언제 발동해야 하는가?"를 쓰는 자리입니다 |
| skills에서 당연한 내용을 적지 않습니다. Codex를 기본 동작에서 벗어나게 하는 정보에 집중합니다 |
| skills에서 Codex를 과도하게 레일 위에 올리지 않습니다. 단계별 명령보다 목표와 제약을 줍니다 |
| built-in skill creator로 새 skill을 스캐폴딩하고, 저장소 전체에서 하나의 호출 스타일만 일관되게 문서화합니다 |

<a id="tips-hooks"></a>■ **Hooks (2)**

| Tip |
|-----|
| 로깅, 보안 스캔, 검증에는 [hooks](https://developers.openai.com/codex/hooks)를 사용합니다. `codex_hooks = true` feature flag가 필요합니다 |
| 코드 자동 포맷팅에 hooks를 사용합니다. Codex가 대체로 잘 포맷된 코드를 만들고, hook이 마지막 10%를 정리해 CI 실패를 줄입니다 |

<a id="tips-workflows"></a>■ **Workflows (4)**

| Tip |
|-----|
| 작은 작업에서는 어떤 워크플로우보다 기본 Codex가 더 낫습니다 |
| 프로젝트에 정의된 안전 수준 전환에는 [profiles](https://developers.openai.com/codex/config-basic)를 사용합니다. 이 저장소에서는 `conservative`, `trusted`가 예시입니다 |
| [on-request](https://developers.openai.com/codex/cli/features) 승인 정책으로 시작하고, 확신이 생겼을 때만 never로 올립니다 |
| 현재 스레드를 잃지 않고 대안을 탐색하려면 세션 안에서 [/fork](https://developers.openai.com/codex/cli/slash-commands)(또는 `codex fork`)를 사용하고, 이어서 작업하려면 [/resume](https://developers.openai.com/codex/cli/slash-commands)(또는 `codex resume`)을 사용합니다 |

<a id="tips-workflows-advanced"></a>■ **Workflows Advanced (5)**

| Tip |
|-----|
| 병렬 fan-out 작업을 위해 [multi-agent](https://developers.openai.com/codex/multi-agent/)로 sub-agent를 생성합니다. 현재는 기본 활성화된 GA 기능입니다 |
| headless/CI 파이프라인에는 [codex exec](https://developers.openai.com/codex/noninteractive)를 사용합니다 |
| [sandbox modes](https://developers.openai.com/codex/cli/features)와 [approval policies](https://developers.openai.com/codex/cli/features)를 조합합니다. `workspace-write + on-request`가 좋은 기본값입니다 |
| 병렬 개발에는 [git worktrees](https://git-scm.com/docs/git-worktree)를 사용합니다 |
| 아키텍처를 이해할 때 ASCII diagram을 자주 사용합니다 |

<a id="tips-git-pr"></a>■ **Git / PR (3)**

| Tip | Source |
|-----|--------|
| PR은 작고 집중되게 유지합니다. 기능 하나당 PR 하나가 리뷰와 revert를 쉽게 만듭니다 | |
| 항상 squash merge를 사용합니다. 선형 이력을 유지하고 기능당 커밋 하나가 되므로 `git revert`, `git bisect`가 쉬워집니다 | |
| 작업이 끝나는 즉시 자주 커밋합니다 | ![Shayan](!/tags/community-shayan.svg) |

<a id="tips-debugging"></a>■ **Debugging (5)**

| Tip | Source |
|-----|--------|
| 보고 싶은 로그가 있는 터미널은 항상 Codex에게 background task로 실행시키라고 합니다 | |
| 브라우저 콘솔 로그를 Codex가 직접 볼 수 있도록 MCP([Chrome DevTools](https://developer.chrome.com/blog/chrome-devtools-mcp), [Playwright](https://github.com/microsoft/playwright-mcp))를 사용합니다 | |
| 이슈에 막혔을 때는 스크린샷을 찍어 Codex와 공유하는 습관을 들입니다 | ![Shayan](!/tags/community-shayan.svg) |
| QA에는 다른 모델을 사용합니다. 예: 계획과 구현 리뷰에는 [Claude Code](https://github.com/shanraisshan/claude-code-best-practice) | |
| agentic search(glob + grep)는 RAG보다 낫습니다. 코드는 쉽게 drift되고 권한 구조도 복잡합니다 | |

<a id="tips-utilities"></a>■ **Utilities (4)**

| Tip | Source |
|-----|--------|
| IDE([VS Code](https://code.visualstudio.com/), [Cursor](https://www.cursor.com/))보다 [iTerm](https://iterm2.com/), [Ghostty](https://ghostty.org/), [tmux](https://github.com/tmux/tmux) 같은 터미널을 사용합니다 | |
| 음성 프롬프팅에는 [Wispr Flow](https://wisprflow.ai)를 사용합니다. 생산성이 크게 올라갑니다 | |
| Codex 피드백에는 [codex-cli-hooks](https://github.com/shanraisshan/codex-cli-hooks)를 사용합니다 | ![Shayan](!/tags/community-shayan.svg) |
| 개인화된 사용 경험을 위해 [profiles](https://developers.openai.com/codex/config-basic), [sandbox modes](https://developers.openai.com/codex/cli/features), [MCP](https://developers.openai.com/codex/mcp) 같은 `config.toml` 기능을 탐색합니다 | |

<a id="tips-daily"></a>■ **Daily (2)**

| Tip | Source |
|-----|--------|
| Codex CLI를 매일 업데이트합니다 | ![Shayan](!/tags/community-shayan.svg) |
| 하루를 [changelog](https://github.com/openai/codex/releases) 읽기로 시작합니다 | ![Shayan](!/tags/community-shayan.svg) |

![Codex](!/tags/codex.svg)

| Article / Tweet | Source |
|-----------------|--------|
| How Codex is built — 90% self-built in Rust (Tibo, Pragmatic Engineer) \| 17 Feb 2026 | [![Tibo](!/tags/tibo.svg)](https://x.com/thsottiaux) |
| Skills in Codex — standardizing .agents/skills across agents (Embiricos) \| Feb 2026 | [![Embiricos](!/tags/embiricos.svg)](https://x.com/embirico) |
| Unrolling the Codex agent loop — how Codex works internally (Bolin) \| Jan 2026 | [Tweet](https://x.com/OpenAIDevs/status/2014794871962533970) |
| AMA with Codex team — CLI, sandbox, agents (Embiricos, Fouad, Tibo + team) \| May 2025 | [Reddit](https://www.reddit.com/r/ChatGPT/comments/1ko3tp1/ama_with_openai_codex_team/) |
| Codex CLI — open-source local coding agent, first look (Fouad + Romain) \| Apr 2025 | [Tweet](https://x.com/OpenAIDevs/status/1912556874211422572) |

<p align="center">
  <img src="!/codex-jumping.svg" alt="section divider" width="60" height="50">
</p>

## 🎬 영상 / 팟캐스트

| Video / Podcast | Source | Link |
|-----------------|--------|------|
| The power user's guide to Codex — parallelizing workflows, planning, context engineering (Embiricos) \| 2026 \| How I AI | [![Embiricos](!/tags/embiricos.svg)](https://x.com/embirico) | [Podcast](https://open.spotify.com/episode/6RNqTaOb5ly3zgQCGB23fE) |
| Scaffolding is coping not scaling, and other lessons from Codex (Tibo) \| 2026 \| Dev Interrupted | [![Tibo](!/tags/tibo.svg)](https://x.com/thsottiaux) | [Podcast](https://linearb.io/dev-interrupted/podcast/openai-codex-thibault-sottiaux-agentic-autonomy) |
| How Codex team uses their coding agent (Tibo + Andrew) \| 18 Feb 2026 \| Every | [![Tibo](!/tags/tibo.svg)](https://x.com/thsottiaux) | [Podcast](https://every.to/podcast/transcript-how-openai-s-codex-team-uses-their-coding-agent) |
| Dogfood — Codex team uses Codex to build Codex (Tibo) \| 24 Feb 2026 \| Stack Overflow | [![Tibo](!/tags/tibo.svg)](https://x.com/thsottiaux) | [Podcast](https://stackoverflow.blog/2026/02/24/dogfood-so-nutritious-it-s-building-the-future-of-sdlcs/) |
| Why humans are AI's biggest bottleneck — Codex product vision (Embiricos) \| Feb 2026 \| Lenny's Podcast | [![Embiricos](!/tags/embiricos.svg)](https://x.com/embirico) | [Podcast](https://www.lennysnewsletter.com/p/why-humans-are-ais-biggest-bottleneck) |
| OpenAI and Codex (Tibo + Ed Bayes) \| 29 Jan 2026 \| Software Engineering Daily | [![Tibo](!/tags/tibo.svg)](https://x.com/thsottiaux) | [Podcast](https://softwareengineeringdaily.com/2026/01/29/openai-and-codex-with-thibault-sottiaux-and-ed-bayes/) |

<p align="center">
  <img src="!/codex-jumping.svg" alt="section divider" width="60" height="50">
</p>

## 🔔 구독

| Source | Name | Badge |
|--------|------|-------|
| ![Reddit](https://img.shields.io/badge/-FF4500?style=flat&logo=reddit&logoColor=white) | [r/ChatGPT](https://www.reddit.com/r/ChatGPT/), [r/OpenAI](https://www.reddit.com/r/OpenAI/), [r/Codex](https://www.reddit.com/r/Codex/) | ![Codex](!/tags/codex.svg) |
| ![X](https://img.shields.io/badge/-000?style=flat&logo=x&logoColor=white) | [OpenAI](https://x.com/OpenAI), [OpenAI Devs](https://x.com/OpenAIDevs), [Tibo](https://x.com/thsottiaux), [Embiricos](https://x.com/embirico), [Jason](https://x.com/jxnlco), [Romain](https://x.com/romainhuet), [Dominik](https://x.com/dkundel), [Fouad](https://x.com/fouadmatin), [Bolin](https://x.com/bolinfest) | ![Codex](!/tags/codex.svg) |
| ![X](https://img.shields.io/badge/-000?style=flat&logo=x&logoColor=white) | [Jesse Kriss](https://x.com/obra) ([Superpowers](https://github.com/obra/superpowers)), [Garry Tan](https://x.com/garrytan) ([gstack](https://github.com/garrytan/gstack)), [Kieran Klaassen](https://x.com/kieranklaassen) ([Compound Eng](https://github.com/EveryInc/compound-engineering-plugin)), [Lex Christopherson](https://x.com/official_taches) ([GSD](https://github.com/gsd-build/get-shit-done)), [Yeachan Heo](https://x.com/bellman_ych) ([oh-my-codex](https://github.com/Yeachan-Heo/oh-my-codex)), [Andrej Karpathy](https://x.com/karpathy) | ![Community](!/tags/community.svg) |
| ![YouTube](https://img.shields.io/badge/-F00?style=flat&logo=youtube&logoColor=white) | [OpenAI](https://www.youtube.com/@OpenAI) | ![Codex](!/tags/codex.svg) |
| ![YouTube](https://img.shields.io/badge/-F00?style=flat&logo=youtube&logoColor=white) | [Lenny's Podcast](https://www.youtube.com/@LennysPodcast), [The Pragmatic Engineer](https://www.youtube.com/@mrgergelyorosz), [Every](https://www.youtube.com/@every_media) | ![Community](!/tags/community.svg) |

<p align="center">
  <img src="!/codex-jumping.svg" alt="section divider" width="60" height="50">
</p>

<a href="https://github.com/shanraisshan/claude-code-best-practice#billion-dollar-questions"><img src="!/tags/billion-dollar-questions.svg" alt="Billion-Dollar Questions"></a>

<p align="center">
  <img src="!/codex-jumping.svg" alt="section divider" width="60" height="50">
</p>

## 다른 저장소

<a href="https://github.com/shanraisshan/codex-cli-hooks"><img src="!/codex-speaking.svg" alt="Codex CLI Hooks" width="40" height="40" align="center"></a> <a href="https://github.com/shanraisshan/codex-cli-hooks"><strong>codex-cli-hooks</strong></a> · <a href="https://github.com/shanraisshan/claude-code-best-practice"><img src="!/claude-jumping.svg" alt="Claude Code" width="40" height="40" align="center"></a> <a href="https://github.com/shanraisshan/claude-code-best-practice"><strong>claude-code-best-practice</strong></a> · <a href="https://github.com/shanraisshan/claude-code-hooks"><img src="!/claude-speaking.svg" alt="Claude Code Hooks" width="40" height="40" align="center"></a> <a href="https://github.com/shanraisshan/claude-code-hooks"><strong>claude-code-hooks</strong></a>

---

<a href="https://openai.com/form/codex-for-oss/"><img src="!/tags/codex-for-oss.svg" alt="Codex for Open Source" width="720"></a>
