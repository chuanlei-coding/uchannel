#!/bin/bash

# 构建 Rust 后端

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${PROJECT_ROOT}/build"
BACKEND_DIR="${PROJECT_ROOT}/backend-rust"

echo "构建 Rust 后端..."

cd "${BACKEND_DIR}"

# 检查 Cargo 是否存在
if ! command -v cargo &> /dev/null; then
    echo "错误: Cargo 未安装，请先安装 Rust"
    exit 1
fi

# 构建发布版本
cargo build --release

BINARY_FILE="${BACKEND_DIR}/target/release/uchannel-backend"

if [ ! -f "$BINARY_FILE" ]; then
    echo "错误: 二进制文件未找到"
    exit 1
fi

# 创建输出目录
mkdir -p "${BUILD_DIR}/bin"

# 复制二进制文件到输出目录
cp "$BINARY_FILE" "${BUILD_DIR}/bin/uchannel-backend"

echo "✓ 构建成功: ${BUILD_DIR}/bin/uchannel-backend"
