# macOS / iOS 运行验证

当前只配置 macOS 的一次性运行验证。游戏使用 Zig 编译为 Apple Silicon
版本，图形后端为 Metal，构建目标为 `aarch64-macos.14.0`，最低系统版本为
macOS 14.0。

`macos-check/game-macos-arm64/` 包含游戏可执行文件、18 个资源文件和
`run.command` 启动脚本。资源直接放在目录中，便于查看和替换。

## 运行流水线

推送后，在 GitHub 的 Actions 页面选择 `macOS one-time run`，点击
`Run workflow` 手动启动。提交和推送不会自动运行。

流水线使用 `macos-15` 的 Apple Silicon 环境；这是本次运行环境，游戏最低
系统版本仍为 macOS 14.0。流水线执行以下步骤：

1. 记录系统和显卡信息，检查是否提供 Metal 设备。
2. 检查游戏签名，启动已编译的游戏，等待 10 秒。
3. 确认进程仍在运行，找到游戏窗口并保存截图。
4. 上传 `macos-run-result`，保留 3 天；失败时也保留已有日志。

下载运行结果后，查看 `game.png` 确认首屏是否正常显示。
`game.log` 是游戏输出，`metal.txt` 是 Metal 设备信息，`run.log` 是完整运行日志。
截图成功表示已获取窗口画面；画面是否正确需要查看截图确认。

这是一次启动和截图验证，不包含游戏逻辑测试，也不重新编译游戏。
如果云端没有 Metal 设备，检查会直接失败并保留日志。

## 在 Mac 上运行

双击 `macos-check/game-macos-arm64/run.command` 可以启动游戏。
也可以在终端执行 `bash macos-check/check.sh`，完成与流水线相同的验证。

## 更新可执行文件

在 Mac 上进入游戏项目目录，显式指定最低系统版本：

```sh
zig build -Dtarget=aarch64-macos.14.0 -Doptimize=ReleaseFast \
  --prefix zig-out/macos-arm64
```

将 `zig-out/macos-arm64/bin/demo` 拷贝到本仓库的
`macos-check/game-macos-arm64/demo`，同时更新 `assets` 目录。

交叉编译时通过 `-Dmacos-sdk` 指定本机的 SDK 路径，路径不写入仓库文档。
