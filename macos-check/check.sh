#!/bin/bash
set -euo pipefail

# 所有路径都相对于脚本所在目录，游戏资源随运行包提供。
cd "$(dirname "$0")"
mkdir -p result
result_dir="$PWD/result"
sw_vers > "$result_dir/system.txt"
uname -m >> "$result_dir/system.txt"
system_profiler SPDisplaysDataType > "$result_dir/graphics.txt"

# 先检查这台云端机器是否实际提供 Metal 设备。
swift metal.swift 2>&1 | tee "$result_dir/metal.txt"
cd game-macos-arm64
codesign --verify --verbose ./demo 2> "$result_dir/signature.txt"

# 启动游戏，等待首屏稳定后保存窗口截图。
./demo > "$result_dir/game.log" 2>&1 &
game_pid=$!
trap 'kill "$game_pid" 2>/dev/null || true' EXIT
sleep 10
kill -0 "$game_pid"
window_id=$(swift ../window.swift "$game_pid")
printf '%s\n' "$window_id" > "$result_dir/window.txt"
screencapture -x -o -l "$window_id" "$result_dir/game.png"
sips -g pixelWidth -g pixelHeight "$result_dir/game.png"
printf '%s\n' 'Game is running; window screenshot saved.'
