#!/bin/bash
set -euo pipefail

# 使用仓库内的应用包，资源与可执行文件一起安装。
cd "$(dirname "$0")"
mkdir -p result
result_dir="$PWD/result"
app="$PWD/game-ios-simulator/demo.app"
bundle_id=$(/usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier' "$app/Info.plist")
sw_vers > "$result_dir/system.txt"
uname -m >> "$result_dir/system.txt"
xcodebuild -version >> "$result_dir/system.txt"
xcrun simctl list runtimes > "$result_dir/runtimes.txt"
xcrun vtool -show-build "$app/demo" > "$result_dir/binary.txt"
plutil -p "$app/Info.plist" > "$result_dir/app.txt"
swift ../macos-check/metal.swift 2>&1 | tee "$result_dir/metal.txt"

# 模拟器使用临时签名，不需要开发者证书或真机描述文件。
codesign --force --sign - --timestamp=none "$app" 2> "$result_dir/signature.txt"
codesign --verify --verbose "$app" 2>> "$result_dir/signature.txt"

# 创建独立设备，明确指定已经预装的 iOS 18.5 运行时。
device_id=$(xcrun simctl create "ZhuYu iOS check" \
  com.apple.CoreSimulator.SimDeviceType.iPhone-16 \
  com.apple.CoreSimulator.SimRuntime.iOS-18-5)
printf '%s\n' "$device_id" > "$result_dir/device.txt"
xcrun simctl boot "$device_id"
xcrun simctl bootstatus "$device_id" -b
xcrun simctl install "$device_id" "$app"

# 保存游戏输出和实际进程号，等待首屏稳定后截图。
xcrun simctl launch --stdout="$result_dir/game.log" \
  --stderr="$result_dir/game-error.log" "$device_id" "$bundle_id" \
  | tee "$result_dir/launch.txt"
game_pid=$(awk -F ': ' '{print $NF}' "$result_dir/launch.txt")
sleep 10
xcrun simctl io "$device_id" screenshot "$result_dir/game.png"
kill -0 "$game_pid"
ps -p "$game_pid" -o pid=,comm= > "$result_dir/process.txt"
sips -g pixelWidth -g pixelHeight "$result_dir/game.png" \
  | tee "$result_dir/screenshot.txt"
printf '%s\n' 'Game is running; simulator screenshot saved.'
