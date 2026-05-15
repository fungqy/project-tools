from typing import List, Optional

from fastapi import APIRouter, Depends, Header, HTTPException
from pydantic import BaseModel

from api.auth import decode_access_token
from db.database import get_session
from db.models import ProjectConfig, ProjectReminderSettings

router = APIRouter(prefix="/api/projects", tags=["项目配置"])


class ProjectReminderSettingsCreate(BaseModel):
    need_story_remind: bool = False
    need_task_remind: bool = False
    need_sonar_scan_remind: bool = False
    need_report_data: bool = False
    # 各任务类型的自定义调度时间 (HH:MM格式)
    story_remind_time: Optional[str] = None
    task_remind_time: Optional[str] = None
    sonar_remind_time: Optional[str] = None
    report_data_time: Optional[str] = None


class ProjectConfigCreate(BaseModel):
    board_id: str
    board_name: str
    project_id: str
    project_name: str
    gitlab_group_key: str = ""
    sonar_key_prefix: str = ""
    sonar_scan_remind_default_person: str = ""
    robot_key: str = ""
    jira_user: str = ""
    jira_token: str = ""
    reminder_settings: Optional[ProjectReminderSettingsCreate] = None


class ProjectConfigUpdate(BaseModel):
    board_name: Optional[str] = None
    board_id: Optional[str] = None
    project_id: Optional[str] = None
    project_name: Optional[str] = None
    gitlab_group_key: Optional[str] = None
    sonar_key_prefix: Optional[str] = None
    sonar_scan_remind_default_person: Optional[str] = None
    robot_key: Optional[str] = None
    jira_user: Optional[str] = None
    jira_token: Optional[str] = None
    reminder_settings: Optional[ProjectReminderSettingsCreate] = None


class ProjectReminderSettingsResponse(BaseModel):
    id: int
    project_config_id: int
    need_story_remind: bool
    need_task_remind: bool
    need_sonar_scan_remind: bool
    need_report_data: bool
    story_remind_time: Optional[str] = None
    task_remind_time: Optional[str] = None
    sonar_remind_time: Optional[str] = None
    report_data_time: Optional[str] = None
    created_at: Optional[str] = None
    updated_at: Optional[str] = None


class ProjectConfigResponse(BaseModel):
    id: int
    board_id: str
    board_name: str
    project_id: str
    project_name: str
    gitlab_group_key: str
    sonar_key_prefix: str
    sonar_scan_remind_default_person: str
    robot_key: str
    jira_user: str
    need_story_remind: bool = False
    need_task_remind: bool = False
    need_sonar_scan_remind: bool = False
    need_report_data: bool = False
    story_remind_time: Optional[str] = None
    task_remind_time: Optional[str] = None
    sonar_remind_time: Optional[str] = None
    report_data_time: Optional[str] = None
    created_by: Optional[int] = None
    created_at: Optional[str] = None
    updated_at: Optional[str] = None
    updated_by: Optional[int] = None


def get_current_user_from_header(authorization: str = Header(None)):
    """从 Authorization header 获取当前用户"""
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="未提供认证信息")

    token = authorization.replace("Bearer ", "")
    payload = decode_access_token(token)
    if not payload:
        raise HTTPException(status_code=401, detail="Token已过期或无效")

    return payload


def check_admin_permission(current_user: dict):
    """检查是否为管理员"""
    if not current_user.get("is_admin"):
        raise HTTPException(status_code=403, detail="需要管理员权限")


@router.get("", response_model=List[ProjectConfigResponse])
async def list_projects(current_user: dict = Depends(get_current_user_from_header)):
    """获取项目列表"""
    session = get_session()
    try:
        user_id = int(current_user.get("sub"))  # type: ignore
        is_admin = current_user.get("is_admin", False)

        if is_admin:
            # 管理员可以查看所有项目
            projects = session.query(ProjectConfig).all()
        else:
            # 普通用户只能查看自己创建的项目
            projects = (
                session.query(ProjectConfig)
                .filter(ProjectConfig.created_by == user_id)
                .all()
            )

        return [p.to_dict(include_token=False) for p in projects]
    finally:
        session.close()


@router.get("/{project_id}", response_model=ProjectConfigResponse)
async def get_project(
    project_id: int, current_user: dict = Depends(get_current_user_from_header)
):
    """获取单个项目详情"""
    session = get_session()
    try:
        user_id = int(current_user.get("sub"))  # type: ignore
        is_admin = current_user.get("is_admin", False)

        project = (
            session.query(ProjectConfig).filter(ProjectConfig.id == project_id).first()
        )
        if not project:
            raise HTTPException(status_code=404, detail="项目不存在")

        # 检查权限：管理员可以查看所有，普通用户只能查看自己创建的
        if not is_admin and int(project.created_by or 0) != user_id:  # type: ignore
            raise HTTPException(status_code=403, detail="无权限访问此项目")

        return project.to_dict(include_token=True)
    finally:
        session.close()


