# 역번역 검증 리포트

이 파일은 한국어 번역본을 다시 영어로 역번역해 기준 원문과 비교했을 때 의미가 달라지는 부분이 있는지 기록합니다.

## 엄격 모드 기준

- 섹션 단위 비교
- 표, 목록, 주의문 별도 확인
- 제약 표현과 기본값 보존 여부 확인
- 시스템 식별자, 경로, 명령어 보존 여부 확인
- 1차 검증은 배치 전체에 수행하고, 이후 재검증은 실패 파일만 대상으로 함

| 파일 | 결과 | 오류 | 경고 | 비교 섹션 수 | 상세 |
|---|---|---:|---:|---|
| `AGENTS.md` | PASS | 0 | 0 | 13 | 주요 개념, 설정 우선순위, 하네스 안내 의미와 제약 유지 |
| `README.md` | PASS | 0 | 0 | 8 | 개념 표, 워크플로우 설명, 팁 섹션의 핵심 의미와 제약 유지 |
| `best-practice/codex-agents-md.md` | PASS | 0 | 0 | 7 | 길이 제한, 계층 구조, 안티패턴 의미 유지 |
| `best-practice/codex-config.md` | PASS | 0 | 0 | 8 | 설정 우선순위, 샌드박스, 승인 정책의 제약 유지 |
| `best-practice/codex-hooks.md` | PASS | 0 | 0 | 16 | 이벤트 동작, 차단 의미, 훅 한계와 가드레일 설명 유지 |
| `best-practice/codex-mcp.md` | PASS | 0 | 0 | 6 | MCP 범위 제한, 보안 지침, 안티패턴 의미 유지 |
| `best-practice/codex-skills.md` | PASS | 0 | 0 | 10 | skill 패턴, frontmatter 지침, 안티패턴 의미 유지 |
| `best-practice/codex-subagents.md` | PASS | 0 | 0 | 18 | subagent 사용 조건, 승인 상속, CSV 배치 규칙 의미 유지 |
| `docs/SKILLS.md` | PASS | 0 | 0 | 12 | SKILL 형식, 필드 정의, 탐색 경로, 패턴 설명 의미 유지 |
| `orchestration-workflow/orchestration-workflow.md` | PASS | 0 | 0 | 11 | Agent → Skill 패턴, 제약 설명, 실행 흐름 의미 유지 |
| `.agents/skills/weather-svg-creator/SKILL.md` | PASS | 0 | 0 | 9 | 입력/출력 경로, 덮어쓰기 지침, 데이터 보존 제약 의미 유지 |
| `.claude/hooks/HOOKS-README.md` | PASS | 0 | 0 | 22 | hook 유형, 옵션 제약, matcher 표, 버그/우회 설명 의미 유지 |

## 배치 A 재검토

### `AGENTS.md`

- 비교 범위: 제목, 개요, 날씨 시스템 설명, 스킬 구조, 설정 우선순위, 탐색 규칙, 프로필, 모범 사례, 샌드박스, 승인 정책, MCP, 문서 목록, 번역 하네스
- 결과: PASS
- 판단 근거: 설정 우선순위, 탐색 순서, 기본값, 하네스 제약 문장이 모두 유지됨
- 특이사항: `progressive disclosure`, `trusted`, `conservative` 같은 시스템 용어는 의도적으로 영어 보존

### `README.md`

- 비교 범위: 배지 설명, 개념 표, 오케스트레이션 설명, 참고 노트, 팁과 트릭, 외부 저장소 안내
- 결과: PASS
- 판단 근거: 표 구조 유지, 링크/경로 보존, custom commands 미지원과 experimental 기능 비공개라는 제약이 유지됨
- 특이사항: 표 내부의 고유 용어와 제품명은 원문 식별자 보존을 우선함

## 배치 B 재검토

### 공통 판단

- 결과: PASS
- 판단 근거: 문서별 표 구조, 코드 블록, 경로, 식별자, 명령어를 유지했고 제약 문장과 기본값 설명이 약화되지 않았음
- 특이사항: `AGENTS.md`, `MCP`, `Hooks`, `Subagents`, `skills`, `workspace-write`, `danger-full-access` 같은 시스템 용어는 문맥상 영어를 유지함

### 파일별 메모

- `best-practice/codex-agents-md.md`: 150줄 제한, 잘림 동작, 모노레포 계층 전략 유지
- `best-practice/codex-config.md`: 우선순위 표, 샌드박스/승인 정책 표, override 규칙 유지
- `best-practice/codex-hooks.md`: experimental 상태, 이벤트별 입력/출력, `decision: "block"` 의미 유지
- `best-practice/codex-mcp.md`: agent-scoped MCP, `codex mcp-server`, 비밀값 처리 지침 유지
- `best-practice/codex-skills.md`: user-invocable/agent-preloaded 구분, `allowed-tools`, 모델 선택 기준 유지
- `best-practice/codex-subagents.md`: 사용 시점, 상속 규칙, custom agent 필드, CSV 배치 처리 규칙 유지

## 배치 C 재검토

### `docs/SKILLS.md`

- 비교 범위: SKILL.md 형식, 프론트매터 필드 표, 문자열 치환, built-in skills, 탐색 경로, skill 패턴, 예시 skill
- 결과: PASS
- 판단 근거: 필드 정의, 우선순위 규칙, `project > user > built-in` 탐색 순서, `user-invocable`, `context: fork` 같은 제약과 식별자가 유지됨
- 특이사항: frontmatter key, 모델명, skill 이름, 명령 예시는 원문 식별자 보존을 우선함

## 배치 D 재검토

### `orchestration-workflow/orchestration-workflow.md`

- 비교 범위: 시스템 개요, 출력 파일, 참고 노트, 컴포넌트 요약, 실행 흐름, 설계 원칙, Claude Code 비교 표
- 결과: PASS
- 판단 근거: Agent → Skill 패턴, custom commands 미지원, 사용자 선호를 프롬프트에서 직접 지정해야 한다는 제약, `developer_instructions` 인라인 구조가 모두 유지됨
- 특이사항: `Agent`, `Skill`, `developer_instructions`, `Command`, `AskUserQuestion` 같은 시스템 식별자는 문맥상 영어 보존

## 조건부 후보 재검토

### `.agents/skills/weather-svg-creator/SKILL.md`

- 비교 범위: 개요, 작업 정의, 입력 설명, SVG 생성 지시, 출력 파일 작성 규칙, 예상 입력/출력, 주의 사항
- 결과: PASS
- 판단 근거: `orchestration-workflow/` 경로, 덮어쓰기 지침, 입력 데이터 재사용 금지, 타임스탬프 포함 요구가 모두 유지됨
- 특이사항: frontmatter key, `name`, `argument-hint`, 코드 블록, 파일 경로는 원문 식별자 보존을 우선함

### `.claude/hooks/HOOKS-README.md`

- 비교 범위: 공식 hook 개요 표, 비공식 항목, 사전 요구 사항, 설정 방법, agent frontmatter hooks, 옵션 설명, hook 유형, 환경 변수, matcher 표, 알려진 이슈, decision control 패턴
- 결과: PASS
- 판단 근거: hook 이름, matcher 값, 환경 변수, 경로, JSON 예시, deprecated 제약, 지원/미지원 범위가 모두 유지됨
- 특이사항: hook 이름, 설정 키, 경로, 환경 변수, JSON 필드, 제품명은 원문 식별자 보존을 우선함
