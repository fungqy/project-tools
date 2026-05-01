from datetime import datetime

from sqlalchemy import (
    BigInteger,
    Boolean,
    Column,
    DateTime,
    ForeignKey,
    String,
)
from sqlalchemy.orm import declarative_base, relationship

Base = declarative_base()


class User(Base):
    """用户模型"""

    __tablename__ = "users"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    username = Column(String(50), unique=True, nullable=False)
    password = Column(String(255), nullable=False)
    is_admin = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.now)
    updated_at = Column(DateTime, default=datetime.now, onupdate=datetime.now)

    # 关联：用户的JIRA认证配置
    jira_auth_config = relationship(
        "JiraAuthConfig",
        back_populates="user",
        uselist=False,
        cascade="all, delete-orphan",
    )
    # 关联：用户创建的项目
    created_projects = relationship(
        "ProjectConfig",
        back_populates="creator",
        foreign_keys="ProjectConfig.created_by",
    )

    def to_dict(self, include_password=False):
        data = {
            "id": self.id,
            "username": self.username,
            "is_admin": self.is_admin,
            "created_at": self.created_at.isoformat()
            if self.created_at is not None
            else None,
            "updated_at": self.updated_at.isoformat()
            if self.updated_at is not None
            else None,
        }
        if include_password:
            data["password"] = self.password
        return data


class JiraAuthConfig(Base):
    """JIRA认证配置模型"""

    __tablename__ = "jira_auth_configs"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    user_id = Column(
        BigInteger,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        unique=True,
    )
    jira_url = Column(
        String(255), nullable=False, default="http://rdm.zvos.zoomlion.com"
    )
    jira_user = Column(String(100), nullable=False)
    jira_token = Column(String(255), nullable=False)
    created_at = Column(DateTime, default=datetime.now)
    updated_at = Column(DateTime, default=datetime.now, onupdate=datetime.now)

    # 关联：所属用户
    user = relationship("User", back_populates="jira_auth_config")
    # 关联：使用此配置的项目
    projects = relationship("ProjectConfig", back_populates="jira_auth_config")

    def to_dict(self, include_token=False):
        data = {
            "id": self.id,
            "user_id": self.user_id,
            "jira_url": self.jira_url,
            "jira_user": self.jira_user,
            "created_at": self.created_at.isoformat()
            if self.created_at is not None
            else None,
            "updated_at": self.updated_at.isoformat()
            if self.updated_at is not None
            else None,
        }
        if include_token:
            data["jira_token"] = self.jira_token
        return data


class ProjectConfig(Base):
    """项目配置模型"""

    __tablename__ = "project_configs"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    board_id = Column(String(50), nullable=False, unique=True)
    board_name = Column(String(255), nullable=False)
    project_id = Column(String(50), nullable=False, unique=True)
    project_name = Column(String(255), nullable=False)
    gitlab_group_key = Column(String(100), default="")
    sonar_key_prefix = Column(String(100), default="")
    sonar_scan_remind_default_person = Column(String(100), default="")
    robot_key = Column(String(100), default="")
    jira_auth_config_id = Column(
        BigInteger, ForeignKey("jira_auth_configs.id", ondelete="SET NULL")
    )
    created_by = Column(BigInteger, ForeignKey("users.id"))
    created_at = Column(DateTime, default=datetime.now)
    updated_at = Column(DateTime, default=datetime.now, onupdate=datetime.now)
    updated_by = Column(BigInteger, ForeignKey("users.id"))

    # 关联：JIRA认证配置
    jira_auth_config = relationship("JiraAuthConfig", back_populates="projects")
    # 关联：创建者
    creator = relationship(
        "User", back_populates="created_projects", foreign_keys=[created_by]
    )
    # 关联：提醒设置
    reminder_settings = relationship(
        "ProjectReminderSettings",
        back_populates="project_config",
        uselist=False,
        cascade="all, delete-orphan",
    )

    def to_dict(self, include_token=False):
        data = {
            "id": self.id,
            "board_id": self.board_id,
            "board_name": self.board_name,
            "project_id": self.project_id,
            "project_name": self.project_name,
            "gitlab_group_key": self.gitlab_group_key,
            "sonar_key_prefix": self.sonar_key_prefix,
            "sonar_scan_remind_default_person": self.sonar_scan_remind_default_person,
            "robot_key": self.robot_key,
            "jira_auth_config_id": self.jira_auth_config_id,
            "created_by": self.created_by,
            "created_at": self.created_at.isoformat()
            if self.created_at is not None
            else None,
            "updated_at": self.updated_at.isoformat()
            if self.updated_at is not None
            else None,
            "updated_by": self.updated_by,
        }
        # 如果需要包含JIRA认证详情
        if self.jira_auth_config is not None:
            auth_data = self.jira_auth_config.to_dict(include_token=include_token)
            data["jira_url"] = auth_data["jira_url"]
            data["jira_user"] = auth_data["jira_user"]
            if include_token:
                data["jira_token"] = auth_data.get("jira_token")
        # 如果包含提醒设置
        if self.reminder_settings is not None:
            reminder_data = self.reminder_settings.to_dict()
            data["need_story_remind"] = reminder_data["need_story_remind"]
            data["need_task_remind"] = reminder_data["need_task_remind"]
            data["need_sonar_scan_remind"] = reminder_data["need_sonar_scan_remind"]
            data["need_report_data"] = reminder_data["need_report_data"]
        return data


class ProjectReminderSettings(Base):
    """项目提醒设置模型"""

    __tablename__ = "project_reminder_settings"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    project_config_id = Column(
        BigInteger,
        ForeignKey("project_configs.id", ondelete="CASCADE"),
        nullable=False,
        unique=True,
    )
    need_story_remind = Column(Boolean, default=False)  # 是否需要故事提醒
    need_task_remind = Column(Boolean, default=False)  # 是否需要子任务到期提醒
    need_sonar_scan_remind = Column(Boolean, default=False)  # 是否需要Sonar扫描提醒
    need_report_data = Column(Boolean, default=False)  # 是否需要生产RDM报表数据
    created_at = Column(DateTime, default=datetime.now)
    updated_at = Column(DateTime, default=datetime.now, onupdate=datetime.now)

    # 关联：所属项目
    project_config = relationship("ProjectConfig", back_populates="reminder_settings")

    def to_dict(self):
        return {
            "id": self.id,
            "project_config_id": self.project_config_id,
            "need_story_remind": self.need_story_remind,
            "need_task_remind": self.need_task_remind,
            "need_sonar_scan_remind": self.need_sonar_scan_remind,
            "need_report_data": self.need_report_data,
            "created_at": self.created_at.isoformat()
            if self.created_at is not None
            else None,
            "updated_at": self.updated_at.isoformat()
            if self.updated_at is not None
            else None,
        }
