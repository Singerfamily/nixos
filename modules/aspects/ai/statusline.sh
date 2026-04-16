#!/usr/bin/env bash
# Claude Code Statusline

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "unknown"')

dir=$(echo "$input" | jq -r '.workspace.project_dir // .workspace.current_dir // ""')
dir_short=$(basename "$dir")

ctx=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)

rl_5h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty' | cut -d. -f1)
rl_7d=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty' | cut -d. -f1)

CYAN="\033[36m"
GREEN="\033[32m"
DIM="\033[2m"
BOLD="\033[1m"
RST="\033[0m"

bar_width=10
filled=$((ctx * bar_width / 100))
empty=$((bar_width - filled))

bar=""
if [ "$filled" -gt 0 ]; then
  fill_str=$(printf "%${filled}s")
  bar="${bar}${fill_str// /▓}"
fi
if [ "$empty" -gt 0 ]; then
  empty_str=$(printf "%${empty}s")
  bar="${bar}${empty_str// /░}"
fi

limits_str=""
if [ -n "$rl_5h" ]; then
  limits_str="${DIM} | ${RST}5h: ${rl_5h}%"
fi
if [ -n "$rl_7d" ]; then
  limits_str="${limits_str}${DIM} | ${RST}7d: ${rl_7d}%"
fi

if [ -z "$limits_str" ]; then
  limits_str="${DIM} | ${RST}Limits: pending..."
fi

echo -e "${BOLD}${CYAN}[${model}]${RST}${DIM} | ${RST}${BOLD}${dir_short}${RST}"
echo -e "${GREEN}[${bar}] ${ctx}%${RST}${limits_str}"
