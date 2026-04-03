# Skills 시스템 레퍼런스

Skills는 Codex CLI에 집중된 workflow와 도메인 지식을 추가하는 재사용 가능한 instruction package입니다. 이들은 공개 `SKILL.md` 표준을 따르며, 재사용 가능한 Codex workflow를 작성하는 기본 형식입니다.

## Skill 구조

Skills는 `.agents/skills/<name>/` 아래에 위치하며 반드시 `SKILL.md`를 포함해야 합니다. skill 디렉토리에는 progressive disclosure를 위한 보조 자료도 함께 둘 수 있습니다.

```text
.agents/skills/
  my-skill/
    SKILL.md
    scripts/
    references/
    assets/
    agents/
      openai.yaml
```

- `SKILL.md`: 필수 지침과 메타데이터
- `scripts/`: 선택적 실행 helper
- `references/`: 선택적 문서와 예제
- `assets/`: 선택적 템플릿 또는 정적 리소스
- `agents/openai.yaml`: 선택적 UI, 정책, 의존성 메타데이터

## 최소 `SKILL.md`

Codex는 YAML frontmatter에 `name`과 `description`만 요구합니다.

```markdown
---
name: my-skill
description: Explain exactly when this skill should and should not trigger.
---

# My Skill

Instructions Codex should follow when this skill is activated.
```

`description`은 암묵 호출의 trigger surface이므로, "언제 이 skill이 발동해야 하는가?"를 정확히 쓰는 문장이어야 합니다.

## Codex가 Skills를 사용하는 방식

Codex는 skill을 두 가지 방식으로 활성화할 수 있습니다.

1. 명시 호출: 프롬프트에서 skill을 직접 언급합니다. CLI나 IDE에서는 `/skills`를 사용하거나 `$`를 입력해 skill mention을 넣습니다.
2. 암묵 호출: 작업이 skill의 `description`과 맞으면 Codex가 해당 skill을 선택합니다.

Codex는 skills에 progressive disclosure를 사용합니다. `name`, `description`, 경로, 선택적 `agents/openai.yaml` 같은 메타데이터로 시작한 뒤, skill이 선택되었을 때만 전체 `SKILL.md`를 읽습니다.

## Built-in Skills

Codex는 기본적으로 system skills를 함께 제공합니다. 흔한 예시는 다음과 같습니다.

- `$plan`
- `$skill-creator`
- `$skill-installer`

built-in skill 목록은 릴리스마다 달라질 수 있으므로, 고정 목록보다는 예시 중심으로 다루는 편이 안전합니다.

## 탐색 경로

Codex는 다음 위치에서 skills를 찾습니다.

1. 현재 작업 디렉토리에서 repo root까지의 repository skills: `.agents/skills/`
2. 사용자 skills: `~/.agents/skills/`
3. 관리자 skills: `/etc/codex/skills`
4. Codex에 번들된 system skills

Codex는 현재 작업 디렉토리에서 위로 올라가며 repository 위치를 스캔합니다. 같은 이름의 skill이 둘 이상 있어도 병합하지 않습니다.

## Plugins로 Skills 배포하기

skills는 작성 형식이고, plugins는 재사용 가능한 skills, apps, MCP integration을 배포하는 설치 단위입니다.

repo 내부 workflow와 일상적인 작성에는 직접 skill 폴더를 사용합니다. skills를 배포하거나 apps, MCP config와 함께 묶거나 marketplace를 통해 배포하려면 plugin으로 패키징합니다.

## Skills 활성화/비활성화

skill을 삭제하지 않고 끄려면 `~/.codex/config.toml`의 `[[skills.config]]`를 사용합니다.

```toml
[[skills.config]]
path = "/path/to/skill/SKILL.md"
enabled = false
```

skill config를 바꾼 뒤에는 Codex를 재시작합니다.

## `agents/openai.yaml`을 이용한 선택적 메타데이터

문서화되지 않은 frontmatter 필드에 의존하지 말고, 선택적 UI, 정책, 의존성 메타데이터에는 `agents/openai.yaml`을 사용합니다.

```yaml
interface:
  display_name: "Docs Helper"
  short_description: "Verifies framework APIs before code changes"

policy:
  allow_implicit_invocation: false

dependencies:
  tools:
    - type: mcp
      value: openaiDeveloperDocs
      description: OpenAI Docs MCP server
      transport: streamable_http
      url: https://developers.openai.com/mcp
```

## 모범 사례

- 각 skill은 하나의 작업에 집중시킵니다.
- 결정적 동작이나 외부 도구가 꼭 필요하지 않다면 scripts보다 instructions를 우선합니다.
- `description` 필드는 마케팅 문구가 아니라 trigger condition으로 작성합니다.
- `SKILL.md`를 짧게 유지하려면 `references/`, `scripts/`를 사용합니다.
- 단일 repo 밖에서 재사용하려면 plugins를 사용합니다.
