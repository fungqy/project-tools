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

# 默认调度配置
DEFAULT_SCHEDULER_CONFIGS = {
    TASK_TYPE_STORY: {"day_of_week": "mon-fri", "default_time": "08:30"},
    TASK_TYPE_TASK: {"day_of_week": "mon-fri", "default_time": "17:20"},
    TASK_TYPE_SONAR: {"day_of_week": "mon-fri", "default_time": "09:00"},
    TASK_TYPE_REPORT: {"day_of_week": "fri", "default_time": "18:00"},
}


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


def get_scheduler_configs():
    """从数据库获取调度器配置"""
    from db.database import get_session
    from db.models import SchedulerConfig

    session = get_session()
    try:
        configs = session.query(SchedulerConfig).all()
        result = {}
        for config in configs:
            result[config.task_type] = {
                "enabled": config.enabled,
                "day_of_week": config.day_of_week,
                "default_time": config.default_time,
            }
        return result
    finally:
        session.close()


def init_scheduler_configs_if_needed():
    """如果调度器配置表为空，初始化默认配置"""
    from db.database import get_session
    from db.models import SchedulerConfig

    session = get_session()
    try:
        count = session.query(SchedulerConfig).count()
        if count == 0:
            for task_type, config in DEFAULT_SCHEDULER_CONFIGS.items():
                new_config = SchedulerConfig(
                    task_type=task_type,
                    enabled=True,
                    day_of_week=config["day_of_week"],
                    default_time=config["default_time"],
                )
                session.add(new_config)
            session.commit()
            logger.info("调度器配置已初始化")
    finally:
        session.close()


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


def check_time_match(config_time: str, default_time: str, now: datetime) -> bool:
    """检查当前时间是否匹配指定的提醒时间"""
    hour, minute = parse_time(config_time) if config_time else parse_time(default_time)
    return now.hour == hour and now.minute == minute


def run_story_task(remind_config: ProjectRemindConfig):
    """执行故事提醒任务"""
    from task.remind_week_story import remind_week_story  # type: ignore

    dateattr = DateAttr()
    if not dateattr.is_workday:
        logger.info(f"[{remind_config.project_name}] 非工作日，跳过故事提醒")
        return
    logger.info(f"[{remind_config.project_name}] 执行本周待完成故事提醒...")
    module_run(remind_week_story, remind_config)


def run_task_reminder(remind_config: ProjectRemindConfig):
    """执行子任务到期提醒"""
    from task.remind_expire_task import remind_expire_task  # type: ignore

    dateattr = DateAttr()
    if not dateattr.is_workday:
        logger.info(f"[{remind_config.project_name}] 非工作日，跳过任务提醒")
        return
    logger.info(f"[{remind_config.project_name}] 执行子任务到期提醒...")
    module_run(remind_expire_task, remind_config)


def run_sonar_scan_reminder(remind_config: ProjectRemindConfig):
    """执行Sonar扫描提醒"""
    import task.remind_sonar_scan as sonar_module

    dateattr = DateAttr()
    if not dateattr.is_workday:
        logger.info(f"[{remind_config.project_name}] 非工作日，跳过Sonar扫描提醒")
        return
    logger.info(f"[{remind_config.project_name}] 执行Sonar扫描提醒...")
    module_run(sonar_module, remind_config)


def run_report_data():
    """执行报表数据生成"""
    from task.report_rdm_data import process

    # 获取报表数据生成的调度配置
    configs = get_scheduler_configs()
    report_config = configs.get(TASK_TYPE_REPORT, {})
    day_of_week = report_config.get("day_of_week", "fri")

    # 检查是否是报表生成日
    weekday_map = {"mon": 0, "tue": 1, "wed": 2, "thu": 3, "fri": 4, "sat": 5, "sun": 6}
    allowed_weekdays = [
        weekday_map[d.strip()]
        for d in day_of_week.split("-")
        if d.strip() in weekday_map
    ]

    if datetime.now().weekday() not in allowed_weekdays:
        logger.info(f"非报表生成日({day_of_week})，跳过报表数据生成")
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
    dateattr = DateAttr()
    if not dateattr.is_workday:
        logger.info("非工作日，跳过所有故事提醒任务")
        return

    configs = get_scheduler_configs()
    story_config = configs.get(TASK_TYPE_STORY, {})
    default_time = story_config.get("default_time", "08:30")
    now = datetime.now()

    logger.info(
        f"============================= {now} 故事提醒任务 ============================="
    )

    project_configs = get_project_configs()
    for config in project_configs:
        if config.need_story_remind:
            # 检查时间是否匹配
            if check_time_match(config.story_remind_time, default_time, now):
                run_story_task(config)
            else:
                logger.info(
                    f"[{config.project_name}] 当前时间不匹配故事提醒时间({config.story_remind_time or default_time})，跳过"
                )


