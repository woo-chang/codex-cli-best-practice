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
