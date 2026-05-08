"""调度器路由"""

from fastapi import APIRouter, HTTPException

from api.scheduler import get_scheduler, get_today_tasks_status

router = APIRouter(prefix="/api/scheduler", tags=["调度器"])


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
    valid_types = ["story_reminder", "task_reminder", "sonar_reminder", "report_data"]
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
