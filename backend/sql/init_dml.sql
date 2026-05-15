-- ================================================
-- 项目管理工具数据库初始化脚本
-- 数据库: rdmdb
-- ================================================

USE rdmdb;


-- ================================================
-- 初始化管理员账号 (用户名: admin, 密码: admin123)
-- 初始化普通用户 (用户名: user01, 密码: user123)
-- ================================================
INSERT INTO sys_users (id, username, password, is_admin) VALUES
(1, 'admin', '$2b$12$eo.dPF13lDkHxB7M8.OIiOzr47TrjioW.KEM7c.SZHzNmIsCNtUWy', 1),
(2, 'user01', '$2b$12$9YXCwmRP4TqllrqSKejuhecXkz8mv5BvYIANGzlWeGnWZ6VG1cvny', 0);

-- ================================================
-- 初始化普通用户的JIRA认证配置
-- ================================================
INSERT INTO project_jira_auth (user_id, jira_url, jira_user, jira_token) VALUES
(2, 'http://rdm.zvos.zoomlion.com', '00773908', 'Nx.0918@ZLZK123');

-- ================================================
-- 初始化项目配置数据(归属user01)
-- ================================================
INSERT INTO project_configs (board_id, board_name, project_id, project_name, gitlab_group_key, sonar_key_prefix, sonar_scan_remind_default_person, robot_key, jira_auth_config_id, created_by) VALUES
('732', '智慧矿山', '12112', '三维生产管控系统', 'zhks', '', '施超', '8ea86c1e-6b13-4304-aecc-f174e54ab7e5', 1, 2),
('747', '高精物联平台', '12301', '高精物联平台', '', '', '', '', 1, 2),
('754', '设备管理系统', '12308', '设备管理系统', '', '', '', '', 1, 2),
('788', '环境安全监测平台', '12431', '环境安全监测平台', '', '', '', '', 1, 2),
('797', '无人机巡检系统', '12507', '无人机巡检系统', '', '', '', '', 1, 2),
('834', '皮带撕裂检测系统', '12800', '皮带撕裂检测系统', '', '', '', '', 1, 2),
('892', '数据工具链平台', '13114', '数据工具链平台', 'cmp', 'cmp-', '李昊', '23fc0566-ba86-44f9-8c8c-143d7e0e9603', 1, 2),
('960', '调度系统', '13254', '调度系统', 'dms', 'dms-', '施超', '25832ddb-bf13-45d6-a474-b5d60a76ba67', 1, 2),
('998', '割草机器人', '13318', '割草机器人', 'mowing', '-zvos-', '邓平', 'cf88a622-8bf9-4f02-bfae-9c997150de46', 1, 2),
('1044', '具身智能生态平台', '13718', '具身智能生态平台', 'jsst', 'jsst-', '李昊', '0595f800-9e08-4bfa-adbf-4c0f92dd51e2', 1, 2),
('1036', '具身智能应用开发平台', '13710', '具身智能应用开发平台', 'embodied-adp', '-', '李昊', 'abb2b360-3eec-47b3-bb73-0f78f05b10ec', 1, 2);

-- ================================================
-- 初始化项目提醒设置数据(关联项目配置)
-- ================================================
INSERT INTO project_reminder_settings
(id, project_config_id, need_story_remind, need_task_remind, need_sonar_scan_remind, need_report_data, story_remind_time, task_remind_time, sonar_remind_time, report_data_time)
VALUES
(1, 1, 0, 0, 0, 0, NULL, NULL, NULL, NULL),
(2, 2, 0, 0, 0, 0, NULL, NULL, NULL, NULL),
(3, 3, 0, 0, 0, 0, NULL, NULL, NULL, NULL),
(4, 4, 0, 0, 0, 0, NULL, NULL, NULL, NULL),
(5, 5, 0, 0, 0, 0, NULL, NULL, NULL, NULL),
(6, 6, 0, 0, 0, 0, NULL, NULL, NULL, NULL),
(7, 7, 0,0, 0, 0, NULL, NULL, NULL, NULL),
(8, 8, 0, 0, 0, 0, NULL, NULL, NULL, NULL),
(9, 9, 0, 0, 0, 1, NULL, NULL, NULL, NULL),
(10, 10, 1, 1, 0, 1, '08:30', '17:20', NULL, NULL),
(11, 11, 1, 1, 0, 1, '08:30', '17:20', NULL, NULL);
