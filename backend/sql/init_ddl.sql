-- ================================================
-- 项目管理工具数据库初始化脚本
-- 数据库: rdmdb
-- ================================================

use rdmdb;

-- 系统用户表
CREATE TABLE IF NOT EXISTS sys_users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '用户ID',
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    password VARCHAR(255) NOT NULL COMMENT '密码(加密存储)',
    is_admin TINYINT(1) DEFAULT 0 COMMENT '是否管理员(0:否,1:是)',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) COMMENT '用户表';

-- 工作日表
CREATE TABLE IF NOT EXISTS sys_workday (
    year INT COMMENT '年份',
    datestr CHAR(10) COMMENT '日期',
    UNIQUE KEY uk_datestr (datestr)
) COMMENT '工作日表';


-- JIRA认证配置表
CREATE TABLE IF NOT EXISTS project_jira_auth (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '配置ID',
    user_id BIGINT NOT NULL UNIQUE COMMENT '所属用户ID',
    jira_url VARCHAR(255) NOT NULL DEFAULT 'http://rdm.zvos.zoomlion.com' COMMENT 'JIRA服务器地址',
    jira_user VARCHAR(100) NOT NULL COMMENT 'JIRA用户名',
    jira_token VARCHAR(255) NOT NULL COMMENT 'JIRA Token/Password',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (user_id) REFERENCES sys_users(id) ON DELETE CASCADE
) COMMENT 'JIRA认证配置表';

-- 项目配置表
CREATE TABLE IF NOT EXISTS project_configs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '配置ID',
    board_id VARCHAR(50) NOT NULL COMMENT 'JIRA面板ID',
    board_name VARCHAR(255) NOT NULL COMMENT 'JIRA面板名称',
    project_id VARCHAR(50) NOT NULL COMMENT 'JIRA项目ID',
    project_name VARCHAR(255) NOT NULL COMMENT 'JIRA项目名称',
    gitlab_group_key VARCHAR(100) DEFAULT '' COMMENT 'GitLab Group Key',
    sonar_key_prefix VARCHAR(100) DEFAULT '' COMMENT 'Sonar Key前缀',
    sonar_scan_remind_default_person VARCHAR(100) DEFAULT '' COMMENT 'Sonar扫描默认提醒人',
    robot_key VARCHAR(100) DEFAULT '' COMMENT '企业微信机器人key',
    jira_user VARCHAR(100) DEFAULT '' COMMENT 'JIRA用户名',
    jira_token VARCHAR(255) DEFAULT '' COMMENT 'JIRA Token',
    jira_auth_config_id BIGINT COMMENT '关联的JIRA认证配置ID',
    created_by BIGINT COMMENT '创建用户ID',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    updated_by BIGINT COMMENT '更新用户ID',
    UNIQUE KEY uk_board_id (board_id),
    UNIQUE KEY uk_project_id (project_id),
    FOREIGN KEY (jira_auth_config_id) REFERENCES project_jira_auth(id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES sys_users(id) ON DELETE SET NULL,
    FOREIGN KEY (updated_by) REFERENCES sys_users(id) ON DELETE SET NULL
) COMMENT '项目配置表';

-- 项目提醒设置表
CREATE TABLE IF NOT EXISTS project_reminder_settings (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    project_config_id BIGINT NOT NULL UNIQUE COMMENT '关联的项目配置ID',
    need_story_remind TINYINT(1) DEFAULT 0 COMMENT '是否需要故事提醒',
    need_task_remind TINYINT(1) DEFAULT 0 COMMENT '是否需要子任务到期提醒',
    need_sonar_scan_remind TINYINT(1) DEFAULT 0 COMMENT '是否需要Sonar扫描提醒',
    need_report_data TINYINT(1) DEFAULT 0 COMMENT '是否需要生产报表数据',
    story_remind_time VARCHAR(10) DEFAULT NULL COMMENT '故事提醒时间(HH:MM格式)',
    task_remind_time VARCHAR(10) DEFAULT NULL COMMENT '任务提醒时间(HH:MM格式)',
    sonar_remind_time VARCHAR(10) DEFAULT NULL COMMENT 'Sonar扫描提醒时间(HH:MM格式)',
    report_data_time VARCHAR(10) DEFAULT NULL COMMENT '报表数据生成时间(HH:MM格式)',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (project_config_id) REFERENCES project_configs(id) ON DELETE CASCADE
) COMMENT '项目提醒设置表';

