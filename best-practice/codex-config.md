# 모범 사례: Config

Codex CLI의 TOML 기반 설정 시스템을 다루는 종합 가이드입니다. 설정 우선순위, 프로필, 샌드박스 모드, 승인 정책을 포함합니다.

<table width="100%">
<tr>
<td><a href="../">← Codex CLI 모범 사례로 돌아가기</a></td>
<td align="right"><img src="../!/codex-jumping.svg" alt="Codex" width="60" /></td>
</tr>
</table>

## 설정 우선순위

설정은 다음 우선순위로 적용됩니다. 위에서 아래 순입니다.

| 우선순위 | 위치 | 범위 | 목적 |
|----------|----------|-------|---------|
| 1 | CLI flags / `-c key=value` | Invocation | 단일 실행에만 적용되는 일회성 재정의 |
| 2 | `.codex/config.toml` | Project | 팀 공유 기본값, profiles, MCP, agents |
| 3 | `~/.codex/config.toml` | Global | 여러 프로젝트에 걸친 개인 기본값 |

## 핵심 설정

```toml
# .codex/config.toml
model = "o4-mini"
sandbox_mode = "workspace-write"
approval_policy = "on-request"
```

## 프로필

`[profiles.<name>]` 아래에 이름 있는 프리셋을 두고 `codex --profile <name>`로 전환합니다.

```toml
[profiles.conservative]
sandbox_mode = "read-only"
approval_policy = "untrusted"

[profiles.development]
sandbox_mode = "workspace-write"
approval_policy = "on-request"

[profiles.ci]
model = "o4-mini"
sandbox_mode = "read-only"
approval_policy = "never"

[profiles.trusted]
sandbox_mode = "danger-full-access"
approval_policy = "never"
```

기본 프로필은 최상위에 `profile = "conservative"`로 설정합니다.

## 샌드박스 모드

| 모드 | 파일 접근 | 네트워크 | 적합한 용도 |
|---|---|---|---|
| `read-only` | 프로젝트 읽기 전용 접근 | 차단 | 리뷰, 감사, CI 분석 |
| `workspace-write` | 워크스페이스 내부 읽기/쓰기 | 차단 | 로컬 개발, 문서/코드 수정 |
| `danger-full-access` | 제한 없는 파일시스템 접근 | 허용 | 네트워크나 설치가 필요한 완전 신뢰 자동화 |

## 승인 정책

| 정책 | 동작 | 적합한 용도 |
|---|---|---|
| `untrusted` | 신뢰 가능한 읽기 계열 명령만 자동 실행하고 나머지는 모두 묻습니다 | 새 repo, 감사, 리뷰 |
| `on-request` | 언제 물어볼지 모델이 결정합니다 | 일상적인 개발 |
| `never` | 절대 묻지 않으며 실패는 그대로 모델에 반환됩니다 | 비대화형 실행, 엄격히 통제된 자동화 |

## Override

개인용 지시 재정의는 `AGENTS.override.md`를 사용합니다. `AGENTS.md`보다 먼저 로드되며 git에는 커밋하지 않습니다.

## MCP 서버

공유 integration은 같은 설정 파일에서 선언합니다.

```toml
[mcp_servers.github]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-github"]
env = { GITHUB_TOKEN = "$GITHUB_TOKEN" }
```

## 에이전트

에이전트는 `[agents.<name>]` 아래에 등록하고, 필요하면 전용 역할 파일을 가리키게 할 수 있습니다.

```toml
[agents.backend-dev]
description = "Handles backend implementation tasks"
config_file = "agents/backend-dev.toml"
```

## 일회성 재정의

```bash
codex -c model=\"o3\" -c approval_policy=\"never\" exec "summarize this diff"
```

## 안티패턴

- 일반적인 편집 작업에 `danger-full-access`를 사용하는 것
- `never`를 범용 로컬 기본값처럼 사용하는 것
- 실제 격리 경계 없이 `danger-full-access`와 `never`를 함께 사용하는 것
- `$ENV_VAR` 확장 대신 비밀값을 하드코딩하는 것
- 집중된 프로필을 만들지 않고 관련 없는 관심사를 하나의 프로필에 섞는 것
