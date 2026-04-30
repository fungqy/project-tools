import base64
import requests
from typing import Optional, List, Dict
from dataclasses import dataclass

# 配置
@dataclass(frozen=True)
class AuthConfig:
    _user = '00773908'
    _pass = 'Nx.0918@ZLZK123'
    url = 'http://rdm.zvos.zoomlion.com'
    headers = {
        'Authorization':
            'Basic ' + base64.b64encode(f'{_user}:{_pass}'.encode('utf-8')).decode('utf-8')
    }


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
    activatedDate: Optional[str]
    completeDate: Optional[str]
    state: str
    goal: Optional[str]

    def __post_init__(self):
        self.startdate = to_beijing_mysql_datetime(self.startdate)
        self.enddate = to_beijing_mysql_datetime(self.enddate)
        self.activatedDate = to_beijing_mysql_datetime(self.activatedDate)
        self.completeDate = to_beijing_mysql_datetime(self.completeDate)

    def url(self) -> str:
        return f"{AuthConfig.url}/rest/agile/1.0/board/{self.board_id}/sprint"

    def issues(
            self,
            issue_types: Optional[List[str]] = None,
            need_changelog: bool = False
    ) -> List[Dict]:
        """
        通用的获取issues的函数
        :param issue_types: 用于筛选 bug 的 JQL 条件（可选）
        :param need_changelog: 是否需要变更日志
        :return: 返回 issues 或 bugs 的列表
        """
        issue_types_param = " AND issuetype in ('{}')".format("','".join(issue_types)) if issue_types else ""
        changelog_param = "&expand=changelog" if need_changelog else ""

        search_url = "http://rdm.zvos.zoomlion.com/rest/api/2/search?"
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
            resp = requests.get(url, headers=AuthConfig.headers)
            if resp.status_code == 200:
                data = resp.json()
                issues.extend(data['issues'])

                # 如果已经获取了所有结果，则退出循环
                if len(issues) >= data["total"]:
                    break
                else:
                    # 更新起始位置，继续查询下一页
                    _start_at += _page_size
        return issues

    @property
    def sample_issues(self) -> List[Dict]:
        issues = self.issues(['故事', '简单故事', '子任务', '故障'])
        return [
            {
                'issueKey': issue['key'],
                'issueName': issue['fields']['summary'],
                'issuetype': issue['fields']['issuetype']['name'],
                'duedate': issue['fields']['duedate'],
                'assignee': (issue['fields'].get('assignee') or {}).get('displayName') or None,
                'status': (issue['fields'].get('status') or {}).get('name') or None,
                'story': (issue['fields'].get('parent') or {}).get('key') or None
            }
            for issue in issues
        ]

    @property
    def sample_tasks(self) -> List[Dict]:
        issues = self.issues(['子任务'])
        return [
            {
                'issueKey': issue['key'],
                'issueName': issue['fields']['summary'],
                'issuetype': issue['fields']['issuetype']['name'],
                'duedate': issue['fields']['duedate'],
                'assignee': (issue['fields'].get('assignee') or {}).get('displayName') or None,
                'status': (issue['fields'].get('status') or {}).get('name') or None,
                'story': (issue['fields'].get('parent') or {}).get('key') or None
            }
            for issue in issues
        ]

    @property
    def rdm_report_data(self):
        """生成RDM报表数据"""
        issues = self.issues([], need_changelog=True)
        stories = [issue for issue in issues if issue['fields']['issuetype']['name'] in ['故事', '简单故事']]
        bugs = [issue for issue in issues if issue['fields']['issuetype']['name'] == '故障']

        report_issues = rdm_report_issues(issues)
        sprint_active_date = to_beijing_mysql_datetime(self.activatedDate)
        for issue in report_issues:
            issue['sprint_id'] = self.sprint_id
            issue['sprint_name'] = self.sprint_name
            issue['sprint_active_date'] =  sprint_active_date
            issue['is_unplaned'] =  (1 if issue['created'] > sprint_active_date else 0) if sprint_active_date else None

        report_stories_changelogs = [log for story in stories for log in story_changlogs(story)]

        report_bugs_changelogs = [log for bug in bugs for log in bug_changelogs(bug)
        ]
        # 在 report_bugs_changelogs 添加 project_id、project_name、sprint_id、sprint_name
        for changlog in report_bugs_changelogs:
            changlog['project_id'] = self.project_id
            changlog['project_name'] = self.project_name
            changlog['sprint_id'] = self.sprint_id
            changlog['sprint_name'] = self.sprint_name

        return report_issues, report_stories_changelogs, report_bugs_changelogs

