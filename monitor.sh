#!/bin/bash
# GitHub 安全仓库监控脚本
# 每次运行时搜索关键词，对比上次结果，仅输出新增仓库

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
STATE_FILE="$SCRIPT_DIR/.seen_repos"
RESULT_FILE="$SCRIPT_DIR/.latest_new.md"

# 关键词列表
KEYWORDS=(
  "网络安全"
  "hack"
  "CVE-2026"
  "反序列化"
  "Inject"
  "POC"
  "Payload"
  "Attack"
  "漏洞"
  "RCE"
  "0day"
  "exploit"
  "webshell"
  "privilege escalation"
  "bypass"
)

# 初始化状态文件
touch "$STATE_FILE"

NEW_REPOS=""
NEW_COUNT=0

for kw in "${KEYWORDS[@]}"; do
  # 搜索最近创建的仓库，按更新时间排序，取前5
  results=$(gh search repos "$kw" \
    --sort updated \
    --order desc \
    --limit 5 \
    --json fullName,description,url,updatedAt,stargazersCount \
    --jq '.[] | "\(.fullName)\t\(.stargazersCount)\t\(.url)\t\(.description // "无描述")"' 2>/dev/null)

  if [ -z "$results" ]; then
    continue
  fi

  while IFS=$'\t' read -r name stars url desc; do
    # 检查是否已见过
    if grep -qF "$name" "$STATE_FILE" 2>/dev/null; then
      continue
    fi
    # 记录为已见
    echo "$name" >> "$STATE_FILE"
    NEW_COUNT=$((NEW_COUNT + 1))
    NEW_REPOS="${NEW_REPOS}
### ${NEW_COUNT}. [${name}](${url}) ⭐${stars}
- **关键词**: \`${kw}\`
- **描述**: ${desc}
"
  done <<< "$results"

  # gh API 限流保护
  sleep 2
done

# 输出结果
if [ "$NEW_COUNT" -gt 0 ]; then
  TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
  REPORT="# 🔍 安全仓库监控报告
> 扫描时间: ${TIMESTAMP}
> 发现 **${NEW_COUNT}** 个新仓库

${NEW_REPOS}"

  echo "$REPORT" > "$RESULT_FILE"
  echo "$REPORT"
  exit 0
else
  # 静默退出，无新结果
  exit 1
fi
