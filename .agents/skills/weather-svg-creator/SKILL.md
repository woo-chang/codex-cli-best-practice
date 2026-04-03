---
name: weather-svg-creator
description: Creates an SVG weather card showing the current temperature and writes it to orchestration-workflow/weather.svg and orchestration-workflow/output.md
argument-hint: "[temperature]"
---

# Weather SVG Creator Skill

이 스킬은 전달받은 온도 데이터를 바탕으로 SVG 날씨 카드를 생성합니다.

## 작업

지정된 도시의 온도를 표시하는 SVG 날씨 카드를 만들고 결과를 출력 파일에 작성합니다.

## 지침

호출 컨텍스트에서 온도 값, 단위(섭씨 또는 화씨), 도시 이름을 전달받습니다.

### 1. SVG 날씨 카드 생성

아래 구조를 기반으로 깔끔한 SVG 날씨 카드를 생성합니다.

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 200" width="400" height="200">
  <rect width="400" height="200" rx="12" fill="#1a1a2e"/>
  <text x="200" y="50" text-anchor="middle" fill="#e0e0e0" font-family="system-ui" font-size="16">[City Name]</text>
  <text x="200" y="110" text-anchor="middle" fill="white" font-family="system-ui" font-size="48" font-weight="bold">[value]°[C/F]</text>
  <text x="200" y="150" text-anchor="middle" fill="#888" font-family="system-ui" font-size="12">[Current date and time]</text>
  <text x="200" y="185" text-anchor="middle" fill="#555" font-family="system-ui" font-size="10">Weather data from Open-Meteo API</text>
</svg>
```

`[value]`, `[C/F]`, `[City Name]`을 입력으로 받은 실제 값으로 바꿉니다.

### 2. 출력 파일 작성

SVG 내용을 `orchestration-workflow/weather.svg`에 작성합니다.

또한 `orchestration-workflow/output.md`에 마크다운 요약을 작성합니다.

```markdown
# Weather Report

![Weather Card](weather.svg)

**Location**: [City Name]
**Temperature**: [value]°[C/F]
**Fetched At**: [Current date and time in ISO 8601 format]

> Weather data provided by [Open-Meteo API](https://open-meteo.com/)
```

- `orchestration-workflow/` 디렉토리가 없으면 생성합니다
- 기존 내용이 있으면 덮어씁니다

## 예상 입력

호출한 에이전트가 제공하는 온도 값, 단위, 도시:
```
Temperature: [X]°[C/F]
City: [City Name]
Unit: [Celsius/Fahrenheit]
```

## 예상 출력

다음 두 파일이 작성됩니다.
- `orchestration-workflow/weather.svg` — SVG 날씨 카드
- `orchestration-workflow/output.md` — SVG를 포함하는 마크다운 보고서

## 참고 사항

- 제공받은 온도 값과 단위를 그대로 사용합니다. 데이터를 다시 가져오거나 수정하지 않습니다
- SVG 디자인은 단순하고 깔끔하게 유지합니다
- 보고서를 추적할 수 있도록 타임스탬프를 포함합니다
- 출력 파일은 `orchestration-workflow/` 디렉토리에 생성합니다
