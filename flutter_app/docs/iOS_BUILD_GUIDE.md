# iOS App 构建指南

## 现状

iOS 源代码已生成并位于 `ios/` 目录。Flutter 框架已编译成功：
- **Debug**: `build/ios/framework/Debug/`
- **Profile**: `build/ios/framework/Profile/`
- **Release**: `build/ios/framework/Release/`

包含的框架：
- `App.xcframework` - 应用代码
- `Flutter.xcframework` - Flutter 引擎
- `objective_c.framework` - Objective-C 互操作
- `shared_preferences_foundation.xcframework` - 共享偏好设置

## iOS 代码签名要求

**重要**: Apple 要求所有 iOS 应用必须经过代码签名才能安装到真机设备上。这是 Apple 的安全策略，无法绕过。

### 构建选项

#### 选项 1: 免费开发 (推荐用于测试)
1. **安装 Xcode** (已完成)
2. **用 Apple ID 登录 Xcode**
3. **选择 "Personal Team"** (免费)
4. **自动签名**

```bash
# 在 Xcode 中打开项目
open ios/Runner.xcworkspace

# 然后在 Xcode 中:
# 1. 选择 Runner > Signing & Capabilities
# 2. 选择你的 Team (Personal Team)
# 3. Xcode 会自动处理签名
# 4. Product > Archive 生成 IPA
```

#### 选项 2: Apple Developer Program (用于发布)
- **费用**: $99/年
- **好处**: 可以发布到 App Store，测试设备无限制
- **申请**: https://developer.apple.com/programs/

### 真机测试步骤

```bash
# 1. 连接 iPhone 到 Mac
# 2. 在 Xcode 中选择你的设备作为目标
# 3. 点击 Run (或 Cmd+R)
```

### 生成 IPA (用于分发)

```bash
# 在 Xcode 中:
# Product > Archive > Distribute App
# 选择分发方式:
# - Ad Hoc (内部测试)
# - Development (开发测试)
# - App Store Connect (上架)
```

## 项目配置

- **Bundle ID**: `com.uchannel.vita`
- **Display Name**: `Vita`
- **Version**: `1.0.0`
- **Deployment Target**: iOS 13.0+

## 文件结构

```
ios/
├── Runner.xcworkspace      # Xcode 工作区 (使用这个打开)
├── Runner.xcodeproj        # Xcode 项目
├── Runner/
│   ├── AppDelegate.swift   # 应用入口
│   ├── Info.plist          # 应用配置
│   └── Assets.xcassets     # 资源文件
└── Podfile                 # CocoaPods 依赖
```

## 下一步

1. 打开 Xcode: `open ios/Runner.xcworkspace`
2. 用你的 Apple ID 登录
3. 选择 Team 进行自动签名
4. 连接 iPhone 并运行

## 常见问题

**Q: 可以像 Android 一样直接安装 IPA 吗？**
A: 不可以。iOS 应用必须签名，且签名需要与开发者账号关联。

**Q: 可以越狱设备绕过签名吗？**
A: 技术上可以，但不推荐。越狱设备有安全风险，且无法代表真实使用场景。

**Q: Personal Team 有什么限制？**
A: 应用有效期 7 天，每次需重新安装，无法发布到 App Store。

**Q: 模拟器运行需要签名吗？**
A: 不需要。但你需要先安装 iOS Simulator Runtime。
