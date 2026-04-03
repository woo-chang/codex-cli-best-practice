---
name: translation-rules
description: Rules for translating repository prose from English to Korean without breaking Codex-specific identifiers, paths, or invocation syntax.
description: Codex 전용 식별자, 경로, 호출 문법을 깨뜨리지 않으면서 저장소 산문을 영어에서 한국어로 번역하는 규칙입니다.
user-invocable: false
---

# 번역 규칙

이 저장소에서 영어를 한국어로 번역할 때 이 규칙을 사용합니다.

## 번역하지 않음

다음 항목은 영어로 유지합니다.

- Frontmatter and config keys such as `name`, `description`, `model`, `allowed-tools`, `context`, `agent`
- TOML, JSON, YAML, and XML keys
- Tool names, command names, profile names, and CLI flags
- File names, directory names, file paths, branch names, and repository names
- Inline code and fenced code blocks
- URLs, badge URLs, image paths, and asset references
- Agent identifiers, skill identifiers, plugin identifiers, and MCP server names
- Literal values that are used as system-facing identifiers

## 번역함

다음 항목은 한국어로 번역합니다.

- Markdown headings
- Explanatory paragraphs
- List items that are prose rather than code
- Table cells containing human-facing descriptions
- Link text, while preserving the link target
- Image alt text when it is clearly user-facing prose

## 저장소 용어

다음 한국어 용어를 일관되게 사용합니다.

| English | Korean |
|---|---|
| best practice | 모범 사례 |
| agent | 에이전트 |
| subagent | 서브에이전트 |
| skill | 스킬 |
| workflow | 워크플로우 |
| orchestration | 오케스트레이션 |
| configuration | 구성 |
| settings | 설정 |
| validation | 검증 |
| back-translation | 역번역 |
| source of truth | 기준 원문 |

## 안전 규칙

어떤 문자열이 산문이면서 동시에 런타임 식별자일 가능성이 있다면, 문맥상 번역 의도가 명확하지 않은 한 영어로 유지합니다.
