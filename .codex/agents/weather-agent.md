# Weather Agent Notes

The active weather agent configuration for this repository lives in
`weather-agent.toml` and is registered from `.codex/config.toml` under
`[agents.weather-agent]`.

This Markdown file remains as a human-readable companion for the example
workflow:

- The agent fetches current temperature from Open-Meteo API for Dubai
- It uses the caller-provided unit preference, defaulting to Celsius
- It invokes the `/weather-svg-creator` skill to create the SVG card
- Codex CLI subagents do not support mid-turn user interaction or preloaded skills
