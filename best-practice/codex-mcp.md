# 모범 사례: MCP (Model Context Protocol)

Codex CLI는 `.codex/config.toml`의 `[mcp_servers.<name>]`를 사용해 MCP integration을 구성합니다. 또한 `codex mcp-server`로 직접 MCP 서버로 실행할 수도 있습니다.

## MCP 서버 설정

```toml
[mcp_servers.filesystem]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-filesystem", "."]

[mcp_servers.github]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-github"]
env = { GITHUB_TOKEN = "$GITHUB_TOKEN" }
```

## 에이전트 범위 MCP 서버

특정 에이전트에만 서버를 붙여 MCP 접근 범위를 좁게 유지합니다.

```toml
[agents.data-analyst]
description = "Works with repository and database context"
config_file = "agents/data-analyst.toml"
```

```toml
# .codex/agents/data-analyst.toml
model = "o4-mini"
mcp_servers = ["filesystem", "github"]
```

## MCP 서버로서의 Codex

```bash
codex mcp-server
```

소비자 측 예시:

```json
{
  "mcpServers": {
    "codex": {
      "command": "codex",
      "args": ["mcp-server"]
    }
  }
}
```

## 보안 지침

1. 비밀값은 `$ENV_VAR` 참조를 사용합니다
2. 모든 서버를 전역으로 열지 말고 에이전트별로 MCP 서버를 제한합니다
3. 서버에 네트워크가 필요 없다면 `workspace-write` 또는 `read-only`를 우선합니다
4. MCP 워크플로우가 실제로 네트워크 접근을 필요로 할 때만 `danger-full-access`로 전환합니다

## 안티패턴

- 예전 Codex 릴리스의 폐기된 MCP 테이블 이름을 계속 문서화하는 것
- config에 토큰을 하드코딩하는 것
- 모든 에이전트에 동일한 MCP 접근 범위를 주는 것
- `codex mcp-server` 대신 폐기된 단일 플래그 문법을 쓰는 것
