# Skills 시스템 레퍼런스

Skills는 Codex CLI의 기능을 확장하는 재사용 가능한 instruction package입니다. 이들은 공개 **SKILL.md 표준**을 따르므로, 프로젝트 간에 이식 가능하고 공유하기 쉽습니다.

## SKILL.md 파일 형식

Skills는 `.agents/skills/<name>/SKILL.md`에 위치합니다. 각 skill은 YAML 프론트매터를 포함한 Markdown 파일입니다.

```markdown
---
name: my-skill
description: When to invoke this skill — used for auto-discovery
argument-hint: "[file-path]"
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
model: o4-mini
---

# My Skill Instructions

Detailed instructions for what the skill should do when invoked...
```

## 프론트매터 필드

| 필드 | 타입 | 기본값 | 설명 |
|---|---|---|---|
| `name` | string | 디렉토리 이름 | 표시 이름과 `/slash-command` 트리거 |
| `description` | string | — | 목적 설명. auto-discovery 순위에 사용 |
| `argument-hint` | string | — | `/name` 뒤에 표시되는 자동완성 힌트. 예: `[issue-number]` |
| `disable-model-invocation` | bool | `false` | 자동 호출을 막습니다. 명시적으로만 호출 가능 |
| `user-invocable` | bool | `true` | `false`면 `/` 메뉴에 숨겨짐. 배경 지식용 |
| `allowed-tools` | string | — | 추가 승인 없이 허용되는 도구 목록. 쉼표로 구분 |
| `model` | string | Inherited | 사용할 모델. 예: `o4-mini`, `o3`, `gpt-4.1` |
| `context` | string | — | 고립된 subagent 컨텍스트에서 실행하려면 `fork`로 설정 |
| `agent` | string | `general-purpose` | `context: fork`일 때 사용할 subagent 유형 |
| `hooks` | object | — | 이 skill에 범위 지정된 lifecycle hooks |

## 문자열 치환

Skills는 동적 변수 주입을 지원합니다.

| 변수 | 확장 결과 |
|---|---|
| `$ARGUMENTS` | skill 이름 뒤에 전달된 전체 인자 문자열 |
| `$0` | 첫 번째 위치 인자 |
| `$1`, `$2`, ... | 그 이후 위치 인자 |

**예시**: 사용자가 `/deploy staging v2.1`을 입력하면, `$ARGUMENTS`는 `staging v2.1`, `$0`는 `staging`, `$1`은 `v2.1`입니다.

## Built-in Skills

Codex CLI는 `$` 접두사가 붙은 built-in skills를 몇 가지 제공합니다.

### $plan
구조화된 planning skill입니다. 복잡한 작업을 실행하기 전에 단계별 계획을 만듭니다. 작업이 다단계로 보이면 자동으로 호출됩니다.

### $skill-creator
새 SKILL.md 파일을 생성하는 meta-skill입니다. `/skill-creator`로 호출하고, skill이 무엇을 해야 하는지 설명하면 됩니다.

### $web-search
웹 검색 기능입니다. 현재 정보가 필요한 질문에 답하기 위해 웹 콘텐츠를 가져오고 처리합니다.

## 탐색 경로

Codex CLI는 여러 위치에서 skills를 찾으며, 우선순위는 다음과 같습니다.

1. **Project skills**: 현재 프로젝트의 `./.agents/skills/` 아래. repo root까지 스캔
2. **User skills**: 개인용 cross-project skills를 위한 `~/.agents/skills/`
3. **Built-in skills**: Codex CLI와 함께 제공되는 skills (`$plan`, `$skill-creator` 등)

같은 이름의 skill이 여러 개 있으면 가장 로컬한 버전이 우선합니다. 즉 `project > user > built-in` 순입니다.

## Skill 패턴

### 사용자 호출형 Skill (Slash Command)
```yaml
---
name: deploy
description: Deploy the application to a target environment
argument-hint: "[environment] [version]"
allowed-tools: Bash, Read
---
```
사용자는 `/deploy production v2.0`처럼 호출합니다.

### 에이전트 사전 로드 Skill (배경 지식)
```yaml
---
name: code-standards
description: Team coding standards and conventions
user-invocable: false
---
```
`.codex/config.toml`의 `[agents.<name>]` 역할 설정과 companion TOML 파일을 통해 agent 컨텍스트에 로드됩니다.

```toml
# .codex/config.toml
[agents.backend-dev]
description = "Handles backend development tasks"
config_file = "agents/backend-dev.toml"
```

```toml
# .codex/agents/backend-dev.toml
model = "o4-mini"
skills = ["code-standards"]
```

`/` 메뉴에는 표시되지 않습니다.

### Forked Skill (고립 실행)
```yaml
---
name: security-audit
description: Run security analysis in isolated context
context: fork
agent: security-reviewer
allowed-tools: Bash, Read, Grep, Glob
---
```
메인 대화를 오염시키지 않기 위해 별도의 subagent 컨텍스트에서 실행됩니다.

## 예시: 완전한 Skill

```markdown
---
name: pr-review
description: Review a pull request and provide structured feedback
argument-hint: "[pr-number]"
allowed-tools: Bash, Read, Grep, Glob
model: o4-mini
---

# PR Review Skill

Review pull request #$0 and provide structured feedback.

## Steps
1. Fetch the PR diff using `gh pr diff $0`
2. Read all changed files for full context
3. Analyze for: correctness, security issues, performance, style
4. Output a structured review with severity ratings

## Output Format
다음 템플릿을 사용합니다.
- **Critical**: Issues that must be fixed
- **Warning**: Issues that should be addressed
- **Suggestion**: Optional improvements
- **Praise**: What was done well
```
