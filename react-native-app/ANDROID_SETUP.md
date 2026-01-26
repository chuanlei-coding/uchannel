# Android React Native 集成指南

## 步骤 1: 更新 settings.gradle

在 `android/settings.gradle` 中添加：

```gradle
rootProject.name = "UChannel"
include ':app'
includeBuild('../node_modules/@react-native/gradle-plugin')
```

## 步骤 2: 更新 app/build.gradle

在 `android/app/build.gradle` 中添加 React Native 依赖：

```gradle
dependencies {
    // React Native
    implementation "com.facebook.react:react-android"
    implementation "com.facebook.react:hermes-android"
    
    // 其他依赖...
}
```

## 步骤 3: 创建 MainApplication.kt

创建 `android/app/src/main/java/com/uchannel/MainApplication.kt`:

```kotlin
package com.uchannel

import android.app.Application
import com.facebook.react.PackageList
import com.facebook.react.ReactApplication
import com.facebook.react.ReactHost
import com.facebook.react.ReactNativeHost
import com.facebook.react.ReactPackage
import com.facebook.react.defaults.DefaultNewArchitectureEntryPoint.load
import com.facebook.react.defaults.DefaultReactHost.getDefaultReactHost
import com.facebook.react.defaults.DefaultReactNativeHost
import com.facebook.soloader.SoLoader

class MainApplication : Application(), ReactApplication {
    override val reactNativeHost: ReactNativeHost =
        object : DefaultReactNativeHost(this) {
            override fun getPackages(): List<ReactPackage> =
                PackageList(this).packages.apply {
                    // 添加自定义包
                }

            override fun getJSMainModuleName(): String = "index"

            override fun getUseDeveloperSupport(): Boolean = BuildConfig.DEBUG

            override val isNewArchEnabled: Boolean = BuildConfig.IS_NEW_ARCHITECTURE_ENABLED
            override val isHermesEnabled: Boolean = BuildConfig.IS_HERMES_ENABLED
        }

    override val reactHost: ReactHost
        get() = getDefaultReactHost(applicationContext, reactNativeHost)

    override fun onCreate() {
        super.onCreate()
        SoLoader.init(this, false)
        if (BuildConfig.IS_NEW_ARCHITECTURE_ENABLED) {
            load()
        }
    }
}
```

## 步骤 4: 更新 MainActivity.kt

更新 `android/app/src/main/java/com/uchannel/MainActivity.kt`:

```kotlin
package com.uchannel

import com.facebook.react.ReactActivity
import com.facebook.react.ReactActivityDelegate
import com.facebook.react.defaults.DefaultNewArchitectureEntryPoint.fabricEnabled
import com.facebook.react.defaults.DefaultReactActivityDelegate

class MainActivity : ReactActivity() {
    override fun getMainComponentName(): String = "uchannel"

    override fun createReactActivityDelegate(): ReactActivityDelegate =
        DefaultReactActivityDelegate(
            this,
            mainComponentName,
            fabricEnabled
        )
}
```

## 步骤 5: 更新 AndroidManifest.xml

确保 `android/app/src/main/AndroidManifest.xml` 中：

```xml
<application
    android:name=".MainApplication"
    ...>
    <activity
        android:name=".MainActivity"
        android:exported="true"
        ...>
```

## 步骤 6: 安装依赖

```bash
cd react-native-app
npm install
```

## 步骤 7: 运行

```bash
npm run android
```
