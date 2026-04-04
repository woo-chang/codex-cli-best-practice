---
name: claude-parity
description: claude-code-best-practice의 번역 하네스와 현재 Codex 번역 하네스를 비교해 핵심 운영 규칙의 누락과 드리프트를 점검합니다.
user-invocable: false
---

# Claude 하네스 정합성 점검

이 스킬은 `claude-code-best-practice`의 하네스 규칙과 현재 Codex 하네스 규칙을 비교합니다.

## 목적

- 번역 하네스의 핵심 운영 원칙이 Codex 쪽에 누락되지 않도록 유지합니다.
- 제품 차이에서 오는 정상적인 차이와 실제 드리프트를 구분합니다.

## 비교 범위

- 브랜치 운영 규칙
- 번역 규칙
- 검증 규칙
- 커밋 규칙
- 상태 기록 규칙

## 제외 범위

- Claude 전용 문법
- Codex 전용 문법
- 제품 기능 차이로 인한 구조 차이

## 작업 절차

1. `translation-harness/claude-parity.md`의 대응 매핑을 기준으로 비교 대상을 정합니다.
2. Claude 저장소와 Codex 저장소의 대응 파일을 읽습니다.
3. 항목별로 `일치`, `의도적 차이`, `누락`, `드리프트`로 분류합니다.
4. `누락`, `드리프트`가 있으면 Codex 하네스 파일을 먼저 수정합니다.
5. 결과를 `reports/claude-parity-report.md`에 기록합니다.

## 출력 규칙

- 제품 차이에서 오는 차이는 억지로 제거하지 않습니다.
- 핵심 운영 규칙의 누락만 우선 수정합니다.
- 비교 결과는 번역본 문서가 아니라 하네스 문서와 규칙 파일에 반영합니다.
