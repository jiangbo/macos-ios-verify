import Metal

// 记录实际可用的 Metal 设备；没有设备时直接停止验证。
guard let device = MTLCreateSystemDefaultDevice() else {
    fatalError("No Metal device available")
}
print("Metal device: \(device.name)")
