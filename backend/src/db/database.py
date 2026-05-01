import os

import bcrypt
from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

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


def get_engine():
    """创建数据库引擎"""
    config = get_db_config()
    return create_engine(
        f"mysql+pymysql://{config['user']}:{config['password']}@{config['host']}:{config['port']}/{config['database']}"
    )


# 全局 Session 工厂
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=get_engine())


def get_session():
    """获取数据库会话"""
    return SessionLocal()


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """验证密码"""
    return bcrypt.checkpw(
        plain_password.encode("utf-8"), hashed_password.encode("utf-8")
    )


def get_password_hash(password: str) -> str:
    """获取密码哈希"""
    return bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")


def init_database():
    """初始化数据库表结构"""
    from db.models import Base

    engine = get_engine()
    Base.metadata.create_all(engine)


def create_admin_user():
    """创建管理员用户（如果不存在）"""
    from db.models import User

    session = get_session()
    try:
        admin = session.query(User).filter(User.username == "admin").first()
        if not admin:
            # 只有用户不存在时才创建
            admin = User(
                username="admin", password=get_password_hash("admin123"), is_admin=True
            )
            session.add(admin)
            session.commit()
            print("管理员账号已创建: admin / admin123")
        else:
            print("管理员账号已存在")
    finally:
        session.close()
