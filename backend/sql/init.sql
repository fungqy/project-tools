-- ================================================
-- 项目管理工具数据库初始化脚本
-- 数据库: rdmdb
-- ================================================

-- 创建数据库(如果不存在)
CREATE DATABASE IF NOT EXISTS rdmdb DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE rdmdb;


-- 创建数据库用户(如果不存在)
CREATE USER IF NOT EXISTS 'rdmuser'@'%' IDENTIFIED BY 'rdmpass123';
CREATE USER IF NOT EXISTS 'rdmuser'@'localhost' IDENTIFIED BY 'rdmpass123';


-- 授权
GRANT ALL PRIVILEGES ON rdmdb.* TO 'rdmuser'@'%';
GRANT ALL PRIVILEGES ON rdmdb.* TO 'rdmuser'@'localhost';

-- 用户表
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '用户ID',
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    password VARCHAR(255) NOT NULL COMMENT '密码(加密存储)',
    is_admin TINYINT(1) DEFAULT 0 COMMENT '是否管理员(0:否,1:是)',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) COMMENT '用户表';

-- ================================================
-- 初始化管理员账号 (用户名: admin, 密码: admin123)
-- 初始化普通用户 (用户名: user01, 密码: user123)
-- ================================================
INSERT INTO users (id, username, password, is_admin) VALUES
(1, 'admin', '$2b$12$eo.dPF13lDkHxB7M8.OIiOzr47TrjioW.KEM7c.SZHzNmIsCNtUWy', 1),
(2, 'user01', '$2b$12$9YXCwmRP4TqllrqSKejuhecXkz8mv5BvYIANGzlWeGnWZ6VG1cvny', 0);

