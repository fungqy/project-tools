#!/bin/bash

# 项目工具服务启动脚本

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# 设置工作目录
cd "$PROJECT_ROOT"

# 默认配置
HOST=${HOST:-"0.0.0.0"}
PORT=${PORT:-"8000"}
LOG_FILE=${LOG_FILE:-"$PROJECT_ROOT/logs/app.log"}

# 创建日志目录
mkdir -p "$PROJECT_ROOT/logs"

# 启动服务
echo "Starting project-tools service on $HOST:$PORT ..."
exec uvicorn src.api.main:app --host "$HOST" --port "$PORT" --log-config "$PROJECT_ROOT/logging.conf"
