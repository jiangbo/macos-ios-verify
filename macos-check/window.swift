import CoreGraphics
import Foundation

// 按游戏进程查找可见主窗口，供系统截图命令使用。
let gamePid = Int(CommandLine.arguments[1])!
let windows = CGWindowListCopyWindowInfo(
    [.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID
) as! [[String: Any]]
guard let window = windows.first(where: {
    ($0[kCGWindowOwnerPID as String] as? Int) == gamePid &&
    ($0[kCGWindowLayer as String] as? Int) == 0
}) else {
    fatalError("No visible game window")
}
print(window[kCGWindowNumber as String] as! Int)