-- ================================================
-- 业务报表相关表
-- ================================================

-- RDM故事完成时长
CREATE TABLE IF NOT EXISTS rdm_story_duration (
    project_id BIGINT COMMENT '项目ID',
    project_name VARCHAR(255) COMMENT '项目名称',
    sprint_id BIGINT COMMENT 'Sprint ID',
    sprint_name VARCHAR(255) COMMENT 'Sprint名称',
    story_id BIGINT COMMENT '故事ID',
    story_key VARCHAR(50) COMMENT '故事Key',
    story_name VARCHAR(500) COMMENT '故事名称',
    create_time DATETIME COMMENT '故事创建时间',
    complete_time DATETIME COMMENT '故事完成时间',
    duration INT COMMENT '故事完成时长(工作日秒数)',
    duration_str VARCHAR(50) COMMENT '故事完成时长(字符串格式)',
    duration_all INT COMMENT '故事完成时长(包含非工作日秒数)',
    duration_all_str VARCHAR(50) COMMENT '故事完成时长(包含非工作日,字符串格式)'
) COMMENT 'RDM故事完成时长';

-- RDM故障解决时长
CREATE TABLE IF NOT EXISTS rdm_bug_duration (
    project_id BIGINT COMMENT '项目ID',
    project_name VARCHAR(255) COMMENT '项目名称',
    sprint_id BIGINT COMMENT 'Sprint ID',
    sprint_name VARCHAR(255) COMMENT 'Sprint名称',
    short_sprint_name VARCHAR(100) COMMENT 'Sprint简称',
    sprint_seqno INT COMMENT 'Sprint序号',
    bug_id BIGINT COMMENT '故障ID',
    bug_key VARCHAR(50) COMMENT '故障Key',
    bug_name VARCHAR(500) COMMENT '故障名称',
    author VARCHAR(100) COMMENT '开发人员',
    create_time DATETIME COMMENT '创建时间',
    test_time DATETIME COMMENT '测试开始时间',
    finish_time DATETIME COMMENT '完成时间',
    dev_seconds_all BIGINT COMMENT '开发时长(包含非工作日,秒数)',
    dev_seconds BIGINT COMMENT '开发时长(工作日秒数)',
    dev_time_all_str VARCHAR(50) COMMENT '开发时长(包含非工作日,字符串格式)',
    dev_time_str VARCHAR(50) COMMENT '开发时长(字符串格式)',
    test_seconds_all BIGINT COMMENT '测试时长(包含非工作日,秒数)',
    test_seconds BIGINT COMMENT '测试时长(工作日秒数)',
    test_time_all_str VARCHAR(50) COMMENT '测试时长(包含非工作日,字符串格式)',
    test_time_str VARCHAR(50) COMMENT '测试时长(字符串格式)',
    finish_seconds_all BIGINT COMMENT '总完成时长(包含非工作日,秒数)',
    finish_seconds BIGINT COMMENT '总完成时长(工作日秒数)',
    finish_time_all_str VARCHAR(50) COMMENT '总完成时长(包含非工作日,字符串格式)',
    finish_time_str VARCHAR(50) COMMENT '总完成时长(字符串格式)'
) COMMENT 'RDM故障解决时长';