def run_all_task_reminders():
    """执行所有需要提醒的项目的任务提醒"""
    dateattr = DateAttr()
    if not dateattr.is_workday:
        logger.info("非工作日，跳过所有任务提醒")
        return

    configs = get_scheduler_configs()
    task_config = configs.get(TASK_TYPE_TASK, {})
    default_time = task_config.get("default_time", "17:20")
    now = datetime.now()

    logger.info(
        f"============================= {now} 任务提醒 ============================="
    )

    project_configs = get_project_configs()
    for config in project_configs:
        if config.need_task_remind:
            # 检查时间是否匹配
            if check_time_match(config.task_remind_time, default_time, now):
                run_task_reminder(config)
            else:
                logger.info(
                    f"[{config.project_name}] 当前时间不匹配任务提醒时间({config.task_remind_time or default_time})，跳过"
                )


def run_all_sonar_scan_reminders():
    """执行所有需要提醒的项目的Sonar扫描提醒"""
    dateattr = DateAttr()
    if not dateattr.is_workday:
        logger.info("非工作日，跳过所有Sonar扫描提醒")
        return

    configs = get_scheduler_configs()
    sonar_config = configs.get(TASK_TYPE_SONAR, {})
    default_time = sonar_config.get("default_time", "09:00")
    now = datetime.now()

    logger.info(
        f"============================= {now} Sonar扫描提醒 ============================="
    )

    project_configs = get_project_configs()
    for config in project_configs:
        if config.need_sonar_scan_remind:
            # 检查时间是否匹配
            if check_time_match(config.sonar_remind_time, default_time, now):
                run_sonar_scan_reminder(config)
            else:
                logger.info(
                    f"[{config.project_name}] 当前时间不匹配Sonar提醒时间({config.sonar_remind_time or default_time})，跳过"
                )


class TaskScheduler:
    """任务调度器"""

    def __init__(self):
        self.scheduler = BackgroundScheduler()
        self._setup_jobs()

    def _get_cron_trigger(self, task_type: str):
        """根据任务类型获取CronTrigger"""
        configs = get_scheduler_configs()
        config = configs.get(task_type, DEFAULT_SCHEDULER_CONFIGS.get(task_type, {}))

        if not config.get("enabled", True):
            return None

        day_of_week = config.get("day_of_week", "mon-fri")
        default_time = config.get("default_time", "08:30")
        hour, minute = parse_time(default_time)

        return CronTrigger(
            hour=hour,
            minute=minute,
            day_of_week=day_of_week,
        )

    def _setup_jobs(self):
        """设置定时任务"""
        # 故事提醒
        trigger = self._get_cron_trigger(TASK_TYPE_STORY)
        if trigger:
            self.scheduler.add_job(
                run_all_story_tasks,
                trigger,
                id=TASK_TYPE_STORY,
                name="故事提醒任务",
                replace_existing=True,
            )

        # 任务到期提醒
        trigger = self._get_cron_trigger(TASK_TYPE_TASK)
        if trigger:
            self.scheduler.add_job(
                run_all_task_reminders,
                trigger,
                id=TASK_TYPE_TASK,
                name="任务到期提醒",
                replace_existing=True,
            )

        # Sonar扫描提醒
        trigger = self._get_cron_trigger(TASK_TYPE_SONAR)
        if trigger:
            self.scheduler.add_job(
                run_all_sonar_scan_reminders,
                trigger,
                id=TASK_TYPE_SONAR,
                name="Sonar扫描提醒",
                replace_existing=True,
            )

        # 报表数据生成
        trigger = self._get_cron_trigger(TASK_TYPE_REPORT)
        if trigger:
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
        # 初始化默认配置
        init_scheduler_configs_if_needed()
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

    def update_job_schedule(
        self,
        job_id: str,
        day_of_week: str,
        default_time: str,
        enabled: bool = True,
    ):
        """更新任务调度时间"""
        from db.database import get_session
        from db.models import SchedulerConfig

        session = get_session()
        try:
            config = (
                session.query(SchedulerConfig)
                .filter(SchedulerConfig.task_type == job_id)
                .first()
            )
            if config:
                setattr(config, "day_of_week", day_of_week)
                setattr(config, "default_time", default_time)
                setattr(config, "enabled", enabled)
                session.commit()

                # 重新加载任务
                self.reload_jobs()
                return {"status": "success", "message": f"任务 {job_id} 调度时间已更新"}
            return {"status": "error", "message": f"未找到任务: {job_id}"}
        finally:
            session.close()


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
