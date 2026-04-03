# 모범 사례: Skills

Skills는 재사용 가능하고 조합 가능한 instruction package로 Codex CLI를 확장하는 기본 메커니즘입니다. 이들은 SKILL.md 공개 표준을 따릅니다.

## 두 가지 Skill 패턴

### 1. 사용자 호출형 Skills (Slash Commands)

사용자가 `/skill-name`으로 명시적으로 호출합니다.

```yaml
---
name: deploy
description: Deploy to target environment
argument-hint: "[env] [version]"
allowed-tools: Bash, Read
---
```

**적합한 경우**: 사용자가 필요할 때 직접 실행하는 워크플로우. 예: deploy, review, generate

### 2. 에이전트 사전 로드 Skills (배경 지식)

일반 skill로 정의한 뒤, 현재 에이전트 설정 모델을 통해 에이전트에 연결합니다.

```toml
# .codex/config.toml
[agents.api-developer]
description = "Builds and reviews HTTP APIs"
config_file = "agents/api-developer.toml"
```

```toml
# .codex/agents/api-developer.toml
model = "o4-mini"
skills = ["api-conventions", "error-handling"]

prompt = """
Work on backend APIs for this project.
"""
```

**적합한 경우**: 에이전트는 필요하지만 사용자가 직접 호출하지는 않는 도메인 지식

## 프론트매터 가이드

### 설명적인 `description` 필드 작성
description은 auto-discovery를 좌우합니다. 언제 이 skill을 써야 하는지 구체적으로 적어야 합니다.

```yaml
# Good: 구체적인 트리거 조건
description: Review TypeScript files for type safety issues and suggest fixes

# Bad: 모호해서 너무 많은 맥락에 걸림
description: Help with TypeScript
```

### `allowed-tools`는 좁게 제한
skill이 실제로 필요한 도구만 허용합니다.

```yaml
# Good: 최소 권한
allowed-tools: Read, Grep, Glob

# Bad: 지나치게 넓은 권한
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, WebFetch
```

### 적절한 모델 선택
단순 작업에는 더 저렴한 모델을 사용합니다.

```yaml
# 빠른 분석 작업
model: o4-mini

# 복잡한 추론 작업
model: o3
```

## Skill 구성

```
.agents/skills/
  deploy/
    SKILL.md          # Main skill instructions
  pr-review/
    SKILL.md
  code-standards/     # Agent-preloaded, not user-invocable
    SKILL.md
  security-audit/
    SKILL.md
```

### 이름 규칙
- 디렉토리 이름은 kebab-case 사용: `pr-review`, `prReview`는 지양
- 이름은 짧되 설명 가능해야 함
- `helper`, `utils` 같은 일반적인 이름은 피함

## 문자열 치환

전체 인자 문자열에는 `$ARGUMENTS`, 첫 번째 위치 인자에는 `$0`를 사용합니다.

```markdown
---
name: fix-issue
argument-hint: "[issue-number]"
---

# Fix Issue Skill

Fetch issue #$0 from GitHub and implement a fix:
1. Run `gh issue view $0` to read the issue
2. Analyze the reported problem
3. Implement and test the fix
```

## Skills 조합

### Commands를 통한 Skill 체인
하나의 command로 여러 skills를 오케스트레이션할 수 있습니다.

```markdown
<!-- commands/full-review.md -->
1. Invoke /security-audit on the changed files
2. Invoke /pr-review for code quality
3. Combine findings into a single report
```

### Agent + Skills
사전 로드된 skills를 가진 에이전트는 사용자 개입 없이 도메인 지식을 활용할 수 있습니다.

```toml
# .codex/config.toml
[agents.backend-dev]
description = "Handles backend development tasks"
config_file = "agents/backend-dev.toml"
```

```toml
# .codex/agents/backend-dev.toml
model = "o4-mini"
skills = ["api-conventions", "database-patterns", "error-handling"]
```

## 안티패턴

| 안티패턴 | 해결책 |
|---|---|
| 모든 지침을 AGENTS.md에 넣기 | 집중된 skills로 분리 |
| 100줄이 넘는 skills | 여러 skills로 나누거나 링크 문서 사용 |
| 모든 걸 다 하는 skills | 하나의 skill은 하나의 책임만 |
| 지식용 skills에 `user-invocable: false`를 빼먹기 | 에이전트 전용 skill에는 항상 설정 |
| 환경별로 달라지는 값을 하드코딩하기 | 동적 값에는 `$ARGUMENTS` 사용 |
