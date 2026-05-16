from fastapi import APIRouter, Depends, Header, HTTPException
from sqlalchemy import text

from api.auth import decode_access_token
from db.database import get_session

router = APIRouter(prefix="/api/reports", tags=["质量报表"])


def get_current_user_from_header(authorization: str = Header(None)):
    """从 Authorization header 获取当前用户"""
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="未提供认证信息")

    token = authorization.replace("Bearer ", "")
    payload = decode_access_token(token)
    if not payload:
        raise HTTPException(status_code=401, detail="Token已过期或无效")

    return payload


@router.get("/projects")
async def list_user_projects(current_user: dict = Depends(get_current_user_from_header)):
    """获取用户有权限的项目列表，admin用户返回所有项目"""
    session = get_session()

    try:
        if current_user.get("is_admin"):
            query = text("""
                SELECT id, project_id, project_name, board_name
                FROM project_configs
                ORDER BY project_name
            """)
            result = session.execute(query)
        else:
            user_id = current_user.get("id")
            query = text("""
                SELECT id, project_id, project_name, board_name
                FROM project_configs
                WHERE created_by = :user_id
                ORDER BY project_name
            """)
            result = session.execute(query, {"user_id": user_id})

        projects = []
        for row in result:
            projects.append({
                "id": row[0],
                "project_id": row[1],
                "project_name": row[2],
                "board_name": row[3],
            })
        return projects
    finally:
        session.close()


@router.get("/sprints/{project_id}")
async def list_project_sprints(
    project_id: int,
    current_user: dict = Depends(get_current_user_from_header)
):
    """根据项目ID获取关联的Sprint列表"""
    session = get_session()

    try:
        # 获取项目的 project_id (JIRA project id)
        query = text("""
            SELECT project_id FROM project_configs WHERE id = :project_id
        """)
        result = session.execute(query, {"project_id": project_id})
        row = result.fetchone()

        if not row:
            return []

        jira_project_id = row[0]

        # 查询 rdm_sprint 表获取该项目的 sprint
        sprints_query = text("""
            SELECT DISTINCT sprint_id, sprint_name, startdate, enddate, state
            FROM rdm_sprint
            WHERE project_id = :jira_project_id
            ORDER BY ISNULL(enddate) DESC, enddate DESC, startdate DESC
            LIMIT 20
        """)
        sprints_result = session.execute(sprints_query, {"jira_project_id": jira_project_id})

        sprints = []
        for sprint_row in sprints_result:
            sprints.append({
                "sprint_id": sprint_row[0],
                "sprint_name": sprint_row[1],
                "start_date": sprint_row[2],
                "end_date": sprint_row[3],
                "state": sprint_row[4],
            })
        return sprints
    finally:
        session.close()


@router.get("/metrics")
async def get_sprint_metrics(
    sprint_id: int,
    current_user: dict = Depends(get_current_user_from_header)
):
    """获取Sprint的指标数据：故事数、故障数"""
    session = get_session()

    try:
        # 故事数：issueType 为 故事 或 简单故事
        story_query = text("""
            SELECT COUNT(*) FROM rdm_issue
            WHERE sprint_id = :sprint_id
            AND issue_type IN ('故事', '简单故事')
        """)
        story_result = session.execute(story_query, {"sprint_id": sprint_id})
        story_count = story_result.fetchone()[0] or 0

        # 故障数：issueType 为 故障
        bug_query = text("""
            SELECT COUNT(*) FROM rdm_issue
            WHERE sprint_id = :sprint_id
            AND issue_type = '故障'
        """)
        bug_result = session.execute(bug_query, {"sprint_id": sprint_id})
        bug_count = bug_result.fetchone()[0] or 0

        # 故障重开数：rdm_issue关联rdm_bug_changelog，存在"待测试 -> 处理中"变更记录
        reopen_query = text("""
            SELECT COUNT(DISTINCT i.issue_id)
            FROM rdm_issue i
            INNER JOIN rdm_bug_changelog c ON i.issue_id = c.bug_id
            WHERE i.sprint_id = :sprint_id
            AND i.issue_type = '故障'
            AND c.change_detail = '待测试 -> 处理中'
        """)
        reopen_result = session.execute(reopen_query, {"sprint_id": sprint_id})
        bug_reopen_count = reopen_result.fetchone()[0] or 0

        return {
            "story_count": story_count,
            "bug_count": bug_count,
            "bug_reopen_count": bug_reopen_count,
        }
    finally:
        session.close()


