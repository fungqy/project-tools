import os
from typing import Optional

from dotenv import load_dotenv
from passlib.context import CryptContext
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

load_dotenv()

# 密码加密上下文
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


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
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password: str) -> str:
    """获取密码哈希"""
    return pwd_context.hash(password)


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


def get_default_jira_auth():
    """获取默认JIRA认证配置"""
    from db.models import JiraAuthConfig

    session = get_session()
    try:
        config = (
            session.query(JiraAuthConfig)
            .filter(JiraAuthConfig.is_default == True)
            .first()
        )

        if config:
            from util.jira import AuthConfig, set_default_auth

            set_default_auth(config.jira_user, config.jira_token, config.jira_url)
            return config
        return None
    finally:
        session.close()


def init_jira_auth_config():
    """初始化JIRA认证配置（如果不存在默认配置）"""
    from db.models import JiraAuthConfig

    session = get_session()
    try:
        # 检查是否已有默认配置
        existing = (
            session.query(JiraAuthConfig)
            .filter(JiraAuthConfig.is_default == True)
            .first()
        )

        if not existing:
            # 创建默认配置
            default_config = JiraAuthConfig(
                config_name="默认配置",
                jira_url="http://rdm.zvos.zoomlion.com",
                jira_user="00773908",
                jira_token="Nx.0918@ZLZK123",
                is_default=True,
            )
            session.add(default_config)
            session.commit()
            print("默认JIRA认证配置已创建")

            # 设置为默认认证
            set_default_auth(
                "00773908", "Nx.0918@ZLZK123", "http://rdm.zvos.zoomlion.com"
            )
        else:
            # 设置已有配置为默认认证
            from util.jira import set_default_auth

            set_default_auth(existing.jira_user, existing.jira_token, existing.jira_url)
            print("JIRA认证配置已加载")
    except ImportError:
        # util.jira 可能还没加载，忽略
        pass
    finally:
        session.close()
