-- ================================================
-- 项目管理工具数据库初始化脚本
-- 数据库: rdmdb
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
