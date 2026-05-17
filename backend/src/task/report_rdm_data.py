import logging

import time
import pandas as pd

from ..db.dboperator import DbOperator
from ..db.sqls import (
    RDM_BUG_DURATION_SQL,
    RDM_STORY_DURATION_SQL,
)
from util.jira import Sprint as JiraSprint

logging.basicConfig(level=logging.INFO).getLogger("report_rdm_data")

def get_radm_data(sprint: JiraSprint) -> tuple:
    """处理Sprint的数据"""
    issues, stories_changelogs, bugs_changelogs = sprint.rdm_report_data

    if issues:
        return issues, stories_changelogs, bugs_changelogs
    return [], [], []


def insert_to_table(
    sprints_data, issues_data, stories_changelogs_data, bugs_changelogs_data
):
    """将数据写入库表"""
    if sprints_data:
        DbOperator.truncate_table("sprints")
        sprints_df = pd.DataFrame(sprints_data)
        sprints_df.to_sql(
            "sprints", con=DbOperator.get_engine(), if_exists="append", index=False
        )

    if issues_data:
        DbOperator.truncate_table("issues")
        all_issues_details_df = pd.DataFrame(issues_data)
        all_issues_details_df.to_sql(
            "issues", con=DbOperator.get_engine(), if_exists="append", index=False
        )

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

    if bugs_changelogs_data:
        DbOperator.truncate_table("bugs_changelogs")
        bugs_changelogs_df = pd.DataFrame(bugs_changelogs_data)
        bugs_changelogs_df["is_max"] = bugs_changelogs_df.groupby("bug_id")[
            "sprint_id"
        ].transform(lambda x: x == x.max())
        filtered_df = bugs_changelogs_df[bugs_changelogs_df["is_max"]].drop(
            columns="is_max"
        )
        filtered_df.to_sql(
            "bugs_changelogs",
            con=DbOperator.get_engine(),
            if_exists="append",
            index=False,
        )


def process_sprint(sprint: JiraSprint):
    """处理Sprint的数据"""
    logger.info(f"开始获取 {sprint.project_name} 的 {sprint.sprint_name} RDM数据 ...\n")
    start = time.perf_counter()

    logger.info("- 1/4 开始获取RDM数据 ...")
    issues, stories_changelogs, bugs_changelogs = get_radm_data(sprint)
    logger.info("- 1/4 RDM数据获取完成")

    logger.info("- 2/4 开始将RDM数据写入库表 ...")
    sprints_data = [sprint.to_dict()]
    insert_to_table(sprints_data, issues, stories_changelogs, bugs_changelogs)
    logger.info("- 2/4 RDM数据写入库表完成")

    logger.info("- 3/4 开始处理故事完成时长数据 rdm_story_duration ...")
    DbOperator.truncate_table("rdm_story_duration")
    DbOperator.exec_sql(RDM_STORY_DURATION_SQL)
    logger.info("- 3/4 故事完成时长数据处理完成")

    logger.info("- 4/4 开始处理故障完成时长数据 rdm_bug_duration ...")
    DbOperator.truncate_table("rdm_bug_duration")
    DbOperator.exec_sql(RDM_BUG_DURATION_SQL)
    logger.info("- 4/4 故障完成时长数据处理完成")

    logger.info(f"{sprint.project_name} 的 {sprint.sprint_name} RDM数据处理完毕 ( 总耗时: {time.perf_counter() - start:.2f}s )")


if __name__ == "__main__":
    process_sprint()
