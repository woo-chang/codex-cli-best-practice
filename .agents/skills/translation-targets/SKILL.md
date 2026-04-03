---
name: translation-targets
description: 번역 대상 파일을 규칙 기반으로 식별하고 upstream 변경 후 재번역 대상을 추리는 규칙입니다.
user-invocable: false
---

# 번역 대상 식별 규칙

이 스킬은 이 저장소에서 어떤 파일을 번역 대상으로 볼지, 그리고 upstream 변경 후 어떤 파일을 재번역해야 하는지 규칙 기반으로 식별합니다.

## 기준

- 기본 기준 원문은 `main` 또는 `upstream/main`의 영어 문서입니다.
- 번역 작업은 `ko`에서만 수행합니다.
- 번역 대상은 마크다운 산문 파일로 제한합니다.

## 포함 규칙

다음은 기본 번역 후보입니다.

- `AGENTS.md`, `README.md`
- `best-practice/**/*.md`, `docs/**/*.md`, `orchestration-workflow/**/*.md`
- 사람이 읽는 설명 비중이 큰 문서형 자산

## 번역 대상 아님

다음은 번역 대상으로 취급하지 않습니다.

- `.agents/skills/**/SKILL.md` 같은 실행용 스킬 자산
- `.codex/agents/*.toml` 같은 설정 및 실행 자산
- 이미지, SVG, 배지, 오디오, 바이너리 파일
- `examples/` 아래의 TOML, YAML 예시 구성 파일
- `translation-harness/`, `reports/` 아래의 운영 파일
- `.originals/` 아래의 임시 스냅샷 파일
  이 파일들은 번역 결과물이 아니라 하네스 운영 또는 임시 작업 자산입니다.

## 조건부 후보

다음은 자동 포함하지 않고 검토 후 결정합니다.

- `.agents/skills/**/SKILL.md`
- `.claude/**` 아래 문서
- 새 디렉토리 아래의 마크다운 문서

설명 문서 성격이 강하면 번역 후보로 승격할 수 있습니다.

## upstream 변경 후 재번역 식별

1. `upstream/main`과 `origin/main` 또는 로컬 `main`의 차이를 확인합니다.
2. 변경 파일 목록을 구합니다.
3. 각 파일에 포함/제외 규칙을 적용해 번역 후보만 추립니다.
4. 해당 파일을 `reports/retranslation-needed.md`에 기록합니다.
5. 재번역이 필요한 파일의 영어 원문을 `.originals/`에 임시 저장합니다.
6. 역번역 검증이 끝나면 `.originals/`를 정리합니다.

## 기록 규칙

- 번역 시작 전: 이번에 처리할 파일 목록을 `reports/translation-progress.md`에 반영합니다.
- upstream 동기화 후: 재번역 대상만 `reports/retranslation-needed.md`에 기록합니다.
- 역번역 검증 후: 결과를 `reports/back-translation-report.md`에 기록합니다.

## 안전 규칙

- 규칙으로 판정되지 않은 파일은 바로 번역하지 않고 먼저 검토 필요 대상으로 남깁니다.
- 새 구조가 들어오면 먼저 `translation-harness/translation-targets.md`의 규칙을 갱신한 뒤 진행합니다.
