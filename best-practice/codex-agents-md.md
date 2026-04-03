# 모범 사례: AGENTS.md

`AGENTS.md` 파일은 Codex CLI의 기본 지침 파일입니다. 프로젝트 수준의 컨텍스트와 행동 지시를 제공합니다.

## 파일 이름과 fallback

Codex CLI는 다음 순서로 지침 파일을 찾습니다.
1. `AGENTS.md` (preferred)
2. `CODEX.md` (alias)

새 프로젝트에서는 `AGENTS.md`를 사용합니다.

## 길이: 150줄 이하 유지

가장 영향이 큰 모범 사례는 **AGENTS.md를 간결하게 유지하는 것**입니다.

- 약 150줄을 넘어가면 무시되거나 잘릴 가능성이 커집니다
- 긴 파일은 중요한 지침을 잡음 속에 묻히게 합니다
- 모델은 지침이 집중되어 있을 때 더 잘 처리합니다

**150줄을 초과한다면** 상세 내용은 다음으로 분리합니다.
- Skill files (`skills/<name>/SKILL.md`) for specialized procedures
- Separate docs files referenced by path
- Agent-preloaded skills for domain-specific knowledge

## 계층 구조와 override 메커니즘

AGENTS.md 파일은 디렉토리 계층을 따릅니다.

```
/repo/AGENTS.md              # Root-level instructions
/repo/packages/api/AGENTS.md # Package-specific overrides
/repo/packages/web/AGENTS.md # Package-specific overrides
```

**로드 동작**:
- Codex는 작업 디렉토리에서 위로 올라가며 찾은 각 AGENTS.md를 로드합니다
- 더 구체적인 파일, 즉 더 깊은 위치의 파일이 일반적인 상위 파일보다 우선합니다
- 모든 파일은 하나의 컨텍스트로 이어붙여지며, 더 깊은 파일이 뒤쪽에 배치됩니다

## 권장 구조

```markdown
# AGENTS.md

## Repository Overview
이 프로젝트가 무엇이고 무엇을 하는지 설명하는 한 단락.

## Key Components
주요 서브시스템을 파일 경로와 함께 짧게 설명.

## Critical Patterns
모델이 반드시 따라야 하는 비자명한 규칙.

## Workflow Rules
빌드, 테스트, 린트 명령과 배포 패턴.

## Do NOT
피해야 할 안티패턴을 명시.
```

## 안티패턴

| 안티패턴 | 실패 이유 | 해결책 |
|---|---|---|
| API 문서를 통째로 넣기 | 줄 수 제한을 넘고 집중도를 떨어뜨림 | 문서 링크를 두고 skills 사용 |
| 뻔한 규칙 반복 | 모델이 이미 아는 내용에 줄을 낭비함 | 비자명한 내용만 문서화 |
| 긴 코드 예시 | 줄 예산을 빠르게 소모함 | 예시는 10줄 이하 유지 |
| 모호한 지시("조심해라") | 실행 가능하지 않음 | `"Always run \`npm test\` before committing"`처럼 구체화 |
| 상충하는 규칙 | 모델이 임의로 하나를 선택함 | 충돌 여부를 점검 |

## 모노레포 전략

모노레포에서는 계층형 접근을 사용합니다.

1. **Root `AGENTS.md`**: 공통 규칙. 예: git workflow, CI 명령, 코딩 표준
2. **Package `AGENTS.md`**: 패키지별 빌드 명령, 아키텍처 결정, 테스트 패턴
3. **Skills**: 복잡한 절차(배포, 마이그레이션)는 어떤 AGENTS.md에서도 참조 가능한 skills로 분리

이렇게 하면 각 파일은 짧게 유지하면서도 전체 범위를 놓치지 않을 수 있습니다.

## 잘림 동작

AGENTS.md가 모델의 처리 용량을 넘으면:
- 파일 끝부분 내용이 가장 잘릴 가능성이 큽니다
- 가장 중요한 지침을 맨 위에 둡니다
- 세부가 일부 사라져도 구조를 훑을 수 있도록 섹션 헤더를 명확히 둡니다
- 서로 다른 섹션의 지침을 반복하게 해 보며 실제 반영 여부를 점검합니다
