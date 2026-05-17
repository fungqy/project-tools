#!/bin/bash

# 项目工具服务启动脚本

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# 设置工作目录
cd "$PROJECT_ROOT"

# 加载 .env 文件（如果存在）
if [ -f "$PROJECT_ROOT/.env" ]; then
    set -a
    source "$PROJECT_ROOT/.env"
    set +a
fi

# 检查必需的数据库配置
check_db_config() {
    local missing_vars=()

    if [ -z "$DB_HOST" ]; then
        missing_vars+=("DB_HOST")
    fi
    if [ -z "$DB_USER" ]; then
        missing_vars+=("DB_USER")
    fi
    if [ -z "$DB_PASSWORD" ]; then
        missing_vars+=("DB_PASSWORD")
    fi
    if [ -z "$DB_NAME" ]; then
        missing_vars+=("DB_NAME")
    fi

    if [ ${#missing_vars[@]} -gt 0 ]; then
        echo "❌ 启动失败: 数据库配置不完整"
        echo ""
        echo "缺少以下环境变量: ${missing_vars[*]}"
        echo ""
        echo "请在 backend/.env 文件中配置以下环境变量:"
        echo "  DB_HOST=数据库主机地址"
        echo "  DB_PORT=数据库端口(默认3306)"
        echo "  DB_USER=数据库用户名"
        echo "  DB_PASSWORD=数据库密码"
        echo "  DB_NAME=数据库名称"
        echo ""
        echo "示例 .env 文件内容:"
        echo "  DB_HOST=localhost"
        echo "  DB_PORT=3306"
        echo "  DB_USER=your_user"
        echo "  DB_PASSWORD=your_password"
        echo "  DB_NAME=your_database"
        exit 1
    fi
}

# 执行配置检查
check_db_config

# 默认配置
HOST=${HOST:-"0.0.0.0"}
PORT=${PORT:-"8000"}
LOG_FILE=${LOG_FILE:-"$PROJECT_ROOT/logs/app.log"}

# 创建日志目录
mkdir -p "$PROJECT_ROOT/logs"

# 启动服务
echo "Starting project-tools service on $HOST:$PORT ..."
exec uvicorn src.api.main:app --host "$HOST" --port "$PORT" --log-config "$PROJECT_ROOT/logging.conf"