@router.post("", response_model=ProjectConfigResponse)
async def create_project(
    config: ProjectConfigCreate,
    current_user: dict = Depends(get_current_user_from_header),
):
    """创建新项目配置"""
    session = get_session()
    try:
        user_id = int(current_user.get("sub"))  # type: ignore

        # 检查 board_id 是否已存在
        existing = (
            session.query(ProjectConfig)
            .filter(ProjectConfig.board_id == config.board_id)
            .first()
        )
        if existing:
            raise HTTPException(status_code=400, detail="Board ID 已存在")

        # 检查 project_id 是否已存在
        existing = (
            session.query(ProjectConfig)
            .filter(ProjectConfig.project_id == config.project_id)
            .first()
        )
        if existing:
            raise HTTPException(status_code=400, detail="Project ID 已存在")

        # 创建项目配置
        new_project = ProjectConfig(
            board_id=config.board_id,
            board_name=config.board_name,
            project_id=config.project_id,
            project_name=config.project_name,
            gitlab_group_key=config.gitlab_group_key,
            sonar_key_prefix=config.sonar_key_prefix,
            sonar_scan_remind_default_person=config.sonar_scan_remind_default_person,
            robot_key=config.robot_key,
            jira_user=config.jira_user,
            jira_token=config.jira_token,
            created_by=user_id,  # type: ignore
            updated_by=user_id,  # type: ignore
        )
        session.add(new_project)
        session.flush()  # 获取项目ID

        # 创建提醒设置
        if config.reminder_settings:
            rs = config.reminder_settings
            reminder_settings = ProjectReminderSettings(
                project_config_id=new_project.id,
                need_story_remind=rs.need_story_remind,
                need_task_remind=rs.need_task_remind,
                need_sonar_scan_remind=rs.need_sonar_scan_remind,
                need_report_data=rs.need_report_data,
                story_remind_time=getattr(rs, "story_remind_time", None),
                task_remind_time=getattr(rs, "task_remind_time", None),
                sonar_remind_time=getattr(rs, "sonar_remind_time", None),
                report_data_time=getattr(rs, "report_data_time", None),
            )
            session.add(reminder_settings)

        session.commit()
        session.refresh(new_project)

        return new_project.to_dict()
    finally:
        session.close()


@router.put("/{project_id}", response_model=ProjectConfigResponse)
async def update_project(
    project_id: int,
    config: ProjectConfigUpdate,
    current_user: dict = Depends(get_current_user_from_header),
):
    """更新项目配置"""
    session = get_session()
    try:
        user_id = int(current_user.get("sub"))  # type: ignore
        is_admin = current_user.get("is_admin", False)

        project = (
            session.query(ProjectConfig).filter(ProjectConfig.id == project_id).first()
        )
        if not project:
            raise HTTPException(status_code=404, detail="项目不存在")

        # 检查权限：管理员可以更新所有，普通用户只能更新自己创建的
        if not is_admin and int(project.created_by or 0) != user_id:  # type: ignore
            raise HTTPException(status_code=403, detail="无权限更新此项目")

        # 更新项目字段
        update_data = config.dict(exclude_unset=True)

        # 分离提醒设置和项目配置
        reminder_settings_data = update_data.pop("reminder_settings", None)

        # 将 reminder_settings_data 转换为 dict（如果是 Pydantic 模型）
        if reminder_settings_data is not None and hasattr(
            reminder_settings_data, "dict"
        ):
            reminder_settings_data = reminder_settings_data.dict(exclude_unset=True)

        for key, value in update_data.items():
            if key == "reminder_settings":
                continue
            if hasattr(project, key):
                setattr(project, key, value)

        # 更新提醒设置
        if reminder_settings_data is not None:
            existing_settings = (
                session.query(ProjectReminderSettings)
                .filter(ProjectReminderSettings.project_config_id == project_id)
                .first()
            )

            if existing_settings:
                for key, value in reminder_settings_data.items():
                    if hasattr(existing_settings, key):
                        setattr(existing_settings, key, value)
            elif reminder_settings_data:
                # 如果之前没有设置，创建新的
                new_settings = ProjectReminderSettings(
                    project_config_id=project_id,
                    **reminder_settings_data,
                )
                session.add(new_settings)

        project.updated_by = user_id  # type: ignore
        session.commit()
        session.refresh(project)

        return project.to_dict()
    finally:
        session.close()


@router.delete("/{project_id}")
async def delete_project(
    project_id: int, current_user: dict = Depends(get_current_user_from_header)
):
    """删除项目配置"""
    session = get_session()
    try:
        user_id = int(current_user.get("sub"))  # type: ignore
        is_admin = current_user.get("is_admin", False)

        project = (
            session.query(ProjectConfig).filter(ProjectConfig.id == project_id).first()
        )
        if not project:
            raise HTTPException(status_code=404, detail="项目不存在")

        # 检查权限：管理员可以删除所有，普通用户只能删除自己创建的
        if not is_admin and int(project.created_by or 0) != user_id:  # type: ignore
            raise HTTPException(status_code=403, detail="无权限删除此项目")

        session.delete(project)
        session.commit()

        return {"message": "项目已删除"}
    finally:
        session.close()
