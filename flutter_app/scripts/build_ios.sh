#!/bin/bash

echo "=== iOS App 构建说明 ==="
echo ""
echo "Apple 要求所有 iOS 应用必须经过代码签名才能安装到真机。"
echo ""
echo "=== 方案 1: 使用 Personal Team (免费) ==="
echo "1. 打开 Xcode: open ios/Runner.xcworkspace"
echo "2. Xcode > Settings > Accounts > 添加 Apple ID"
echo "3. 选择 Runner target > Signing & Capabilities"
echo "4. Team 选择你的 Personal Team"
echo "5. 连接 iPhone"
echo "6. Product > Run (直接安装到设备)"
echo "   或 Product > Archive (生成 IPA 文件)"
echo ""
echo "=== 方案 2: Apple Developer Program ($99/年) ==="
echo "访问: https://developer.apple.com/programs/"
echo ""
echo "正在打开 Xcode..."
open ios/Runner.xcworkspace

