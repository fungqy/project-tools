import logging
import sys
from datetime import datetime
from pathlib import Path

# 添加项目根目录到 Python 路径
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.cron import CronTrigger

from util.dateattr import DateAttr
from util.jira import AuthConfig, ProjectRemindConfig, set_default_auth
from util.qywx import post

# 配置日志
logger = logging.getLogger(__name__)


def get_user_jira_auth(user_id: int):
    """获取用户的JIRA认证配置"""
    from db.database import get_session
    from db.models import JiraAuthConfig

    session = get_session()
    try:
        config = (
            session.query(JiraAuthConfig)
            .filter(JiraAuthConfig.user_id == user_id)
            .first()
        )

        if config:
            return AuthConfig(
                user=config.jira_user, token=config.jira_token, url=config.jira_url
            )
        return None
    finally:
        session.close()


def get_project_configs():
    """从数据库获取项目配置"""
    from db.database import get_session
    from db.models import ProjectConfig

    session = get_session()
    try:
        configs = (
            session.query(ProjectConfig)
            .filter(ProjectConfig.need_progress_remind == True)
            .all()
        )

        result = []
        for config in configs:
            # 获取项目创建者的JIRA认证
            auth_config = None
            if config.created_by:
                auth_config = get_user_jira_auth(config.created_by)

            # 构建 ProjectRemindConfig 对象
            result.append(
                ProjectRemindConfig(
                    board_id=config.board_id,
                    board_name=config.board_name,
                    project_id=config.project_id,
                    project_name=config.project_name,
                    gitlab_group_key=config.gitlab_group_key or "",
                    need_progress_remind=config.need_progress_remind,
                    need_sonar_scan_remind=config.need_sonar_scan_remind,
                    need_report_data=config.need_report_data,
                    sonar_key_prefix=config.sonar_key_prefix or "",
                    sonar_scan_remind_default_person=config.sonar_scan_remind_default_person
                    or "",
                    robot_key=config.robot_key or "",
                    jira_user=auth_config.user if auth_config else "",
                    jira_token=auth_config.token if auth_config else "",
                )
            )
        return result
    finally:
        session.close()


def module_run(module, remind_config: ProjectRemindConfig):
    """统一处理消息生成与发送逻辑"""
    # 设置当前使用的JIRA认证
    if remind_config.jira_user and remind_config.jira_token:
        set_default_auth(remind_config.jira_user, remind_config.jira_token)

    message_list = module.gene_message(remind_config)
    if not message_list:
        return
    for message in message_list:
        if message:
            logger.info(f"[{remind_config.project_name}] {message}")
            post(remind_config.robot_key, message)


def run_story_task(remind_config: ProjectRemindConfig):
    """执行故事提醒任务"""
    from task.remind_week_story import remind_week_story

    dateattr = DateAttr()
    if not dateattr.is_workday:
        logger.info(f"[{remind_config.project_name}] 非工作日，跳过故事提醒")
        return
    logger.info(f"[{remind_config.project_name}] 执行本周待完成故事提醒...")
    module_run(remind_week_story, remind_config)


def run_task_reminder(remind_config: ProjectRemindConfig):
    """执行子任务到期提醒"""
    from task.remind_expire_task import remind_expire_task

    dateattr = DateAttr()
    if not dateattr.is_workday:
        logger.info(f"[{remind_config.project_name}] 非工作日，跳过任务提醒")
        return
    logger.info(f"[{remind_config.project_name}] 执行子任务到期提醒...")
    module_run(remind_expire_task, remind_config)


def run_all_story_tasks():
    """执行所有项目的故事提醒任务"""
    dateattr = DateAttr()
    if not dateattr.is_workday:
        logger.info("非工作日，跳过所有故事提醒任务")
        return

    logger.info(
        f"============================= {datetime.now()} 故事提醒任务 ============================="
    )

    configs = get_project_configs()
    for config in configs:
        if config.need_progress_remind:
            run_story_task(config)


def run_all_task_reminders():
    """执行所有项目的任务提醒"""
    dateattr = DateAttr()
    if not dateattr.is_workday:
        logger.info("非工作日，跳过所有任务提醒")
        return

    logger.info(
        f"============================= {datetime.now()} 任务提醒 ============================="
    )

    configs = get_project_configs()
    for config in configs:
        if config.need_progress_remind:
            run_task_reminder(config)


class TaskScheduler:
    """任务调度器"""

    def __init__(self):
        self.scheduler = BackgroundScheduler()
        self._setup_jobs()

    def _setup_jobs(self):
        """设置定时任务"""
        # 工作日每天 08:30 执行故事提醒
        self.scheduler.add_job(
            run_all_story_tasks,
            CronTrigger(hour=8, minute=30, day_of_week="mon-fri"),
            id="story_reminder",
            name="故事提醒任务",
            replace_existing=True,
        )

        # 工作日每天 17:20 执行任务提醒
        self.scheduler.add_job(
            run_all_task_reminders,
            CronTrigger(hour=17, minute=20, day_of_week="mon-fri"),
            id="task_reminder",
            name="任务到期提醒",
            replace_existing=True,
        )

    def start(self):
        """启动调度器"""
        self.scheduler.start()
        logger.info("任务调度器已启动")

    def stop(self):
        """停止调度器"""
        self.scheduler.shutdown()
        logger.info("任务调度器已停止")

    def get_jobs(self):
        """获取所有任务状态"""
        jobs = []
        for job in self.scheduler.get_jobs():
            jobs.append(
                {
                    "id": job.id,
                    "name": job.name,
                    "next_run_time": str(job.next_run_time)
                    if job.next_run_time
                    else None,
                    "trigger": str(job.trigger),
                }
            )
        return jobs

    def run_job_now(self, job_id: str):
        """手动触发任务"""
        if job_id == "story_reminder":
            run_all_story_tasks()
            return {"status": "success", "message": "故事提醒任务已执行"}
        elif job_id == "task_reminder":
            run_all_task_reminders()
            return {"status": "success", "message": "任务提醒任务已执行"}
        return {"status": "error", "message": f"未知任务: {job_id}"}