-- JIRA认证配置表
CREATE TABLE IF NOT EXISTS jira_auth_configs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '配置ID',
    user_id BIGINT NOT NULL UNIQUE COMMENT '所属用户ID',
    jira_url VARCHAR(255) NOT NULL DEFAULT 'http://rdm.zvos.zoomlion.com' COMMENT 'JIRA服务器地址',
    jira_user VARCHAR(100) NOT NULL COMMENT 'JIRA用户名',
    jira_token VARCHAR(255) NOT NULL COMMENT 'JIRA Token/Password',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
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
    FOREIGN KEY (jira_auth_config_id) REFERENCES jira_auth_configs(id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL
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
-- 初始化普通用户的JIRA认证配置
-- ================================================
INSERT INTO jira_auth_configs (user_id, jira_url, jira_user, jira_token) VALUES
(2, 'http://rdm.zvos.zoomlion.com', '00773908', 'Nx.0918@ZLZK123');

-- ================================================
-- 初始化项目配置数据(归属user01)
-- ================================================
INSERT INTO project_configs (board_id, board_name, project_id, project_name, gitlab_group_key, sonar_key_prefix, sonar_scan_remind_default_person, robot_key, jira_auth_config_id, created_by) VALUES
('732', '智慧矿山', '12112', '三维生产管控系统', 'zhks', '', '<@施超>', '8ea86c1e-6b13-4304-aecc-f174e54ab7e5', 1, 2),
('747', '高精物联平台', '12301', '高精物联平台', '', '', '', '', 1, 2),
('754', '设备管理系统', '12308', '设备管理系统', '', '', '', '', 1, 2),
('788', '环境安全监测平台', '12431', '环境安全监测平台', '', '', '', '', 1, 2),
('797', '无人机巡检系统', '12507', '无人机巡检系统', '', '', '', '', 1, 2),
('834', '皮带撕裂检测系统', '12800', '皮带撕裂检测系统', '', '', '', '', 1, 2),
('892', '数据工具链平台', '13114', '数据工具链平台', 'cmp', 'cmp-', '<@李昊>', '23fc0566-ba86-44f9-8c8c-143d7e0e9603', 1, 2),
('960', '调度系统', '13254', '调度系统', 'dms', 'dms-', '<@施超>', '25832ddb-bf13-45d6-a474-b5d60a76ba67', 1, 2),
('998', '割草机器人', '13318', '割草机器人', 'mowing', '-zvos-', '<@邓平>', 'cf88a622-8bf9-4f02-bfae-9c997150de46', 1, 2),
('1044', '具身智能生态平台', '13718', '具身智能生态平台', 'jsst', 'jsst-', '<@李昊>', '0595f800-9e08-4bfa-adbf-4c0f92dd51e2', 1, 2),
('1036', '具身智能应用开发平台', '13710', '具身智能应用开发平台', 'embodied-adp', '-', '<@李昊>', 'abb2b360-3eec-47b3-bb73-0f78f05b10ec', 1, 2);

-- ================================================
-- 初始化项目提醒设置数据(关联项目配置)
-- ================================================
INSERT INTO project_reminder_settings (project_config_id, need_story_remind, need_task_remind, need_sonar_scan_remind, need_report_data) VALUES
(1, 1, 1, 0, 0),   -- 智慧矿山：故事提醒+任务提醒
(2, 0, 0, 0, 0),   -- 高精物联平台
(3, 0, 0, 0, 0),   -- 设备管理系统
(4, 0, 0, 0, 0),   -- 环境安全监测平台
(5, 0, 0, 0, 0),   -- 无人机巡检系统
(6, 0, 0, 0, 0),   -- 皮带撕裂检测系统
(7, 1, 1, 0, 1),   -- 数据工具链平台：故事提醒+任务提醒+报表
(8, 1, 1, 1, 1),   -- 调度系统：全部提醒
(9, 0, 0, 0, 1),   -- 割草机器人：仅报表
(10, 1, 1, 0, 0),  -- 具身智能生态平台：故事提醒+任务提醒
(11, 1, 1, 0, 0);  -- 具身智能应用开发平台：故事提醒+任务提醒

-- ================================================
-- 业务报表相关表
-- ================================================

-- 故事完成时长表
CREATE TABLE IF NOT EXISTS stories_complete_duration (
    project_id BIGINT COMMENT '项目ID',
    project_name VARCHAR(255) COMMENT '项目名称',
    sprint_id BIGINT COMMENT 'Sprint ID',
    sprint_name VARCHAR(255) COMMENT 'Sprint名称',
    story_id BIGINT COMMENT '故事ID',
    story_key VARCHAR(50) COMMENT '故事Key',
    story_name VARCHAR(500) COMMENT '故事名称',
    story_create_time DATETIME COMMENT '故事创建时间',
    story_complete_time DATETIME COMMENT '故事完成时间',
    story_complete_duration INT COMMENT '故事完成时长(工作日秒数)',
    story_complete_duration_str VARCHAR(50) COMMENT '故事完成时长(字符串格式)',
    story_complete_duration_all INT COMMENT '故事完成时长(包含非工作日秒数)',
    story_complete_duration_all_str VARCHAR(50) COMMENT '故事完成时长(包含非工作日,字符串格式)'
) COMMENT '故事完成时长表';

-- 故障完成时长表
CREATE TABLE IF NOT EXISTS bugs_complete_duration (
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
    dev_seconds_all INT COMMENT '开发时长(包含非工作日,秒数)',
    dev_seconds INT COMMENT '开发时长(工作日秒数)',
    dev_time_all_str VARCHAR(50) COMMENT '开发时长(包含非工作日,字符串格式)',
    dev_time_str VARCHAR(50) COMMENT '开发时长(字符串格式)',
    test_seconds_all INT COMMENT '测试时长(包含非工作日,秒数)',
    test_seconds INT COMMENT '测试时长(工作日秒数)',
    test_time_all_str VARCHAR(50) COMMENT '测试时长(包含非工作日,字符串格式)',
    test_time_str VARCHAR(50) COMMENT '测试时长(字符串格式)',
    finish_seconds_all INT COMMENT '总完成时长(包含非工作日,秒数)',
    finish_seconds INT COMMENT '总完成时长(工作日秒数)',
    finish_time_all_str VARCHAR(50) COMMENT '总完成时长(包含非工作日,字符串格式)',
    finish_time_str VARCHAR(50) COMMENT '总完成时长(字符串格式)'
) COMMENT '故障完成时长表';

-- 各Sprint故障平均完成时长表
CREATE TABLE IF NOT EXISTS sprints_bugs_avg_complete_duration (
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
) COMMENT '各Sprint故障平均完成时长表';

-- 各开发人员的故障平均完成时长表
CREATE TABLE IF NOT EXISTS authors_bugs_avg_complete_duration (
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
) COMMENT '各开发人员的故障平均完成时长表';

-- 节假日表
CREATE TABLE IF NOT EXISTS holidays (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    datestr DATE COMMENT '日期字符串',
    isholiday TINYINT(1) COMMENT '是否节假日(0:否,1:是)',
    iscompday TINYINT(1) COMMENT '是否调休工作日(0:否,1:是)',
    weekday INT COMMENT '星期几(1-7)',
    UNIQUE KEY uk_datestr (datestr)
) COMMENT '节假日表';

-- 任务执行记录表
CREATE TABLE IF NOT EXISTS task_execution_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    project_config_id BIGINT NOT NULL COMMENT '项目配置ID',
    task_type VARCHAR(50) NOT NULL COMMENT '任务类型(story_reminder/task_reminder/sonar_reminder/report_data)',
    scheduled_time DATETIME NOT NULL COMMENT '计划执行时间',
    executed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '实际执行时间',
    status VARCHAR(20) NOT NULL COMMENT '执行状态(success/failed)',
    error_message VARCHAR(500) DEFAULT '' COMMENT '错误信息',
    FOREIGN KEY (project_config_id) REFERENCES project_configs(id) ON DELETE CASCADE
) COMMENT '任务执行记录表';



