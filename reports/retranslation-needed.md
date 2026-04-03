# 재번역 필요 파일

이 파일은 `upstream/main` 변경 감지 이후, 번역 규칙에 따라 재작업이 필요한 파일만 기록합니다.

## 동기화 메타데이터

- 동기화 일시: 2026-04-04
- 기준 브랜치: `main..upstream/main`
- upstream 커밋: `0e868f3c310330a873b441c097ae891b311b15c9`

## 재번역 대상

| 파일 | 변경 유형 | 판정 메모 |
|---|---|---|
| `README.md` | `M` | 처리 완료. upstream 본문 변경 반영 |
| `best-practice/codex-skills.md` | `M` | 처리 완료. 최신 skill 설명 구조 반영 |
| `docs/SKILLS.md` | `M` | 처리 완료. 최신 skill 시스템 레퍼런스 반영 |
| `.codex/hooks/HOOKS-README.md` | `A` | 처리 완료. 조건부 포함 대상으로 승격 후 번역 |

## 제외된 변경 파일

- `!/tags/*.svg`: 비텍스트 자산이므로 제외
- `.codex/hooks.json`: 설정 자산이므로 제외
- `.codex/hooks/config/hooks-config.json`: 설정 자산이므로 제외
- `.codex/hooks/logs/.gitkeep`: 운영용 placeholder 파일이므로 제외
- `.codex/hooks/scripts/hooks.py`: 실행 스크립트이므로 제외
- `.codex/hooks/sounds/**/*`: 오디오 자산이므로 제외
