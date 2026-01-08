#!/bin/bash

# 生成自签名SSL证书脚本（用于开发环境）

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
KEYSTORE_DIR="${PROJECT_ROOT}/backend-java/src/main/resources"
KEYSTORE_FILE="${KEYSTORE_DIR}/keystore.p12"
KEYSTORE_PASSWORD="changeit"
KEY_ALIAS="uchannel"

echo "生成SSL证书..."
echo "=========================================="

# 检查keytool是否可用
if ! command -v keytool &> /dev/null; then
    echo "错误: keytool未找到，请确保已安装JDK"
    exit 1
fi

# 如果证书已存在，询问是否覆盖
if [ -f "$KEYSTORE_FILE" ]; then
    echo "警告: 证书文件已存在: $KEYSTORE_FILE"
    read -p "是否覆盖? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "取消操作"
        exit 0
    fi
    rm -f "$KEYSTORE_FILE"
fi

# 生成自签名证书
keytool -genkeypair \
    -alias "$KEY_ALIAS" \
    -keyalg RSA \
    -keysize 2048 \
    -storetype PKCS12 \
    -keystore "$KEYSTORE_FILE" \
    -validity 365 \
    -storepass "$KEYSTORE_PASSWORD" \
    -keypass "$KEYSTORE_PASSWORD" \
    -dname "CN=localhost, OU=Development, O=UChannel, L=City, ST=State, C=CN" \
    -ext "SAN=IP:127.0.0.1,IP:10.0.2.2,DNS:localhost"

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ SSL证书生成成功！"
    echo "证书位置: $KEYSTORE_FILE"
    echo "密码: $KEYSTORE_PASSWORD"
    echo "别名: $KEY_ALIAS"
    echo ""
    echo "证书信息:"
    keytool -list -v -keystore "$KEYSTORE_FILE" -storepass "$KEYSTORE_PASSWORD" | grep -E "(别名|有效期|CN)"
    echo ""
    echo "注意: 这是自签名证书，仅用于开发环境"
    echo "生产环境请使用CA签发的证书"
else
    echo "错误: 证书生成失败"
    exit 1
fi