-- RDM各Sprint故障平均解决时长
CREATE TABLE IF NOT EXISTS rdm_bug_avgtime_sprint (
    project_id BIGINT COMMENT '项目ID',
    project_name VARCHAR(255) COMMENT '项目名称',
    sprint_id BIGINT COMMENT 'Sprint ID',
    sprint_name VARCHAR(255) COMMENT 'Sprint名称',
    short_sprint_name VARCHAR(100) COMMENT 'Sprint简称',
    sprint_seqno INT COMMENT 'Sprint序号',
    dev_seconds_all INT COMMENT '平均开发时长(包含非工作日,秒数)',
    dev_seconds INT COMMENT '平均开发时长(工作日秒数)',
    dev_time_all_str VARCHAR(50) COMMENT '平均开发时长(包含非工作日,字符串格式)',
    dev_time_str VARCHAR(50) COMMENT '平均开发时长(字符串格式)',
    test_seconds_all INT COMMENT '平均测试时长(包含非工作日,秒数)',
    test_seconds INT COMMENT '平均测试时长(工作日秒数)',
    test_time_all_str VARCHAR(50) COMMENT '平均测试时长(包含非工作日,字符串格式)',
    test_time_str VARCHAR(50) COMMENT '平均测试时长(字符串格式)',
    finish_seconds_all INT COMMENT '平均总完成时长(包含非工作日,秒数)',
    finish_seconds INT COMMENT '平均总完成时长(工作日秒数)',
    finish_time_all_str VARCHAR(50) COMMENT '平均总完成时长(包含非工作日,字符串格式)',
    finish_time_str VARCHAR(50) COMMENT '平均总完成时长(字符串格式)'
) COMMENT 'RDM各Sprint故障平均解决时长';

-- RDM各开发人员的故障平均解决时长
CREATE TABLE IF NOT EXISTS rdm_bug_avgtime_author (
    project_id BIGINT COMMENT '项目ID',
    project_name VARCHAR(255) COMMENT '项目名称',
    sprint_id BIGINT COMMENT 'Sprint ID',
    sprint_name VARCHAR(255) COMMENT 'Sprint名称',
    short_sprint_name VARCHAR(100) COMMENT 'Sprint简称',
    sprint_seqno INT COMMENT 'Sprint序号',
    author VARCHAR(100) COMMENT '开发人员',
    bug_count INT COMMENT '故障数量',
    dev_seconds_all INT COMMENT '平均开发时长(包含非工作日,秒数)',
    dev_seconds INT COMMENT '平均开发时长(工作日秒数)',
    dev_time_all_str VARCHAR(50) COMMENT '平均开发时长(包含非工作日,字符串格式)',
    dev_time_str VARCHAR(50) COMMENT '平均开发时长(字符串格式)',
    test_seconds_all INT COMMENT '平均测试时长(包含非工作日,秒数)',
    test_seconds INT COMMENT '平均测试时长(工作日秒数)',
    test_time_all_str VARCHAR(50) COMMENT '平均测试时长(包含非工作日,字符串格式)',
    test_time_str VARCHAR(50) COMMENT '平均测试时长(字符串格式)',
    finish_seconds_all INT COMMENT '平均总完成时长(包含非工作日,秒数)',
    finish_seconds INT COMMENT '平均总完成时长(工作日秒数)',
    finish_time_all_str VARCHAR(50) COMMENT '平均总完成时长(包含非工作日,字符串格式)',
    finish_time_str VARCHAR(50) COMMENT '平均总完成时长(字符串格式)'
) COMMENT 'RDM各开发人员的故障平均解决时长';



-- 任务执行记录表
CREATE TABLE IF NOT EXISTS project_task_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    project_config_id BIGINT NOT NULL COMMENT '项目配置ID',
    task_type VARCHAR(50) NOT NULL COMMENT '任务类型(story_reminder/task_reminder/sonar_reminder/report_data)',
    scheduled_time DATETIME NOT NULL COMMENT '计划执行时间',
    executed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '实际执行时间',
    status VARCHAR(20) NOT NULL COMMENT '执行状态(success/failed)',
    error_message VARCHAR(500) DEFAULT '' COMMENT '错误信息',
    task_exec_type VARCHAR(50) NOT NULL COMMENT '任务执行类型(manual/automatic)',
    FOREIGN KEY (project_config_id) REFERENCES project_configs(id) ON DELETE CASCADE
) COMMENT '任务执行记录表';


-- ==================================
-- RDM
-- ==================================
-- rdmdb.rdm_issue definition