@dataclass
class BaseProject:
    """项目提醒配置信息"""
    board_id: str                  # 面板ID
    board_name: str                # 面板名称
    project_id: str                # JIRA项目ID
    project_name: str              # JIRA项目名称


@dataclass
class ProjectRemindConfig(BaseProject):
    """项目提醒配置信息"""
    gitlab_group_key: str          # gitlab 项目的group key
    need_progress_remind: bool     # 是否需要进行项目进度提醒（含本周故事、子任务到期）
    need_sonar_scan_remind: bool   # 是否需要Sonar扫描提醒
    need_report_data: bool = False # 是否需要生产RDM报表数据
    sonar_key_prefix: str = ""     # Sonar key 名称前缀（基于项目名称）
    sonar_scan_remind_default_person: str = ""  # Sonar扫描默认提醒人
    robot_key: str = "8a0ff77b-9936-42a9-911b-fbbf3ad533d4"  # 企业微信群机器人key


class ProjectUtil:
    def __init__(self, project: BaseProject) -> None:
        self.project = project

    def url(self):
        return f"{AuthConfig.url}/rest/agile/1.0/board/{self.project.board_id}/project"

    def sprint_to_obj(self, sprint) -> Optional[Sprint]:
        import re
        def sprint_name(name):
            """格式化Sprint名称"""
            return re.sub(
                r'\s+',
                '-',
                re.sub(r'Sprint\s+', 'Sprint', name, flags=re.IGNORECASE)
            )

        def short_sprint_name(name):
            """格式化Sprint名称（短名称）"""
            return 'Sprint' + name[len('md-dc-sp'):] if name.startswith('md-dc-sp') else (
                match.group()
                if (match := re.search(
                    r'Sprint[^-]*',
                    re.sub(r'\s+', '-',
                           re.sub(r'Sprint\s+', 'Sprint', name, flags=re.IGNORECASE)),
                    flags=re.IGNORECASE
                ))
                else name
            )

        # 过滤掉不等于参数board_id的数据(之前建错在了其他项目下), 过滤掉cmp项目中以CMP开头的迭代
        if str(sprint.get('originBoardId')) == self.project.board_id and not (
                self.project.board_id == '892' and sprint['name'].startswith('CMP')):
            return (
                Sprint(**{
                    "board_id": self.project.board_id,
                    'board_name': self.project.board_name,
                    'project_id': self.project.project_id,
                    'project_name': self.project.project_name,
                    'sprint_id': sprint['id'],
                    'origin_sprint_name': sprint['name'],
                    'sprint_name': sprint_name(sprint['name']),
                    'short_sprint_name': short_sprint_name(sprint['name']),
                    'startdate': sprint.get('startDate', None),
                    'enddate': sprint.get('endDate', None),
                    'activatedDate': sprint.get('activatedDate', None),
                    'completeDate': sprint.get('completeDate', None),
                    'state': sprint['state'],
                    'goal': sprint.get('goal') or None
                }))

    @property
    def sprints(self) -> Optional[List[Sprint]]:
        response = requests.get(f"{AuthConfig.url}/rest/agile/1.0/board/{self.project.board_id}/sprint", headers=AuthConfig.headers)
        sprint_objs = []
        if response.status_code == 200 and response.json()['values']:
            for sprint in response.json()['values']:
                obj = self.sprint_to_obj(sprint)
                if obj:
                    sprint_objs.append(obj)
        return sprint_objs

    @property
    def active_sprints(self) -> Optional[List[Sprint]]:
        """获取激活中的Sprint"""
        response = requests.get(f"{AuthConfig.url}/rest/agile/1.0/board/{self.project.board_id}/sprint?state=active", headers=AuthConfig.headers)
        if response.status_code == 200 and response.json()['values']:
            return [self.sprint_to_obj(sprint) for sprint in response.json()['values']]
        else:
            return []


