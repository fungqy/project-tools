import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

import remind_week_story as story
import remind_expire_task as task
from datetime import datetime
from utils.jira import ProjectRemindConfig, ProjectRemindConfigUtil
import utils.qywx as qywx
from utils.dateattr import DateAttr


def module_run(module, remind_config: ProjectRemindConfig):
        """统一处理消息生成与发送逻辑"""
        message_list = module.gene_message(remind_config)
        if not message_list:
            return
        for message in message_list:
            if message:
                print(f"{message}")
                qywx.post(remind_config.robot_key, message)
                # qywx.post('8a0ff77b-9936-42a9-911b-fbbf3ad533d4', message)

def run(remind_config: ProjectRemindConfig,
        datetime_run_story_flag: bool = False, # 当前时间是否需要执行本周故事情况提醒
        datetime_run_task_flag: bool = False   # 当前时间是否需要执行子任务到期提醒
    ) -> None:
        if remind_config.need_progress_remind and datetime_run_story_flag:
            module_run(story, remind_config)
        if remind_config.need_progress_remind and datetime_run_task_flag:
            module_run(task, remind_config)


def datetime_run_flag():
    run_story_flag, run_task_flag = False, False
    # 获取当前日期属性
    dateattr = DateAttr()
    today_is_workday = dateattr.is_workday

    if not today_is_workday:
        print("非工作日，所有任务都不用执行...")
    else:
        now = datetime.now()
        print(f"============================= {now} =============================")
        now_hour = now.hour
        now_minute = now.minute
        if now_hour == 8 and now_minute >= 30:
            print("工作日每天上午8点30分 执行本周待完成故事提醒任务...")
            run_story_flag = True
        if now_hour == 17 and now_minute >= 20:
            print("工作日每天下午5点20分 执行子任务到期提醒任务...")
            run_task_flag = True

    return run_story_flag, run_task_flag


def main():
    # 当前时间是否执行各种提醒任务
    datetime_run_story_flag, datetime_run_task_flag = datetime_run_flag()

    import multiprocessing
    from functools import partial
    with multiprocessing.Pool(processes=4) as pool:
        bound = partial(
            run,
            datetime_run_story_flag=datetime_run_story_flag,
            datetime_run_task_flag=datetime_run_task_flag
        )
        pool.map(bound, ProjectRemindConfigUtil.configs())


if __name__ == "__main__":
    main()
