import concurrent.futures
import threading
import time
from typing import List, Optional

import pandas as pd

from db.dboperator import DbOperator
from db.sqls import (
    AUTHORS_BUGS_AVG_COMPLETE_DURATION_SQL,
    BUGS_COMPLETE_DURATION_SQL,
    SPRINTS_BUGS_AVG_COMPLETE_DURATION_SQL,
    STORIES_COMPLETE_DURATION_SQL,
)
from util.jira import ProjectRemindConfigUtil, ProjectUtil
from util.jira import Sprint as JiraSprint


def get_sprint_issues_data(sprint: JiraSprint, print_lock):
    """处理获取到的Sprint数据"""
    # 开始处理
    start_time = time.perf_counter()
    start_msg = (
        "      \033[1;41;30m {} \033[0m-\033[1;32m{}\033[0m 正在处理 ...".format(
            sprint.project_name, sprint.sprint_name
        )
    )
    with print_lock:
        print(start_msg)

    # 获取所有issue, 并写入库表
    issues, stories_changelogs, bugs_changelogs = sprint.rdm_report_data
    with print_lock:
        print(
            "      \033[1;41;30m {} \033[0m-\033[1;32m{}\033[0m 处理完成! ( 耗时: {:.2f}s )".format(
                sprint.project_name,
                sprint.sprint_name,
                time.perf_counter() - start_time,
            )
        )
    if issues:
        return issues, stories_changelogs, bugs_changelogs
    return [], [], []


def data_to_table(
    sprints_data, issues_data, stories_changelogs_data, bugs_changelogs_data
):
    """将数据写入库表"""
    # 写入Sprint数据
    if sprints_data:
        DbOperator.truncate_table("sprints")
        sprints_df = pd.DataFrame(sprints_data)
        sprints_df.to_sql(
            "sprints", con=DbOperator.get_engine(), if_exists="append", index=False
        )

    # 写入issues数据
    if issues_data:
        DbOperator.truncate_table("issues")
        all_issues_details_df = pd.DataFrame(issues_data)
        all_issues_details_df.to_sql(
            "issues", con=DbOperator.get_engine(), if_exists="append", index=False
        )

    # 写入stories_changelogs数据
    if stories_changelogs_data:
        DbOperator.truncate_table("stories_changelogs")
        stories_changelogs_df = pd.DataFrame(stories_changelogs_data)
        stories_changelogs_df_unique = stories_changelogs_df.drop_duplicates()
        stories_changelogs_df_unique.to_sql(
            "stories_changelogs",
            con=DbOperator.get_engine(),
            if_exists="append",
            index=False,
        )

    # 写入bugs_changelogs数据
    if bugs_changelogs_data:
        DbOperator.truncate_table("bugs_changelogs")
        bugs_changelogs_df = pd.DataFrame(bugs_changelogs_data)
        # 按 bug_id 分组，标记每组中 sprint_id 等于最大值的记录
        bugs_changelogs_df["is_max"] = bugs_changelogs_df.groupby("bug_id")[
            "sprint_id"
        ].transform(lambda x: x == x.max())
        # 筛选出最大 sprint_id 的记录，并移除临时列
        filtered_df = bugs_changelogs_df[bugs_changelogs_df["is_max"]].drop(
            columns="is_max"
        )
        # 只写入筛选后的数据（不包含 is_max 列）
        filtered_df.to_sql(
            "bugs_changelogs",
            con=DbOperator.get_engine(),
            if_exists="append",
            index=False,
        )


def get_sprints_data() -> Optional[List[JiraSprint]]:
    jira_sprint_list = []
    for config in ProjectRemindConfigUtil.configs():
        project_util = ProjectUtil(config)
        """if not project.need_report_data:
            continue"""
        sprints = project_util.sprints
        if sprints:
            jira_sprint_list.extend(sprints)
    return jira_sprint_list


def parallel_get_issues_data(sprints: List[JiraSprint]):
    # 初始化结果容器
    all_issues = []
    all_stories_changelogs = []
    all_bugs_changelogs = []

    # 并发度为7
    print_lock = threading.Lock()
    with concurrent.futures.ThreadPoolExecutor(max_workers=7) as executor:
        # 提交任务
        futures = {
            executor.submit(get_sprint_issues_data, sprint, print_lock): sprint
            for sprint in sprints
        }

        # 按任务完成顺序处理结果
        for future in concurrent.futures.as_completed(futures):
            sprint = futures[future]
            try:
                issues, stories_changelogs, bugs_changelogs = future.result()
                # 合并结果
                all_issues.extend(issues)
                all_stories_changelogs.extend(stories_changelogs)
                all_bugs_changelogs.extend(bugs_changelogs)
            except Exception as e:
                with print_lock:
                    print(f"Sprint {sprint.sprint_name} 处理失败: {e}")

    return all_issues, all_stories_changelogs, all_bugs_changelogs


def process():
    """主处理流程"""
    print("开始处理 ...\n")
    start = time.perf_counter()

    print("- 1/5 开始获取Sprint数据 ...")
    sprints = get_sprints_data()
    if not sprints:
        print("无Sprint数据可处理")
        return
    print("- 1/5 Sprint数据获取完成")

    print("- 2/5 开始获取Issue及变更记录数据 ...")
    issues, stories_changelogs, bugs_changelogs = parallel_get_issues_data(sprints)
    print("- 2/5 Issue及变更记录数据获取完成")

    # 将数据写入数据库
    print("- 3/5 开始将数据写入库表 ...")
    data_to_table(sprints, issues, stories_changelogs, bugs_changelogs)
    print("- 3/5 数据写入库表完成")

    print("- 4/5 开始处理故事完成时长表的数据 stories_complete_duration ...")
    DbOperator.truncate_table("stories_complete_duration")
    # 使用SQL语句计算故事完成时长，并写入库表
    DbOperator.exec_sql(STORIES_COMPLETE_DURATION_SQL)
    print("- 4/5 故事完成时长表的数据处理完成")

    print("- 5-1/5 开始处理故障完成时长表的数据 bugs_complete_duration ...")
    DbOperator.truncate_table("bugs_complete_duration")
    DbOperator.exec_sql(BUGS_COMPLETE_DURATION_SQL)
    print("- 5-1/5 故障完成时长表的数据处理完成")

    print(
        "- 5-2/5 开始处理各Sprint故障平均完成时长表的数据 sprints_bugs_avg_complete_duration ..."
    )
    DbOperator.truncate_table("sprints_bugs_avg_complete_duration")
    DbOperator.exec_sql(SPRINTS_BUGS_AVG_COMPLETE_DURATION_SQL)
    print("- 5-2/5 各Sprint故障平均故障完成时长表的数据处理完成")

    print(
        "- 5-3/5 开始处理各开发人员的故障平均完成时长表的数据 authors_bugs_avg_complete_duration ..."
    )
    DbOperator.truncate_table("authors_bugs_avg_complete_duration")
    DbOperator.exec_sql(AUTHORS_BUGS_AVG_COMPLETE_DURATION_SQL)
    print("- 5-3/5 各开发人员的故障平均完成时长表的数据处理完成")

    print("所有内容处理完毕 ( 总耗时: {:.2f}s )".format(time.perf_counter() - start))


def main():
    try:
        process()
    except Exception as err:
        # 捕获异常
        print(f"脚本执行出错: {err}")
        # 发送企业微信通知
        message = "## RDM报表数据拉取失败:\n" + f">{err}\n" + "@聂祥"
        print(message)
        import utils.qywx as qywx

        qywx.post("8a0ff77b-9936-42a9-911b-fbbf3ad533d4", message)


if __name__ == "__main__":
    main()
