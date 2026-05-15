import base64
from dataclasses import dataclass, field
from typing import Dict, List, Optional

import requests

# 默认配置
DEFAULT_AUTH_CONFIG = None


def set_default_auth(user: str, token: str, url: str = "http://rdm.zvos.zoomlion.com"):
    """设置默认认证配置"""
    global DEFAULT_AUTH_CONFIG
    DEFAULT_AUTH_CONFIG = AuthConfig(user=user, token=token, url=url)


@dataclass
class AuthConfig:
    """JIRA认证配置"""

    user: str = ""
    token: str = ""
    url: str = "http://rdm.zvos.zoomlion.com"

    @property
    def headers(self):
        auth_str = base64.b64encode(f"{self.user}:{self.token}".encode("utf-8")).decode(
            "utf-8"
        )
        return {"Authorization": f"Basic {auth_str}"}


# Sprint
@dataclass
class Sprint:
    """Sprint"""

    board_id: str
    board_name: str
    project_id: str
    project_name: str
    sprint_id: str
    origin_sprint_name: str
    sprint_name: str
    short_sprint_name: str
    startdate: Optional[str]
    enddate: Optional[str]
    activated_date: Optional[str]
    complete_date: Optional[str]
    state: str
    goal: Optional[str]
    auth_config: Optional[AuthConfig] = field(default=None)

    def __post_init__(self):
        self.startdate = to_beijing_mysql_datetime(self.startdate)
        self.enddate = to_beijing_mysql_datetime(self.enddate)
        self.activated_date = to_beijing_mysql_datetime(self.activated_date)
        self.complete_date = to_beijing_mysql_datetime(self.complete_date)

    @property
    def auth(self) -> Optional[AuthConfig]:
        """获取认证配置，如果没有项目级别配置则使用默认配置

        注意: set_default_auth() 必须在调用JIRA API之前被调用
        """
        return self.auth_config or DEFAULT_AUTH_CONFIG

    @property
    def headers(self):
        # auth 已在调用前通过 set_default_auth() 设置
        assert self.auth is not None, "请先调用 set_default_auth() 设置JIRA认证"
        return self.auth.headers

    @property
    def api_url(self) -> str:
        # auth 已在调用前通过 set_default_auth() 设置
        assert self.auth is not None, "请先调用 set_default_auth() 设置JIRA认证"
        return self.auth.url

    def url(self) -> str:
        return f"{self.api_url}/rest/agile/1.0/board/{self.board_id}/sprint"

    def issues(
        self, issue_types: Optional[List[str]] = None, need_changelog: bool = False
    ) -> List[Dict]:
        """
        通用的获取issues的函数
        :param issue_types: 用于筛选 bug 的 JQL 条件（可选）
        :param need_changelog: 是否需要变更日志
        :return: 返回 issues 或 bugs 的列表
        """
        issue_types_param = (
            " AND issuetype in ('{}')".format("','".join(issue_types))
            if issue_types
            else ""
        )
        changelog_param = "&expand=changelog" if need_changelog else ""

        search_url = f"{self.api_url}/rest/api/2/search?"
        jql = f"jql=project={self.project_id} AND sprint={self.sprint_id}{issue_types_param}&startAt={{}}&maxResults={{}}{changelog_param}"
        # 分页查询初始值
        _start_at = 0
        _page_size = 500  # 每次请求的最大结果数

        issues = []
        while True:
            # 构造 JQL 查询
            jql = jql.format(_start_at, _page_size)
            url = search_url + jql

            # 发送请求
            resp = requests.get(url, headers=self.headers)
            if resp.status_code == 200:
                data = resp.json()
                issues.extend(data["issues"])

                # 如果已经获取了所有结果，则退出循环
                if len(issues) >= data["total"]:
                    break
                else:
                    # 更新起始位置，继续查询下一页
                    _start_at += _page_size
        return issues

    @property
    def sample_issues(self) -> List[Dict]:
        issues = self.issues(["故事", "简单故事", "子任务", "故障"])
        return [
            {
                "issue_key": issue["key"],
                "issue_name": issue["fields"]["summary"],
                "issue_type": issue["fields"]["issuetype"]["name"],
                "duedate": issue["fields"]["duedate"],
                "assignee": (issue["fields"].get("assignee") or {}).get("displayName")
                or None,
                "status": (issue["fields"].get("status") or {}).get("name") or None,
                "story": (issue["fields"].get("parent") or {}).get("key") or None,
            }
            for issue in issues
        ]

    @property
    def sample_tasks(self) -> List[Dict]:
        issues = self.issues(["子任务"])
        return [
            {
                "issue_key": issue["key"],
                "issue_name": issue["fields"]["summary"],
                "issue_type": issue["fields"]["issuetype"]["name"],
                "duedate": issue["fields"]["duedate"],
                "assignee": (issue["fields"].get("assignee") or {}).get("displayName")
                or None,
                "status": (issue["fields"].get("status") or {}).get("name") or None,
                "story": (issue["fields"].get("parent") or {}).get("key") or None,
            }
            for issue in issues
        ]

    @property
    def rdm_report_data(self):
        """生成RDM报表数据"""
        issues = self.issues([], need_changelog=True)
        stories = [
            issue
            for issue in issues
            if issue["fields"]["issuetype"]["name"] in ["故事", "简单故事"]
        ]
        bugs = [
            issue for issue in issues if issue["fields"]["issuetype"]["name"] == "故障"
        ]

        report_issues = rdm_report_issues(issues)
        sprint_active_date = to_beijing_mysql_datetime(self.activated_date)
        for issue in report_issues:
            issue["sprint_id"] = self.sprint_id
            issue["sprint_name"] = self.sprint_name
            issue["sprint_active_date"] = sprint_active_date
            issue["is_unplaned"] = (
                (1 if issue["created"] > sprint_active_date else 0)
                if sprint_active_date
                else None
            )

        report_stories_changelogs = [
            log for story in stories for log in story_changlogs(story)
        ]

        report_bugs_changelogs = [log for bug in bugs for log in bug_changelogs(bug)]
        # 在 report_bugs_changelogs 添加 project_id、project_name、sprint_id、sprint_name
        for changlog in report_bugs_changelogs:
            changlog["project_id"] = self.project_id
            changlog["project_name"] = self.project_name
            changlog["sprint_id"] = self.sprint_id
            changlog["sprint_name"] = self.sprint_name

        return report_issues, report_stories_changelogs, report_bugs_changelogs


