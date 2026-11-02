# SpeakPen MCP

[English](README.md) | [简体中文](README.zh-CN.md)

**随口记下的想法，需要时让 AI 帮你找回来。** SpeakPen 帮你把说过的想法留成笔记。这个 MCP 集成让支持相应连接方式的 AI 客户端搜索笔记、读取原文，再基于你的思考整理计划或草稿。

- 服务地址：`https://speakpen.app/mcp`
- 传输方式：Streamable HTTP，无状态，仅 POST，不维护会话。
- 权限：**只读**。只能读取自己账号内处理完成的笔记，不能创建、修改或删除笔记，也不会返回原始音频。
- MCP Registry：[`io.github.Qumge/speakpen-mcp`](https://registry.modelcontextprotocol.io/v0/servers?search=speakpen)。

这是一个**托管服务**，不需要在本地运行服务器。本仓库公开文档、检查脚本和 Registry 元数据；线上服务运行在 speakpen.app，服务端实现不包含在这里。

## 从这里开始

**[先用 SpeakPen 记录一个想法 →](https://speakpen.app/zh-Hans?utm_source=github-speakpen-mcp&utm_medium=readme&utm_campaign=voice_to_action)**

[下载 iOS](https://apps.apple.com/app/id6743360755) · [下载 Android](https://play.google.com/store/apps/details?id=com.qumge.speakpen) · [使用网页版](https://speakpen.app/app?utm_source=github-speakpen-mcp&utm_medium=readme&utm_campaign=voice_to_action)

1. 在 SpeakPen 录一段想法，等待笔记处理完成。
2. 按[连接指南](https://speakpen.app/zh-Hans/connect?utm_source=github-speakpen-mcp&utm_medium=readme&utm_campaign=voice_to_action)授权 AI 客户端，使用 OAuth 或自己的 API token。
3. 试着问：**“找到我的定价笔记，帮我梳理下一步怎么做。”**

已经有 SpeakPen 笔记？可以[直接连接](#连接)。只需配置托管服务地址，不必克隆这个仓库。

## 不连接 SpeakPen 账号可以用吗？

不注册也能阅读和复用本仓库。**调用托管 MCP 服务需要 SpeakPen 账号，以及 OAuth 或个人 API token 授权**，初始化和 `tools/list` 也需要认证。仅在浏览器登录 SpeakPen 不会自动授权 MCP；客户端必须携带 bearer token。

| 你想做什么 | 当前条件 |
|---|---|
| 阅读或复用 MIT 许可的文档与元数据 | 不需要账号 |
| 连接线上 MCP 服务 | 账号 + OAuth 或 API token |
| 搜索、读取有用的个人内容 | 账号内已有处理完成的笔记 |
| 克隆本仓库后独立运行或自托管服务器 | 当前不支持，仓库未包含服务端实现 |
| 使用游客模式或内置演示笔记 | 尚未实现 |

仅连接这个只读集成不要求付费订阅。空账号可以连接，但没有笔记可返回。录音等服务功能仍受套餐额度限制；AI 客户端也可能有自己的权限和费用要求。

[从免费账号开始](https://speakpen.app/zh-Hans?utm_source=github-speakpen-mcp&utm_medium=readme&utm_campaign=voice_to_action) → 在 App 或 https://speakpen.app/app 录下一段想法 → 等待处理完成 → 授权连接 → 向 AI 提问。本仓库没有可安装的本地服务程序或转写引擎。

## 连接

[各客户端连接指南](https://speakpen.app/zh-Hans/connect?utm_source=github-speakpen-mcp&utm_medium=readme&utm_campaign=voice_to_action)，也可以让 Agent 阅读。

**ChatGPT / Claude.ai / Claude Desktop**：在支持远程 MCP 的客户端中添加 `https://speakpen.app/mcp`，随后登录 SpeakPen 并同意只读授权。已授权客户端可在“设置 → 连接 → AI 助手”中查看和断开。

**Claude Code**：优先使用 OAuth。

```bash
claude mcp add --transport http speakpen https://speakpen.app/mcp
```

也可以在 https://speakpen.app/app 的“设置 → 连接 → 开发者”创建个人 token：

```bash
claude mcp add --transport http speakpen https://speakpen.app/mcp \
  --header "Authorization: Bearer YOUR_TOKEN"
```

**Cursor**：`~/.cursor/mcp.json`

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

**VS Code**：`.vscode/mcp.json`

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

**Codex**：`~/.codex/config.toml`

```toml
[mcp_servers.speakpen]
url = "https://speakpen.app/mcp"
bearer_token_env_var = "SPEAKPEN_TOKEN"
```

不要把真实 token 提交到仓库、共享配置文件或聊天记录。客户端支持时，使用其密钥或环境变量机制。使用 API token 仍受账号授权和撤销机制约束。

## 工具

工具同时返回 `structuredContent`（JSON）和 `content` 中相同 JSON 的文本形式。开发时以工具名和 `structuredContent` 为合同。未完成或属于他人的笔记统一返回“Note not found”。

| 工具 | 用途 |
|---|---|
| `search` | 按关键词搜索自己的笔记，最多 10 条，包含 id、标题、链接、日期和片段 |
| `fetch` | 读取一条笔记的原文、摘要、分类、日期和时长 |
| `list_recent_notes` | 按时间倒序读取最近笔记，可限制两个 ISO 8601 日期之间的范围 |

`search` 和 `fetch` 使用兼容搜索/读取连接器的结构。结果中的 `url` 会打开 SpeakPen Web 中对应笔记。

限制：每个账号每分钟 60 次工具调用。

## 可以这样问

- “这周我对发布计划说过什么？”
- “找到我的定价笔记，整理最后的结论。”
- “把昨天记录的内容整理成待办事项。”

### 处理状态

原文可读和 AI 摘要完成是两件事。原生笔记的 `fetch` 可能返回 `metadata.transcript_status` 与 `metadata.summary_status`。摘要等待或失败时，不能说摘要已经生成；旧笔记缺少状态时应视为未知。工具报错也不能当作搜索成功但没有结果。需要核对时以原始转写为依据。

## 选择适合你的连接方式

- **本仓库的 MCP 连接**：让兼容 AI 客户端只读访问 SpeakPen 云端笔记。
- **[SpeakPen Skill](https://github.com/Qumge/speakpen-skill)**：给 Agent 一套查找、阅读、引用笔记的流程；已有 MCP 时不是必装项。
- **[SpeakPen Sync for Obsidian](https://github.com/Qumge/speakpen-obsidian)**：把笔记同步成 vault 中的普通 Markdown。

## 也可以在 Obsidian 中使用

[SpeakPen Sync](https://github.com/Qumge/speakpen-obsidian) 可以把 SpeakPen 笔记同步到 Obsidian，变成普通 Markdown。Agent 可以直接读取已经存在于知识库中的文件，无需再通过 MCP；先从 SpeakPen 同步这些笔记仍需要 SpeakPen 账号。

## 许可证

MIT 适用于本仓库的文档、元数据和脚本。托管后端实现不在本仓库中，本仓库不是可自托管服务器发行包。线上服务遵循 [SpeakPen 服务条款](https://speakpen.app/terms)。
