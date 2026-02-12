# iOS IPA 构建完整指南

## 📱 准备工作

确保你有：
- ✅ Mac 电脑
- ✅ Xcode 已安装
- ✅ Apple ID (免费即可)
- ✅ USB 数据线（用于连接 iPhone）

---

## 🚀 快速开始（推荐方式）

### 方式一：使用自动化脚本

```bash
cd /Users/chuanlei/code/uchannel/flutter_app
./scripts/build_ipa.sh
```

脚本会自动：
1. 检查环境
2. 安装依赖
3. 构建 Archive
4. 导出 IPA 文件

---

## 📝 手动操作步骤（首次使用）

### 第 1 步：登录 Apple ID

1. 打开 Xcode
2. 点击菜单栏 **Xcode** → **Settings...**
3. 选择 **Accounts** 标签
4. 点击左下角 **+** 按钮
5. 选择 **Apple ID**
6. 输入你的 Apple ID 和密码登录

```
Xcode → Settings → Accounts → + → Apple ID → 登录
```

### 第 2 步：配置代码签名

1. 在 Xcode 左侧，点击 **Runner** 项目
2. 选择 **TARGETS** → **Runner**
3. 点击 **Signing & Capabilities** 标签
4. 确保 ✅ **Automatically manage signing** 已勾选
5. 在 **Team** 下拉菜单中选择你的 Apple ID
6. 等待 Xcode 自动配置（显示绿色勾）

```
左侧导航 → Runner → TARGETS → Runner
→ Signing & Capabilities
→ Team → 选择你的 Apple ID
```

### 第 3 步：连接 iPhone（可选）

如果要在真机上测试：
1. 用 USB 线连接 iPhone 到 Mac
2. iPhone 上会弹出"信任此电脑"提示，点击**信任**
3. Xcode 顶部工具栏会显示你的设备名称
4. 选择你的设备作为目标

### 第 4 步：构建 Archive

1. 在 Xcode 菜单选择 **Product** → **Archive**
2. 等待构建完成（约 5-10 分钟）
3. 构建成功后会自动打开 **Organizer** 窗口

```
Product → Archive → 等待构建 → 自动打开 Organizer
```

### 第 5 步：导出 IPA

在 Organizer 窗口中：

1. 选择刚构建的 Archive
2. 点击右侧 **Distribute App** 按钮
3. 选择分发方式：
   - **Development** - 用于开发测试
   - **Ad Hoc** - 用于内部测试
   - **App Store** - 用于上架（需要付费账号）
4. 点击 **Next**
5. 选择自动签名
6. 点击 **Export**
7. 选择保存位置
8. 完成！🎉

---

## 📦 安装 IPA 到 iPhone

### 方法 1：使用 Xcode

1. 连接 iPhone
2. Xcode 菜单 → **Window** → **Devices and Simulators**
3. 选择你的 iPhone
4. 点击 **Settings**，确保"开发者模式"已启用
5. 点击左侧 **Installed Apps**
6. 点击 **+** 按钮
7. 选择 IPA 文件
8. 点击安装

### 方法 2：命令行（需要设备 UDID）

```bash
# 列出连接的设备
xcrun devicectl list devices

# 安装 IPA
xcrun devicectl device install app --device <UDID> /path/to/Vita.ipa
```

---

## ⚠️ 重要说明

### 免费开发者账号限制
- 应用有效期 **7 天**
- 需要重新签名才能继续使用
- 每个设备最多 3 个应用

### 付费开发者账号 ($99/年)
- 应用有效期 **1 年**
- 可发布到 App Store
- 设备数量无限制

---

## 🔄 重新签名（应用过期后）

```bash
cd /Users/chuanlei/code/uchannel/flutter_app
./scripts/build_ipa.sh
```

或在 Xcode 中：
1. Product → Archive
2. Organizer → Distribute App
3. 重新导出

---

## 📁 文件位置

| 文件 | 路径 |
|------|------|
| IPA 文件 | `build/ios/export/Vita.ipa` |
| Xcode 项目 | `ios/Runner.xcworkspace` |
| 构建脚本 | `scripts/build_ipa.sh` |
| 详细步骤 | `docs/XCODE_STEPS.md` |

---

## 🆘 常见问题

### "No team selected" 错误
**解决**: Xcode → Settings → Accounts → 添加 Apple ID

### "Failed to create provisioning profile" 错误
**解决**:
- 修改 Bundle ID
- 或等待几分钟后重试

### "Could not find a device" 错误
**解决**: 连接 iPhone 或选择模拟器

### 应用闪退
**解决**:
- 确保 iPhone 信任开发者证书
- 设置 → 通用 → VPN与设备管理 → 信任

---

## 🎯 下一步

完成构建后，你可以：

1. **测试应用**: 在 iPhone 上安装并运行
2. **分发应用**: 通过 TestFlight 分发测试版本
3. **上架应用**: 加入 Apple Developer Program 后上架 App Store

---

需要帮助？查看：
- [Apple 官方文档](https://developer.apple.com/documentation/xcode)
- [Flutter iOS 构建指南](https://docs.flutter.dev/deployment/ios)
