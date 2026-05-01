"""调度器配置路由"""

from datetime import datetime
from typing import Optional

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from db.database import get_session
from db.models import SchedulerConfig

router = APIRouter(prefix="/scheduler", tags=["调度器配置"])


class SchedulerConfigCreate(BaseModel):
    """创建调度配置请求"""

    task_type: str
    enabled: bool = True
    day_of_week: str = "mon-fri"
    default_time: str = "08:30"


class SchedulerConfigUpdate(BaseModel):
    """更新调度配置请求"""

    enabled: Optional[bool] = None
    day_of_week: Optional[str] = None
    default_time: Optional[str] = None


class SchedulerConfigResponse(BaseModel):
    """调度配置响应"""

    id: int
    task_type: str
    enabled: bool
    day_of_week: str
    default_time: str
    created_at: Optional[str] = None
    updated_at: Optional[str] = None


def config_to_response(config: SchedulerConfig) -> SchedulerConfigResponse:
    """将模型转换为响应"""
    return SchedulerConfigResponse(
        id=getattr(config, "id"),
        task_type=getattr(config, "task_type"),
        enabled=getattr(config, "enabled"),
        day_of_week=getattr(config, "day_of_week"),
        default_time=getattr(config, "default_time"),
        created_at=config.created_at.isoformat()
        if config.created_at is not None
        else None,
        updated_at=config.updated_at.isoformat()
        if config.updated_at is not None
        else None,
    )


@router.get("/configs", response_model=list[SchedulerConfigResponse])
def get_all_configs():
    """获取所有调度配置"""
    session = get_session()
    try:
        configs = session.query(SchedulerConfig).all()
        return [config_to_response(c) for c in configs]
    finally:
        session.close()


@router.get("/configs/{task_type}", response_model=SchedulerConfigResponse)
def get_config(task_type: str):
    """获取指定任务类型的调度配置"""
    session = get_session()
    try:
        config = (
            session.query(SchedulerConfig)
            .filter(SchedulerConfig.task_type == task_type)
            .first()
        )
        if not config:
            raise HTTPException(status_code=404, detail=f"未找到任务类型: {task_type}")
        return config_to_response(config)
    finally:
        session.close()


@router.put("/configs/{task_type}", response_model=SchedulerConfigResponse)
def update_config(task_type: str, update: SchedulerConfigUpdate):
    """更新指定任务类型的调度配置"""
    from api.scheduler import get_scheduler

    session = get_session()
    try:
        config = (
            session.query(SchedulerConfig)
            .filter(SchedulerConfig.task_type == task_type)
            .first()
        )
        if not config:
            raise HTTPException(status_code=404, detail=f"未找到任务类型: {task_type}")

        # 更新字段
        if update.enabled is not None:
            setattr(config, "enabled", update.enabled)
        if update.day_of_week is not None:
            setattr(config, "day_of_week", update.day_of_week)
        if update.default_time is not None:
            setattr(config, "default_time", update.default_time)

        setattr(config, "updated_at", datetime.now())
        session.commit()
        session.refresh(config)

        # 重新加载调度器任务
        scheduler = get_scheduler()
        scheduler.reload_jobs()

        return config_to_response(config)
    finally:
        session.close()


@router.post("/configs/{task_type}/reload")
def reload_scheduler(task_type: str):
    """重新加载指定任务的调度"""
    from api.scheduler import get_scheduler

    valid_types = ["story_reminder", "task_reminder", "sonar_reminder", "report_data"]
    if task_type not in valid_types:
        raise HTTPException(
            status_code=400, detail=f"无效的任务类型，可选值: {valid_types}"
        )

    scheduler = get_scheduler()
    scheduler.reload_jobs()
    return {"status": "success", "message": "调度器已重新加载"}


@router.get("/jobs", response_model=list)
def get_jobs():
    """获取调度器当前所有任务状态"""
    from api.scheduler import get_scheduler

    scheduler = get_scheduler()
    return scheduler.get_jobs()


@router.post("/jobs/{job_id}/run")
def run_job_now(job_id: str):
    """手动触发指定任务"""
    from api.scheduler import get_scheduler

    scheduler = get_scheduler()
    return scheduler.run_job_now(job_id)
