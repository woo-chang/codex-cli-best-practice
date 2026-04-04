# Claude 하네스 정합성 점검

이 문서는 `claude-code-best-practice`의 번역 하네스와 현재 Codex 번역 하네스가 핵심 운영 원칙에서 얼마나 일치하는지 점검하는 절차를 정의합니다.

이 문서의 목적은 두 저장소를 완전히 같은 구조로 강제하는 것이 아니라, 번역 운영에 필요한 핵심 규칙이 한쪽에만 누락되지 않도록 유지하는 것입니다.

## 기준 저장소

- 비교 기준 저장소: `~/Documents/Repository/claude-code-best-practice`
- 비교 대상 저장소: 현재 `codex-cli-best-practice`

## 점검 대상 영역

다음 영역은 Claude 저장소와 주기적으로 비교합니다.

1. 브랜치 운영 규칙
   `main`, `origin/main`, `ko`, upstream 동기화, 재번역 루프
2. 번역 규칙
   영어 유지 대상, 한글 번역 대상, 용어 통일, 구조 보존
3. 검증 규칙
   구조 검증, 역번역 검증, 실패 파일만 재검증하는 루프
4. 커밋 규칙
   메시지 형식, 브랜치 보호, staging 금지 대상, 검증 체크리스트
5. 상태 기록 규칙
   `reports/` 기록 범위와 유지 기준

## 비비교 영역

다음은 제품 차이로 인해 완전 일치를 요구하지 않습니다.

- Claude 전용 도구명, 훅 이름, frontmatter 키
- `.claude/` 전용 실행 구조
- Codex 전용 `.codex/`, `.agents/skills/` 구조
- 제품별 기능 차이에서 오는 문법 차이

## 점검 트리거

다음 상황에서는 Claude 하네스 정합성 점검을 수행합니다.

- Codex 하네스 규칙 파일을 수정한 뒤
- Claude 저장소의 하네스 규칙이 갱신된 것을 확인한 뒤
- upstream 유지보수 루프를 크게 바꾼 뒤
- 커밋 규칙, 번역 규칙, 검증 규칙을 변경한 뒤

## 점검 절차

1. Claude 저장소의 대응 규칙 파일을 읽습니다.
2. Codex 저장소의 대응 규칙 파일을 읽습니다.
3. 다음 중 하나로 분류합니다.
   - `일치`: 의미와 운영 의도가 같다
   - `의도적 차이`: 제품 차이 때문에 다르지만 정당하다
   - `누락`: Claude 쪽 핵심 운영 규칙이 Codex 쪽에 빠져 있다
   - `드리프트`: 한때 맞췄지만 현재는 의미가 어긋났다
4. `누락` 또는 `드리프트`가 있으면 먼저 하네스를 수정합니다.
5. 결과를 `reports/claude-parity-report.md`에 기록합니다.

## 최소 대응 매핑

| Claude 저장소 | Codex 저장소 |
|---|---|
| `.claude/skills/sync-upstream/SKILL.md` | `.agents/skills/sync-upstream/SKILL.md` |
| `.claude/skills/translation-rules/SKILL.md` | `.agents/skills/translation-rules/SKILL.md` |
| `.claude/skills/validation-rules/SKILL.md` | `.agents/skills/validation-rules/SKILL.md` |
| `.claude/skills/commit-rules/SKILL.md` | `.agents/skills/commit-rules/SKILL.md` |
| 하네스 운영 문서 묶음 | `translation-harness/README.md`, `translation-harness/*.md` |

## 판단 원칙

- 제품 차이로 설명 가능한 차이는 유지할 수 있습니다.
- 번역 운영의 핵심 원칙이 한쪽에만 있으면 Codex 하네스에 반영합니다.
- 하네스 비교 결과는 번역본 문서가 아니라 운영 문서와 규칙 파일에만 반영합니다.
- 정합성 점검은 번역 작업보다 앞선 안전망으로 취급합니다.
