# 번역 대상 배치

이 문서는 번역 대상 식별 전용 하네스 문서입니다. 번역 범위를 배치 단위로 고정하고, upstream 변경 후 어떤 파일을 재번역할지 판단하는 기준을 제공합니다.

## 원칙

- 배치 목록에 없는 파일은 번역하지 않습니다.
- 번역 대상 확대는 먼저 이 문서를 수정한 뒤 진행합니다.
- upstream 변경 후에는 전체를 다시 번역하지 않고, 변경된 번역 대상 파일만 재번역합니다.

## 배치 목록

### 배치 A: 진입점 문서

| 파일 | 설명 |
|---|---|
| `AGENTS.md` | Codex 진입점 문서 |
| `README.md` | 저장소 개요 및 모범 사례 요약 |

### 배치 B: 모범 사례 문서

| 파일 | 설명 |
|---|---|
| `best-practice/codex-agents-md.md` | AGENTS.md 작성 가이드 |
| `best-practice/codex-config.md` | config, profile, MCP 구성 |
| `best-practice/codex-hooks.md` | hooks 운영 방식 |
| `best-practice/codex-mcp.md` | MCP 서버 사용 가이드 |
| `best-practice/codex-skills.md` | skills 모범 사례 |
| `best-practice/codex-subagents.md` | subagents 모범 사례 |

### 배치 C: 참고 문서

| 파일 | 설명 |
|---|---|
| `docs/SKILLS.md` | SKILL.md 형식과 discovery 규칙 |

### 배치 D: 워크플로우 문서

| 파일 | 설명 |
|---|---|
| `orchestration-workflow/orchestration-workflow.md` | weather 예제 워크플로우 설명 |

## 번역 대상에서 제외

다음은 기본적으로 번역하지 않습니다.

- `.agents/skills/` 아래 실행용 스킬 자산
- `.codex/agents/` 아래 TOML 에이전트 정의
- `examples/` 아래 예시 설정 파일
- 이미지, SVG, GIF, 오디오 등 비텍스트 자산
- `translation-harness/`, `reports/`, `.originals/` 아래 운영 자산

운영 자산은 한국어로 관리할 수 있지만, 그것은 번역 결과물이 아니라 하네스 유지보수 작업으로 취급합니다.

## upstream 변경 후 식별 절차

1. `git fetch upstream`
2. `origin/main..upstream/main` 또는 `main..upstream/main` 범위의 변경 파일 목록 확인
3. 배치 목록과 교집합인 파일만 추출
4. 해당 파일을 `reports/retranslation-needed.md`에 기록
5. `.originals/`에 기준 원문 스냅샷 저장
6. 해당 배치만 재번역

## 운영 메모

- 배치 A부터 순서대로 진행합니다.
- 번역 완료 후 `reports/translation-progress.md` 상태를 갱신합니다.
- 재번역은 전체 진행률과 별도로 `reports/retranslation-needed.md`에서 관리합니다.
