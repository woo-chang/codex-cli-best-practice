# 모범 사례: Skills

Skills는 재사용 가능하고 조합 가능한 instruction package로 Codex CLI를 확장하는 기본 메커니즘입니다. 이들은 `SKILL.md` 표준을 따르며, 범위가 좁고 트리거가 명확하고 컨텍스트를 작게 유지할수록 가장 잘 동작합니다.

## 핵심 패턴

Codex는 skills를 두 가지 방식으로 사용합니다.

1. 명시 호출: 프롬프트에서 skill을 직접 언급합니다. CLI나 IDE에서는 `/skills`를 사용하거나 `$`를 입력해 skill mention을 넣습니다.
2. 암묵 호출: 작업이 skill의 `description`과 맞으면 Codex가 해당 skill을 선택합니다.

즉 `description` 필드는 skill 메타데이터에서 가장 중요한 부분입니다.

## 최소 Frontmatter

문서화된 이유가 없다면 필수 frontmatter만 사용합니다.

```yaml
---
name: docs-helper
description: Verify framework API details before making code changes or writing migration guidance.
---
```

나머지 skill 본문은 입력, workflow, expected outputs에 집중해야 합니다.

## Progressive Disclosure용 구조

Codex가 필요할 때만 추가 정보를 읽을 수 있도록 skill을 구성합니다.

```text
.agents/skills/
  docs-helper/
    SKILL.md
    references/
    scripts/
    assets/
    agents/
      openai.yaml
```

- 핵심 workflow 지침은 `SKILL.md`에 둡니다.
- 깊은 참고 자료는 `references/`에 둡니다.
- 결정적인 helper는 `scripts/`에 둡니다.
- 선택적 UI 메타데이터, invocation policy, tool dependency는 `agents/openai.yaml`을 사용합니다.

## 더 나은 Description 작성

좋은 description은 trigger condition처럼 동작합니다.

```yaml
# Good
description: Review TypeScript changes for type-safety regressions and missing runtime validation.

# Bad
description: Help with TypeScript.
```

언제 이 skill이 발동해야 하는지, 필요하다면 언제 발동하지 말아야 하는지까지 구체적으로 씁니다.

## 현재 Codex 동작 기준으로 설계하기

- skills를 custom slash command가 아니라 재사용 가능한 workflow로 취급합니다.
- 명시 호출 예시는 `/skills`와 `$skill-name` mention을 우선 사용합니다.
- 단일 repo 밖으로 재사용 가능한 skills를 배포할 때는 plugins를 사용합니다.
- skill을 삭제하지 않고 끄려면 `~/.codex/config.toml`의 `[[skills.config]]`를 사용합니다.

예시:

```toml
[[skills.config]]
path = "/path/to/skill/SKILL.md"
enabled = false
```

## 선택적 메타데이터

더 풍부한 메타데이터가 필요하면 `agents/openai.yaml`을 사용합니다.

```yaml
interface:
  display_name: "Docs Helper"
  short_description: "Checks APIs before code changes"

policy:
  allow_implicit_invocation: false
```

UI 표현과 invocation policy는 여기에 두는 것이 맞습니다. 오래됐거나 문서화되지 않은 frontmatter 필드에 의존하지 마십시오.

## 안티패턴

| 안티패턴 | 해결책 |
|---|---|
| skills를 `/skill-name` slash command처럼 다루기 | `/skills` 또는 `$skill-name` mention으로 명시 호출을 문서화 |
| `user-invocable`, `allowed-tools`, `context: fork` 같은 문서화되지 않은 frontmatter 사용 | 현재 문서화된 `SKILL.md` + `agents/openai.yaml` 패턴 사용 |
| `skills = [...]`를 도메인 지식을 붙이는 주된 방식으로 간주 | description으로 trigger되게 하거나 `[[skills.config]]`로 가용성 관리 |
| 모든 지침을 `AGENTS.md`에 넣기 | 집중된 workflow를 skills로 분리 |
| 모든 것과 매칭되는 넓은 description 작성 | `description`을 정확한 trigger condition으로 작성 |
