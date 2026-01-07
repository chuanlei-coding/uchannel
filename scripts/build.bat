@echo off
REM 打包脚本 (Windows) - 同时生成APK和后端JAR包
REM 使用方法: scripts\build.bat [release|debug]

setlocal enabledelayedexpansion

set BUILD_TYPE=%1
if "%BUILD_TYPE%"=="" set BUILD_TYPE=release

set PROJECT_ROOT=%~dp0..
set BUILD_DIR=%PROJECT_ROOT%\build
set APK_OUTPUT_DIR=%BUILD_DIR%\apk
set JAR_OUTPUT_DIR=%BUILD_DIR%\jar
set SCRIPTS_OUTPUT_DIR=%BUILD_DIR%\scripts

echo ========================================
echo 开始构建项目
echo 构建类型: %BUILD_TYPE%
echo ========================================

REM 创建输出目录
if not exist "%APK_OUTPUT_DIR%" mkdir "%APK_OUTPUT_DIR%"
if not exist "%JAR_OUTPUT_DIR%" mkdir "%JAR_OUTPUT_DIR%"
if not exist "%SCRIPTS_OUTPUT_DIR%" mkdir "%SCRIPTS_OUTPUT_DIR%"

REM ==================== 构建Android APK ====================
echo.
echo [1/3] 构建Android APK...

cd /d "%PROJECT_ROOT%\android"

if not exist "gradlew.bat" (
    echo 错误: Gradle wrapper不存在
    exit /b 1
)

if "%BUILD_TYPE%"=="release" (
    call gradlew.bat clean assembleRelease
    for /r "app\build\outputs\apk\release" %%f in (*.apk) do set APK_FILE=%%f
) else (
    call gradlew.bat clean assembleDebug
    for /r "app\build\outputs\apk\debug" %%f in (*.apk) do set APK_FILE=%%f
)

if not exist "!APK_FILE!" (
    echo 错误: APK文件未找到
    exit /b 1
)

REM 复制APK到输出目录
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do set DATE=%%c%%a%%b
for /f "tokens=1-2 delims=: " %%a in ('time /t') do set TIME=%%a%%b
set TIME=!TIME: =0!
set APK_NAME=uchannel-%BUILD_TYPE%-!DATE!-!TIME!.apk
copy "!APK_FILE!" "%APK_OUTPUT_DIR%\!APK_NAME!" >nul

echo ✓ APK构建成功: %APK_OUTPUT_DIR%\!APK_NAME!

REM ==================== 构建后端JAR包 ====================
echo.
echo [2/3] 构建后端JAR包...

cd /d "%PROJECT_ROOT%\backend-java"

where mvn >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo 错误: Maven未安装，请先安装Maven
    exit /b 1
)

call mvn clean package -DskipTests

for /r target %%f in (*.jar) do (
    set "FILENAME=%%~nxf"
    if not "!FILENAME!"=="*-sources.jar" if not "!FILENAME!"=="*-javadoc.jar" (
        set JAR_FILE=%%f
        goto :jar_found
    )
)
:jar_found

if not exist "!JAR_FILE!" (
    echo 错误: JAR文件未找到
    exit /b 1
)

REM 复制JAR到输出目录
set JAR_NAME=push-notification-service-!DATE!-!TIME!.jar
copy "!JAR_FILE!" "%JAR_OUTPUT_DIR%\!JAR_NAME!" >nul
copy "!JAR_FILE!" "%JAR_OUTPUT_DIR%\push-notification-service-latest.jar" >nul

echo ✓ JAR构建成功: %JAR_OUTPUT_DIR%\!JAR_NAME!

REM ==================== 生成启动脚本 ====================
echo.
echo [3/3] 生成启动脚本...

REM 复制启动脚本到输出目录
copy "%PROJECT_ROOT%\scripts\start-backend.bat" "%SCRIPTS_OUTPUT_DIR%\" >nul

echo ✓ 启动脚本生成成功
echo   - Windows: %SCRIPTS_OUTPUT_DIR%\start-backend.bat

echo.
echo ========================================
echo 构建完成！
echo ========================================
echo.
echo 构建输出:
echo   APK: %APK_OUTPUT_DIR%\!APK_NAME!
echo   JAR: %JAR_OUTPUT_DIR%\!JAR_NAME!
echo   启动脚本: %SCRIPTS_OUTPUT_DIR%
echo.

endlocal