@router.get("/bugs/detail")
async def get_bug_details(
    sprint_id: int,
    current_user: dict = Depends(get_current_user_from_header)
):
    """获取故障详情，按开发人员、级别、标签分组统计"""
    session = get_session()

    try:
        # 查询故障详情
        query = text("""
            SELECT
                COALESCE(bug_maker, reporter, '其他') as developer,
                priority,
                bug_reason,
                issue_id
            FROM rdm_issue
            WHERE sprint_id = :sprint_id
            AND issue_type = '故障'
        """)
        result = session.execute(query, {"sprint_id": sprint_id})
        rows = result.fetchall()

        # 定义优先级排序
        priority_order = {'致命': 0, '严重': 1, '一般': 2, '轻微': 3, '优化': 4}

        # 定义标签排序
        tag_order = {'代码实现': 0, '业务需求': 1, '环境配置': 2, '其他': 3}

        # 处理数据
        developers = {}  # {developer: {priority: {tag: count}}}

        for row in rows:
            developer = row[0]
            priority = row[1] or ''
            bug_reason = row[2] or ''

            # 处理标签：按-分隔取第一个，去空格
            if '-' in bug_reason:
                tag = bug_reason.split('-')[0].strip()
            else:
                tag = '其他'

            # 初始化
            if developer not in developers:
                developers[developer] = {}

            # 获取该开发者的优先级映射
            priority_map = developers[developer]
            if priority not in priority_map:
                priority_map[priority] = {}

            # 累加计数
            tag_counts = priority_map[priority]
            tag_counts[tag] = tag_counts.get(tag, 0) + 1

        # 构建返回结果
        # 获取所有出现过的优先级和标签
        all_priorities = set()
        all_tags = set()
        for dev_data in developers.values():
            all_priorities.update(dev_data.keys())
            for tag_map in dev_data.values():
                all_tags.update(tag_map.keys())

        # 排序优先级
        sorted_priorities = sorted(
            all_priorities,
            key=lambda x: priority_order.get(x, 99)
        )

        # 排序标签
        sorted_tags = sorted(
            all_tags,
            key=lambda x: tag_order.get(x, 99)
        )

        # 构建开发者行数据
        developer_rows = []
        for developer in sorted(developers.keys()):
            row_data = {"developer": developer}
            total = 0
            for priority in sorted_priorities:
                priority_map = developers[developer]
                if priority in priority_map:
                    for tag in sorted_tags:
                        if tag in priority_map[priority]:
                            total += priority_map[priority][tag]
            row_data["total"] = total
            developer_rows.append(row_data)

        return {
            "developers": developer_rows,
            "priorities": sorted_priorities,
            "tags": sorted_tags,
            "data": developers,
        }
    finally:
        session.close()


