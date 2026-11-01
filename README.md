# SpeakPen MCP

[English](README.md) | [简体中文](README.zh-CN.md)

**Your spoken ideas, readable by your AI.** SpeakPen turns what you say into your phone or
browser into titled, summarized notes. This MCP server lets ChatGPT, Claude, Claude Code,
Codex, Cursor and any other MCP client search and read those notes — so "what did I say
about pricing last week?" just works.

- Endpoint: `https://speakpen.app/mcp`
- Transport: Streamable HTTP (stateless — POST only, no sessions)
- Access: **read-only**. Assistants can search and read your completed notes. They can't
  create, change or delete anything, and they never receive your audio.
- Registry: [`io.github.Qumge/speakpen-mcp`](https://registry.modelcontextprotocol.io/v0/servers?search=speakpen)

This is a **hosted** server: there is nothing to install or run locally. This repo holds
its documentation and registry metadata; the server itself runs at speakpen.app.

## Can I use it without a SpeakPen account?

You can read and reuse this repository without an account. **The hosted MCP endpoint
requires a SpeakPen account and OAuth authorization or a personal API token**, including
for initialization and `tools/list`. Signing into the SpeakPen website alone does not
authorize MCP calls; the client must send its bearer token.

| What you want to do | Current requirement |
|---|---|
| Read or reuse the MIT-licensed docs and metadata | No SpeakPen account |
| Connect to the hosted MCP endpoint | Account + OAuth or API token |
| Search and read useful personal content | Completed notes in that account |
| Run an independent or local MCP server from this repository | Not available; server implementation is not included |
| Try guest or bundled demo notes | Not implemented |

A paid SpeakPen subscription is not required just to connect this read-only integration.
An empty account can connect, but has no notes to return. Recording and other service
features remain subject to your plan's limits; your AI client may have separate access
requirements and costs.

[Start with a free SpeakPen account](https://speakpen.app/?utm_source=github-speakpen-mcp&utm_medium=readme)
→ record an idea in the app or at https://speakpen.app/app → wait for processing to finish
→ authorize the connector → ask about that note. There is no local executable or
transcription engine to install from this repository.

## Connect

Step-by-step setup for each client (also readable by agents):
[SpeakPen connection guide](https://speakpen.app/connect?utm_source=github-speakpen-mcp&utm_medium=readme)

**ChatGPT / Claude.ai / Claude Desktop** — add a custom connector with the URL
`https://speakpen.app/mcp`. You'll be sent to SpeakPen to sign in and approve read-only
access. Approved apps are listed under **Settings → Connections → AI assistants**, where you can
disconnect them at any time.

**Claude Code** — the same URL works with OAuth:

```bash
claude mcp add --transport http speakpen https://speakpen.app/mcp
```

or with an API token (create one at https://speakpen.app/app → Settings → Connections → Developers):

```bash
claude mcp add --transport http speakpen https://speakpen.app/mcp \
  --header "Authorization: Bearer YOUR_TOKEN"
```

**Cursor** — `~/.cursor/mcp.json`

```json
{
  "mcpServers": {
    "speakpen": {
      "url": "https://speakpen.app/mcp",
      "headers": { "Authorization": "Bearer YOUR_TOKEN" }
    }
  }
}
```

**VS Code** — `.vscode/mcp.json`

```json
{
  "servers": {
    "speakpen": {
      "type": "http",
      "url": "https://speakpen.app/mcp",
      "headers": { "Authorization": "Bearer YOUR_TOKEN" }
    }
  }
}
```

**Codex** — `~/.codex/config.toml`

```toml
[mcp_servers.speakpen]
url = "https://speakpen.app/mcp"
bearer_token_env_var = "SPEAKPEN_TOKEN"
```

Keep real tokens out of shared configuration files, repositories and chat history. Use
your client's secret or environment-variable support where available. Revocation and
account authorization still apply when using an API token.

## Tools

Every tool returns `structuredContent` (JSON) alongside the same JSON as text in
`content`. **Build against `structuredContent` and the tool names** — those are the
contract. Only completed notes are visible; a note that is still transcribing, or that
belongs to someone else, is reported as "Note not found".

| Tool | What it does |
|---|---|
| `search` | Search your notes by keywords; up to 10 results with id, title, url, date and a snippet |
| `fetch` | Read one note in full: title, summary, full transcript, category, date, length |
| `list_recent_notes` | Your most recent notes, newest first, optionally between two ISO 8601 dates |

`search` and `fetch` follow the shape ChatGPT expects for search/fetch connectors, so
ChatGPT's deep research can use your notes directly. Each result's `url` opens that note
in the SpeakPen web app.

Limits: 60 tool calls per minute per account.

## Try

- "What did I say about the launch plan this week?"
- "Find my notes about pricing and summarize where I landed"
- "List everything I recorded yesterday and turn it into a to-do list"

## Also in your Obsidian vault

Your notes can also sync into Obsidian as plain Markdown with the
[SpeakPen Sync](https://github.com/xnjiang/speakpen-obsidian) plugin — any agent pointed at
your vault reads existing local files without MCP. Syncing those notes from SpeakPen
still requires your SpeakPen account. This repository does not provide a general-purpose
local-notes MCP server.

## License

MIT covers this repository's documentation, metadata and scripts. The hosted backend
implementation is not included here; this is not a self-hostable server distribution.
The hosted service is governed by [SpeakPen's terms](https://speakpen.app/terms).