@dataclass
class BaseProject:
    """项目提醒配置信息"""

    board_id: str  # 面板ID
    board_name: str  # 面板名称
    project_id: str  # JIRA项目ID
    project_name: str  # JIRA项目名称


@dataclass
class ProjectRemindConfig(BaseProject):
    """项目提醒配置信息"""

    project_config_id: int = 0  # 数据库项目配置ID
    gitlab_group_key: str = ""  # gitlab 项目的group key
    need_story_remind: bool = False  # 是否需要故事提醒
    need_task_remind: bool = False  # 是否需要子任务到期提醒
    need_sonar_scan_remind: bool = False  # 是否需要Sonar扫描提醒
    need_report_data: bool = False  # 是否需要生产RDM报表数据
    sonar_key_prefix: str = ""  # Sonar key 名称前缀（基于项目名称）
    sonar_scan_remind_default_person: str = ""  # Sonar扫描默认提醒人
    robot_key: str = ""  # 企业微信群机器人key
    jira_user: str = ""  # JIRA用户名
    jira_token: str = ""  # JIRA Token
    # 各任务类型的自定义调度时间 (HH:MM格式，留空使用全局默认)
    story_remind_time: str = ""  # 故事提醒时间
    task_remind_time: str = ""  # 任务提醒时间
    sonar_remind_time: str = ""  # Sonar扫描提醒时间
    report_data_time: str = ""  # 报表数据生成时间


