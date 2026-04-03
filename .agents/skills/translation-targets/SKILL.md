---
name: translation-targets
description: 번역 대상 파일을 배치별로 식별하고 upstream 변경 후 재번역 대상을 추리는 규칙입니다.
user-invocable: false
---

# 번역 대상 식별 규칙

이 스킬은 이 저장소에서 어떤 파일을 번역 대상으로 볼지, 그리고 upstream 변경 후 어떤 파일을 재번역해야 하는지 식별하는 규칙을 정의합니다.

## 기준

- 기본 기준 원문은 `main` 또는 `upstream/main`의 영어 문서입니다.
- 번역 작업은 `ko`에서만 수행합니다.
- 번역 대상은 마크다운 산문 파일로 제한합니다.

## 현재 번역 대상 배치

### 배치 A: 진입점 문서

- `AGENTS.md`
- `README.md`

### 배치 B: 모범 사례 문서

- `best-practice/codex-agents-md.md`
- `best-practice/codex-config.md`
- `best-practice/codex-hooks.md`
- `best-practice/codex-mcp.md`
- `best-practice/codex-skills.md`
- `best-practice/codex-subagents.md`

### 배치 C: 참고 문서

- `docs/SKILLS.md`

### 배치 D: 워크플로우 문서

- `orchestration-workflow/orchestration-workflow.md`

## 번역 대상 아님

다음은 번역 대상으로 취급하지 않습니다.

- `.agents/skills/weather-svg-creator/` 같은 실행용 스킬 자산
- `.codex/agents/*.toml` 같은 설정 및 실행 자산
- 이미지, SVG, 배지, 오디오, 바이너리 파일
- `examples/` 아래의 TOML, YAML 예시 구성 파일
- `translation-harness/`, `reports/` 아래의 운영 파일
- `.originals/` 아래의 임시 스냅샷 파일
  이 파일들은 번역 결과물이 아니라 하네스 운영 또는 임시 작업 자산입니다.

## upstream 변경 후 재번역 식별

1. `upstream/main`과 `origin/main` 또는 로컬 `main`의 차이를 확인합니다.
2. 변경 파일 목록을 구합니다.
3. 변경 파일 중 현재 번역 대상 배치에 포함된 파일만 추립니다.
4. 해당 파일을 `reports/retranslation-needed.md`에 기록합니다.
5. 재번역이 필요한 파일의 영어 원문을 `.originals/`에 임시 저장합니다.
6. 역번역 검증이 끝나면 `.originals/`를 정리합니다.

## 기록 규칙

- 번역 시작 전: 대상 배치와 파일 수를 `reports/translation-progress.md`에 반영합니다.
- upstream 동기화 후: 재번역 대상만 `reports/retranslation-needed.md`에 기록합니다.
- 역번역 검증 후: 결과를 `reports/back-translation-report.md`에 기록합니다.

## 안전 규칙

- 배치 목록에 없는 파일은 번역하지 않습니다.
- 번역 대상 확대가 필요하면 먼저 `translation-harness/translation-targets.md`를 갱신한 뒤 진행합니다.
