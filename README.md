---
name: security-monitor
description: "每小时监控 GitHub 安全相关新仓库。自动搜索网络安全、hack、CVE、POC、漏洞等关键词，发现新仓库时推送报告，无新结果时静默。"
version: "1.0.0"
---

# GitHub 安全仓库监控技能

每小时自动搜索 GitHub 上与安全相关的新仓库，发现新仓库时输出报告，无新结果时静默。

## 监控关键词

`网络安全` `hack` `CVE-2026` `反序列化` `Inject` `POC` `Payload` `Attack` `漏洞` `RCE` `0day` `exploit` `webshell` `privilege escalation` `bypass`

## 使用方式

### 手动执行一次扫描

```bash
bash monitor.sh
```

- 有新仓库 → 输出 Markdown 报告（同时写入 `.latest_new.md`）
- 无新仓库 → 静默退出（exit code 1）

### 设置每小时自动监控

在 Claude Code 中使用 cron 调度：

> 每小时运行一次安全仓库监控，有新结果时展示报告

### 自定义关键词

编辑 `monitor.sh` 中的 `KEYWORDS` 数组即可增删关键词。

## 状态文件

| 文件 | 用途 |
|------|------|
| `.seen_repos` | 已发现仓库列表（去重用） |
| `.latest_new.md` | 最近一次扫描的新增报告 |

## 依赖

- `gh` CLI（已登录 GitHub 账号）
