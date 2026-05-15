import sys
from pathlib import Path

# 添加项目根目录到 Python 路径
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from api.routes import auth, projects, reports
from api.routes import scheduler as scheduler_routes
from api.scheduler import TaskScheduler

# 全局调度器实例
scheduler = TaskScheduler()


@asynccontextmanager
async def lifespan(app: FastAPI):
    """应用生命周期管理"""
    # 启动时创建管理员账号
    from db.database import create_admin_user

    create_admin_user()

    scheduler.start()
    yield
    scheduler.stop()


app = FastAPI(
    title="项目工具服务",
    description="定时任务调度与项目管理工具API",
    version="1.0.0",
    lifespan=lifespan,
)

# CORS配置
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 注册路由
app.include_router(auth.router)
app.include_router(projects.router)
app.include_router(scheduler_routes.router)
app.include_router(reports.router)


@app.get("/", tags=["健康检查"])
async def root():
    """服务健康检查"""
    return {"status": "ok", "service": "project-tools", "version": "1.0.0"}


@app.get("/health", tags=["健康检查"])
async def health():
    """服务健康状态"""
    return {"status": "healthy"}


@app.get("/api/jobs", tags=["调度任务"])
async def get_jobs():
    """获取所有定时任务状态"""
    return {"total": len(scheduler.get_jobs()), "jobs": scheduler.get_jobs()}


@app.post("/api/jobs/{job_id}/trigger", tags=["调度任务"])
async def trigger_job(job_id: str):
    """手动触发指定任务"""
    result = scheduler.run_job_now(job_id)
    from fastapi import HTTPException

    if result["status"] == "error":
        raise HTTPException(status_code=404, detail=result["message"])
    return result


@app.post("/api/jobs/story-reminder/trigger", tags=["调度任务"])
async def trigger_story_reminder():
    """手动触发故事提醒任务"""
    return scheduler.run_job_now("story_reminder")


@app.post("/api/jobs/task-reminder/trigger", tags=["调度任务"])
async def trigger_task_reminder():
    """手动触发任务提醒任务"""
    return scheduler.run_job_now("task_reminder")


@app.post("/api/jobs/sonar-reminder/trigger", tags=["调度任务"])
async def trigger_sonar_reminder():
    """手动触发Sonar扫描提醒任务"""
    return scheduler.run_job_now("sonar_reminder")


@app.post("/api/jobs/report-data/trigger", tags=["调度任务"])
async def trigger_report_data():
    """手动触发报表数据生成任务"""
    return scheduler.run_job_now("report_data")
