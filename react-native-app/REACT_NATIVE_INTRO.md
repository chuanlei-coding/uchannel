# React Native 技术介绍

## 什么是 React Native？

React Native 是由 Facebook（现 Meta）开发的开源移动应用开发框架，允许开发者使用 JavaScript 和 React 来构建原生移动应用。

### 核心特点

1. **跨平台开发**
   - 使用一套代码同时开发 iOS 和 Android 应用
   - 减少开发时间和维护成本

2. **原生性能**
   - 不是 WebView 包装的混合应用
   - 直接调用原生组件，性能接近原生应用

3. **热重载（Hot Reload）**
   - 修改代码后立即看到效果
   - 无需重新编译整个应用

4. **丰富的生态系统**
   - 大量第三方库和组件
   - 活跃的社区支持

### 工作原理

```
JavaScript 代码 (React Native)
    ↓
Metro Bundler (打包和转换)
    ↓
原生组件桥接 (Bridge)
    ↓
iOS/Android 原生 UI
```

React Native 通过一个"桥接"（Bridge）层，将 JavaScript 代码转换为原生组件调用。这意味着：

- **UI 组件**：React Native 组件会被映射到原生组件（如 `View` → `UIView`/`ViewGroup`）
- **性能**：关键操作在原生层执行，JavaScript 只负责业务逻辑
- **API 访问**：可以通过原生模块访问设备功能（相机、GPS 等）

### 与原生开发对比

| 特性 | React Native | 原生开发 |
|------|--------------|----------|
| 开发语言 | JavaScript/TypeScript | Kotlin/Java (Android), Swift/Objective-C (iOS) |
| 代码复用 | 一套代码，多平台 | 需要分别为每个平台开发 |
| 性能 | 接近原生 | 原生性能 |
| 开发速度 | 快速迭代 | 相对较慢 |
| 学习曲线 | 较平缓（Web 开发者友好） | 需要学习平台特定技术 |

### 适用场景

✅ **适合使用 React Native：**
- 需要同时支持 iOS 和 Android
- 团队熟悉 JavaScript/React
- 应用以业务逻辑为主，对性能要求不是极致
- 需要快速迭代和更新

❌ **不适合使用 React Native：**
- 需要极致性能的应用（如游戏、复杂动画）
- 需要大量使用平台特定功能
- 应用非常简单，原生开发更快

---

## 什么是 Metro Bundler？

Metro 是 React Native 的 JavaScript 打包工具（bundler），类似于 Web 开发中的 Webpack 或 Vite。

### Metro 的作用

1. **代码打包**
   - 将多个 JavaScript 文件打包成一个或多个 bundle
   - 处理模块依赖关系

2. **代码转换**
   - 将 ES6+、TypeScript、JSX 转换为目标环境可执行的代码
   - 使用 Babel 进行转换

3. **资源处理**
   - 处理图片、字体等静态资源
   - 优化资源大小

4. **开发服务器**
   - 提供开发时的热重载功能
   - 实时编译和更新代码

### Metro 工作流程

```
源代码文件
    ↓
入口文件 (index.js)
    ↓
依赖解析 (Dependency Resolution)
    ↓
代码转换 (Babel Transform)
    ↓
打包 (Bundling)
    ↓
输出 Bundle 文件
    ↓
发送到设备/模拟器
```

### Metro 的主要功能

#### 1. 模块解析
```javascript
// Metro 会自动解析 import/require 语句
import React from 'react';
import {View, Text} from 'react-native';
import MyComponent from './components/MyComponent';
```

#### 2. 代码转换
- **Babel 转换**：ES6+ → ES5，JSX → JavaScript
- **TypeScript 支持**：自动编译 TypeScript
- **Flow 支持**：类型检查（如果使用）

#### 3. 资源优化
- 图片压缩和优化
- 字体文件处理
- 自动生成资源映射

#### 4. 开发模式特性
- **Fast Refresh**：保存文件后立即更新
- **Source Maps**：便于调试
- **错误提示**：友好的错误信息

### Metro 配置文件

Metro 的配置通常在 `metro.config.js` 中：

```javascript
const {getDefaultConfig, mergeConfig} = require('@react-native/metro-config');

const config = {
  // 自定义配置
  transformer: {
    // Babel 配置
  },
  resolver: {
    // 模块解析配置
  },
};

module.exports = mergeConfig(getDefaultConfig(__dirname), config);
```

### 启动 Metro Bundler

#### 方式 1：使用 npm 脚本
```bash
npm start
# 或
yarn start
```

#### 方式 2：直接运行
```bash
npx react-native start
```

#### 常用命令选项
```bash
# 清除缓存并启动
npm start -- --reset-cache

# 指定端口
npm start -- --port 8081

# 不打开浏览器
npm start -- --no-open
```

### Metro 开发服务器界面

启动 Metro 后，你会看到：

```
Metro waiting on exp://192.168.1.100:8081
Scanning folders for symlinks in /path/to/project/node_modules
Metro Bundler ready.

Loading dependency graph, done.
```

**快捷键：**
- `r` - 重新加载应用
- `d` - 打开开发者菜单
- `i` - 在 iOS 模拟器中打开
- `a` - 在 Android 模拟器中打开

### Metro vs 其他打包工具

| 特性 | Metro | Webpack | Vite |
|------|-------|---------|------|
| 用途 | React Native 专用 | Web 应用 | Web 应用 |
| 速度 | 快速（针对 RN 优化） | 较慢 | 非常快 |
| 配置 | 简单，开箱即用 | 复杂 | 简单 |
| 热重载 | 原生支持 | 需要配置 | 原生支持 |

### 常见问题

#### 1. Metro 启动失败
```bash
# 清除缓存
npm start -- --reset-cache

# 删除 node_modules 重新安装
rm -rf node_modules
npm install
```

#### 2. 端口被占用
```bash
# 使用其他端口
npm start -- --port 8082
```

#### 3. 模块找不到
```bash
# 清除 watchman（如果安装了）
watchman watch-del-all

# 清除 Metro 缓存
npm start -- --reset-cache
```

---

## React Native 项目结构

```
react-native-app/
├── android/              # Android 原生代码
├── ios/                  # iOS 原生代码（如果有）
├── src/                  # JavaScript/TypeScript 源代码
│   ├── screens/          # 页面组件
│   ├── components/       # 可复用组件
│   ├── navigation/       # 导航配置
│   ├── services/         # API 服务
│   └── utils/           # 工具函数
├── node_modules/         # 依赖包
├── App.tsx              # 应用入口组件
├── index.js             # React Native 入口
├── package.json         # 项目配置和依赖
├── metro.config.js      # Metro 配置
└── babel.config.js       # Babel 配置
```

---

## 总结

- **React Native**：使用 JavaScript 开发原生移动应用的框架
- **Metro Bundler**：React Native 的打包工具，负责代码转换、打包和开发服务器
- **优势**：跨平台、快速开发、接近原生性能
- **适用**：需要同时支持 iOS 和 Android 的应用开发

通过 React Native，我们可以用熟悉的 Web 开发技术栈来构建移动应用，大大提高了开发效率。