class ProjectRemindConfigUtil:
    _ProjectRemindConfigs = [
        ProjectRemindConfig(board_id="732", board_name="智慧矿山", project_id="12112",
                            project_name="三维生产管控系统", gitlab_group_key="zhks", need_progress_remind=True,
                            need_sonar_scan_remind=False, sonar_scan_remind_default_person="<@施超>",
                            robot_key="8ea86c1e-6b13-4304-aecc-f174e54ab7e5"),
        ProjectRemindConfig(board_id="747", board_name="高精物联平台", project_id="12301", project_name="高精物联平台",
                            gitlab_group_key="", need_progress_remind=False, need_sonar_scan_remind=False),
        ProjectRemindConfig(board_id="754", board_name="设备管理系统", project_id="12308", project_name="设备管理系统",
                            gitlab_group_key="", need_progress_remind=False, need_sonar_scan_remind=False),
        ProjectRemindConfig(board_id="788", board_name="环境安全监测平台", project_id="12431",
                            project_name="环境安全监测平台", gitlab_group_key="", need_progress_remind=False,
                            need_sonar_scan_remind=False),
        ProjectRemindConfig(board_id="797", board_name="无人机巡检系统", project_id="12507",
                            project_name="无人机巡检系统",
                            gitlab_group_key="", need_progress_remind=False, need_sonar_scan_remind=False),
        ProjectRemindConfig(board_id="834", board_name="皮带撕裂检测系统", project_id="12800",
                            project_name="皮带撕裂检测系统", gitlab_group_key="", need_progress_remind=False,
                            need_sonar_scan_remind=False),
        ProjectRemindConfig(board_id="892", board_name="数据工具链平台", project_id="13114",
                            project_name="数据工具链平台",
                            gitlab_group_key="cmp", need_progress_remind=True, need_sonar_scan_remind=False,
                            need_report_data=True, sonar_key_prefix="cmp-", sonar_scan_remind_default_person="<@李昊>",
                            robot_key="23fc0566-ba86-44f9-8c8c-143d7e0e9603"),
        ProjectRemindConfig(board_id="960", board_name="调度系统", project_id="13254", need_report_data=True,
                            project_name="调度系统",
                            gitlab_group_key="dms", need_progress_remind=True, need_sonar_scan_remind=True,
                            sonar_key_prefix="dms-", sonar_scan_remind_default_person="<@施超>",
                            robot_key="25832ddb-bf13-45d6-a474-b5d60a76ba67"),
        ProjectRemindConfig(board_id="998", board_name="割草机器人", project_id="13318", need_report_data=True,
                            project_name="割草机器人",
                            gitlab_group_key="mowing", need_progress_remind=False, need_sonar_scan_remind=False,
                            sonar_key_prefix="-zvos-", sonar_scan_remind_default_person="<@邓平>",
                            robot_key="cf88a622-8bf9-4f02-bfae-9c997150de46"),
        ProjectRemindConfig(board_id="1044", board_name="具身智能生态平台", project_id="13718", need_report_data=False,
                            project_name="具身智能生态平台",
                            gitlab_group_key="jsst", need_progress_remind=True, need_sonar_scan_remind=False,
                            sonar_key_prefix="jsst-", sonar_scan_remind_default_person="<@李昊>",
                            robot_key="0595f800-9e08-4bfa-adbf-4c0f92dd51e2"),
        ProjectRemindConfig(board_id="1036", board_name="具身智能应用开发平台", project_id="13710", need_report_data=False,
                            project_name="具身智能应用开发平台",
                            gitlab_group_key="embodied-adp", need_progress_remind=True, need_sonar_scan_remind=False,
                            sonar_key_prefix="-", sonar_scan_remind_default_person="<@李昊>",
                            robot_key="abb2b360-3eec-47b3-bb73-0f78f05b10ec")
    ]

    @classmethod
    def config(cls, board_id: str) -> ProjectRemindConfig:
        return next((item for item in cls._ProjectRemindConfigs if item.board_id == board_id), None)

    @classmethod
    def configs(cls):
        return cls._ProjectRemindConfigs


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
    from datetime import datetime, timezone, timedelta
    # 修正时区格式（+0800 -> +08:00）
    if "+" in iso_str and ":" not in iso_str[-5:]:
        iso_str = f"{iso_str[:-2]}:{iso_str[-2:]}"

    dt = datetime.fromisoformat(iso_str)  # 此时格式为 "2025-02-28T14:40:58.000+08:00"
    beijing_tz = timezone(timedelta(hours=8))
    beijing_time = dt.astimezone(beijing_tz)
    return beijing_time.strftime("%Y-%m-%d %H:%M:%S")