class ProjectUtil:
    def __init__(
        self, project: BaseProject, auth_config: Optional[AuthConfig] = None
    ) -> None:
        self.project = project
        self.auth_config = auth_config or DEFAULT_AUTH_CONFIG

    @property
    def auth(self) -> Optional[AuthConfig]:
        return self.auth_config

    @property
    def headers(self):
        # auth 已在调用前通过 set_default_auth() 设置
        assert self.auth is not None, "请先调用 set_default_auth() 设置JIRA认证"
        return self.auth.headers

    @property
    def api_url(self) -> str:
        # auth 已在调用前通过 set_default_auth() 设置
        assert self.auth is not None, "请先调用 set_default_auth() 设置JIRA认证"
        return self.auth.url

    def url(self):
        return f"{self.api_url}/rest/agile/1.0/board/{self.project.board_id}/project"

    def sprint_to_obj(self, sprint) -> Optional[Sprint]:
        import re

        def sprint_name(name):
            """格式化Sprint名称"""
            return re.sub(
                r"\s+", "-", re.sub(r"Sprint\s+", "Sprint", name, flags=re.IGNORECASE)
            )

        def short_sprint_name(name):
            """格式化Sprint名称（短名称）"""
            return (
                "Sprint" + name[len("md-dc-sp") :]
                if name.startswith("md-dc-sp")
                else (
                    match.group()
                    if (
                        match := re.search(
                            r"Sprint[^-]*",
                            re.sub(
                                r"\s+",
                                "-",
                                re.sub(
                                    r"Sprint\s+", "Sprint", name, flags=re.IGNORECASE
                                ),
                            ),
                            flags=re.IGNORECASE,
                        )
                    )
                    else name
                )
            )

        # 过滤掉不等于参数board_id的数据(之前建错在了其他项目下), 过滤掉cmp项目中以CMP开头的迭代
        if str(sprint.get("originBoardId")) == self.project.board_id and not (
            self.project.board_id == "892" and sprint["name"].startswith("CMP")
        ):
            return Sprint(
                **{
                    "board_id": self.project.board_id,
                    "board_name": self.project.board_name,
                    "project_id": self.project.project_id,
                    "project_name": self.project.project_name,
                    "sprint_id": sprint["id"],
                    "origin_sprint_name": sprint["name"],
                    "sprint_name": sprint_name(sprint["name"]),
                    "short_sprint_name": short_sprint_name(sprint["name"]),
                    "startdate": sprint.get("startDate", None),
                    "enddate": sprint.get("endDate", None),
                    "activated_date": sprint.get("activatedDate", None),
                    "complete_date": sprint.get("completeDate", None),
                    "state": sprint["state"],
                    "goal": sprint.get("goal") or None,
                    "auth_config": self.auth_config,
                }
            )

    @property
    def sprints(self) -> Optional[List[Sprint]]:
        response = requests.get(
            f"{self.api_url}/rest/agile/1.0/board/{self.project.board_id}/sprint",
            headers=self.headers,
        )
        sprint_objs = []
        if response.status_code == 200 and response.json()["values"]:
            for sprint in response.json()["values"]:
                obj = self.sprint_to_obj(sprint)
                if obj:
                    sprint_objs.append(obj)
        return sprint_objs

    @property
    def active_sprints(self) -> Optional[List[Sprint]]:
        """获取激活中的Sprint"""
        response = requests.get(
            f"{self.api_url}/rest/agile/1.0/board/{self.project.board_id}/sprint?state=active",
            headers=self.headers,
        )
        if response.status_code == 200 and response.json()["values"]:
            return [
                s
                for s in [
                    self.sprint_to_obj(sprint) for sprint in response.json()["values"]
                ]
                if s is not None
            ]
        else:
            return []


def to_beijing_mysql_datetime(iso_str: Optional[str]) -> Optional[str]:
    """
    将ISO时间字符串转换为北京时间的MySQL DATETIME格式（无毫秒）
    Args:
        iso_str: ISO 8601格式时间字符串（如 "2025-04-29T09:03:00.000+08:00"）
    Returns:
        str: MySQL兼容的北京时间字符串，格式 "YYYY-MM-DD HH:MI:SS"
    """
    if not iso_str:
        return None
    from datetime import datetime, timedelta, timezone

    # 修正时区格式（+0800 -> +08:00）
    if "+" in iso_str and ":" not in iso_str[-5:]:
        iso_str = f"{iso_str[:-2]}:{iso_str[-2:]}"

    dt = datetime.fromisoformat(iso_str)  # 此时格式为 "2025-02-28T14:40:58.000+08:00"
    beijing_tz = timezone(timedelta(hours=8))
    beijing_time = dt.astimezone(beijing_tz)
    return beijing_time.strftime("%Y-%m-%d %H:%M:%S")


def story_changlogs(story):
    """处理故事中的变更记录"""
    story_id = story["id"]
    story_key = story["key"]
    story_complete_time = to_beijing_mysql_datetime(
        story["fields"].get("resolutiondate", None)
    )
    author = story["fields"]["creator"]["displayName"]
    change_time = to_beijing_mysql_datetime(story["fields"]["created"])

    # 添加创建日志
    story_changelogs = [
        {
            "log_id": 1,
            "story_id": story_id,
            "story_key": story_key,
            "story_complete_time": story_complete_time,
            "author": author,
            "change_time": change_time,
            "change_detail": "创建",
        }
    ]
    # 添加变更日志
    for log in story["changelog"]["histories"]:
        for item in log["items"]:
            if item["field"] == "status":
                story_changelogs.append(
                    {
                        "log_id": log["id"],
                        "story_id": story_id,
                        "story_key": story_key,
                        "story_complete_time": story_complete_time,
                        "author": log["author"]["displayName"],
                        "change_time": to_beijing_mysql_datetime(log["created"]),
                        "change_detail": f"从 {item['fromString']} 变更为 {item['toString']}",
                    }
                )
    return story_changelogs


