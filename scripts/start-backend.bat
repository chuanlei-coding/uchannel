@echo off
REM 后端服务启动脚本 (Windows)
REM 使用方法: scripts\start-backend.bat [port]

setlocal

set SCRIPT_DIR=%~dp0
set PROJECT_ROOT=%SCRIPT_DIR%..
set JAR_DIR=%PROJECT_ROOT%\build\jar
set JAR_FILE=%JAR_DIR%\push-notification-service-latest.jar
set SERVER_PORT=%1
if "%SERVER_PORT%"=="" set SERVER_PORT=8080

REM 如果build目录下没有JAR，尝试从target目录找
if not exist "%JAR_FILE%" (
    for /r "%PROJECT_ROOT%\backend-java\target" %%f in (*.jar) do (
        if not "%%~nxf"=="*-sources.jar" if not "%%~nxf"=="*-javadoc.jar" (
            set JAR_FILE=%%f
            echo 使用target目录中的JAR: %%f
            goto :found
        )
    )
    echo 错误: JAR文件未找到
    echo 请先运行构建脚本: scripts\build.bat
    exit /b 1
)
:found

REM 检查Java是否安装
where java >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo 错误: Java未安装，请先安装JDK 17或更高版本
    exit /b 1
)

REM 启动参数
set JAVA_OPTS=-Xms512m -Xmx1024m -Dspring.profiles.active=prod

REM 检查Firebase配置文件
set FIREBASE_CONFIG=%PROJECT_ROOT%\backend-java\src\main\resources\serviceAccountKey.json
if not exist "%FIREBASE_CONFIG%" (
    echo 警告: Firebase配置文件未找到: %FIREBASE_CONFIG%
    echo 请确保已配置Firebase服务账号密钥
)

echo ==========================================
echo 启动推送通知服务
echo ==========================================
echo JAR文件: %JAR_FILE%
echo 端口: %SERVER_PORT%
echo Java选项: %JAVA_OPTS%
echo ==========================================
echo.

java %JAVA_OPTS% -jar "%JAR_FILE%" --server.port=%SERVER_PORT%