CREATE TABLE `rdm_issue` (
  `issue_id` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'issue_id',
  `sprint_id` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'sprint_id',
  `sprint_name` varchar(512) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'sprint名称',
  `issue_key` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'issue_key',
  `issue_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'issue类型',
  `issue_name` varchar(512) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'issue名称',
  `reporter` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '报告人',
  `assignee` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '经办人',
  `created` datetime DEFAULT NULL COMMENT '创建时间',
  `updated` datetime DEFAULT NULL COMMENT '更新时间',
  `description` mediumtext COLLATE utf8mb4_unicode_ci COMMENT '描述',
  `status` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '状态',
  `resolution` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '解决结果',
  `priority` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '优先级',
  `require_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '需求类型',
  `callback` int DEFAULT NULL COMMENT '打回次数',
  `developer` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '开发负责人',
  `tester` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '测试负责人',
  `duedate` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '到期日',
  `module` varchar(512) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '模块',
  `bug_story` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '所属故事',
  `bug_type` varchar(512) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '故障类型',
  `bug_flag` varchar(512) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '故障标签',
  `bug_reason` varchar(512) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '故障原因',
  `bug_solver` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '故障修复人',
  `bug_maker` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '故障产生人',
  `is_unplaned` tinyint DEFAULT NULL COMMENT '是否计划外',
  `sprint_active_date` datetime DEFAULT NULL COMMENT 'sprint启动时间',
  `plan_worktime` float DEFAULT NULL COMMENT '计划工时',
  `actual_worktime` float DEFAULT NULL COMMENT '实际工时',
  `actual_worktime2` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '镜像提交信息',
  KEY `idx_issues_sprint_id_name` (`sprint_id`,`sprint_name`),
  KEY `idx_issues_sprint_id` (`sprint_id`),
  KEY `idx_issues_id` (`issue_id`),
  KEY `idx_issues_key` (`issue_key`),
  KEY `idx_issues_id_key` (`issue_id`,`issue_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='rdm issue数据';

-- rdmdb.rdm_sprint definition

CREATE TABLE `rdm_sprint` (
  `board_id` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '看板id',
  `board_name` varchar(512) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '看板名称',
  `project_id` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '项目id',
  `project_name` varchar(512) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '项目名称',
  `sprint_id` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Sprint id',
  `origin_sprint_name` varchar(512) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '原Sprint名称',
  `sprint_name` varchar(512) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Sprint名称',
  `short_sprint_name` varchar(512) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '短Sprint名称',
  `startdate` datetime DEFAULT NULL COMMENT 'Sprint计划开始日期',
  `enddate` datetime DEFAULT NULL COMMENT 'Sprint计划结束日期',
  `activated_date` datetime DEFAULT NULL COMMENT 'Sprint激活日期',
  `complete_date` datetime DEFAULT NULL COMMENT 'Sprint完成日期',
  `state` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Sprint状态',
  `goal` varchar(1024) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Sprint目标',
  KEY `idx_sprint_id_name` (`sprint_id`,`sprint_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='rdm sprint数据';


-- rdmdb.bug_flag_class definition

CREATE TABLE `rdm_bug_label_class` (
  `class_id` int DEFAULT NULL COMMENT 'Bug标签分类ID',
  `class_name` varchar(50) DEFAULT NULL COMMENT 'Bug标签分类名称',
  `label` varchar(512) DEFAULT NULL COMMENT 'Bug标签'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bug标签分类';


-- rdmdb.rdm_bug_changelog definition

CREATE TABLE `rdm_bug_changelog` (
  `log_id` varchar(50) DEFAULT NULL COMMENT '变更日志id',
  `bug_id` varchar(50) DEFAULT NULL COMMENT '故障id',
  `bug_key` varchar(50) DEFAULT NULL COMMENT '故障key',
  `bug_name` varchar(512) DEFAULT NULL COMMENT '故障名称',
  `bug_solver` varchar(100) DEFAULT NULL COMMENT '故障归属人',
  `author` varchar(100) DEFAULT NULL COMMENT '变更人',
  `change_time` datetime DEFAULT NULL COMMENT '变更时间',
  `change_type` varchar(50) DEFAULT NULL COMMENT '变更类型',
  `change_detail` varchar(512) DEFAULT NULL COMMENT '变更详情',
  `project_id` varchar(50) DEFAULT NULL COMMENT '项目id',
  `project_name` varchar(512) DEFAULT NULL COMMENT '项目名称',
  `sprint_id` varchar(50) DEFAULT NULL COMMENT 'SprintID',
  `sprint_name` varchar(512) DEFAULT NULL COMMENT '看板id',
  KEY `idx_project_sprint_bug` (`project_id`,`sprint_id`,`bug_id`),
  KEY `idx_project_bug` (`project_id`,`bug_id`),
  KEY `idx_sprint_bug` (`sprint_id`,`bug_id`),
  KEY `idx_sprint` (`sprint_id`),
  KEY `idx_bug` (`bug_id`),
  KEY `idx_key` (`bug_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='bug变更记录';


-- rdmdb.rdm_story_changelog definition

CREATE TABLE `rdm_story_changelog` (
  `log_id` varchar(50) DEFAULT NULL COMMENT '日志id',
  `story_id` varchar(50) DEFAULT NULL COMMENT '故事id',
  `story_key` varchar(50) DEFAULT NULL COMMENT '故事key',
  `complete_time` datetime DEFAULT NULL COMMENT '完成时间',
  `author` varchar(100) DEFAULT NULL COMMENT '变更人',
  `change_time` datetime DEFAULT NULL COMMENT '变更时间',
  `change_detail` varchar(512) DEFAULT NULL COMMENT '变更详情',
  KEY `idx_story_id` (`story_id`),
  KEY `idx_story_key` (`story_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='故事变更记录';


-- ==================================
-- DOC
-- ==================================
-- rdmdb.rdm_doc_bug definition

CREATE TABLE `rdm_doc_bug` (
  `key` varchar(50) DEFAULT NULL COMMENT '编码',  -- 取【问题编号】列，若存在为空的数据，提示用户不能导入
  `name` text DEFAULT NULL COMMENT '名称', -- 取【功能点】和【问题详述】列进行拼接，拼接规则：【功能点】>【问题详述】，若【功能点为空】，只取【问题详述】。 【问题详述】存在为空的数据，提示用户不能导入
  `priority` varchar(50) DEFAULT NULL COMMENT '优先级', -- 取优先级列：并按高->严重、中->一般、低->优化进行转换， 若列中数据在高、中、低之外提示用户默认为哪个值
  `reason` varchar(512) DEFAULT NULL COMMENT '原因', -- 取【原因分析】和【处理意见】列进行拼接，拼接规则：【原因分析】>【处理意见】，若【处理意见为空】，只取【原因分析】
  `resolve_method` mediumtext DEFAULT NULL COMMENT '解决方法', -- 取【处理方式】列， 若没有该列，默认为空
  `maker` varchar(100) DEFAULT NULL COMMENT '产生人',  -- 取【处理人】列。需要将内容中的@、换行符、中文逗号都转换成英文逗号，然后按英文逗号分隔，取最后一个不为空的值
  `propose` varchar(100) DEFAULT NULL COMMENT '提出人', -- 取【提出人】列。若没有该列，默认为空。
  `propose_time` datetime DEFAULT NULL COMMENT '提出时间',  -- 取【提出时间】列
  `resolve_time` datetime DEFAULT NULL COMMENT '解决时间',  -- 取【完成时间】列
  `status` varchar(50) DEFAULT NULL COMMENT '状态(不处理、处理中、待测试、继续观察、未开始、验证通过、已解决、转任务、转需求)',  -- 取【处理状态】列，若列中数据不在不处理、处理中、待测试、继续观察、未开始、验证通过、已解决、转任务、转需求这几个范围内，提示补充或修改后上传。
  `type` varchar(100) DEFAULT NULL COMMENT '类型（需求问题、漏做、代码逻辑问题、环境问题、第三方影响、沟通问题）', -- 取【问题类型】列，按规则进行转换。转换规则：代码逻辑问题->代码实现, 漏做->代码实现, 需求问题->业务需求, 环境问题->环境配置, 第三方影响、沟通问题->其他
  `original_type` varchar(100) DEFAULT NULL COMMENT '原类型（需求问题、漏做、代码逻辑问题、环境问题、第三方影响、沟通问题）', -- 取【问题类型】列，若列中数据不在需求问题、漏做、代码逻辑问题、环境问题、第三方影响、沟通问题这几个范围内的数据，提示补充或修改后上传。
  `sprint_id` varchar(50) DEFAULT NULL COMMENT 'SprintID',  
  `project_id` varchar(512) DEFAULT NULL COMMENT '项目ID',
  KEY `idx_doc_bug_key` (`key`),
  KEY `idx_doc_bug_sprint_id` (`sprint_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='文档故障';