-- ==================================
-- RDM
-- ==================================
-- rdmdb.rdm_issue definition

CREATE TABLE `rdm_issue` (
  `issueId` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'issueId',
  `sprint_id` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'sprintId',
  `sprint_name` varchar(512) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'sprint名称',
  `issueKey` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'issueKey',
  `issueType` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'issue类型',
  `issueName` varchar(512) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'issue名称',
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
  KEY `idx_issues_id` (`issueId`),
  KEY `idx_issues_key` (`issueKey`),
  KEY `idx_issues_id_key` (`issueId`,`issueKey`)
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
  `activatedDate` datetime DEFAULT NULL COMMENT 'Sprint激活日期',
  `completeDate` datetime DEFAULT NULL COMMENT 'Sprint完成日期',
  `state` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Sprint状态',
  `goal` varchar(1024) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Sprint目标',
  KEY `idx_sprint_id_name` (`sprint_id`,`sprint_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='rdm sprint数据';


-- rdmdb.bug_flag_class definition

CREATE TABLE `rdm_bug_label_class` (
  `class_id` int DEFAULT NULL COMMENT 'Bug标签分类ID',
  `class_name` varchar(50) DEFAULT NULL COMMENT 'Bug标签分类名称',
  `label` varchar(512) DEFAULT NULL COMMENT 'Bug标签'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Bug标签分类';


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
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='bug变更记录';


-- rdmdb.rdm_storie_changelog definition

CREATE TABLE `rdm_storie_changelog` (
  `log_id` varchar(50) DEFAULT NULL COMMENT '日志id',
  `story_id` varchar(50) DEFAULT NULL COMMENT '故事id',
  `story_key` varchar(50) DEFAULT NULL COMMENT '故事key',
  `story_complete_time` datetime DEFAULT NULL COMMENT '故事完成时间',
  `author` varchar(100) DEFAULT NULL COMMENT '变更人',
  `change_time` datetime DEFAULT NULL COMMENT '变更时间',
  `change_detail` varchar(512) DEFAULT NULL COMMENT '变更详情',
  KEY `idx_story_id` (`story_id`),
  KEY `idx_story_key` (`story_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='故事变更记录';
