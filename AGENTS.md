# AGENTS.md

이 파일은 Codex CLI가 이 저장소에서 작업할 때 따라야 할 지침을 제공합니다.

## 저장소 개요

이 저장소는 OpenAI Codex CLI 구성을 위한 모범 사례 저장소입니다. 스킬, 에이전트, 오케스트레이션 워크플로우, 프로젝트 범위 설정 패턴을 시연하며, 애플리케이션 코드베이스라기보다 참조 구현체 역할을 합니다.

## 주요 구성 요소

### 날씨 시스템 (예제 워크플로우)

**Agent → Skill** 오케스트레이션 패턴을 보여주는 예제입니다.
- `weather-agent` (`.codex/agents/weather-agent.toml`): 진입점. Open-Meteo API에서 기온을 가져오고 렌더러 스킬을 호출합니다
- `weather-svg-creator` skill (`.agents/skills/weather-svg-creator/SKILL.md`): 에이전트가 호출하며 SVG 날씨 카드를 생성합니다

오케스트레이션 흐름은 다음과 같습니다. 에이전트가 Open-Meteo에서 기온을 가져오고, 호출자가 지정한 단위를 사용하며 기본값은 Celsius입니다. 이후 `/weather-svg-creator`를 호출해 SVG 출력을 렌더링합니다. 전체 흐름도는 `orchestration-workflow/orchestration-workflow.md`를 참고하세요.

### 스킬 정의 구조

스킬은 `.agents/skills/<name>/SKILL.md`에 위치하며 YAML 프론트매터를 사용합니다.
- `name`: 표시 이름. 기본값은 디렉토리 이름입니다
- `description`: 스킬을 언제 호출할지 설명하며 자동 발견에 사용됩니다

각 스킬 디렉토리에는 다음이 추가로 포함될 수 있습니다.
- `scripts/`: 스킬이 호출하는 실행 코드
- `references/`: 스킬이 참조하는 문서
- `assets/`: 템플릿, 리소스, 정적 파일
- `agents/openai.yaml`: 선택적 외형 및 의존성 메타데이터

Codex는 progressive disclosure 방식으로 스킬을 발견합니다. 먼저 메타데이터만 읽고, 스킬이 실제로 활성화될 때만 전체 지침을 불러옵니다.

### 설정 시스템

Codex CLI는 두 수준의 TOML 기반 설정을 사용합니다.
- **User-level**: `~/.codex/config.toml` — 모든 프로젝트에 적용되는 개인 기본값
- **Project-level**: `.codex/config.toml` — 팀이 공유하는 프로젝트 범위 재정의. 프로젝트가 trusted 상태일 때만 로드됩니다

### 설정 우선순위

1. `.codex/config.toml`: 팀이 공유하는 프로젝트 설정(버전 관리에 포함)
2. `~/.codex/config.toml`: 개인 사용자 수준 설정
3. CLI flags (`--model`, `--ask-for-approval`, `--sandbox`): 두 설정 파일을 모두 덮어씀
4. `--config key=value`: 커맨드라인에서 한 번만 적용하는 재정의

### 에이전트와 스킬

스킬은 다음 우선순위에 따라 여러 범위에서 발견됩니다.
1. `$CWD/.agents/skills` — 현재 작업 디렉토리, 가장 구체적
2. `$CWD/../.agents/skills` — 부모 디렉토리를 따라 repo root까지
3. `$REPO_ROOT/.agents/skills` — 저장소 루트
4. `$HOME/.agents/skills` — 사용자 수준 개인 스킬
5. `/etc/codex/skills` — 시스템/관리자 수준 공유 스킬

에이전트는 `.codex/config.toml`의 `[agents.<name>]` 아래에 등록하며, 필요하면 `.codex/agents/*.toml`의 전용 역할 파일을 가리킬 수 있습니다.

## AGENTS.md 탐색

Codex는 Git root에서 현재 작업 디렉토리까지 내려오며 각 디렉토리에서 `AGENTS.override.md`와 그다음 `AGENTS.md`를 읽습니다. 현재 디렉토리에 가까운 파일일수록 결합된 프롬프트에서 더 뒤에 들어가며 우선순위를 가집니다. 결합된 전체 크기는 기본적으로 32 KiB(`project_doc_max_bytes`)로 제한됩니다.

