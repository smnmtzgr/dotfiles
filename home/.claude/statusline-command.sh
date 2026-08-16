#!/usr/bin/env bash

input=$(cat)

dir=$(echo "$input" | jq -r '.workspace.current_dir')
dir_name=$(basename "$dir")
model=$(echo "$input" | jq -r '.model.display_name')

ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
ctx_used_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
ctx_used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

ctx_info=""
if [ -n "$ctx_size" ] && [ -n "$ctx_used_tokens" ]; then
  ctx_size_k=$(awk -v n="$ctx_size" 'BEGIN { printf "%.0fk", n/1000 }')
  ctx_used_k=$(awk -v n="$ctx_used_tokens" 'BEGIN { printf "%.1fk", n/1000 }')
  if [ -n "$ctx_used_pct" ]; then
    ctx_info=$(printf "%s/%s (%.0f%%)" "$ctx_used_k" "$ctx_size_k" "$ctx_used_pct")
  else
    ctx_info=$(printf "%s/%s" "$ctx_used_k" "$ctx_size_k")
  fi
fi

printf "\033[2m%s\033[0m in \033[2;36m%s\033[0m" "$model" "$dir_name"
if [ -n "$ctx_info" ]; then
  printf " | \033[2mctx: %s\033[0m" "$ctx_info"
fi
