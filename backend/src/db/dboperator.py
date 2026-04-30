import os

import pymysql
from dotenv import load_dotenv
from sqlalchemy import create_engine

# 加载环境变量
load_dotenv()


def get_db_config():
    """获取数据库配置"""
    return {
        "host": os.getenv("DB_HOST"),
        "port": int(os.getenv("DB_PORT", 3306)),
        "user": os.getenv("DB_USER"),
        "password": os.getenv("DB_PASSWORD"),
        "database": os.getenv("DB_NAME"),
    }


class DbOperator:
    """数据库操作类"""

    @staticmethod
    def get_connection():
        """获取数据库连接"""
        _connection = None
        try:
            config = get_db_config()
            _connection = pymysql.connect(**config)
        except pymysql.err.Error as e:
            print(f"      The error '{e}' occurred")
        return _connection

    @staticmethod
    def truncate_table(table_name):
        """清空表数据"""
        connection = DbOperator.get_connection()
        if connection is None:
            return
        cursor = connection.cursor()
        try:
            cursor.execute(f"truncate table {table_name};")
            connection.commit()
        except Exception as e:
            print(f"Failed to truncate table: {e}")
        finally:
            cursor.close()
            connection.close()

    @staticmethod
    def exec_sql(sql_query):
        """执行SQL语句"""
        connection = DbOperator.get_connection()
        if connection is None:
            return
        cursor = connection.cursor()
        try:
            cursor.execute(sql_query)
            connection.commit()
        except Exception as e:
            print(f"Failed to exec sql: {e}")
        finally:
            cursor.close()
            connection.close()

    @staticmethod
    def get_engine():
        # 创建数据库引擎
        config = get_db_config()
        return create_engine(
            f"mysql+pymysql://{config['user']}:{config['password']}@{config['host']}:{config['port']}/{config['database']}"
        )
