"""调度器路由"""

from datetime import datetime
from typing import Optional

from fastapi import APIRouter, Depends, Header, HTTPException, Query
from pydantic import BaseModel
from sqlalchemy import and_, desc, func

from api.routes.auth import get_current_user_from_header
from api.scheduler import get_scheduler, get_today_tasks_status
from db.database import get_session
from db.models import ProjectConfig, TaskExecutionLog

router = APIRouter(prefix="/api/scheduler", tags=["调度器"])


class ManualExecuteRequest(BaseModel):
    project_config_id: int


class ManualReportDataRequest(BaseModel):
    project_config_id: int
    sprint_id: str


@router.get("/jobs", response_model=list)
def get_jobs():
    """获取调度器当前所有任务状态"""
    scheduler = get_scheduler()
    return scheduler.get_jobs()


@router.get("/today-tasks")
def get_today_tasks():
    """获取今日任务状态"""
    return get_today_tasks_status()


@router.post("/jobs/{job_id}/run")
def run_job_now(job_id: str):
    """手动触发指定任务"""
    valid_types = ["story_reminder", "task_reminder", "sonar_reminder"]
    if job_id not in valid_types:
        raise HTTPException(
            status_code=400, detail=f"无效的任务类型，可选值: {valid_types}"
        )
    scheduler = get_scheduler()
    return scheduler.run_job_now(job_id)


@router.post("/jobs/reload")
def reload_jobs():
    """重新加载所有调度任务"""
    scheduler = get_scheduler()
    scheduler.reload_jobs()
    return {"status": "success", "message": "调度任务已重新加载"}


@router.get("/logs")
def get_execution_logs(
    page: int = Query(1, ge=1),
    page_size: int = Query(10, ge=1, le=100),
    project_name: Optional[str] = Query(None),
    executed_date: Optional[str] = Query(None),
    task_type: Optional[str] = Query(None),
    current_user: dict = Depends(get_current_user_from_header),
):
    session = get_session()
    try:
        query = session.query(TaskExecutionLog, ProjectConfig.project_name).join(
            ProjectConfig,
            TaskExecutionLog.project_config_id == ProjectConfig.id,
        )

        if executed_date:
            try:
                target_date = datetime.strptime(executed_date, "%Y-%m-%d")
            except ValueError:
                target_date = datetime.now()
        else:
            target_date = datetime.now()

        day_start = target_date.replace(hour=0, minute=0, second=0, microsecond=0)
        day_end = target_date.replace(
            hour=23, minute=59, second=59, microsecond=999999
        )
        query = query.filter(
            and_(
                TaskExecutionLog.executed_at >= day_start,
                TaskExecutionLog.executed_at <= day_end,
            )
        )

        if project_name:
            query = query.filter(
                ProjectConfig.project_name.like(f"%{project_name}%")
            )

        if task_type:
            query = query.filter(TaskExecutionLog.task_type == task_type)

        total = query.count()
        results = (
            query.order_by(desc(TaskExecutionLog.executed_at))
            .offset((page - 1) * page_size)
            .limit(page_size)
            .all()
        )

        items = []
        for log, proj_name in results:
            items.append(
                {
                    "id": log.id,
                    "project_name": proj_name,
                    "task_type": log.task_type,
                    "executed_at": log.executed_at.isoformat()
                    if log.executed_at
                    else None,
                    "scheduled_time": log.scheduled_time.isoformat()
                    if log.scheduled_time
                    else None,
                    "status": log.status,
                    "error_message": log.error_message,
                    "task_exec_type": log.task_exec_type,
                }
            )

        return {"total": total, "page": page, "page_size": page_size, "items": items}
    finally:
        session.close()


@router.post("/manual/story-reminder")
def manual_story_reminder(req: ManualExecuteRequest):
    from api.scheduler import get_project_config_by_id, manual_run_story_task

    config = get_project_config_by_id(req.project_config_id)
    if not config:
        raise HTTPException(status_code=404, detail="项目配置不存在")

    now = datetime.now()
    manual_run_story_task(config, now)
    return {"status": "success", "message": f"项目 {config.project_name} 故事提醒已执行"}


@router.post("/manual/task-reminder")
def manual_task_reminder(req: ManualExecuteRequest):
    from api.scheduler import get_project_config_by_id, manual_run_task_reminder

    config = get_project_config_by_id(req.project_config_id)
    if not config:
        raise HTTPException(status_code=404, detail="项目配置不存在")

    now = datetime.now()
    manual_run_task_reminder(config, now)
    return {"status": "success", "message": f"项目 {config.project_name} 任务提醒已执行"}


@router.post("/manual/sonar-reminder")
def manual_sonar_reminder(req: ManualExecuteRequest):
    from api.scheduler import get_project_config_by_id, manual_run_sonar_scan_reminder

    config = get_project_config_by_id(req.project_config_id)
    if not config:
        raise HTTPException(status_code=404, detail="项目配置不存在")

    now = datetime.now()
    manual_run_sonar_scan_reminder(config, now)
    return {
        "status": "success",
        "message": f"项目 {config.project_name} Sonar提醒已执行",
    }


@router.get("/manual/report-data/check/{project_config_id}/{sprint_id}")
def check_report_data_exists(project_config_id: int, sprint_id: str):
    from api.scheduler import check_sprint_data_exists

    exists = check_sprint_data_exists(sprint_id)
    return {"exists": exists}


@router.post("/manual/report-data")
def manual_report_data(req: ManualReportDataRequest):
    from api.scheduler import get_project_config_by_id
    from task.report_rdm_data import process_sprint
    from util.jira import JiraSprint

    config = get_project_config_by_id(req.project_config_id)
    if not config:
        raise HTTPException(status_code=404, detail="项目配置不存在")

    sprint = JiraSprint.from_jira_id(req.sprint_id)
    process_sprint(sprint)
    return {
        "status": "success",
        "message": f"项目 {config.project_name} 报表数据已执行",
    }