# iOS IPA 生成详细步骤

## 第一步：登录 Apple ID

1. 在 Xcode 菜单栏点击 **Xcode** → **Settings** (或 Preferences)
2. 选择 **Accounts** 标签
3. 点击左下角的 **+** 号
4. 选择 **Apple ID**
5. 输入你的 Apple ID 和密码
6. 登录成功后会显示你的账号

## 第二步：配置代码签名

1. 在 Xcode 左侧导航器中，点击 **Runner** (蓝色图标)
2. 选择 **TARGETS** 下的 **Runner**
3. 点击 **Signing & Capabilities** 标签
4. 勾选 **"Automatically manage signing"**
5. 在 **Team** 下拉菜单中选择你的 Apple ID (会显示为 "Personal Team")
6. Bundle Identifier 会自动设置为 `com.uchannel.vita`
7. 等待 Xcode 自动生成 Provisioning Profile (可能需要几分钟)

## 第三步：选择目标设备

### 方案 A：连接真机 (推荐)
1. 用 USB 线连接 iPhone 到 Mac
2. 在 Xcode 顶部工具栏的设备选择器中选择你的 iPhone
3. 在 iPhone 上信任此电脑 (如果弹出提示)

### 方案 B：使用模拟器
1. 在 Xcode 顶部工具栏点击设备选择器
2. 选择任意 iPhone 模拟器 (如 iPhone 15 Pro)

## 第四步：构建 Archive

1. 在 Xcode 菜单栏选择 **Product** → **Archive**
2. 等待构建完成 (可能需要 5-10 分钟)
3. 构建成功后会自动打开 **Organizer** 窗口

## 第五步：导出 IPA

### 方法 1：用于真机安装 (Ad Hoc)

1. 在 Organizer 中，选择刚构建的 Archive
2. 点击右侧的 **Distribute App**
3. 选择 **Ad Hoc** (用于内部测试)
4. 点击 **Next**
5. 确认分发选项 (选择自动签名)
6. 点击 **Export**
7. 选择保存位置
8. IPA 文件生成完成！

### 方法 2：用于开发测试 (Development)

1. 在 Organizer 中，选择刚构建的 Archive
2. 点击 **Distribute App**
3. 选择 **Development** (用于开发测试)
4. 按提示操作完成导出

## 安装 IPA 到 iPhone

### 方法 1：使用 Xcode
1. 连接 iPhone
2. 在 Xcode 中选择 **Window** → **Devices and Simulators**
3. 选择你的 iPhone
4. 点击 **+** 按钮
5. 选择生成的 IPA 文件
6. 点击安装

### 方法 2：使用 AltStore (第三方，需越狱或侧载)
1. 在 iPhone 上安装 AltStore
2. 通过 AltStore 安装 IPA

## 常见问题

### Q: "Could not find a Team" 错误
A: 确保已在 Xcode > Settings > Accounts 中登录 Apple ID

### Q: "Failed to create provisioning profile" 错误
A:
- 尝试修改 Bundle ID (改为其他名称)
- 或者等待几分钟后重试

### Q: 应用 7 天后过期怎么办？
A: 重新用 Xcode 安装即可 (免费开发者账号的限制)

### Q: 想要永久使用怎么办？
A: 需要加入 Apple Developer Program ($99/年)

---

## 快捷命令参考

```bash
# 打开 Xcode 项目
open ios/Runner.xcworkspace

# 查看 Xcode 版本
xcodebuild -version

# 查看可用设备
xcrun xctrace list devices
```
