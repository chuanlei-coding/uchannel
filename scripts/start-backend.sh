#!/bin/bash

# 后端服务启动脚本
# 使用方法: ./scripts/start-backend.sh [port]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
BACKEND_DIR="${PROJECT_ROOT}/backend-rust"
BUILD_DIR="${PROJECT_ROOT}/build/bin"
SERVER_PORT="${1:-8080}"

# 查找二进制文件
if [ -f "${BUILD_DIR}/uchannel-backend" ]; then
    BINARY="${BUILD_DIR}/uchannel-backend"
elif [ -f "${BACKEND_DIR}/target/release/uchannel-backend" ]; then
    BINARY="${BACKEND_DIR}/target/release/uchannel-backend"
elif [ -f "${BACKEND_DIR}/target/debug/uchannel-backend" ]; then
    BINARY="${BACKEND_DIR}/target/debug/uchannel-backend"
else
    echo "错误: 二进制文件未找到"
    echo "请先运行构建脚本: ./scripts/build-backend.sh"
    exit 1
fi

echo "=========================================="
echo "启动 UChannel 后端服务"
echo "=========================================="
echo "二进制文件: $BINARY"
echo "端口: $SERVER_PORT"
echo "=========================================="
echo ""

# 设置环境变量并启动
cd "${BACKEND_DIR}"
SERVER_PORT=$SERVER_PORT $BINARY
