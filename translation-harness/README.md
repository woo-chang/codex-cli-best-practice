# 번역 하네스

이 저장소는 Codex용 한국어 번역 하네스를 사용합니다. 목적은 번역 작업 규칙, 검증 기준, 진행 상태를 저장소 안에서 분리해 관리하고, 번역본 문서와 운영용 하네스 문서를 섞지 않는 것입니다.

이 디렉토리는 upstream 원문 문서의 번역본이 아닙니다. 번역 작업을 운영하기 위한 한국어 전용 하네스 문서입니다.

## 브랜치 모델

- `main`: upstream와 동기화되는 영어 기준 브랜치
- `ko`: 한국어 번역 작업 브랜치

번역 관련 변경은 모두 `ko`에서만 수행합니다.

## 기준 원문

- upstream 영어 문서가 기준 원문입니다.
- 역번역 비교용 원문 스냅샷은 `.originals/`에 보관합니다.
- 진행 상황과 검토 결과는 `reports/`에 기록합니다.

## 디렉토리 역할

- `AGENTS.md`: 짧은 진입점과 탐색 안내
- `.agents/skills/translation-rules/SKILL.md`: 번역 경계와 용어 규칙
- `.agents/skills/translation-targets/SKILL.md`: 번역 대상 배치와 재번역 식별 규칙
- `.agents/skills/validation-rules/SKILL.md`: 구조 검증 체크리스트
- `.agents/skills/sync-upstream/SKILL.md`: `main`과 `ko` 동기화 절차
- `.agents/skills/commit-rules/SKILL.md`: 한글 커밋 메시지와 커밋 전 검증 규칙
- `.originals/`: 원문 스냅샷
- `reports/translation-progress.md`: 배치 진행 현황
- `reports/back-translation-report.md`: 역번역 의미 검증 결과
- `reports/retranslation-needed.md`: upstream 동기화 후 재번역 필요 목록
- `translation-harness/translation-targets.md`: 배치별 번역 대상 목록
- `translation-harness/commit-policy.md`: 커밋 정책 요약

## 운영 원칙

1. 산문만 번역하고 식별자는 번역하지 않습니다.
2. 파일 경로, 명령어, 설정 키, TOML/JSON/YAML 키, 코드 펜스, 인라인 코드, URL, 이미지 경로는 영어로 유지합니다.
3. 번역 때문에 디렉토리 구조나 호출 경로를 바꾸지 않습니다.
4. 배치 단위로 진행 상황을 남겨 중단된 작업도 저장소만 보면 복구 가능해야 합니다.
5. 번역 완료 후 구조 검증과 역번역 검증을 거쳐야 배치를 완료로 표시할 수 있습니다.
6. 기존 진입점 파일은 최소 수정 원칙을 따릅니다. 특히 `AGENTS.md`에는 요약 포인터만 두고, 상세 규칙은 이 디렉토리와 스킬 파일로 분리합니다.
7. upstream 동기화 중 충돌이 발생하면 로컬 번역보다 upstream 영어 원문을 우선 수용하고, 해당 파일을 재번역 대상으로 돌립니다.
8. 커밋은 `영어 접두사 + 한글 요약` 형식을 사용하고, upstream 동기화 커밋과 번역 커밋을 분리합니다.

## 권장 루프

1. `main`을 `upstream` 기준으로 동기화합니다.
2. `main`을 `ko`에 병합합니다.
3. `translation-targets` 규칙으로 변경된 번역 대상 파일을 식별해 `reports/retranslation-needed.md`에 기록합니다.
4. 원문 스냅샷을 `.originals/`에 저장합니다.
5. `ko`에서 선택한 배치를 번역합니다.
6. `validation-rules` 기준으로 구조 검증을 수행합니다.
7. 역번역 검증 결과를 `reports/back-translation-report.md`에 기록합니다.
8. `reports/translation-progress.md`를 갱신합니다.

## 현재 번역 범위

현재 배치 목록과 파일별 범위는 `translation-harness/translation-targets.md`를 기준으로 관리합니다.

## 충돌 최소화 원칙

번역 하네스는 upstream 추적과 충돌하지 않도록 다음 원칙을 따릅니다.

- 기존 upstream 파일 수정은 최소화합니다.
- 새 운영 규칙은 가능하면 `translation-harness/`, `.agents/skills/`, `reports/`, `.originals/` 아래에 둡니다.
- `AGENTS.md`는 진입점 역할만 하며 상세 운영 규칙을 직접 담지 않습니다.
- upstream 변경과 번역 변경이 충돌하면 upstream 영어 내용을 먼저 반영하고, 이후 `ko`에서 다시 번역합니다.
