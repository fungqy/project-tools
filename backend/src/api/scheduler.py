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

# 任务类型常量
TASK_TYPE_STORY = "story_reminder"
TASK_TYPE_TASK = "task_reminder"
TASK_TYPE_SONAR = "sonar_reminder"
TASK_TYPE_REPORT = "report_data"


def parse_time(time_str: str) -> tuple[int, int]:
    """解析 HH:MM 格式时间字符串为 (hour, minute)"""
    if not time_str:
        return 0, 0
    parts = time_str.split(":")
    try:
        hour = int(parts[0]) if len(parts) > 0 else 0
        minute = int(parts[1]) if len(parts) > 1 else 0
        return hour, minute
    except (ValueError, IndexError):
        return 0, 0


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
                user=str(config.jira_user),
                token=str(config.jira_token),
                url=str(config.jira_url),
            )
        return None
    finally:
        session.close()


def get_project_configs():
    """从数据库获取项目配置"""
    from db.database import get_session
    from db.models import ProjectReminderSettings

    session = get_session()
    try:
        # 查询所有需要提醒的项目配置
        reminder_settings = (
            session.query(ProjectReminderSettings)
            .filter(
                (ProjectReminderSettings.need_story_remind.is_(True))
                | (ProjectReminderSettings.need_task_remind.is_(True))
                | (ProjectReminderSettings.need_sonar_scan_remind.is_(True))
                | (ProjectReminderSettings.need_report_data.is_(True))
            )
            .all()
        )

        result = []
        for setting in reminder_settings:
            config = setting.project_config
            if config is None:
                continue

            # 获取项目创建者的JIRA认证
            auth_config = None
            if config.created_by is not None:
                auth_config = get_user_jira_auth(int(config.created_by))

            # 构建 ProjectRemindConfig 对象
            _gitlab_key = (
                str(config.gitlab_group_key)
                if config.gitlab_group_key is not None
                else ""
            )
            _sonar_key = (
                str(config.sonar_key_prefix)
                if config.sonar_key_prefix is not None
                else ""
            )
            _sonar_person = (
                str(config.sonar_scan_remind_default_person)
                if config.sonar_scan_remind_default_person is not None
                else ""
            )
            _robot_key = str(config.robot_key) if config.robot_key is not None else ""

            # 获取各任务的自定义时间
            story_time = getattr(setting, "story_remind_time", None) or ""
            task_time = getattr(setting, "task_remind_time", None) or ""
            sonar_time = getattr(setting, "sonar_remind_time", None) or ""
            report_time = getattr(setting, "report_data_time", None) or ""

            result.append(
                ProjectRemindConfig(
                    project_config_id=config.id,
                    board_id=str(config.board_id),
                    board_name=str(config.board_name),
                    project_id=str(config.project_id),
                    project_name=str(config.project_name),
                    gitlab_group_key=_gitlab_key,
                    need_story_remind=bool(setting.need_story_remind),
                    need_task_remind=bool(setting.need_task_remind),
                    need_sonar_scan_remind=bool(setting.need_sonar_scan_remind),
                    need_report_data=bool(setting.need_report_data),
                    sonar_key_prefix=_sonar_key,
                    sonar_scan_remind_default_person=_sonar_person,
                    robot_key=_robot_key,
                    jira_user=auth_config.user if auth_config else "",
                    jira_token=auth_config.token if auth_config else "",
                    story_remind_time=story_time,
                    task_remind_time=task_time,
                    sonar_remind_time=sonar_time,
                    report_data_time=report_time,
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
            # post(remind_config.robot_key, message)


def check_time_match(config_time: str, now: datetime) -> bool:
    """检查当前时间是否匹配指定的提醒时间"""
    if not config_time:
        return False
    hour, minute = parse_time(config_time)
    return now.hour == hour and now.minute == minute


def record_execution(
    project_config_id: int,
    task_type: str,
    scheduled_time: datetime,
    status: str,
    error_message: str = "",
):
    """记录任务执行日志"""
    from db.database import get_session
    from db.models import TaskExecutionLog

    session = get_session()
    try:
        log = TaskExecutionLog(
            project_config_id=project_config_id,
            task_type=task_type,
            scheduled_time=scheduled_time,
            executed_at=datetime.now(),
            status=status,
            error_message=error_message,
        )
        session.add(log)
        session.commit()
    except Exception as e:
        logger.error(f"记录执行日志失败: {e}")
    finally:
        session.close()


def get_today_tasks_status():
    """获取今日任务状态"""
    from sqlalchemy import and_

    from db.database import get_session
    from db.models import ProjectConfig, TaskExecutionLog

    session = get_session()
    try:
        today = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)
        tomorrow = today.replace(hour=23, minute=59, second=59)

        # 获取今日所有执行记录
        logs = (
            session.query(TaskExecutionLog)
            .filter(
                and_(
                    TaskExecutionLog.scheduled_time >= today,
                    TaskExecutionLog.scheduled_time <= tomorrow,
                )
            )
            .all()
        )

        # 构建执行记录映射 {(project_config_id, task_type): log}
        log_map = {(log.project_config_id, log.task_type): log for log in logs}

        # 获取所有项目配置
        configs = session.query(ProjectConfig).all()

        result = []
        now = datetime.now()

        for config in configs:
            settings = config.reminder_settings
            if not settings:
                continue

            # 检查每个任务类型
            tasks = [
                (
                    "story_reminder",
                    settings.need_story_remind,
                    settings.story_remind_time,
                ),
                ("task_reminder", settings.need_task_remind, settings.task_remind_time),
                (
                    "sonar_reminder",
                    settings.need_sonar_scan_remind,
                    settings.sonar_remind_time,
                ),
                ("report_data", settings.need_report_data, settings.report_data_time),
            ]

            for task_type, needed, remind_time in tasks:
                if not needed or not remind_time:
                    continue

                # 计算计划执行时间
                hour, minute = parse_time(remind_time)
                scheduled_time = today.replace(
                    hour=hour, minute=minute, second=0, microsecond=0
                )

                # 获取执行记录
                log = log_map.get((config.id, task_type))

                # 确定状态
                if log:
                    status = log.status
                    executed_at = (
                        log.executed_at.isoformat() if log.executed_at else None
                    )
                elif scheduled_time < now:
                    status = "expired"  # 已过期未执行
                    executed_at = None
                else:
                    status = "pending"  # 待执行
                    executed_at = None

                result.append(
                    {
                        "project_name": config.project_name,
                        "task_type": task_type,
                        "scheduled_time": scheduled_time.isoformat(),
                        "status": status,
                        "executed_at": executed_at,
                    }
                )

        # 按计划执行时间排序
        result.sort(key=lambda x: x["scheduled_time"])
        return result
    finally:
        session.close()


def run_story_task(remind_config: ProjectRemindConfig, scheduled_time: datetime):
    """执行故事提醒任务"""
    from task import remind_week_story as module

    logger.info(f"[{remind_config.project_name}] 执行本周待完成故事提醒...")
    try:
        module_run(module, remind_config)
        record_execution(
            remind_config.project_config_id, TASK_TYPE_STORY, scheduled_time, "success"
        )
    except Exception as e:
        logger.error(f"[{remind_config.project_name}] 故事提醒执行失败: {e}")
        record_execution(
            remind_config.project_config_id,
            TASK_TYPE_STORY,
            scheduled_time,
            "failed",
            str(e),
        )


def run_task_reminder(remind_config: ProjectRemindConfig, scheduled_time: datetime):
    """执行子任务到期提醒"""
    from task import remind_expire_task as module

    logger.info(f"[{remind_config.project_name}] 执行子任务到期提醒...")
    try:
        module_run(module, remind_config)
        record_execution(
            remind_config.project_config_id, TASK_TYPE_TASK, scheduled_time, "success"
        )
    except Exception as e:
        logger.error(f"[{remind_config.project_name}] 任务提醒执行失败: {e}")
        record_execution(
            remind_config.project_config_id,
            TASK_TYPE_TASK,
            scheduled_time,
            "failed",
            str(e),
        )


def run_sonar_scan_reminder(
    remind_config: ProjectRemindConfig, scheduled_time: datetime
):
    """执行Sonar扫描提醒"""
    import task.remind_sonar_scan as sonar_module

    logger.info(f"[{remind_config.project_name}] 执行Sonar扫描提醒...")
    try:
        module_run(sonar_module, remind_config)
        record_execution(
            remind_config.project_config_id, TASK_TYPE_SONAR, scheduled_time, "success"
        )
    except Exception as e:
        logger.error(f"[{remind_config.project_name}] Sonar扫描提醒执行失败: {e}")
        record_execution(
            remind_config.project_config_id,
            TASK_TYPE_SONAR,
            scheduled_time,
            "failed",
            str(e),
        )


def run_report_data():
    """执行报表数据生成"""
    from task.report_rdm_data import process

    now = datetime.now()

    # 获取报表生成配置的时间
    project_configs = get_project_configs()
    report_time = None
    for config in project_configs:
        if config.need_report_data and config.report_data_time:
            report_time = config.report_data_time
            break

    if not report_time:
        logger.info("未配置报表生成时间，跳过")
        return

    if not check_time_match(report_time, now):
        logger.info(f"当前时间不匹配报表生成时间({report_time})，跳过")
        return

    logger.info("开始执行报表数据生成...")
    try:
        process()
        logger.info("报表数据生成完成")
    except Exception as e:
        logger.error(f"报表数据生成失败: {e}")
        raise


def run_all_story_tasks():
    """执行所有需要提醒的项目的故事提醒任务"""
    now = datetime.now()

    logger.info(
        f"============================= {now} 故事提醒任务 ============================="
    )

    project_configs = get_project_configs()
    for config in project_configs:
        if config.need_story_remind:
            # 检查项目是否配置了提醒时间
            if not config.story_remind_time:
                logger.info(f"[{config.project_name}] 未配置故事提醒时间，跳过")
                continue
            # 检查时间是否匹配
            if check_time_match(config.story_remind_time, now):
                # 计算计划执行时间
                hour, minute = parse_time(config.story_remind_time)
                scheduled_time = now.replace(
                    hour=hour, minute=minute, second=0, microsecond=0
                )
                run_story_task(config, scheduled_time)
            else:
                logger.info(
                    f"[{config.project_name}] 当前时间不匹配故事提醒时间({config.story_remind_time})，跳过"
                )


def run_all_task_reminders():
    """执行所有需要提醒的项目的任务提醒"""
    now = datetime.now()

    logger.info(
        f"============================= {now} 任务提醒 ============================="
    )

    project_configs = get_project_configs()
    for config in project_configs:
        if config.need_task_remind:
            # 检查项目是否配置了提醒时间
            if not config.task_remind_time:
                logger.info(f"[{config.project_name}] 未配置任务提醒时间，跳过")
                continue
            # 检查时间是否匹配
            if check_time_match(config.task_remind_time, now):
                # 计算计划执行时间
                hour, minute = parse_time(config.task_remind_time)
                scheduled_time = now.replace(
                    hour=hour, minute=minute, second=0, microsecond=0
                )
                run_task_reminder(config, scheduled_time)
            else:
                logger.info(
                    f"[{config.project_name}] 当前时间不匹配任务提醒时间({config.task_remind_time})，跳过"
                )


def run_all_sonar_scan_reminders():
    """执行所有需要提醒的项目的Sonar扫描提醒"""
    now = datetime.now()

    logger.info(
        f"============================= {now} Sonar扫描提醒 ============================="
    )

    project_configs = get_project_configs()
    for config in project_configs:
        if config.need_sonar_scan_remind:
            # 检查项目是否配置了提醒时间
            if not config.sonar_remind_time:
                logger.info(f"[{config.project_name}] 未配置Sonar提醒时间，跳过")
                continue
            # 检查时间是否匹配
            if check_time_match(config.sonar_remind_time, now):
                # 计算计划执行时间
                hour, minute = parse_time(config.sonar_remind_time)
                scheduled_time = now.replace(
                    hour=hour, minute=minute, second=0, microsecond=0
                )
                run_sonar_scan_reminder(config, scheduled_time)
            else:
                logger.info(
                    f"[{config.project_name}] 当前时间不匹配Sonar提醒时间({config.sonar_remind_time})，跳过"
                )


class TaskScheduler:
    """任务调度器

    所有任务每天每分钟触发检查，由 DateAttr.is_workday 和项目配置决定是否执行。
    """

    def __init__(self):
        self.scheduler = BackgroundScheduler()
        self._setup_jobs()

    def _setup_jobs(self):
        """设置定时任务，每分钟触发检查"""
        # 每10分钟触发一次，由 run_all_xxx 函数检查 is_workday 和项目时间配置是否匹配
        trigger = CronTrigger(minute="*/10")

        dateattr = DateAttr()
        if not dateattr.is_workday:
            logger.info("非工作日，跳过所有任务提醒")
            return

        # 故事提醒
        self.scheduler.add_job(
            run_all_story_tasks,
            trigger,
            id=TASK_TYPE_STORY,
            name="故事提醒任务",
            replace_existing=True,
        )

        # 任务到期提醒
        self.scheduler.add_job(
            run_all_task_reminders,
            trigger,
            id=TASK_TYPE_TASK,
            name="任务到期提醒",
            replace_existing=True,
        )

        # Sonar扫描提醒
        self.scheduler.add_job(
            run_all_sonar_scan_reminders,
            trigger,
            id=TASK_TYPE_SONAR,
            name="Sonar扫描提醒",
            replace_existing=True,
        )

        # 报表数据生成
        self.scheduler.add_job(
            run_report_data,
            trigger,
            id=TASK_TYPE_REPORT,
            name="报表数据生成",
            replace_existing=True,
        )

    def reload_jobs(self):
        """重新加载所有任务配置"""
        # 移除所有现有任务
        self.scheduler.remove_all_jobs()
        # 重新设置任务
        self._setup_jobs()
        logger.info("调度任务已重新加载")

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
        if job_id == TASK_TYPE_STORY:
            run_all_story_tasks()
            return {"status": "success", "message": "故事提醒任务已执行"}
        elif job_id == TASK_TYPE_TASK:
            run_all_task_reminders()
            return {"status": "success", "message": "任务提醒任务已执行"}
        elif job_id == TASK_TYPE_SONAR:
            run_all_sonar_scan_reminders()
            return {"status": "success", "message": "Sonar扫描提醒任务已执行"}
        elif job_id == TASK_TYPE_REPORT:
            run_report_data()
            return {"status": "success", "message": "报表数据生成任务已执行"}
        return {"status": "error", "message": f"未知任务: {job_id}"}


# 全局调度器实例
_scheduler_instance = None


def get_scheduler():
    """获取全局调度器实例"""
    global _scheduler_instance
    if _scheduler_instance is None:
        _scheduler_instance = TaskScheduler()
    return _scheduler_instance


def start_scheduler():
    """启动调度器"""
    scheduler = get_scheduler()
    scheduler.start()


def stop_scheduler():
    """停止调度器"""
    global _scheduler_instance
    if _scheduler_instance:
        _scheduler_instance.stop()
        _scheduler_instance = None