def bug_changelogs(bug):
    def log_type_detail(log):
        # 检查 items 列表中是否存在 field 为 "status" 的元素
        status_item = next(
            (item for item in log["items"] if item.get("field") == "status"), None
        )
        if status_item:
            _type = "status"
            _detail = (
                status_item.get("fromString") + " -> " + status_item.get("toString")
            )
        else:
            first_item = log["items"][0]
            _type = first_item.get("field")
            if _type in ["summary", "description"]:
                _detail = None
            else:
                _detail = (
                    (first_item.get("fromString") or "")
                    + " -> "
                    + (first_item.get("toString") or "")
                )
        return _type, _detail

    """处理BUG中的变更记录"""
    assignee = (bug["fields"].get("assignee") or {}).get("displayName") or None
    bug_solver = (bug["fields"].get("customfield_11700") or {}).get(
        "displayName"
    ) or assignee

    # 添加创建日志
    changelogs = [
        {
            "log_id": "1",
            "bug_id": bug["id"],
            "bug_key": bug["key"],
            "bug_name": bug["fields"]["summary"],
            "bug_solver": bug_solver,
            "author": bug["fields"]["creator"]["displayName"],
            "change_time": to_beijing_mysql_datetime(bug["fields"]["created"]),
            "change_type": "create",
            "change_detail": None,
        }
    ]

    # 添加变更日志
    logs = bug["changelog"]["histories"]
    if logs:
        for _log in logs:
            change_type, change_detail = log_type_detail(_log)
            changelogs.append(
                {
                    "log_id": _log["id"],
                    "bug_id": bug["id"],
                    "bug_key": bug["key"],
                    "bug_name": bug["fields"]["summary"],
                    "bug_solver": bug_solver,
                    "author": _log["author"]["displayName"],
                    "change_time": to_beijing_mysql_datetime(_log["created"]),
                    "change_type": change_type,
                    "change_detail": change_detail,
                }
            )
    return changelogs


def rdm_report_issues(issues):
    result = []
    for _issue in issues:
        _fields = _issue.get("fields", {})
        _created = to_beijing_mysql_datetime(_fields.get("created"))
        _updated = to_beijing_mysql_datetime(_fields.get("updated"))

        result.append(
            {
                "issue_id": _issue.get("id"),
                "sprint_id": None,
                "sprint_name": None,
                "issue_key": _issue.get("key"),
                "issue_type": _fields["issuetype"]["name"],
                "issue_name": _fields["summary"],
                "reporter": _fields["reporter"]["displayName"],
                "assignee": (_fields.get("assignee") or {}).get("displayName") or None,
                "created": _created,
                "updated": _updated,
                "description": _fields["description"],
                "status": _fields["status"]["name"],
                "resolution": (_fields.get("resolution") or {}).get("name") or None,
                "priority": (_fields.get("priority") or {}).get("name") or None,
                "require_type": (_fields.get("customfield_11302") or {}).get("value")
                or None,
                "callback": int(val)
                if (val := _fields.get("customfield_11300")) is not None
                else None,
                "developer": (_fields.get("customfield_11506") or {}).get("displayName")
                or None,
                "tester": (_fields.get("customfield_11304") or {}).get("displayName")
                or None,
                "duedate": _fields.get("duedate") or None,
                "module": ", ".join(
                    comp["name"] for comp in _fields.get("components", [])
                )
                or None,
                "bug_story": (_fields.get("parent") or {}).get("key") or None,
                "bug_type": (_fields.get("customfield_10303") or {}).get("value")
                or None,
                "bug_flag": (_fields.get("labels") or [None])[0],
                "bug_reason": (
                    f"{v['value']} - {v['child']['value']}"
                    if (v := _fields.get("customfield_11400"))
                    else None
                ),
                "bug_solver": (_fields.get("customfield_11700") or {}).get(
                    "displayName"
                )
                or None,
                "bug_maker": (_fields.get("customfield_11307") or {}).get("displayName")
                or None,
                "is_unplaned": None,
                "sprint_active_date": None,
            }
        )
    return result