@router.get("/bugs/list")
async def get_bug_list(
    sprint_id: int,
    priority: str,
    tag: str,
    developer: str = '',
    current_user: dict = Depends(get_current_user_from_header)
):
    """获取故障明细列表"""
    session = get_session()

    try:
        if developer:
            query = text("""
                SELECT
                    issue_key,
                    COALESCE(bug_maker, reporter, '其他') as developer,
                    priority,
                    issue_name,
                    bug_reason,
                    'RDM' as source
                FROM rdm_issue
                WHERE sprint_id = :sprint_id
                AND issue_type = '故障'
                AND COALESCE(bug_maker, reporter, '其他') = :developer
            """)
            result = session.execute(query, {
                "sprint_id": sprint_id,
                "developer": developer
            })
        else:
            query = text("""
                SELECT
                    issue_key,
                    COALESCE(bug_maker, reporter, '其他') as developer,
                    priority,
                    issue_name,
                    bug_reason,
                    'RDM' as source
                FROM rdm_issue
                WHERE sprint_id = :sprint_id
                AND issue_type = '故障'
            """)
            result = session.execute(query, {"sprint_id": sprint_id})
        rows = result.fetchall()

        # 在Python中过滤并处理标签
        filtered_rows = []
        for row in rows:
            row_priority = row[2] or ''
            bug_reason = row[4] or ''
            row_tag = '其他'
            if '-' in bug_reason:
                row_tag = bug_reason.split('-')[0].strip()

            if row_priority == priority and row_tag == tag:
                filtered_rows.append({
                    "issue_key": row[0],
                    "developer": row[1],
                    "priority": row_priority,
                    "issue_name": row[3] or '',
                    "reason_analysis": '',  # 原因及分析：先默认为空
                    "is_typical": '',  # 是否典型：先默认为空
                    "source": row[5] or 'RDM',
                    "tag": bug_reason,  # 返回原始bug_reason值
                })

        # 添加序号
        for i, item in enumerate(filtered_rows, 1):
            item["index"] = i

        return filtered_rows
    finally:
        session.close()


@router.get("/bugs/avg-time")
async def get_bug_avg_time(
    sprint_id: int,
    current_user: dict = Depends(get_current_user_from_header)
):
    """获取故障平均Dev时长和Test时长"""
    session = get_session()

    try:
        query = text("""
            SELECT
                COALESCE(AVG(dev_seconds), 0) as avg_dev_seconds,
                COALESCE(AVG(test_seconds), 0) as avg_test_seconds
            FROM rdm_bug_avgtime_sprint
            WHERE sprint_id = :sprint_id
        """)
        result = session.execute(query, {"sprint_id": sprint_id})
        row = result.fetchone()

        return {
            "avg_dev_seconds": int(row[0]) if row[0] else 0,
            "avg_test_seconds": int(row[1]) if row[1] else 0,
        }
    finally:
        session.close()


@router.get("/bugs/reopen")
async def get_reopen_bugs(
    sprint_id: int,
    current_user: dict = Depends(get_current_user_from_header)
):
    """获取故障重开列表"""
    session = get_session()

    try:
        query = text("""
            SELECT
                i.issue_key,
                i.issue_name,
                COALESCE(i.bug_maker, i.reporter, '其他') as bug_maker,
                i.reporter,
                i.bug_type,
                i.priority,
                i.bug_reason,
                i.resolution
            FROM rdm_issue i
            INNER JOIN rdm_bug_changelog c ON i.issue_id = c.bug_id
            WHERE i.sprint_id = :sprint_id
            AND i.issue_type = '故障'
            AND c.change_detail = '待测试 -> 处理中'
            GROUP BY i.issue_id, i.issue_key, i.issue_name, i.bug_maker,
                     i.reporter, i.bug_type, i.priority, i.bug_reason, i.resolution
            ORDER BY i.priority, i.issue_key
        """)
        result = session.execute(query, {"sprint_id": sprint_id})
        rows = result.fetchall()

        items = []
        for idx, row in enumerate(rows, 1):
            items.append({
                "index": idx,
                "issue_key": row[0] or '',
                "issue_name": row[1] or '',
                "bug_maker": row[2] or '',
                "reporter": row[3] or '',
                "bug_type": row[4] or '',
                "priority": row[5] or '',
                "bug_reason": row[6] or '',
                "resolution": row[7] or '',
            })

        return items
    finally:
        session.close()