## 프로필

`config.toml`의 `[profiles.<name>]` 아래에 이름 있는 프로필을 정의하면 설정을 빠르게 전환할 수 있습니다.

```bash
codex --profile conservative   # read-only, asks before every action
codex --profile development    # workspace-write sandbox, on-request approval
codex --profile trusted        # no approval prompts, workspace-write sandbox
codex --profile ci             # headless CI/CD mode
codex --profile review         # read-only code review mode
```

기본 프로필은 `config.toml` 최상위에 `profile = "conservative"`로 설정합니다. 예시 프로필 구성은 `examples/profiles/`에 있습니다.

## 워크플로우 모범 사례

이 저장소 운영 경험상 다음을 권장합니다.

- AGENTS.md는 신뢰성 있는 준수를 위해 150줄 이하로 유지합니다
- 자동 발견을 위해 `name`과 `description` 프론트매터가 명확한 스킬을 사용합니다
- 스킬은 기능 도메인 기준으로 구성합니다. 예: `weather-svg-creator`
- 안전 수준 전환에는 프로필을 사용합니다. 예: 검토용 `conservative`, 개발용 `trusted`
- 팀에 영향을 주지 않는 개인 선호는 `AGENTS.override.md`를 사용합니다
- 복잡한 작업은 거대한 지침 하나보다 조합 가능한 스킬들로 나눕니다

### 샌드박스 모드

- `read-only`: 파일 읽기만 가능하며 쓰기와 네트워크 접근은 불가
- `workspace-write`: 프로젝트 안에서 읽기/쓰기가 가능하며 네트워크는 샌드박스 처리됨
- `danger-full-access`: 제한 없는 접근. 주의해서 사용

### 승인 정책

- `untrusted`: 안전한 읽기 명령만 자동 승인되고 나머지는 모두 확인을 요청
- `on-request`: 모델이 언제 승인을 요청할지 결정. 권장 기본값
- `never`: 모든 명령이 자동 승인되며 실패는 모델에 바로 반환됨

## MCP 서버

MCP 서버는 `.codex/config.toml`의 `[mcp_servers.*]` 아래에 설정합니다. 현재는 다음이 구성돼 있습니다.
- `context7`: `@upstash/context7-mcp@latest`를 통한 문서 조회

## 문서

- `best-practice/codex-agents-md.md`: AGENTS.md 작성 가이드
- `best-practice/codex-config.md`: 설정, 프로필, MCP 구조
- `best-practice/codex-mcp.md`: MCP 서버 모범 사례
- `best-practice/codex-skills.md`: 스킬 모범 사례
- `best-practice/codex-subagents.md`: 서브에이전트 가이드
- `docs/SKILLS.md`: 스킬 시스템 레퍼런스
- `translation-harness/README.md`: 한국어 번역 워크플로우, 범위, 검증 루프
- `translation-harness/translation-targets.md`: 번역 대상 배치와 재번역 식별 규칙
- `translation-harness/commit-policy.md`: 한글 커밋 메시지와 커밋 전 검증 규칙
- `translation-harness/claude-parity.md`: Claude 하네스와의 정합성 점검 기준
- `orchestration-workflow/orchestration-workflow.md`: 날씨 시스템 흐름도
- `examples/`: 예시 프로필 구성과 CI/CD 설정

## 번역 하네스

이 저장소는 `main`과 `ko`를 분리한 한국어 번역 하네스를 사용합니다.

번역 작업을 할 때는:
- `main`은 upstream 정렬용 영어 기준 브랜치로 유지합니다
- `ko`에서만 번역 작업을 수행합니다
- 상세 규칙은 `translation-harness/README.md`와 `.agents/skills/*` 하네스 파일에서 확인합니다
- 번역 대상 식별은 `translation-harness/translation-targets.md`와 `.agents/skills/translation-targets/SKILL.md`를 따릅니다
- 커밋 규칙은 `translation-harness/commit-policy.md`와 `.agents/skills/commit-rules/SKILL.md`를 따릅니다
- Claude 저장소와의 교차 점검은 `translation-harness/claude-parity.md`와 `.agents/skills/claude-parity/SKILL.md`를 따릅니다

이 파일에는 번역 하네스의 세부 규칙을 복제하지 않습니다.
