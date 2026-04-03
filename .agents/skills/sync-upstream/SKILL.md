---
name: sync-upstream
description: main 브랜치를 upstream과 정렬하고 그 변경사항을 ko 번역 브랜치에 전파하는 절차입니다.
user-invocable: false
---

# Upstream 동기화

fork를 upstream 기준으로 갱신할 때 이 절차를 사용합니다.

## 브랜치 의도

- `main`은 영어 upstream 정렬 브랜치로 유지합니다
- `main`은 fast-forward 후 `origin/main`에도 push 해 fork의 기준 원문 브랜치를 최신 상태로 유지합니다
- `ko`에는 한국어 번역 작업만 둡니다

## 동기화 절차

1. 워킹 트리가 깨끗한지 확인합니다.
2. `upstream`을 fetch 합니다.
3. `origin/main..upstream/main` 범위의 커밋을 검토합니다.
4. 로컬 `main`을 `upstream/main`으로 fast-forward 합니다.
5. `main`을 `origin/main`에 push 합니다.
6. `main`을 `ko`에 병합합니다.
7. 충돌이 나면 upstream 영어 내용을 우선 수용하고, 해당 파일을 재번역 대상으로 표시합니다.
8. 영향받은 번역 대상 파일을 `reports/retranslation-needed.md`에 기록합니다.

## 필수 기록

동기화 후에는 다음을 수행합니다.

- `reports/retranslation-needed.md`를 갱신합니다
- 재번역할 파일의 `.originals/` 임시 스냅샷을 갱신합니다
- 이후 번역 작업은 `ko`에서만 계속합니다
- 역번역 검증이 끝나면 `.originals/`를 비웁니다
- 기준 diff는 `main..upstream/main` 또는 `origin/main..upstream/main` 중 현재 운영 상태에 맞는 범위를 사용하되, 둘이 어긋나지 않도록 `origin/main`을 최신으로 유지합니다

## 충돌 처리 원칙

- 하네스 관련 새 규칙은 가능하면 별도 파일로 분리해 유지합니다.
- `AGENTS.md` 같은 기존 진입점 파일은 최소 수정 상태를 유지합니다.
- 병합 충돌 시 번역본을 억지로 보존하지 말고 upstream 영어 내용을 우선 반영한 뒤 재번역합니다.
