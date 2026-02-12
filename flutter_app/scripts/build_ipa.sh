#!/bin/bash

# iOS IPA 自动化构建脚本
# 使用方法: ./scripts/build_ipa.sh

set -e

FLUTTER_APP_PATH="/Users/chuanlei/code/uchannel/flutter_app"
IOS_PATH="$FLUTTER_APP_PATH/ios"
ARCHIVE_PATH="$FLUTTER_APP_PATH/build/ios/Runner.xcarchive"
EXPORT_PATH="$FLUTTER_APP_PATH/build/ios/export"
IPA_PATH="$EXPORT_PATH/Vita.ipa"

echo "======================================"
echo "   iOS IPA 自动化构建脚本"
echo "======================================"
echo ""

# 检查 Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ 错误: 未找到 Xcode"
    exit 1
fi
echo "✓ Xcode 已安装"

cd "$IOS_PATH"

# 检查 CocoaPods
if ! command -v pod &> /dev/null; then
    echo "❌ 错误: 未找到 CocoaPods"
    exit 1
fi
echo "✓ CocoaPods 已安装"

# 安装依赖
echo ""
echo "[1/4] 安装 CocoaPods 依赖..."
pod install

# 检查项目配置
echo ""
echo "[2/4] 检查项目配置..."
if grep -q "DEVELOPMENT_TEAM = \"\"" Runner.xcodeproj/project.pbxproj; then
    echo "⚠️  警告: 未配置开发团队"
    echo ""
    echo "请在 Xcode 中完成以下步骤:"
    echo "  1. 打开项目: open ios/Runner.xcworkspace"
    echo "  2. Xcode > Settings > Accounts > 添加 Apple ID"
    echo "  3. Runner target > Signing & Capabilities > Team"
    echo "  4. 选择你的 Apple ID (Personal Team)"
    echo ""
    echo "完成后重新运行此脚本"
    echo ""
    open Runner.xcworkspace
    exit 1
fi
echo "✓ 项目配置正常"

# 构建 Archive
echo ""
echo "[3/4] 构建 Archive (这可能需要几分钟)..."

# 尝试自动构建 archive
xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -archivePath "$ARCHIVE_PATH" \
  -allowProvisioningUpdates \
  archive | xcpretty || {
    echo ""
    echo "❌ Archive 构建失败"
    echo ""
    echo "可能的原因:"
    echo "  - 未配置开发团队"
    echo "  - 未连接设备"
    echo ""
    echo "请在 Xcode 中手动完成首次构建:"
    echo "  open ios/Runner.xcworkspace"
    echo ""
    open Runner.xcworkspace
    exit 1
  }

echo "✓ Archive 构建成功"

# 导出 IPA
echo ""
echo "[4/4] 导出 IPA 文件..."

# 创建导出配置
mkdir -p "$EXPORT_PATH"

# 使用 xcodebuild 导出
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist exportOptions.plist \
  -allowProvisioningUpdates | xcpretty || {
    echo ""
    echo "❌ IPA 导出失败"
    echo ""
    echo "请在 Xcode Organizer 中手动导出:"
    echo "  Window > Organizer > Distribute App"
    exit 1
  }

echo "✓ IPA 导出成功"
echo ""
echo "======================================"
echo "  构建完成！"
echo "======================================"
echo ""
echo "IPA 文件位置: $IPA_PATH"
echo ""
echo "安装到 iPhone:"
echo "  1. 连接 iPhone"
echo "  2. 在 Xcode 中: Window > Devices and Simulators"
echo "  3. 选择你的 iPhone，点击 '+'，选择 IPA 文件"
echo ""
echo "或使用命令行安装:"
echo "  xcrun devicectl device install app --device <设备UDID> $IPA_PATH"
echo ""