def story_changlogs(story):
    """处理故事中的变更记录"""
    story_id = story['id']
    story_key = story['key']
    story_complete_time = to_beijing_mysql_datetime(story['fields'].get('resolutiondate', None))
    author = story['fields']['creator']['displayName']
    change_time = to_beijing_mysql_datetime(story['fields']['created'])

    # 添加创建日志
    story_changelogs = [{'log_id': 1, 'story_id': story_id, 'story_key': story_key,
                         'story_complete_time': story_complete_time, 'author': author,
                         'change_time': change_time, 'change_detail': '创建'}]
    # 添加变更日志
    for log in story['changelog']['histories']:
        for item in log['items']:
            if item['field'] == 'status':
                story_changelogs.append({
                    'log_id': log['id'],
                    'story_id': story_id,
                    'story_key': story_key,
                    'story_complete_time': story_complete_time,
                    'author': log['author']['displayName'],
                    'change_time': to_beijing_mysql_datetime(log['created']),
                    'change_detail': f"从 {item['fromString']} 变更为 {item['toString']}"})
    return story_changelogs


def bug_changelogs(bug):
    def log_type_detail(log):
        # 检查 items 列表中是否存在 field 为 "status" 的元素
        status_item = next((item for item in log['items'] if item.get('field') == 'status'), None)
        if status_item:
            _type = "status"
            _detail = status_item.get('fromString') + " -> " + status_item.get('toString')
        else:
            first_item = log['items'][0]
            _type = first_item.get('field')
            if _type in ['summary', 'description']:
                _detail = None
            else:
                _detail = (first_item.get('fromString') or "") + " -> " + (first_item.get('toString') or "")
        return _type, _detail
    """处理BUG中的变更记录"""
    assignee = (bug['fields'].get('assignee') or {}).get('displayName') or None
    bug_solver = (bug['fields'].get('customfield_11700') or {}).get('displayName') or assignee

    # 添加创建日志
    changelogs = [{
        'log_id': "1",
        'bug_id': bug['id'],
        'bug_key': bug['key'],
        'bug_name': bug['fields']['summary'],
        'bug_solver': bug_solver,
        'author': bug['fields']['creator']['displayName'],
        'change_time': to_beijing_mysql_datetime(bug['fields']['created']),
        'change_type': "create",
        'change_detail': None
    }]

    # 添加变更日志
    logs = bug['changelog']['histories']
    if logs:
        for _log in logs:
            change_type, change_detail = log_type_detail(_log)
            changelogs.append({
                'log_id': _log['id'],
                'bug_id': bug['id'],
                'bug_key': bug['key'],
                'bug_name': bug['fields']['summary'],
                'bug_solver': bug_solver,
                'author': _log['author']['displayName'],
                'change_time': to_beijing_mysql_datetime(_log['created']),
                'change_type': change_type,
                'change_detail': change_detail
            })
    return changelogs


def rdm_report_issues(issues):
    result = []
    for _issue in issues:
        _fields = _issue.get('fields', {})
        _created = to_beijing_mysql_datetime(_fields.get('created'))
        _updated = to_beijing_mysql_datetime(_fields.get('updated'))

        result.append(
            {
                'issueId': _issue.get('id'),
                'sprint_id': None,
                'sprint_name': None,
                'issueKey': _issue.get('key'),
                'issueType': _fields['issuetype']['name'],
                'issueName': _fields['summary'],
                'reporter': _fields['reporter']['displayName'],
                'assignee': (_fields.get('assignee') or {}).get('displayName') or None,
                'created': _created,
                'updated': _updated,
                'description': _fields['description'],
                'status': _fields['status']['name'],
                'resolution': (_fields.get('resolution') or {}).get('name') or None,
                'priority': (_fields.get('priority') or {}).get('name') or None,
                'require_type': (_fields.get('customfield_11302') or {}).get('value') or None,
                'callback': int(val) if (val := _fields.get('customfield_11300')) is not None else None,
                'developer': (_fields.get('customfield_11506') or {}).get('displayName') or None,
                'tester': (_fields.get('customfield_11304') or {}).get('displayName') or None,
                'duedate': _fields.get('duedate') or None,
                'module': ", ".join(comp['name'] for comp in _fields.get('components', [])) or None,
                'bug_story': (_fields.get('parent') or {}).get('key') or None,
                'bug_type': (_fields.get('customfield_10303') or {}).get('value') or None,
                'bug_flag': (_fields.get('labels') or [None])[0],
                'bug_reason': (
                    f"{v['value']} - {v['child']['value']}" if (v := _fields.get('customfield_11400')) else None
                ),
                'bug_solver': (_fields.get('customfield_11700') or {}).get('displayName') or None,
                'bug_maker': (_fields.get('customfield_11307') or {}).get('displayName') or None,
                'is_unplaned': None,
                'sprint_active_date': None
            }
        )
    return result


def debug():
    config = ProjectRemindConfigUtil.config("747")
    print(config.robot_key)
    project_util = ProjectUtil(config)
    print(project_util.sprints)


if __name__ == "__main__":
    debug()
