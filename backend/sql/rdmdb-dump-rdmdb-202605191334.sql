-- MySQL dump 10.13  Distrib 8.0.19, for Win64 (x86_64)
--
-- Host: 169.254.106.105    Database: rdmdb
-- ------------------------------------------------------
-- Server version	8.4.8

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `project_configs`
--

DROP TABLE IF EXISTS `project_configs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `project_configs` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '配置ID',
  `board_id` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'JIRA面板ID',
  `board_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'JIRA面板名称',
  `project_id` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'JIRA项目ID',
  `project_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'JIRA项目名称',
  `gitlab_group_key` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT 'GitLab Group Key',
  `sonar_key_prefix` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT 'Sonar Key前缀',
  `sonar_scan_remind_default_person` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT 'Sonar扫描默认提醒人',
  `robot_key` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '企业微信机器人key',
  `jira_user` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT 'JIRA用户名',
  `jira_token` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT 'JIRA Token',
  `jira_auth_config_id` bigint DEFAULT NULL COMMENT '关联的JIRA认证配置ID',
  `created_by` bigint DEFAULT NULL COMMENT '创建用户ID',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `updated_by` bigint DEFAULT NULL COMMENT '更新用户ID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_board_id` (`board_id`),
  UNIQUE KEY `uk_project_id` (`project_id`),
  KEY `jira_auth_config_id` (`jira_auth_config_id`),
  KEY `created_by` (`created_by`),
  KEY `updated_by` (`updated_by`),
  CONSTRAINT `project_configs_ibfk_1` FOREIGN KEY (`jira_auth_config_id`) REFERENCES `project_jira_auth` (`id`) ON DELETE SET NULL,
  CONSTRAINT `project_configs_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `sys_users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `project_configs_ibfk_3` FOREIGN KEY (`updated_by`) REFERENCES `sys_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='项目配置表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `project_configs`
--

LOCK TABLES `project_configs` WRITE;
/*!40000 ALTER TABLE `project_configs` DISABLE KEYS */;
INSERT INTO `project_configs` VALUES (1,'732','智慧矿山','12112','三维生产管控系统','zhks','','<@施超>','8ea86c1e-6b13-4304-aecc-f174e54ab7e5','','',1,2,'2026-05-07 13:57:04','2026-05-07 13:57:04',NULL),(2,'747','高精物联平台','12301','高精物联平台','','','','','','',1,2,'2026-05-07 13:57:04','2026-05-07 13:57:04',NULL),(3,'754','设备管理系统','12308','设备管理系统','','','','','','',1,2,'2026-05-07 13:57:04','2026-05-07 13:57:04',NULL),(4,'788','环境安全监测平台','12431','环境安全监测平台','','','','','','',1,2,'2026-05-07 13:57:04','2026-05-07 13:57:04',NULL),(5,'797','无人机巡检系统','12507','无人机巡检系统','','','','','','',1,2,'2026-05-07 13:57:04','2026-05-07 13:57:04',NULL),(6,'834','皮带撕裂检测系统','12800','皮带撕裂检测系统','','','','','','',1,2,'2026-05-07 13:57:04','2026-05-07 13:57:04',NULL),(7,'892','数据工具链平台','13114','数据工具链平台','cmp','cmp-','<@李昊>','23fc0566-ba86-44f9-8c8c-143d7e0e9603','','',1,2,'2026-05-07 13:57:04','2026-05-07 13:57:04',NULL),(8,'960','调度系统','13254','调度系统','dms','dms-','<@施超>','25832ddb-bf13-45d6-a474-b5d60a76ba67','','',1,2,'2026-05-07 13:57:04','2026-05-07 13:57:04',NULL),(9,'998','割草机器人','13318','割草机器人','mowing','-zvos-','<@邓平>','cf88a622-8bf9-4f02-bfae-9c997150de46','','',1,2,'2026-05-07 13:57:04','2026-05-07 13:57:04',NULL),(10,'1044','具身智能生态平台','13718','具身智能生态平台','jsst','jsst-','<@李昊>','0595f800-9e08-4bfa-adbf-4c0f92dd51e2','','',1,2,'2026-05-07 13:57:04','2026-05-07 13:57:04',NULL),(11,'1036','具身智能应用开发平台','13710','具身智能应用开发平台','embodied-adp','-','<@李昊>','abb2b360-3eec-47b3-bb73-0f78f05b10ec','00773908','Nx@3.1415926',1,2,'2026-05-07 13:57:04','2026-05-07 18:25:11',1);
/*!40000 ALTER TABLE `project_configs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `project_jira_auth`
--

DROP TABLE IF EXISTS `project_jira_auth`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `project_jira_auth` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '配置ID',
  `user_id` bigint NOT NULL COMMENT '所属用户ID',
  `jira_url` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'http://rdm.zvos.zoomlion.com' COMMENT 'JIRA服务器地址',
  `jira_user` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'JIRA用户名',
  `jira_token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'JIRA Token/Password',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `project_jira_auth_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `sys_users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='JIRA认证配置表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `project_jira_auth`
--

LOCK TABLES `project_jira_auth` WRITE;
/*!40000 ALTER TABLE `project_jira_auth` DISABLE KEYS */;
INSERT INTO `project_jira_auth` VALUES (1,2,'http://rdm.zvos.zoomlion.com','00773908','Nx.0918@ZLZK123','2026-05-07 13:57:04','2026-05-07 13:57:04');
/*!40000 ALTER TABLE `project_jira_auth` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `project_reminder_settings`
--

DROP TABLE IF EXISTS `project_reminder_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `project_reminder_settings` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `project_config_id` bigint NOT NULL COMMENT '关联的项目配置ID',
  `need_story_remind` tinyint(1) DEFAULT '0' COMMENT '是否需要故事提醒',
  `need_task_remind` tinyint(1) DEFAULT '0' COMMENT '是否需要子任务到期提醒',
  `need_sonar_scan_remind` tinyint(1) DEFAULT '0' COMMENT '是否需要Sonar扫描提醒',
  `need_report_data` tinyint(1) DEFAULT '0' COMMENT '是否需要生产报表数据',
  `story_remind_time` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '故事提醒时间(HH:MM格式)',
  `task_remind_time` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '任务提醒时间(HH:MM格式)',
  `sonar_remind_time` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Sonar扫描提醒时间(HH:MM格式)',
  `report_data_time` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '报表数据生成时间(HH:MM格式)',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `project_config_id` (`project_config_id`),
  CONSTRAINT `project_reminder_settings_ibfk_1` FOREIGN KEY (`project_config_id`) REFERENCES `project_configs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='项目提醒设置表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `project_reminder_settings`
--

LOCK TABLES `project_reminder_settings` WRITE;
/*!40000 ALTER TABLE `project_reminder_settings` DISABLE KEYS */;
INSERT INTO `project_reminder_settings` VALUES (1,1,0,0,0,0,NULL,NULL,NULL,NULL,'2026-05-15 15:06:40','2026-05-15 15:06:40'),(2,2,0,0,0,0,NULL,NULL,NULL,NULL,'2026-05-15 15:06:40','2026-05-15 15:06:40'),(3,3,0,0,0,0,NULL,NULL,NULL,NULL,'2026-05-15 15:06:40','2026-05-15 15:06:40'),(4,4,0,0,0,0,NULL,NULL,NULL,NULL,'2026-05-15 15:06:40','2026-05-15 15:06:40'),(5,5,0,0,0,0,NULL,NULL,NULL,NULL,'2026-05-15 15:06:40','2026-05-15 15:06:40'),(6,6,0,0,0,0,NULL,NULL,NULL,NULL,'2026-05-15 15:06:40','2026-05-15 15:06:40'),(7,7,0,0,0,0,NULL,NULL,NULL,NULL,'2026-05-15 15:06:40','2026-05-15 15:06:40'),(8,8,0,0,0,0,NULL,NULL,NULL,NULL,'2026-05-15 15:06:40','2026-05-15 15:06:40'),(9,9,0,0,0,1,NULL,NULL,NULL,NULL,'2026-05-15 15:06:40','2026-05-15 15:06:40'),(10,10,1,1,0,1,'08:30','17:20',NULL,'17:20','2026-05-15 15:06:40','2026-05-15 15:07:15'),(11,11,1,1,0,1,'08:30','17:20',NULL,'17:20','2026-05-15 15:06:40','2026-05-15 15:07:15');
/*!40000 ALTER TABLE `project_reminder_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `project_task_logs`
--

DROP TABLE IF EXISTS `project_task_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `project_task_logs` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `project_config_id` bigint NOT NULL COMMENT '项目配置ID',
  `task_type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '任务类型(story_reminder/task_reminder/sonar_reminder/report_data)',
  `scheduled_time` datetime NOT NULL COMMENT '计划执行时间',
  `executed_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '实际执行时间',
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '执行状态(success/failed)',
  `error_message` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '错误信息',
  `task_exec_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'automatic' COMMENT '任务执行类型(manual/automatic)',
  PRIMARY KEY (`id`),
  KEY `project_config_id` (`project_config_id`),
  CONSTRAINT `project_task_logs_ibfk_1` FOREIGN KEY (`project_config_id`) REFERENCES `project_configs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='任务执行记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `project_task_logs`
--

LOCK TABLES `project_task_logs` WRITE;
/*!40000 ALTER TABLE `project_task_logs` DISABLE KEYS */;
INSERT INTO `project_task_logs` VALUES (4,11,'story_reminder','2026-05-07 18:30:00','2026-05-07 18:30:00','failed','HTTPConnectionPool(host=\'rdm.zvos.zoomlion.com\', port=80): Max retries exceeded with url: /rest/agile/1.0/board/1036/sprint?state=active (Caused by NameResolutionError(\"<urllib3.connection.HTTPConnection object at 0x71c769d7a290>: Failed to resolve \'rdm.zvos.zoomlion.com\' ([Errno -2] Name or service not known)\"))','automatic'),(5,11,'task_reminder','2026-05-08 14:00:00','2026-05-08 14:00:02','failed','HTTPConnectionPool(host=\'rdm.zvos.zoomlion.com\', port=80): Max retries exceeded with url: /rest/agile/1.0/board/1036/sprint?state=active (Caused by NameResolutionError(\"<urllib3.connection.HTTPConnection object at 0x713e085d7610>: Failed to resolve \'rdm.zvos.zoomlion.com\' ([Errno -2] Name or service not known)\"))','automatic'),(6,11,'story_reminder','2026-05-08 18:30:00','2026-05-08 18:30:06','failed','HTTPConnectionPool(host=\'rdm.zvos.zoomlion.com\', port=80): Max retries exceeded with url: /rest/agile/1.0/board/1036/sprint?state=active (Caused by NameResolutionError(\"<urllib3.connection.HTTPConnection object at 0x708e0c158f90>: Failed to resolve \'rdm.zvos.zoomlion.com\' ([Errno -2] Name or service not known)\"))','automatic'),(7,11,'sonar_reminder','2026-05-09 01:00:00','2026-05-09 01:00:00','failed','HTTPConnectionPool(host=\'gitlab.zoomlion.com\', port=80): Max retries exceeded with url: /api/v4/groups/embodied-adp/projects?per_page=200 (Caused by NameResolutionError(\"<urllib3.connection.HTTPConnection object at 0x75e898c7f2d0>: Failed to resolve \'gitlab.zoomlion.com\' ([Errno -2] Name or service not known)\"))','automatic'),(8,11,'task_reminder','2026-05-09 09:00:00','2026-05-09 09:00:00','failed','HTTPConnectionPool(host=\'rdm.zvos.zoomlion.com\', port=80): Max retries exceeded with url: /rest/agile/1.0/board/1036/sprint?state=active (Caused by NameResolutionError(\"<urllib3.connection.HTTPConnection object at 0x7a8ad0232550>: Failed to resolve \'rdm.zvos.zoomlion.com\' ([Errno -2] Name or service not known)\"))','automatic'),(9,10,'task_reminder','2026-05-15 17:20:00','2026-05-15 17:20:00','failed','HTTPConnectionPool(host=\'rdm.zvos.zoomlion.com\', port=80): Max retries exceeded with url: /rest/agile/1.0/board/1044/sprint?state=active (Caused by NameResolutionError(\"<urllib3.connection.HTTPConnection object at 0x715dc19bf710>: Failed to resolve \'rdm.zvos.zoomlion.com\' ([Errno -2] Name or service not known)\"))','automatic'),(10,11,'task_reminder','2026-05-15 17:20:00','2026-05-15 17:20:00','failed','HTTPConnectionPool(host=\'rdm.zvos.zoomlion.com\', port=80): Max retries exceeded with url: /rest/agile/1.0/board/1036/sprint?state=active (Caused by NameResolutionError(\"<urllib3.connection.HTTPConnection object at 0x715dc1a060d0>: Failed to resolve \'rdm.zvos.zoomlion.com\' ([Errno -2] Name or service not known)\"))','automatic');
/*!40000 ALTER TABLE `project_task_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rdm_bug_avgtime_author`
--

DROP TABLE IF EXISTS `rdm_bug_avgtime_author`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rdm_bug_avgtime_author` (
  `project_id` bigint DEFAULT NULL COMMENT '项目ID',
  `project_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '项目名称',
  `sprint_id` bigint DEFAULT NULL COMMENT 'Sprint ID',
  `sprint_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Sprint名称',
  `short_sprint_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Sprint简称',
  `sprint_seqno` int DEFAULT NULL COMMENT 'Sprint序号',
  `author` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '开发人员',
  `bug_count` int DEFAULT NULL COMMENT '故障数量',
  `dev_seconds_all` int DEFAULT NULL COMMENT '平均开发时长(包含非工作日,秒数)',
  `dev_seconds` int DEFAULT NULL COMMENT '平均开发时长(工作日秒数)',
  `dev_time_all_str` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '平均开发时长(包含非工作日,字符串格式)',
  `dev_time_str` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '平均开发时长(字符串格式)',
  `test_seconds_all` int DEFAULT NULL COMMENT '平均测试时长(包含非工作日,秒数)',
  `test_seconds` int DEFAULT NULL COMMENT '平均测试时长(工作日秒数)',
  `test_time_all_str` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '平均测试时长(包含非工作日,字符串格式)',
  `test_time_str` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '平均测试时长(字符串格式)',
  `finish_seconds_all` int DEFAULT NULL COMMENT '平均总完成时长(包含非工作日,秒数)',
  `finish_seconds` int DEFAULT NULL COMMENT '平均总完成时长(工作日秒数)',
  `finish_time_all_str` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '平均总完成时长(包含非工作日,字符串格式)',
  `finish_time_str` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '平均总完成时长(字符串格式)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='RDM各开发人员的故障平均解决时长';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rdm_bug_avgtime_author`
--

LOCK TABLES `rdm_bug_avgtime_author` WRITE;
/*!40000 ALTER TABLE `rdm_bug_avgtime_author` DISABLE KEYS */;
INSERT INTO `rdm_bug_avgtime_author` VALUES (13718,'具身智能生态平台',7492,'JSST-1.0-Sprint-8','Sprint',9,'段星宇',2,20196,20196,'5小时37分','5小时37分',66035,66034,'1天18小时','1天18小时',86231,86230,'1天0小时','1天0小时'),(13718,'具身智能生态平台',7492,'JSST-1.0-Sprint-8','Sprint',9,'杨霄',18,51436,51435,'1天14小时','1天14小时',15326,15326,'4小时15分','4小时15分',66762,66761,'1天19小时','1天19小时'),(13718,'具身智能生态平台',7492,'JSST-1.0-Sprint-8','Sprint',9,'杨辉煌',2,56763,56762,'1天16小时','1天16小时',528,528,'9分','9分',57291,57290,'1天16小时','1天16小时'),(13718,'具身智能生态平台',7629,'JSST-1.0-Sprint-9','Sprint',10,'段星宇',2,5961,5961,'1小时39分','1小时39分',163,163,'3分','3分',6124,6124,'1小时42分','1小时42分'),(13718,'具身智能生态平台',7629,'JSST-1.0-Sprint-9','Sprint',10,'杨辉煌',2,2577,2577,'43分','43分',251,251,'4分','4分',2828,2828,'47分','47分');
/*!40000 ALTER TABLE `rdm_bug_avgtime_author` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rdm_bug_avgtime_sprint`
--

DROP TABLE IF EXISTS `rdm_bug_avgtime_sprint`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rdm_bug_avgtime_sprint` (
  `project_id` bigint DEFAULT NULL COMMENT '项目ID',
  `project_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '项目名称',
  `sprint_id` bigint DEFAULT NULL COMMENT 'Sprint ID',
  `sprint_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Sprint名称',
  `short_sprint_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Sprint简称',
  `sprint_seqno` int DEFAULT NULL COMMENT 'Sprint序号',
  `dev_seconds_all` int DEFAULT NULL COMMENT '平均开发时长(包含非工作日,秒数)',
  `dev_seconds` int DEFAULT NULL COMMENT '平均开发时长(工作日秒数)',
  `dev_time_all_str` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '平均开发时长(包含非工作日,字符串格式)',
  `dev_time_str` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '平均开发时长(字符串格式)',
  `test_seconds_all` int DEFAULT NULL COMMENT '平均测试时长(包含非工作日,秒数)',
  `test_seconds` int DEFAULT NULL COMMENT '平均测试时长(工作日秒数)',
  `test_time_all_str` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '平均测试时长(包含非工作日,字符串格式)',
  `test_time_str` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '平均测试时长(字符串格式)',
  `finish_seconds_all` int DEFAULT NULL COMMENT '平均总完成时长(包含非工作日,秒数)',
  `finish_seconds` int DEFAULT NULL COMMENT '平均总完成时长(工作日秒数)',
  `finish_time_all_str` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '平均总完成时长(包含非工作日,字符串格式)',
  `finish_time_str` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '平均总完成时长(字符串格式)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='RDM各Sprint故障平均解决时长';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rdm_bug_avgtime_sprint`
--

LOCK TABLES `rdm_bug_avgtime_sprint` WRITE;
/*!40000 ALTER TABLE `rdm_bug_avgtime_sprint` DISABLE KEYS */;
INSERT INTO `rdm_bug_avgtime_sprint` VALUES (13718,'具身智能生态平台',7492,'JSST-1.0-Sprint-8','Sprint',9,49080,49079,'1天14小时','1天14小时',18591,18590,'5小时10分','5小时10分',67671,67670,'1天19小时','1天19小时'),(13718,'具身智能生态平台',7629,'JSST-1.0-Sprint-9','Sprint',10,4269,4269,'1小时11分','1小时11分',207,207,'3分','3分',4476,4476,'1小时15分','1小时15分');
/*!40000 ALTER TABLE `rdm_bug_avgtime_sprint` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rdm_bug_changelog`
--

DROP TABLE IF EXISTS `rdm_bug_changelog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='bug变更记录';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rdm_bug_changelog`
--

LOCK TABLES `rdm_bug_changelog` WRITE;
/*!40000 ALTER TABLE `rdm_bug_changelog` DISABLE KEYS */;
INSERT INTO `rdm_bug_changelog` VALUES ('1','892482','JSST-2010','【AWS】用户认证','段星宇','陈钊宏','2026-03-23 14:14:39','create',NULL,'13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('6939234','892482','JSST-2010','【AWS】用户认证','段星宇','陈钊宏','2026-03-23 14:39:13','Attachment',' -> image-2026-03-23-14-39-13-094.png','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('6939245','892482','JSST-2010','【AWS】用户认证','段星宇','陈钊宏','2026-03-23 14:40:20','Attachment',' -> image-2026-03-23-14-40-20-184.png','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('6939247','892482','JSST-2010','【AWS】用户认证','段星宇','陈钊宏','2026-03-23 14:40:31','description',NULL,'13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('6941874','892482','JSST-2010','【AWS】用户认证','段星宇','段星宇','2026-03-23 19:51:08','status','待办 -> 处理中','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('6941875','892482','JSST-2010','【AWS】用户认证','段星宇','段星宇','2026-03-23 19:51:15','status','处理中 -> 待测试','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('6946480','892482','JSST-2010','【AWS】用户认证','段星宇','陈钊宏','2026-03-24 14:11:50','status','待测试 -> 完成','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('1','892525','JSST-2011','【AWS】账户登录','杨霄','陈钊宏','2026-03-23 14:31:33','create',NULL,'13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('6939148','892525','JSST-2011','【AWS】账户登录','杨霄','陈钊宏','2026-03-23 14:31:39','Sprint',' -> JSST-1.0-Sprint-8','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('6939149','892525','JSST-2011','【AWS】账户登录','杨霄','陈钊宏','2026-03-23 14:31:39','等级',' -> 评级更高','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('6939221','892525','JSST-2011','【AWS】账户登录','杨霄','罗丽辉','2026-03-23 14:37:42','description',NULL,'13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('6939227','892525','JSST-2011','【AWS】账户登录','杨霄','罗丽辉','2026-03-23 14:38:10','description',NULL,'13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('6939239','892525','JSST-2011','【AWS】账户登录','杨霄','罗丽辉','2026-03-23 14:39:32','assignee','罗丽辉 -> 杨霄','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('6941047','892525','JSST-2011','【AWS】账户登录','杨霄','杨霄','2026-03-23 17:00:25','status','待办 -> 处理中','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('6941049','892525','JSST-2011','【AWS】账户登录','杨霄','杨霄','2026-03-23 17:00:33','status','处理中 -> 待测试','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('6949301','892525','JSST-2011','【AWS】账户登录','杨霄','陈钊宏','2026-03-24 16:55:44','status','待测试 -> 完成','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('1','892566','JSST-2012','移动端无法登出','杨霄','罗丽辉','2026-03-23 14:50:31','create',NULL,'13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('6941061','892566','JSST-2012','移动端无法登出','杨霄','杨霄','2026-03-23 17:02:28','status','待办 -> 处理中','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('6941063','892566','JSST-2012','移动端无法登出','杨霄','杨霄','2026-03-23 17:02:38','status','处理中 -> 待测试','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('6941705','892566','JSST-2012','移动端无法登出','杨霄','罗丽辉','2026-03-23 19:19:11','status','待测试 -> 完成','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('1','892760','JSST-2015','登录时账号或密码错误，Log in 按钮一直转圈圈，无法点击','杨霄','罗丽辉','2026-03-23 16:27:19','create',NULL,'13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('6941068','892760','JSST-2015','登录时账号或密码错误，Log in 按钮一直转圈圈，无法点击','杨霄','杨霄','2026-03-23 17:02:59','status','待办 -> 处理中','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('6941072','892760','JSST-2015','登录时账号或密码错误，Log in 按钮一直转圈圈，无法点击','杨霄','杨霄','2026-03-23 17:03:07','status','处理中 -> 待测试','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('6941098','892760','JSST-2015','登录时账号或密码错误，Log in 按钮一直转圈圈，无法点击','杨霄','罗丽辉','2026-03-23 17:06:05','status','待测试 -> 完成','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('1','892791','JSST-2016','输入错误密码后，强刷页面，输入正确的密码也登录不了','杨霄','罗丽辉','2026-03-23 16:50:15','create',NULL,'13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('6941066','892791','JSST-2016','输入错误密码后，强刷页面，输入正确的密码也登录不了','杨霄','杨霄','2026-03-23 17:02:46','status','待办 -> 处理中','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('6941067','892791','JSST-2016','输入错误密码后，强刷页面，输入正确的密码也登录不了','杨霄','杨霄','2026-03-23 17:02:53','status','处理中 -> 待测试','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('6941102','892791','JSST-2016','输入错误密码后，强刷页面，输入正确的密码也登录不了','杨霄','罗丽辉','2026-03-23 17:06:55','status','待测试 -> 完成','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('1','892975','JSST-2017','用户认证未做移动端适配','杨霄','罗丽辉','2026-03-23 19:33:56','create',NULL,'13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('6945121','892975','JSST-2017','用户认证未做移动端适配','杨霄','杨霄','2026-03-24 11:40:25','status','待办 -> 处理中','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('6945141','892975','JSST-2017','用户认证未做移动端适配','杨霄','杨霄','2026-03-24 11:40:35','status','处理中 -> 待测试','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('6946801','892975','JSST-2017','用户认证未做移动端适配','杨霄','罗丽辉','2026-03-24 14:18:08','status','待测试 -> 完成','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('1','892983','JSST-2018','邮箱验证码登录时，输入错误验证码，点击登录未停留在原页','杨霄','罗丽辉','2026-03-23 19:45:04','create',NULL,'13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('6941853','892983','JSST-2018','邮箱验证码登录时，输入错误验证码，点击登录未停留在原页','杨霄','罗丽辉','2026-03-23 19:46:21','summary',NULL,'13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('6942894','892983','JSST-2018','邮箱验证码登录时，输入错误验证码，点击登录未停留在原页','杨霄','杨霄','2026-03-24 09:16:25','status','待办 -> 处理中','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('6942895','892983','JSST-2018','邮箱验证码登录时，输入错误验证码，点击登录未停留在原页','杨霄','杨霄','2026-03-24 09:16:32','status','处理中 -> 待测试','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('6945461','892983','JSST-2018','邮箱验证码登录时，输入错误验证码，点击登录未停留在原页','杨霄','罗丽辉','2026-03-24 13:51:55','status','待测试 -> 完成','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('1','893788','JSST-2024','认证未通过后无法重新进行认证','杨霄','罗丽辉','2026-03-24 14:44:02','create',NULL,'13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('6949468','893788','JSST-2024','认证未通过后无法重新进行认证','杨霄','杨霄','2026-03-24 17:08:05','status','待办 -> 处理中','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('6949470','893788','JSST-2024','认证未通过后无法重新进行认证','杨霄','杨霄','2026-03-24 17:08:16','status','处理中 -> 待测试','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('6949969','893788','JSST-2024','认证未通过后无法重新进行认证','杨霄','罗丽辉','2026-03-24 18:56:12','status','待测试 -> 完成','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('1','894326','JSST-2037','个人认证驳回后，再次认证，运营后台审核时申请人姓名非提交的姓名','杨辉煌','罗丽辉','2026-03-24 18:59:52','create',NULL,'13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('6950137','894326','JSST-2037','个人认证驳回后，再次认证，运营后台审核时申请人姓名非提交的姓名','杨辉煌','罗丽辉','2026-03-24 19:08:27','summary',NULL,'13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('6950139','894326','JSST-2037','个人认证驳回后，再次认证，运营后台审核时申请人姓名非提交的姓名','杨辉煌','罗丽辉','2026-03-24 19:09:38','description',NULL,'13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('6950725','894326','JSST-2037','个人认证驳回后，再次认证，运营后台审核时申请人姓名非提交的姓名','杨辉煌','杨霄','2026-03-25 08:37:24','assignee','杨霄 -> 杨辉煌','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('6952620','894326','JSST-2037','个人认证驳回后，再次认证，运营后台审核时申请人姓名非提交的姓名','杨辉煌','杨辉煌','2026-03-25 10:45:42','status','待办 -> 处理中','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('6952621','894326','JSST-2037','个人认证驳回后，再次认证，运营后台审核时申请人姓名非提交的姓名','杨辉煌','杨辉煌','2026-03-25 10:45:55','status','处理中 -> 待测试','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('6952681','894326','JSST-2037','个人认证驳回后，再次认证，运营后台审核时申请人姓名非提交的姓名','杨辉煌','罗丽辉','2026-03-25 10:54:43','status','待测试 -> 完成','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('1','895707','JSST-2038','【阿里云】绑定邮箱时无法获取邮箱验证码','罗丽辉','罗丽辉','2026-03-25 16:11:27','create',NULL,'13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('6985478','895707','JSST-2038','【阿里云】绑定邮箱时无法获取邮箱验证码','罗丽辉','罗丽辉','2026-03-31 08:40:14','assignee','李昊 -> 罗丽辉','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('6985483','895707','JSST-2038','【阿里云】绑定邮箱时无法获取邮箱验证码','罗丽辉','罗丽辉','2026-03-31 08:40:18','status','待办 -> 完成','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('1','902348','JSST-2046','移动端登录注册页面未与UI一致','杨霄','罗丽辉','2026-03-31 16:15:06','create',NULL,'13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('7002972','902348','JSST-2046','移动端登录注册页面未与UI一致','杨霄','杨霄','2026-04-02 13:54:53','status','待办 -> 处理中','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('7002973','902348','JSST-2046','移动端登录注册页面未与UI一致','杨霄','杨霄','2026-04-02 13:55:06','status','处理中 -> 待测试','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('7005424','902348','JSST-2046','移动端登录注册页面未与UI一致','杨霄','罗丽辉','2026-04-02 16:42:08','status','待测试 -> 完成','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('1','902376','JSST-2047','移动端刚进入时未直接加载移动端','杨霄','罗丽辉','2026-03-31 16:31:49','create',NULL,'13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('7002975','902376','JSST-2047','移动端刚进入时未直接加载移动端','杨霄','杨霄','2026-04-02 13:55:13','status','待办 -> 处理中','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('7002976','902376','JSST-2047','移动端刚进入时未直接加载移动端','杨霄','杨霄','2026-04-02 13:55:20','status','处理中 -> 待测试','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('7003178','902376','JSST-2047','移动端刚进入时未直接加载移动端','杨霄','罗丽辉','2026-04-02 14:07:40','status','待测试 -> 完成','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('1','913014','JSST-2109','个人认证报错：运营商三要素认证不一致','罗丽辉','罗丽辉','2026-04-13 09:10:09','create',NULL,'13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('7052006','913014','JSST-2109','个人认证报错：运营商三要素认证不一致','罗丽辉','罗丽辉','2026-04-13 09:10:30','assignee','杨辉煌 -> 罗丽辉','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('7052079','913014','JSST-2109','个人认证报错：运营商三要素认证不一致','罗丽辉','罗丽辉','2026-04-13 09:12:43','assignee','罗丽辉 -> 杨辉煌','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('7052847','913014','JSST-2109','个人认证报错：运营商三要素认证不一致','罗丽辉','罗丽辉','2026-04-13 09:45:14','assignee','杨辉煌 -> 罗丽辉','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('7052848','913014','JSST-2109','个人认证报错：运营商三要素认证不一致','罗丽辉','罗丽辉','2026-04-13 09:45:33','status','待办 -> 完成','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8'),('1','907090','JSST-2064','时间注解原因，平台时区未统一','罗丽辉','罗丽辉','2026-04-07 16:41:07','create',NULL,'13718','具身智能生态平台','7629','JSST-1.0-Sprint-9'),('7017380','907090','JSST-2064','时间注解原因，平台时区未统一','罗丽辉','罗丽辉','2026-04-07 16:42:09','description',NULL,'13718','具身智能生态平台','7629','JSST-1.0-Sprint-9'),('7031439','907090','JSST-2064','时间注解原因，平台时区未统一','罗丽辉','罗丽辉','2026-04-09 11:01:35','summary',NULL,'13718','具身智能生态平台','7629','JSST-1.0-Sprint-9'),('7041571','907090','JSST-2064','时间注解原因，平台时区未统一','罗丽辉','罗丽辉','2026-04-10 10:38:47','Sprint','JSST-1.0-Sprint-8 -> JSST-1.0-Sprint-9','13718','具身智能生态平台','7629','JSST-1.0-Sprint-9'),('7057939','907090','JSST-2064','时间注解原因，平台时区未统一','罗丽辉','罗丽辉','2026-04-13 16:34:48','assignee','杨辉煌 -> 罗丽辉','13718','具身智能生态平台','7629','JSST-1.0-Sprint-9'),('7057941','907090','JSST-2064','时间注解原因，平台时区未统一','罗丽辉','罗丽辉','2026-04-13 16:35:18','status','待办 -> 完成','13718','具身智能生态平台','7629','JSST-1.0-Sprint-9'),('1','926592','JSST-2198','真实姓名表头右侧无隐私保护开关','段星宇','罗丽辉','2026-04-24 15:46:04','create',NULL,'13718','具身智能生态平台','7629','JSST-1.0-Sprint-9'),('7133454','926592','JSST-2198','真实姓名表头右侧无隐私保护开关','段星宇','段星宇','2026-04-24 17:25:17','status','待办 -> 处理中','13718','具身智能生态平台','7629','JSST-1.0-Sprint-9'),('7133456','926592','JSST-2198','真实姓名表头右侧无隐私保护开关','段星宇','段星宇','2026-04-24 17:25:25','status','处理中 -> 待测试','13718','具身智能生态平台','7629','JSST-1.0-Sprint-9'),('7133467','926592','JSST-2198','真实姓名表头右侧无隐私保护开关','段星宇','罗丽辉','2026-04-24 17:28:08','status','待测试 -> 完成','13718','具身智能生态平台','7629','JSST-1.0-Sprint-9'),('1','926595','JSST-2199','无法进行实名认证、团队认证、账号状态搜索','罗丽辉','罗丽辉','2026-04-24 15:49:26','create',NULL,'13718','具身智能生态平台','7629','JSST-1.0-Sprint-9'),('7132152','926595','JSST-2199','无法进行实名认证、团队认证、账号状态搜索','罗丽辉','罗丽辉','2026-04-24 16:05:33','assignee','段星宇 -> 罗丽辉','13718','具身智能生态平台','7629','JSST-1.0-Sprint-9'),('7132170','926595','JSST-2199','无法进行实名认证、团队认证、账号状态搜索','罗丽辉','罗丽辉','2026-04-24 16:05:39','status','待办 -> 完成','13718','具身智能生态平台','7629','JSST-1.0-Sprint-9'),('1','930697','JSST-2200','账号新建后，未给注册手机号发送短信','杨辉煌','罗丽辉','2026-04-28 15:19:36','create',NULL,'13718','具身智能生态平台','7629','JSST-1.0-Sprint-9'),('7152699','930697','JSST-2200','账号新建后，未给注册手机号发送短信','杨辉煌','罗丽辉','2026-04-28 15:57:30','priority','严重 -> 一般','13718','具身智能生态平台','7629','JSST-1.0-Sprint-9'),('7153772','930697','JSST-2200','账号新建后，未给注册手机号发送短信','杨辉煌','杨辉煌','2026-04-28 16:52:41','status','待办 -> 完成','13718','具身智能生态平台','7629','JSST-1.0-Sprint-9'),('1','930740','JSST-2201','后台新建的用户进行团队认证时未带入真实姓名，无法进行团队认证','罗丽辉','罗丽辉','2026-04-28 15:37:53','create',NULL,'13718','具身智能生态平台','7629','JSST-1.0-Sprint-9'),('7152702','930740','JSST-2201','后台新建的用户进行团队认证时未带入真实姓名，无法进行团队认证','罗丽辉','罗丽辉','2026-04-28 15:57:56','priority','严重 -> 一般','13718','具身智能生态平台','7629','JSST-1.0-Sprint-9'),('7152705','930740','JSST-2201','后台新建的用户进行团队认证时未带入真实姓名，无法进行团队认证','罗丽辉','罗丽辉','2026-04-28 15:58:09','priority','一般 -> 严重','13718','具身智能生态平台','7629','JSST-1.0-Sprint-9'),('7153121','930740','JSST-2201','后台新建的用户进行团队认证时未带入真实姓名，无法进行团队认证','罗丽辉','罗丽辉','2026-04-28 16:26:08','assignee','杨辉煌 -> 罗丽辉','13718','具身智能生态平台','7629','JSST-1.0-Sprint-9'),('7153124','930740','JSST-2201','后台新建的用户进行团队认证时未带入真实姓名，无法进行团队认证','罗丽辉','罗丽辉','2026-04-28 16:26:18','status','待办 -> 完成','13718','具身智能生态平台','7629','JSST-1.0-Sprint-9'),('1','930892','JSST-2205','后台新建账号，选择内部客户，创建后却是外部客户','杨辉煌','罗丽辉','2026-04-28 16:10:37','create',NULL,'13718','具身智能生态平台','7629','JSST-1.0-Sprint-9'),('7153777','930892','JSST-2205','后台新建账号，选择内部客户，创建后却是外部客户','杨辉煌','杨辉煌','2026-04-28 16:53:18','status','待办 -> 处理中','13718','具身智能生态平台','7629','JSST-1.0-Sprint-9'),('7153784','930892','JSST-2205','后台新建账号，选择内部客户，创建后却是外部客户','杨辉煌','杨辉煌','2026-04-28 16:53:34','status','处理中 -> 待测试','13718','具身智能生态平台','7629','JSST-1.0-Sprint-9'),('7153910','930892','JSST-2205','后台新建账号，选择内部客户，创建后却是外部客户','杨辉煌','罗丽辉','2026-04-28 16:57:45','status','待测试 -> 完成','13718','具身智能生态平台','7629','JSST-1.0-Sprint-9'),('1','930967','JSST-2206','团队认证通过后，租户名称错误','罗丽辉','罗丽辉','2026-04-28 16:51:29','create',NULL,'13718','具身智能生态平台','7629','JSST-1.0-Sprint-9'),('7153760','930967','JSST-2206','团队认证通过后，租户名称错误','罗丽辉','罗丽辉','2026-04-28 16:51:35','assignee','段星宇 -> 罗丽辉','13718','具身智能生态平台','7629','JSST-1.0-Sprint-9'),('7153767','930967','JSST-2206','团队认证通过后，租户名称错误','罗丽辉','罗丽辉','2026-04-28 16:51:46','status','待办 -> 完成','13718','具身智能生态平台','7629','JSST-1.0-Sprint-9'),('7133457','926592','JSST-2198','真实姓名表头右侧无隐私保护开关','段星宇','罗丽辉','2026-04-24 21:25:25','status','待测试 -> 处理中','13718','具身智能生态平台','7629','JSST-1.0-Sprint-9');
/*!40000 ALTER TABLE `rdm_bug_changelog` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rdm_bug_duration`
--

DROP TABLE IF EXISTS `rdm_bug_duration`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rdm_bug_duration` (
  `project_id` bigint DEFAULT NULL COMMENT '项目ID',
  `project_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '项目名称',
  `sprint_id` bigint DEFAULT NULL COMMENT 'Sprint ID',
  `sprint_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Sprint名称',
  `short_sprint_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Sprint简称',
  `sprint_seqno` int DEFAULT NULL COMMENT 'Sprint序号',
  `bug_id` bigint DEFAULT NULL COMMENT '故障ID',
  `bug_key` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '故障Key',
  `bug_name` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '故障名称',
  `author` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '开发人员',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `test_time` datetime DEFAULT NULL COMMENT '测试开始时间',
  `finish_time` datetime DEFAULT NULL COMMENT '完成时间',
  `dev_seconds_all` bigint DEFAULT NULL COMMENT '开发时长(包含非工作日,秒数)',
  `dev_seconds` bigint DEFAULT NULL COMMENT '开发时长(工作日秒数)',
  `dev_time_all_str` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '开发时长(包含非工作日,字符串格式)',
  `dev_time_str` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '开发时长(字符串格式)',
  `test_seconds_all` bigint DEFAULT NULL COMMENT '测试时长(包含非工作日,秒数)',
  `test_seconds` bigint DEFAULT NULL COMMENT '测试时长(工作日秒数)',
  `test_time_all_str` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '测试时长(包含非工作日,字符串格式)',
  `test_time_str` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '测试时长(字符串格式)',
  `finish_seconds_all` bigint DEFAULT NULL COMMENT '总完成时长(包含非工作日,秒数)',
  `finish_seconds` bigint DEFAULT NULL COMMENT '总完成时长(工作日秒数)',
  `finish_time_all_str` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '总完成时长(包含非工作日,字符串格式)',
  `finish_time_str` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '总完成时长(字符串格式)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='RDM故障解决时长';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rdm_bug_duration`
--

LOCK TABLES `rdm_bug_duration` WRITE;
/*!40000 ALTER TABLE `rdm_bug_duration` DISABLE KEYS */;
INSERT INTO `rdm_bug_duration` VALUES (13718,'具身智能生态平台',7492,'JSST-1.0-Sprint-8','Sprint',9,892482,'JSST-2010','【AWS】用户认证','段星宇','2026-03-23 14:14:39','2026-03-23 19:51:15','2026-03-24 14:11:50',20196,20196,'5小时37分','5小时37分',66035,66034,'1天18小时','1天18小时',86231,86230,'1天0小时','1天0小时'),(13718,'具身智能生态平台',7492,'JSST-1.0-Sprint-8','Sprint',9,892525,'JSST-2011','【AWS】账户登录','杨霄','2026-03-23 14:31:33','2026-03-23 17:00:33','2026-03-24 16:55:44',8940,8940,'2小时29分','2小时29分',86111,86110,'1天0小时','1天0小时',95051,95050,'1天2小时','1天2小时'),(13718,'具身智能生态平台',7492,'JSST-1.0-Sprint-8','Sprint',9,892566,'JSST-2012','移动端无法登出','杨霄','2026-03-23 14:50:31','2026-03-23 17:02:38','2026-03-23 19:19:11',7927,7927,'2小时12分','2小时12分',8193,8193,'2小时17分','2小时17分',16120,16120,'4小时29分','4小时29分'),(13718,'具身智能生态平台',7492,'JSST-1.0-Sprint-8','Sprint',9,892760,'JSST-2015','登录时账号或密码错误，Log in 按钮一直转圈圈，无法点击','杨霄','2026-03-23 16:27:19','2026-03-23 17:03:07','2026-03-23 17:06:05',2148,2148,'36分','36分',178,178,'3分','3分',2326,2326,'39分','39分'),(13718,'具身智能生态平台',7492,'JSST-1.0-Sprint-8','Sprint',9,892791,'JSST-2016','输入错误密码后，强刷页面，输入正确的密码也登录不了','杨霄','2026-03-23 16:50:15','2026-03-23 17:02:53','2026-03-23 17:06:55',758,758,'13分','13分',242,242,'4分','4分',1000,1000,'17分','17分'),(13718,'具身智能生态平台',7492,'JSST-1.0-Sprint-8','Sprint',9,892975,'JSST-2017','用户认证未做移动端适配','杨霄','2026-03-23 19:33:56','2026-03-24 11:40:35','2026-03-24 14:18:08',57999,57998,'1天16小时','1天16小时',9453,9453,'2小时38分','2小时38分',67452,67451,'1天19小时','1天19小时'),(13718,'具身智能生态平台',7492,'JSST-1.0-Sprint-8','Sprint',9,892983,'JSST-2018','邮箱验证码登录时，输入错误验证码，点击登录未停留在原页','杨霄','2026-03-23 19:45:04','2026-03-24 09:16:32','2026-03-24 13:51:55',48688,48687,'1天14小时','1天14小时',16523,16523,'4小时35分','4小时35分',65211,65210,'1天18小时','1天18小时'),(13718,'具身智能生态平台',7492,'JSST-1.0-Sprint-8','Sprint',9,893788,'JSST-2024','认证未通过后无法重新进行认证','杨霄','2026-03-24 14:44:02','2026-03-24 17:08:16','2026-03-24 18:56:12',8654,8654,'2小时24分','2小时24分',6476,6476,'1小时48分','1小时48分',15130,15130,'4小时12分','4小时12分'),(13718,'具身智能生态平台',7492,'JSST-1.0-Sprint-8','Sprint',9,894326,'JSST-2037','个人认证驳回后，再次认证，运营后台审核时申请人姓名非提交的姓名','杨辉煌','2026-03-24 18:59:52','2026-03-25 10:45:55','2026-03-25 10:54:43',56763,56762,'1天16小时','1天16小时',528,528,'9分','9分',57291,57290,'1天16小时','1天16小时'),(13718,'具身智能生态平台',7492,'JSST-1.0-Sprint-8','Sprint',9,902348,'JSST-2046','移动端登录注册页面未与UI一致','杨霄','2026-03-31 16:15:06','2026-04-02 13:55:06','2026-04-02 16:42:08',164400,164398,'2天22小时','2天22小时',10022,10022,'2小时47分','2小时47分',174422,174420,'2天0小时','2天0小时'),(13718,'具身智能生态平台',7492,'JSST-1.0-Sprint-8','Sprint',9,902376,'JSST-2047','移动端刚进入时未直接加载移动端','杨霄','2026-03-31 16:31:49','2026-04-02 13:55:20','2026-04-02 14:07:40',163411,163409,'2天21小时','2天21小时',740,740,'12分','12分',164151,164149,'2天22小时','2天22小时'),(13718,'具身智能生态平台',7629,'JSST-1.0-Sprint-9','Sprint',10,926592,'JSST-2198','真实姓名表头右侧无隐私保护开关','段星宇','2026-04-24 15:46:04','2026-04-24 17:25:25','2026-04-24 17:28:08',5961,5961,'1小时39分','1小时39分',163,163,'3分','3分',6124,6124,'1小时42分','1小时42分'),(13718,'具身智能生态平台',7629,'JSST-1.0-Sprint-9','Sprint',10,930892,'JSST-2205','后台新建账号，选择内部客户，创建后却是外部客户','杨辉煌','2026-04-28 16:10:37','2026-04-28 16:53:34','2026-04-28 16:57:45',2577,2577,'43分','43分',251,251,'4分','4分',2828,2828,'47分','47分'),(13718,'具身智能生态平台',7492,'JSST-1.0-Sprint-8','Sprint',9,892482,'JSST-2010','【AWS】用户认证','段星宇','2026-03-23 14:14:39','2026-03-23 19:51:15','2026-03-24 14:11:50',20196,20196,'5小时37分','5小时37分',66035,66034,'1天18小时','1天18小时',86231,86230,'1天0小时','1天0小时'),(13718,'具身智能生态平台',7492,'JSST-1.0-Sprint-8','Sprint',9,892525,'JSST-2011','【AWS】账户登录','杨霄','2026-03-23 14:31:33','2026-03-23 17:00:33','2026-03-24 16:55:44',8940,8940,'2小时29分','2小时29分',86111,86110,'1天0小时','1天0小时',95051,95050,'1天2小时','1天2小时'),(13718,'具身智能生态平台',7492,'JSST-1.0-Sprint-8','Sprint',9,892566,'JSST-2012','移动端无法登出','杨霄','2026-03-23 14:50:31','2026-03-23 17:02:38','2026-03-23 19:19:11',7927,7927,'2小时12分','2小时12分',8193,8193,'2小时17分','2小时17分',16120,16120,'4小时29分','4小时29分'),(13718,'具身智能生态平台',7492,'JSST-1.0-Sprint-8','Sprint',9,892760,'JSST-2015','登录时账号或密码错误，Log in 按钮一直转圈圈，无法点击','杨霄','2026-03-23 16:27:19','2026-03-23 17:03:07','2026-03-23 17:06:05',2148,2148,'36分','36分',178,178,'3分','3分',2326,2326,'39分','39分'),(13718,'具身智能生态平台',7492,'JSST-1.0-Sprint-8','Sprint',9,892791,'JSST-2016','输入错误密码后，强刷页面，输入正确的密码也登录不了','杨霄','2026-03-23 16:50:15','2026-03-23 17:02:53','2026-03-23 17:06:55',758,758,'13分','13分',242,242,'4分','4分',1000,1000,'17分','17分'),(13718,'具身智能生态平台',7492,'JSST-1.0-Sprint-8','Sprint',9,892975,'JSST-2017','用户认证未做移动端适配','杨霄','2026-03-23 19:33:56','2026-03-24 11:40:35','2026-03-24 14:18:08',57999,57998,'1天16小时','1天16小时',9453,9453,'2小时38分','2小时38分',67452,67451,'1天19小时','1天19小时'),(13718,'具身智能生态平台',7492,'JSST-1.0-Sprint-8','Sprint',9,892983,'JSST-2018','邮箱验证码登录时，输入错误验证码，点击登录未停留在原页','杨霄','2026-03-23 19:45:04','2026-03-24 09:16:32','2026-03-24 13:51:55',48688,48687,'1天14小时','1天14小时',16523,16523,'4小时35分','4小时35分',65211,65210,'1天18小时','1天18小时'),(13718,'具身智能生态平台',7492,'JSST-1.0-Sprint-8','Sprint',9,893788,'JSST-2024','认证未通过后无法重新进行认证','杨霄','2026-03-24 14:44:02','2026-03-24 17:08:16','2026-03-24 18:56:12',8654,8654,'2小时24分','2小时24分',6476,6476,'1小时48分','1小时48分',15130,15130,'4小时12分','4小时12分'),(13718,'具身智能生态平台',7492,'JSST-1.0-Sprint-8','Sprint',9,894326,'JSST-2037','个人认证驳回后，再次认证，运营后台审核时申请人姓名非提交的姓名','杨辉煌','2026-03-24 18:59:52','2026-03-25 10:45:55','2026-03-25 10:54:43',56763,56762,'1天16小时','1天16小时',528,528,'9分','9分',57291,57290,'1天16小时','1天16小时'),(13718,'具身智能生态平台',7492,'JSST-1.0-Sprint-8','Sprint',9,902348,'JSST-2046','移动端登录注册页面未与UI一致','杨霄','2026-03-31 16:15:06','2026-04-02 13:55:06','2026-04-02 16:42:08',164400,164398,'2天22小时','2天22小时',10022,10022,'2小时47分','2小时47分',174422,174420,'2天0小时','2天0小时'),(13718,'具身智能生态平台',7492,'JSST-1.0-Sprint-8','Sprint',9,902376,'JSST-2047','移动端刚进入时未直接加载移动端','杨霄','2026-03-31 16:31:49','2026-04-02 13:55:20','2026-04-02 14:07:40',163411,163409,'2天21小时','2天21小时',740,740,'12分','12分',164151,164149,'2天22小时','2天22小时'),(13718,'具身智能生态平台',7629,'JSST-1.0-Sprint-9','Sprint',10,926592,'JSST-2198','真实姓名表头右侧无隐私保护开关','段星宇','2026-04-24 15:46:04','2026-04-24 17:25:25','2026-04-24 17:28:08',5961,5961,'1小时39分','1小时39分',163,163,'3分','3分',6124,6124,'1小时42分','1小时42分'),(13718,'具身智能生态平台',7629,'JSST-1.0-Sprint-9','Sprint',10,930892,'JSST-2205','后台新建账号，选择内部客户，创建后却是外部客户','杨辉煌','2026-04-28 16:10:37','2026-04-28 16:53:34','2026-04-28 16:57:45',2577,2577,'43分','43分',251,251,'4分','4分',2828,2828,'47分','47分');
/*!40000 ALTER TABLE `rdm_bug_duration` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rdm_bug_label_class`
--

DROP TABLE IF EXISTS `rdm_bug_label_class`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rdm_bug_label_class` (
  `class_id` int DEFAULT NULL COMMENT 'Bug标签分类ID',
  `class_name` varchar(50) DEFAULT NULL COMMENT 'Bug标签分类名称',
  `label` varchar(512) DEFAULT NULL COMMENT 'Bug标签'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='Bug标签分类';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rdm_bug_label_class`
--

LOCK TABLES `rdm_bug_label_class` WRITE;
/*!40000 ALTER TABLE `rdm_bug_label_class` DISABLE KEYS */;
/*!40000 ALTER TABLE `rdm_bug_label_class` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rdm_doc_bug`
--

DROP TABLE IF EXISTS `rdm_doc_bug`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rdm_doc_bug` (
  `key` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '编码',
  `name` text COLLATE utf8mb4_unicode_ci COMMENT '名称',
  `priority` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '优先级',
  `reason` varchar(512) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '原因',
  `resolve_method` mediumtext COLLATE utf8mb4_unicode_ci COMMENT '解决方法',
  `maker` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '产生人',
  `propose` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '提出人',
  `propose_time` datetime DEFAULT NULL COMMENT '提出时间',
  `resolve_time` datetime DEFAULT NULL COMMENT '解决时间',
  `status` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '状态(不处理、处理中、待测试、继续观察、未开始、验证通过、已解决、转任务、转需求)',
  `type` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '类型（需求问题、漏做、代码逻辑问题、环境问题、第三方影响、沟通问题）',
  `original_type` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '原类型（需求问题、漏做、代码逻辑问题、环境问题、第三方影响、沟通问题）',
  `sprint_id` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'SprintID',
  `project_id` varchar(512) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '项目ID',
  KEY `idx_doc_bug_key` (`key`),
  KEY `idx_doc_bug_sprint_id` (`sprint_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='文档故障';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rdm_doc_bug`
--

LOCK TABLES `rdm_doc_bug` WRITE;
/*!40000 ALTER TABLE `rdm_doc_bug` DISABLE KEYS */;
INSERT INTO `rdm_doc_bug` VALUES ('m0317-6','交互>交互：提问后回答延迟较大','严重','与腾讯tts连接受网络波动影响和知识召回有关，但主要受知识库召回影响>减少绑定知识库、召回文本数、关闭重排（会影响召回文本质量）或者降低知识召回接口的延迟（需要aigc平台优化）','','崔志伦','',NULL,NULL,'继续观察','代码实现','代码逻辑问题','7492','13718'),('m0317-7','交互>交互：无法区分杂音（非人声）；多人说话，无法区分主音频；','严重','目前算法层面暂时无法区分杂音，物理设备也不支持>1、目前尝试科大讯飞的设备测试;','','孙灿','',NULL,NULL,'继续观察','代码实现','代码逻辑问题','7492','13718'),('m0320-1','收音偶尔收不到','严重','声音检测模型存在一定的误差，不能百分百收音>优先使用麦克风，进一步调研','','孙灿','',NULL,NULL,'继续观察','代码实现','代码逻辑问题','7492','13718'),('m0413-14','浏览器兼容>aws-苹果自带浏览器下，应用编排页，时间轴音频无法播放（历史版本）','优化','没有做苹果电脑的适配','','魏忠亮','',NULL,NULL,'验证通过','代码实现','代码逻辑问题','7492','13718'),('m0413-15','浏览器兼容>aws-苹果自带浏览器下，应用编排页，交互收音抛错：mimeType is not supported','优化','没有做苹果电脑的适配','','魏忠亮','',NULL,NULL,'验证通过','代码实现','代码逻辑问题','7492','13718'),('m0417-2','智能编排>SP5音频合成后能修改文案内容再次合成吗？','严重','业务场景考虑不到位>转需求','','郭秦逸','',NULL,NULL,'转需求','','','7492','13718'),('m0417-3','智能编排>SP5如果所选速度下合成音频后，又修改文本，点击最终的保存，不再重新生成音频会不会不合理？','严重','业务场景考虑不到位>转需求','','郭秦逸','',NULL,NULL,'转需求','','','7492','13718'),('m0420-3','建图>本体触发开始建图后，没有取消建图功能，现在只能先完成建图再次建图','严重','','','郭秦逸','',NULL,NULL,'不处理','','','7492','13718'),('m0420-6','应用部署>流程结束了，但平台上仍然显示了执行中','严重','遥控器取消结束，未给平台发消息>进一步梳理数据链路','','刘炀勇','',NULL,NULL,'验证通过','','','7492','13718'),('m0421-4','应用编排>节点交互事件没有命中curl \'https://mine.zvalley.com/botapi/botadp/voice/recognize-text\' \\\n  -H \'accept: */*\' \\\n  -H \'accept-language: zh\' \\\n  -H \'content-type: multipart/form-data; boundary=----WebKitFormBoundaryAWmTyBcrhBsgChRw\' \\\n  -b \'i18n_redirected=zh; xLanguage=zh; x-user-token=151a8313ea1574ba5af4c4b224ed2dd18\' \\\n  -H \'origin: https://mine.zvalley.com\' \\\n  -H \'priority: u=1, i\' \\\n  -H \'referer: https://mine.zvalley.com/bot/arrangement?id=2044979211511533568\' \\\n  -H \'sec-ch-ua: \"Google Chrome\";v=\"147\", \"Not.A/Brand\";v=\"8\", \"Chromium\";v=\"147\"\' \\\n  -H \'sec-ch-ua-mobile: ?0\' \\\n  -H \'sec-ch-ua-platform: \"Windows\"\' \\\n  -H \'sec-fetch-dest: empty\' \\\n  -H \'sec-fetch-mode: cors\' \\\n  -H \'sec-fetch-site: same-origin\' \\\n  -H \'timestamp: 1776740496501\' \\\n  -H \'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36\' \\\n  -H \'x-client-type: pc\' \\\n  -H \'x-sign: w5lhqlc39c7f16b47a6e23da62c99b1fc7a89a\' \\\n  -H \'x-timezone: Asia/Shanghai\' \\\n  -H \'x-user-token: 151a8313ea1574ba5af4c4b224ed2dd18\' \\\n  -H \'x-zas-starttime: 1776740496502\' \\','严重','不是模型的问题，未带节点信息>对话过程中带节点信息','','魏忠亮','',NULL,NULL,'验证通过','','','7492','13718'),('m0421-6','应用编排>节点事件拖拽至节点后，应该在总列表可见，支持一个事件被多个节点引用','严重','代码合并冲突>已重新合并','','胡昆','',NULL,NULL,'验证通过','','','7492','13718'),('m0421-7','应用编排>音频播放时，唤醒交互，会出现交互音频与列表音频同时播放；\n或者交互音频播放时，播放列表音频，也会出现交互音频与列表音频同时播放；\n这里交互得明确下','严重','未考虑可能的使用场景>转需求','','郭秦逸','',NULL,NULL,'转需求','','','7492','13718'),('m0421-12','应用部署>执行结束、失败、取消后，应用被自动卸载了','严重','未复现，需继续观察>优化定时任务逻辑','','唐柳','',NULL,NULL,'验证通过','代码实现','代码逻辑问题','7492','13718'),('m0421-14','应用执行>二重奏仍然存在：交互答复进行中，突然进入下一流程节点，出现二重奏','严重','1. 在播固定音频，打断，进行交互，此时进入到下一流程节点，由于过滤条件为交互且固定音频未中断，所以新的音频进来不满足条件，所以会出现二重奏现象>仅设置过滤条件为交互','','孙灿','',NULL,NULL,'待测试','','','7492','13718'),('m0421-15','应用执行>遥控器控制：\n1、不灵敏，多次触控偶尔会生效；\n2、最远距离两米；\n3、室内、无遮挡的情况下，多数情况下一米左右','严重','初步判断硬件问题>更换了一个遥控器，目前距离大约1米比之前30cm有提高，期望距离3米。','1、更换了一个遥控器，尝试再换一个','李昊','',NULL,NULL,'验证通过','','','7492','13718'),('m0422-1','遥控器>问题补录：遥控器操作取消后，取消成功，但未报告平台更新状态，导致状态不对应','严重','遥控器取消结束，未给平台发消息>上报消息给平台','','刘炀勇','',NULL,NULL,'验证通过','','','7492','13718'),('m0422-4','问题补录：当前应用下发搭配了地图切换，时间3分钟起，等待期间前端页面未及时关闭，按钮也未置灰，也无状态展示','严重','未考虑异常状态下的平台处理>转需求','','郭秦逸','',NULL,NULL,'转需求','','','7492','13718'),('m0422-6','问题补录：应用保存后，下发前，引用的音频素材、动作、地图被删除或修改，流程可能无法正常进行','严重','未考虑异常状态下的平台处理>增加应用可用状态显示','','郭秦逸','',NULL,NULL,'转需求','','','7492','13718'),('m0422-10','应用编排>音频编辑，打开音频编辑页，是否应该默认选中上次所选语速？','严重','是','','李若谷','',NULL,NULL,'验证通过','','','7492','13718'),('m0423-3','阿里云生产-编排列表>列表抛错curl \'https://eai-api.zvalley.com/botapi/botadp/application/listWithAuth\' \\\n  -H \'accept: application/json\' \\\n  -H \'accept-language: zh\' \\\n  -H \'content-type: application/json\' \\\n  -H \'origin: https://eai-adp.zvalley.com\' \\\n  -H \'priority: u=1, i\' \\\n  -H \'referer: https://eai-adp.zvalley.com/\' \\\n  -H \'sec-ch-ua: \"Google Chrome\";v=\"147\", \"Not.A/Brand\";v=\"8\", \"Chromium\";v=\"147\"\' \\\n  -H \'sec-ch-ua-mobile: ?0\' \\\n  -H \'sec-ch-ua-platform: \"Windows\"\' \\\n  -H \'sec-fetch-dest: empty\' \\\n  -H \'sec-fetch-mode: cors\' \\\n  -H \'sec-fetch-site: same-site\' \\\n  -H \'timestamp: 1776931212796\' \\\n  -H \'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36\' \\\n  -H \'x-client-type: pc\' \\\n  -H \'x-sign: 5sb3rv282668a0d7dda0218b7884d98ddc1ce0\' \\\n  -H \'x-timezone: Asia/Shanghai\' \\\n  -H \'x-user-token: 11bb93acd6bc34b348d2169fa7d339fbd0x2\' \\\n  -H \'x-zas-starttime: 1776931212796\' \\\n  --data-raw \'{\"pageNo\":1,\"pageSize\":6,\"example\":{\"source\":null}}\'','严重','代码未发布到最新>已发版','','王志熙','',NULL,NULL,'验证通过','','','7492','13718'),('m0423-5','阿里云生产-动作库列表>上传动作成功后，动作库列表打开抛错curl \'https://eai-api.zvalley.com/botapi/botadp/actionLibrary/listByCondition\' \\\n  -H \'accept: application/json\' \\\n  -H \'accept-language: zh\' \\\n  -H \'content-type: application/json\' \\\n  -H \'origin: https://eai-adp.zvalley.com\' \\\n  -H \'priority: u=1, i\' \\\n  -H \'referer: https://eai-adp.zvalley.com/\' \\\n  -H \'sec-ch-ua: \"Google Chrome\";v=\"147\", \"Not.A/Brand\";v=\"8\", \"Chromium\";v=\"147\"\' \\\n  -H \'sec-ch-ua-mobile: ?0\' \\\n  -H \'sec-ch-ua-platform: \"Windows\"\' \\\n  -H \'sec-fetch-dest: empty\' \\\n  -H \'sec-fetch-mode: cors\' \\\n  -H \'sec-fetch-site: same-site\' \\\n  -H \'timestamp: 1776932076944\' \\\n  -H \'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36\' \\\n  -H \'x-client-type: pc\' \\\n  -H \'x-sign: yd42ha9ebbb152c8de9fbc6571d6073325fa74\' \\\n  -H \'x-timezone: Asia/Shanghai\' \\\n  -H \'x-user-token: 11bb93acd6bc34b348d2169fa7d339fbd0x2\' \\\n  -H \'x-zas-starttime: 1776932076944\' \\\n  --data-raw \'{\"searchKey\":\"\",\"category\":\"2047228122681712640\",\"robotModelId\":\"2030187355412635648\"}\'','严重','代码未发布到最新>已发版','','王志熙','',NULL,NULL,'验证通过','','','7492','13718'),('m0423-9','应用执行>应用下发后，本体无法正常执行任务','严重','换图逻辑没对齐，底盘定位驱动掉线>换图逻辑已处理，底盘定位掉线需定位问题','','邹浩东','',NULL,NULL,'验证通过','','','7492','13718'),('m0424-1','阿里云生产-应用编排>个人音色显示不出来，现音色无法选择，语音合成失败，流程不通','严重','后端没有发版','','胡昆','',NULL,NULL,'验证通过','','','7492','13718'),('m0424-2','阿里云生产-应用编排>模型显示不出来','严重','被注释掉了，现在已放开','','魏忠亮','',NULL,NULL,'验证通过','','','7492','13718'),('m0424-3','阿里云生产-应用编排>语音唤醒失败','严重','代码合并的问题，正在修复','','魏忠亮','',NULL,NULL,'验证通过','','','7492','13718'),('m0424-4','阿里云生产-应用编排>知识库无法解析','严重','调用网关问题>改一下调用网关','','蔡锦辉','',NULL,NULL,'验证通过','','','7492','13718'),('m0424-5','阿里云生产-应用编排>人设列表跳转资源中心，不应该聚焦在音色页签','一般','代码没有合并上>重新合并','','胡昆','',NULL,NULL,'验证通过','','','7492','13718'),('m0424-6','应用编排>全局交互事件这里是不是不应该有资源中心入口？','一般','细节问题>隐藏资源中心入口','','李若谷','',NULL,NULL,'验证通过','','','7492','13718'),('m0424-7','阿里云生产-应用编排>设置-移动速度显示不出来','一般','阿里云字典没有配置该参数>环境配置时尽量不遗漏字典项','','杨霄','',NULL,NULL,'验证通过','','','7492','13718'),('m0424-8','阿里云生产-应用编排>模型下载不下来','严重','T4双足的现在才可以','','魏忠亮','',NULL,NULL,'验证通过','','','7492','13718'),('m0424-9','应用编排>地图切换，未选中地图，点击地图，应控制不允许。现在有报错','优化','没考虑到边界情况','','魏忠亮','',NULL,NULL,'验证通过','','','7492','13718'),('m0424-10','阿里云生产-应用编排>润色后使用撤销功能，应该恢复到润色前，不应该清空','一般','未加入历史栈内>编辑时同步历史栈','','胡昆','',NULL,NULL,'验证通过','','','7492','13718'),('m0424-11','阿里云生产-应用编排>交互总结词，应该是导览员视角','一般','提示词简单>提示词优化','','唐柳','',NULL,NULL,'验证通过','','','7492','13718'),('m0424-12','阿里云生产-应用编排>交互总结词没有播放','一般','加入语音后被我关闭掉了','','魏忠亮','',NULL,NULL,'验证通过','','','7492','13718'),('m0424-13','阿里云生产-应用编排>交互总结词第一个字和后续其他文案显示的时间间隔太久了','一般','为了不等待全部弄完，提前弄了几个字出来告诉用户已经可以了只是再处理','','魏忠亮','',NULL,NULL,'验证通过','','','7492','13718'),('m0424-14','应用编排>组合编排，选择音频试听，试听结束之前，点击下一步按钮进入下一页，应该停止上一页试听','一般','','','李若谷','',NULL,NULL,'验证通过','','','7492','13718'),('m0424-15','应用编排>拖动图片动作区域，动画显示有误','一般','css兼容性问题','','李若谷','',NULL,NULL,'验证通过','','','7492','13718'),('m0424-16','应用编排>编排页打开后，中间若出现断网，重连后交互功能不可用','一般','断网时间过长超过三次重连后出现的问题','','魏忠亮','',NULL,NULL,'待测试','','','7492','13718'),('m0424-17','首页>功能说明尚不可查看','一般','前端工程为创建流水线>搭建操作说明流水线部署','','唐柳','',NULL,NULL,'验证通过','','','7492','13718'),('m0424-18','阿里云生产-应用编排>设置-收音强度没显示','一般','阿里云字典没有配置该参数>环境配置时尽量不遗漏字典项','','杨霄','',NULL,NULL,'验证通过','','','7492','13718'),('m0424-19','应用编排>动作库、音色列表、人设列表、地图列表、知识库列表、插件库列表跳转资源中心入口丢失m0424-6','严重','','','李若谷','',NULL,NULL,'验证通过','','','7492','13718'),('m0424-20','应用编排>智能编排，若选择时长选择20min，点位只有3个，导致每个点位音频超长。此时生成应用后，各音频总长5min左右','一般','代码逻辑问题>修改提示词，设置单语句最大值','','聂祥','',NULL,NULL,'验证通过','','','7492','13718'),('m0424-21','资源中心>SP6：https://mine.zvalley.com/botapi/botadp/plugin/upload插件上传失败','严重','解压框架问题，会有乱码>更换压缩工具，适配多种编码','','唐柳','',NULL,NULL,'验证通过','','','7492','13718'),('m0427-1','资源中心>SP6：插件开发指南未提供','一般','','','李昊','',NULL,NULL,'已解决','','','7492','13718'),('m0427-2','资源中心>地图删除需求不明确：\n如果目的是在本体删除地图文件，那触发条件放在平台地图列表删除，流程有点衔接不上。应该是在应用卸载的时候，同步删除本体地图吧？','严重','删除地图时校验是否被应用引用','','郭秦逸','',NULL,NULL,'待测试','','','7492','13718'),('m0428-1','应用编排>mine环境，点击设置按钮，设置页弹出了两次','严重','','','杨霄','',NULL,NULL,'验证通过','','','7492','13718'),('m0428-2','地图创建>T4：发起建图指令，因雷达驱动掉了导致本体建图失败，平台端未接收到消息反馈；\n此场景流程走向产品需要给方案——现在是必须点击结束建图进入下一步才能退出建图步骤','严重','收到反馈消息，已经通过websocket推送到前端，前端未处理这个消息，>前端需要处理反馈的错误消息','有失败回复，需要平台侧进一步排查@王志熙','邹浩东','',NULL,NULL,'处理中','','','7492','13718'),('m0428-3','地图创建>T4：发起建图指令，本体建图失败-雷达驱动掉了','严重','','','吴凡','',NULL,NULL,'处理中','','','7492','13718'),('m0428-4','地图创建>T4:遥操打点后点位名称没有显示','严重','','','邹浩东','',NULL,NULL,'验证通过','','','7492','13718'),('m0428-5','应用发布>部署中状态取消部署，抛错curl \'https://eai-api.zvalley.com/botapi/botadp/applicationIssueHistory/cancel\' \\\n  -H \'accept: application/json\' \\\n  -H \'accept-language: zh\' \\\n  -H \'content-type: application/json\' \\\n  -H \'origin: https://eai-adp.zvalley.com\' \\\n  -H \'priority: u=1, i\' \\\n  -H \'referer: https://eai-adp.zvalley.com/\' \\\n  -H \'sec-ch-ua: \"Google Chrome\";v=\"147\", \"Not.A/Brand\";v=\"8\", \"Chromium\";v=\"147\"\' \\\n  -H \'sec-ch-ua-mobile: ?0\' \\\n  -H \'sec-ch-ua-platform: \"Windows\"\' \\\n  -H \'sec-fetch-dest: empty\' \\\n  -H \'sec-fetch-mode: cors\' \\\n  -H \'sec-fetch-site: same-site\' \\\n  -H \'timestamp: 1777345726172\' \\\n  -H \'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36\' \\\n  -H \'x-client-type: pc\' \\\n  -H \'x-sign: gfqlu2148d3f9fc60632fe9a44030730e37d94\' \\\n  -H \'x-timezone: Asia/Shanghai\' \\\n  -H \'x-user-token: 13acb30deceb842ddaeaf7af5ab7e93880x2\' \\\n  -H \'x-zas-starttime: 1777345726173\' \\\n  --data-raw \'{\"operate\":\"cancelForDeploy\"}\'','一般','','开发环境正常，没有复现','李若谷','',NULL,NULL,'继续观察','','','7492','13718'),('m0428-6','阿里云生产-智能编排>智能编排，设置页动作库列表显示不出来-排查下代码是不是未发布','一般','','','胡昆','',NULL,NULL,'验证通过','','','7492','13718'),('m0428-7','应用发布>T4：下发执行指令后本体执行，平台查不到之执行中状态','一般','','','邹浩东','',NULL,NULL,'验证通过','','','7492','13718'),('m0428-8','应用发布>T4：导航失败后，后续流程执行混乱，待排查','严重','','','胡印轩','',NULL,NULL,'未开始','','','7492','13718'),('m0428-9','应用编排>组合编排：选择音频点击下一步，前端抛错','严重','','','李若谷','',NULL,NULL,'验证通过','','','7492','13718'),('m0428-10','知识库>mine环境，知识库文件上传失败','严重','偶发与文件服务关联，无法稳定复现','','蔡锦辉','',NULL,NULL,'不处理','','','7492','13718'),('m0428-11','阿里云生产-应用编排>知识库切片匹配不上，待aigc今天发版验证','严重','','','杜玉洁','',NULL,NULL,'验证通过','','','7492','13718'),('m0428-12','应用编排>mine环境，从应用列表跳转应用详情，抛错。18735698653账号','严重','','','李若谷','',NULL,NULL,'验证通过','','','7492','13718'),('m0428-13','阿里云生产-应用编排>交互唤醒，偶发响应超时（公司网络，晚7:30以后）','严重','腾讯云接口调用偶发超时，问题排查中','','张逸玮','',NULL,NULL,'处理中','','','7492','13718'),('m0428-14','阿里云生产-资源中心>动作库图片加载很慢，常会显示不出来curl \'https://eai-api.zvalley.com/document/file/v1/download?fileId=343c1f122faf4c5a924ba4c112e19824&timestamp=1777378819&sign=b1d2e28e2425b52b451a141d7e0b0864\' \\\n  -H \'accept: image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8\' \\\n  -H \'accept-language: en,zh-CN;q=0.9,zh;q=0.8\' \\\n  -H \'priority: i\' \\\n  -H \'referer: https://eai-adp.zvalley.com/\' \\\n  -H \'sec-ch-ua: \"Google Chrome\";v=\"147\", \"Not.A/Brand\";v=\"8\", \"Chromium\";v=\"147\"\' \\\n  -H \'sec-ch-ua-mobile: ?0\' \\\n  -H \'sec-ch-ua-platform: \"Windows\"\' \\\n  -H \'sec-fetch-dest: image\' \\\n  -H \'sec-fetch-mode: no-cors\' \\\n  -H \'sec-fetch-site: same-site\' \\\n  -H \'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36\'','严重','网关下载文件不是流式，导致内存溢出>网关发版解决','','王志熙','',NULL,NULL,'验证通过','','','7492','13718'),('m0429-1','应用编排>人设选定的显示要与后端一致，故新建应用，未选定人设值（即后端未反馈当前应用选定人设值）时，应该不显示默认勾选','严重','有默认选中第一个卡片的逻辑>修改代码逻辑','','李若谷','',NULL,NULL,'验证通过','','','7492','13718'),('m0429-2','阿里云生产-应用发布>T4-应用更新，进度、状态无更新（偶发）','严重','','','王志熙','',NULL,NULL,'验证通过','','','7492','13718'),('m0429-3','知识库>知识库上传后，同步状态、内容更新逻辑优化','一般','状态更新和分段数量的更新不同步>修改代码逻辑','修改代码逻辑','聂祥','',NULL,NULL,'验证通过','','','7492','13718'),('m0429-4','建图>选择已下架的机器人应该可以绘图','一般','之前缺少这块规则定义>需要新接口兼容已下架机器人场景','','郭秦逸','',NULL,NULL,'转需求','','','7492','13718'),('m0429-5','建图>建图页，机器人状态取值、交互控制明确；','一般','之前缺少这块规则定义>修改代码逻辑','','李若谷','',NULL,NULL,'验证通过','','','7492','13718'),('m0429-6','应用编排>组合编排，先播放组合内选中的音频，再播放时间轴音频，应该停止组合编排页音频','严重','边界场景没考虑到','','魏忠亮','',NULL,NULL,'验证通过','','','7492','13718'),('m0429-7','应用编排>需要明确下官方应用编排页需要屏蔽哪些按钮','严重','业务场景考虑不到位>对于官方应用，只保留预览功能，但可以通过创建副本的功能进行复制（复制后视为个人应用）','','郭秦逸','',NULL,NULL,'转需求','','','7492','13718'),('m0429-8','应用编排>需要排查下测试环境官方应用：查看官方应用，数据为为空；查看复制后产生的应用，数据不为空','严重','测试环境官方应用数据是之前旧数据，会有很多兼容问题>新建一个官方应用，配置好数据权限','','王志熙','',NULL,NULL,'待测试','','','7492','13718'),('m0429-9','应用编排>智能编排，3节点，每节点两个，总20分钟多段音频生成，数据为空','严重','大模型连续5次生成的导览文本不符合字数要求，最终判定智能编排失败，后台数据表已记录失败状态，基于模型能力，出现失败是不可避免的情况。>后续切换模型','当前实现效果为生成短时间音频','聂祥','',NULL,NULL,'验证通过','','','7492','13718'),('m0429-10','应用编排>节点事件命中：第一个节点配置了事件，第二个节点没有配置事件，在第二个节点交互，不应该命中','严重','历史对话数据影响，非交互事件命中>每次切换节点清空历史数据','','魏忠亮','',NULL,NULL,'待测试','','','7492','13718'),('m0429-11','应用编排>接上个场景，节点命中事件后，本体位置飘了','严重','加了动作以后位置没刷新','','魏忠亮','',NULL,NULL,'验证通过','','','7492','13718'),('m0429-12','知识库>知识库列表返回箭头显示不全','严重','环境问题','','李若谷','',NULL,NULL,'验证通过','','','7492','13718'),('m0429-13','知识库>知识库上传后状态：同一条数据先显示失败后又显示成功（偶发）','一般','无法复现','','蔡锦辉','',NULL,NULL,'不处理','','','7492','13718'),('m0429-14','知识库>19m文档上传接口等待时间达到20s以上。更大文档可能效率问题更为严重','一般','文档体积过大>先增加loading状态【已添加】，后续改为分片上传','','李若谷','',NULL,NULL,'待测试','','','7492','13718'),('m0429-15','知识库>湘钢一个18.8M知识库文档有两千多个分片，这个列表没有分页，打开很慢，约7s左右','一般','业务场景考虑不到位>@郭秦逸加优化需求，产品设计的就不是分页','','郭秦逸','',NULL,NULL,'转需求','','','7492','13718'),('m0429-15','编排页>编排页知识库列表也没有分页，且显示当前知识库下所有文档的切片，效率问题更加验证','一般','业务场景考虑不到位>转需求','','郭秦逸','',NULL,NULL,'转需求','','','7492','13718'),('m0429-16','编排页>本体执行/平台交互：人设中未指定角色时，机器人可能会回复自己本名','一般','业务场景考虑不到位>增加系统提示词，提示模型名称','','李昊','',NULL,NULL,'处理中','','','7492','13718'),('m0429-17','知识库>知识库批删报错curl \'https://eai-api.zvalley.com/botapi/botadp/knowledge/delete\' \\\n  -H \'accept: application/json\' \\\n  -H \'accept-language: zh\' \\\n  -H \'content-type: application/json\' \\\n  -H \'origin: https://eai-adp.zvalley.com\' \\\n  -H \'priority: u=1, i\' \\\n  -H \'referer: https://eai-adp.zvalley.com/\' \\\n  -H \'sec-ch-ua: \"Google Chrome\";v=\"147\", \"Not.A/Brand\";v=\"8\", \"Chromium\";v=\"147\"\' \\\n  -H \'sec-ch-ua-mobile: ?0\' \\\n  -H \'sec-ch-ua-platform: \"Windows\"\' \\\n  -H \'sec-fetch-dest: empty\' \\\n  -H \'sec-fetch-mode: cors\' \\\n  -H \'sec-fetch-site: same-site\' \\\n  -H \'timestamp: 1777473906343\' \\\n  -H \'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36\' \\\n  -H \'x-client-type: pc\' \\\n  -H \'x-sign: f21y4l32dfaf1cc4c0fcfde0a57453f72fd415\' \\\n  -H \'x-timezone: Asia/Shanghai\' \\\n  -H \'x-user-token: 1b935ef00ced945faa69ebe5d891cefc30x2\' \\\n  -H \'x-zas-starttime: 1777473906343\' \\\n  --data-raw \'{\"id\":\"2047561118196043776\"}\'','严重','aigc删除接口限制了有文档的知识库的删除，所以后端接口调用aigc接口时发生了错误。>后端调整代码逻辑：同时从AIGC平台和应用开关平台删除知识库时，不再去校验AIGC平台的删除状态。【已完成】\n\n@李若谷前端调整删除时的提示词【已完成】\n\n@蔡锦辉数据集删除接口需要允许有文档的数据集删除\naigc开发环境已修改，生产需要等发版','','聂祥','',NULL,NULL,'验证通过','','','7492','13718'),('m00506-1','应用编排>mine环境，组合素材列表——卡片样式异常，见截图','严重','','','李若谷','',NULL,NULL,'验证通过','','','7492','13718'),('m00507-1','阿里云生产-地图创建>发起建图，失败的情况下没有消息反馈','严重','','','李若谷','',NULL,NULL,'待测试','','','7492','13718'),('m00507-2','阿里云生产-地图创建>地图创建过程，本体到达图示区域后，没有再接收到地图扩张','严重','地图话题一直在更新，最后保存地图也是完整的，建议继续观察','','吴凡','',NULL,NULL,'继续观察','','','7492','13718'),('m00507-3','阿里云生产-地图创建>接上个问题：建图完成后，结束建图，没有等待过程，直接进入了第三步，提示如图curl \'https://eai-api.zvalley.com/botapi/botadp/sceneMap/loadMap/2052201296305852416\' \\\n  -H \'accept: application/json\' \\\n  -H \'accept-language: zh\' \\\n  -H \'content-type: application/json\' \\\n  -H \'origin: https://eai-adp.zvalley.com\' \\\n  -H \'priority: u=1, i\' \\\n  -H \'referer: https://eai-adp.zvalley.com/\' \\\n  -H \'sec-ch-ua: \"Google Chrome\";v=\"147\", \"Not.A/Brand\";v=\"8\", \"Chromium\";v=\"147\"\' \\\n  -H \'sec-ch-ua-mobile: ?0\' \\\n  -H \'sec-ch-ua-platform: \"Windows\"\' \\\n  -H \'sec-fetch-dest: empty\' \\\n  -H \'sec-fetch-mode: cors\' \\\n  -H \'sec-fetch-site: same-site\' \\\n  -H \'timestamp: 1778117997953\' \\\n  -H \'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36\' \\\n  -H \'x-client-type: pc\' \\\n  -H \'x-sign: 3it2thfa3ad951c7c36dd709f7e5af9b826855\' \\\n  -H \'x-timezone: Asia/Shanghai\' \\\n  -H \'x-user-token: 1c8614ea5bc34428fb7b383603d0a912f0x2\' \\\n  -H \'x-zas-starttime: 1778117997953\' \\\n  --data-raw \'{}\'','严重','前端逻辑是，socket接收到成功的消息后，设定30s定时器，30s后出现下一步的按钮，所以只能是点击建图的时候，socket直接返回了建图成功的消息，30s定时器直接启动了,后续操作完刚好接上30s,直接去掉第3步。>建议继续观察，','需前端查看状态更新来源','胡昆','',NULL,NULL,'继续观察','','','7492','13718'),('m00507-4','阿里云生产-地图创建>建图失败概率高，需要排查原因','严重','建图程序实际已经启动，但是由于设定时间范围内，SDK里没有wait到发布的有效点云(实际已经发布)，因此判定建图启动异常，杀掉程序。>将等待时间由5s延长至15s，7日下午反复测试十几次，均能正常启动。7日上午集中失败原因无法复现，需继续观察。','','吴凡','',NULL,NULL,'待测试','','','7492','13718'),('m00507-5','阿里云生产-地图创建>打点偶发失败','严重','初始化失败或未触发，而打点要求定位结果较为准确>将定位等待时间延长至30s，然后再初始化，改善情况需要继续观察','','丁建勋','',NULL,NULL,'待测试','','','7492','13718'),('m00507-6','阿里云生产-地图创建>预览结束，自动退出预览模式后，是否应该恢复按钮未开始预览？','严重','按钮未更新状态>预览结束后，按钮恢复至默认状态','','胡昆','',NULL,NULL,'待测试','','','7492','13718'),('m00507-7','阿里云生产-地图创建>预览结束，自动退出预览模式后>>结束建图>>保存并加载到当前应用，抛错\ncurl \'https://eai-api.zvalley.com/botapi/botadp/sceneMap/stopPreview/undefined\' \\\n  -H \'accept: application/json\' \\\n  -H \'accept-language: zh\' \\\n  -H \'content-type: application/json\' \\\n  -H \'origin: https://eai-adp.zvalley.com\' \\\n  -H \'priority: u=1, i\' \\\n  -H \'referer: https://eai-adp.zvalley.com/\' \\\n  -H \'sec-ch-ua: \"Google Chrome\";v=\"147\", \"Not.A/Brand\";v=\"8\", \"Chromium\";v=\"147\"\' \\\n  -H \'sec-ch-ua-mobile: ?0\' \\\n  -H \'sec-ch-ua-platform: \"Windows\"\' \\\n  -H \'sec-fetch-dest: empty\' \\\n  -H \'sec-fetch-mode: cors\' \\\n  -H \'sec-fetch-site: same-site\' \\\n  -H \'timestamp: 1778124589665\' \\\n  -H \'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36\' \\\n  -H \'x-client-type: pc\' \\\n  -H \'x-sign: 76n54pf0da936f30003defa70c12551d688a96\' \\\n  -H \'x-timezone: Asia/Shanghai\' \\\n  -H \'x-user-token: 1c8614ea5bc34428fb7b383603d0a912f0x2\' \\\n  -H \'x-zas-starttime: 1778124589665\' \\\n  --data-raw \'{}\'','严重','地图mapid丢失，mapid取值于浏览器地址中所带参数，不应该有丢失情况,>路由跳转的时候query mapId的确会丢失，已改为路由的生命周期','','胡昆','',NULL,NULL,'待测试','','','7492','13718'),('m00507-8','阿里云生产-任务执行>执行指令下发后，等待一段时间后，返回抛错','严重','已修改为异步，此场景不存在','','胡昆','',NULL,NULL,'待测试','','','7492','13718'),('m00507-9','阿里云生产-任务执行>手动取消执行，提示超时。curl \'https://eai-api.zvalley.com/botapi/botadp/applicationRelease/terminateExecute\' \\\n  -H \'accept: application/json\' \\\n  -H \'accept-language: zh\' \\\n  -H \'content-type: application/json\' \\\n  -H \'origin: https://eai-adp.zvalley.com\' \\\n  -H \'priority: u=1, i\' \\\n  -H \'referer: https://eai-adp.zvalley.com/\' \\\n  -H \'sec-ch-ua: \"Google Chrome\";v=\"147\", \"Not.A/Brand\";v=\"8\", \"Chromium\";v=\"147\"\' \\\n  -H \'sec-ch-ua-mobile: ?0\' \\\n  -H \'sec-ch-ua-platform: \"Windows\"\' \\\n  -H \'sec-fetch-dest: empty\' \\\n  -H \'sec-fetch-mode: cors\' \\\n  -H \'sec-fetch-site: same-site\' \\\n  -H \'timestamp: 1778121257387\' \\\n  -H \'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36\' \\\n  -H \'x-client-type: pc\' \\\n  -H \'x-sign: ubuy6qc7722b225993f092b2702566fcd94417\' \\\n  -H \'x-timezone: Asia/Shanghai\' \\\n  -H \'x-user-token: 1c8614ea5bc34428fb7b383603d0a912f0x2\' \\\n  -H \'x-zas-starttime: 1778121257387\' \\\n  --data-raw \'{\"id\":\"2049309072068845568\",\"robotId\":\"robot-T4-002\",\"operateType\":\"terminate\"}\'','严重','本体的流程引擎挂了，返回结果慢，导致平台接口超时>流程引擎在本体配置开机自启','本体不在任务执行状态中，再调用取消执行会失败（但会有失败回复，需平台配合排查回复内容是否有误）','刘炀勇','',NULL,NULL,'待测试','','','7492','13718'),('m00507-10','阿里云生产-应用部署>操作版本更新，先闪现了已部署，又显示了版本更新中','严重','按钮默认状态字段已部署和socket中最新传的状态字段赋值时间冲突影响>前置设置默认状态字段','','李若谷','',NULL,NULL,'待测试','','','7492','13718'),('m00507-11','阿里云生产-打断交互>下发应用，包含人设。应用执行，本体交互过程中，提问“你是谁”，没有按照人设回答，而是回答了模型原有身份','严重','历史上下文里面包含了原有身份，和提示词里面给的身份不同，存在信息冲突>配置更新清除历史对话和给默认提示词，还有两次对话超过一段时间后，可以把历史对话清除','','崔志伦','',NULL,NULL,'未开始','','','7492','13718'),('m00507-12','阿里云生产-打断交互>固定音频播放，存在打断的情况下，恢复后，出现了长时间等待','严重','','','刘炀勇','',NULL,NULL,'验证通过','','','7492','13718'),('m00507-13','阿里云生产-应用执行>执行弹窗，点击取消，弹窗样式问题，见截图','严重','样式写了之后代码被覆盖了','','魏忠亮','',NULL,NULL,'待测试','','','7492','13718'),('m00507-14','阿里云生产-交互>未执行应用期间，发起本体交互，提问“你是谁”，本体回答了模型原有身份，是否应该有默认人设？','严重','未设置默认人设','','m00508-1解决后此问题无需解决','',NULL,NULL,'未开始','','','7492','13718'),('m00507-15','阿里云生产-任务执行>应用执行，存在换图的情况下（3min左右），平台等待会超时，需要出处理方案（m0422-4）','严重','换图需要三分钟，接口在超时时间内拿不到结果>平台直接显示执行中，本体进行语音播放提示当前进程','换图部分增加语音播报（开始、成功、失败）','邹浩东','',NULL,NULL,'待测试','','','7492','13718'),('m00507-16','阿里云生产-任务执行>本体偶发异常离线','严重','ros2环境偶发各节点失联','','邹浩东','',NULL,NULL,'不处理','','','7492','13718'),('m00507-17','阿里云生产-编排页-交互设置>由于麦克风方案变更，需屏蔽声源角度字段','严重','','','李若谷','',NULL,NULL,'待测试','','','7492','13718'),('m00507-18','阿里云生产-应用执行>取消执行偶发抛错导致流程卡住-需要排查','严重','取消流程遥控器没有上报平台>修改代码,取消后上传到平台','','刘炀勇','',NULL,NULL,'待测试','','','7492','13718'),('m00507-19','阿里云生产-应用执行>取消执行操作成功后，机器人不应该继续前行','严重','补充逻辑：收到终止流程后调用停止导航服务','','邹浩东','',NULL,NULL,'待测试','','','7492','13718'),('m00507-20','阿里云生产-智能编排>智能编排选择地图的情况下，编排无法结束','严重','后端未支持不选择动作库分类，也未进行校验>修改后端代码：支持不选择动作库分类','','聂祥','',NULL,NULL,'待测试','代码实现','代码逻辑问题','7492','13718'),('m00507-21','阿里云生产-首页>更改系统名称为具身智能任务编排平台，英文翻译与aws环境保持一致','严重','','','李若谷','',NULL,NULL,'待测试','','','7492','13718'),('m00508-1','应用编排>应用执行期间唤醒交互，使用：应用内人设、应用内设为启用的知识库、应用内指定音色；\n未在应用执行期间唤醒交互：人设、知识库、音色怎么取？——确认方案','严重','未设置默认人设>本体预置默认音色、人设。当未执行应用时，在唤醒交互后视为应用此默认音色与人设；当执行应用时，优先使用此应用中的人设与音色配置','','崔志伦','',NULL,NULL,'未开始','','','7492','13718'),('m00508-2','阿里云生产-首页>应用执行时固定音频、交互音频音量优化——效果未达预期，需要再次讨论','致命','音量功能未做>控制模型输出音量（关联设置中的音量数值做映射）--已发添加发在测试环境','','郭秦逸','',NULL,NULL,'未开始','','','7492','13718'),('m00508-3','智能编排>明确智能编排图示字段必填、默认值规则','一般','未设置默认字段>必填项：应用名称；机器人型号；描述词。\n非必填项：资源配置\n默认值配置：动作（默认全选）；知识库（默认全选）；音色（默认第一个）；人设（默认第一个）；地图（默认第一个）','','李若谷','',NULL,NULL,'待测试','','','7492','13718'),('m00508-4','智能编排>智能编排-创建页，型号字段出现图示大括号','一般','有字段未显示>不存在时隐藏','','李若谷','',NULL,NULL,'待测试','','','7492','13718'),('m00508-5','智能编排>智能编排，若遇到服务重启等异常情况，前后端都拿不到失败状态，图示动态会一直展示。看看是否需要优化','优化','未考虑异常场景>转需求','','郭秦逸','',NULL,NULL,'转需求','','','7492','13718'),('m00508-6','智能编排>智能编排，若生成失败，打开应用，音频是空的。用户接收不到任何提示，是否需要优化（比如一个点位，总时长20min是会生成失败）','优化','未考虑异常场景>转需求','','郭秦逸','',NULL,NULL,'转需求','','','7492','13718'),('m00508-7','智能编排>事件没有拖至节点3，在节点3交互，不应该命中','严重','历史对话数据影响，非交互事件命中>每次切换节点清空历史数据','','唐柳','',NULL,NULL,'待测试','','','7492','13718'),('m00509-1','智能编排>平台交互唤醒，偶发不按照回应语设定进行回应。当前回应语设定为“我在呢”','严重','历史对话数据影响，非交互事件命中>非软件的问题，这个是历史对话的影响，已更新了新的一版功能','','魏忠亮','',NULL,NULL,'待测试','','','7492','13718'),('m00509-2','智能编排>组合内动作较多时，页面打开、组合素材拖入会有卡顿。——已优化，待发版','一般','动作过多，导致重复的读取到内存上，已调整到本地缓存中','','魏忠亮','',NULL,NULL,'待测试','','','7492','13718'),('m00509-4','阿里云生产-地图创建>发起地图创建，机器人移动过程中，平台看点位没有移动，地图也没有持续扩张','一般','','','丁建勋','',NULL,NULL,'验证通过','','','7492','13718'),('m00509-5','阿里云生产-本体交互>本体交互音色和固定音频音色不一致','严重','','','孙灿','',NULL,NULL,'验证通过','','','7492','13718'),('m00509-6','阿里云生产-地图创建>无法对历史地图遥操打点（即地图绘制结束后，关闭建图页；然后通过地图编辑入口进入打点页，发起遥操，此时本体已返回位置信息，但地图页显示不到本体图标）','严重','机器人实时位姿可能没有推送，看到了ws服务也有一部分上次未关闭的ws服务>等待机器人再次复现问题并修改','','郭秦逸','',NULL,NULL,'转需求','','','7492','13718'),('m00509-7','阿里云生产-流程执行>麦灵敏度太高了','严重','已调整KWS和VAD模型的参数，降低灵敏度','','孙灿','',NULL,NULL,'待测试','','','7492','13718'),('m00509-8','阿里云生产-流程执行>湘钢知识库回答，每次都拼接了中联重科作为主语，需要修改应用中的人设','严重','机器人的人设中给定了中联重科>修改人设','','郭秦逸','',NULL,NULL,'未开始','','','7492','13718'),('m00509-9','阿里云生产-流程执行>本体去往下一个点位时，出现原地不停转圈的情况','严重','','','未知','',NULL,NULL,'不处理','','','7492','13718'),('m00509-10','阿里云生产-流程执行>本体移动不稳定','严重','','','未知','',NULL,NULL,'验证通过','','','7492','13718'),('m00509-11','阿里云生产-流程执行>手动控制模式，遥控器控制不生效','严重','','','邹浩东','',NULL,NULL,'验证通过','','','7492','13718'),('m00509-12','阿里云生产-流程执行>交互过程被本体低电量提醒打断后，无法再次通过麦唤醒','严重','交互过程，播放低电量提醒，可能会影响流程中播放状态，导致逻辑出现问题，需进一步排查>低电量提示时，会改变默认输入设备，打算写一个定时程序（30秒）来重新设置默认输入设备','','孙灿','',NULL,NULL,'处理中','','','7492','13718'),('m00509-13','阿里云生产-流程执行>偶发：喇叭找不见','严重','','','未知','',NULL,NULL,'不处理','','','7492','13718'),('m00509-14','阿里云生产-流程执行>动作无法执行','严重','','','未知','',NULL,NULL,'验证通过','','','7492','13718'),('m00509-15','阿里云生产-流程执行>点位1无法到达-偶发','严重','','','未知','',NULL,NULL,'验证通过','','','7492','13718'),('m00509-17','阿里云生产-流程执行>点位间移动，若需要先调整方向，会出现卡顿','严重','雷达点云较为稀疏，可能导致上一帧障碍物无法清除(清除需要扫描到障碍物与传感器连线后方的体素)，继而导致频繁检测到碰撞而停止>提高体素分辨率','','丁建勋','',NULL,NULL,'待测试','','','7492','13718'),('m005011-1','阿里云生产-流程执行>流程执行过程中，无法唤醒，模型抛错','严重','模型服务挂了，已经重启','','崔志伦','',NULL,NULL,'待测试','','','7492','13718'),('m005011-2','阿里云生产-流程执行>t4新动作现无法在平台播放预览','严重','目前执行动作，类似VLA指令方式执行，无需动作文件，因此可能无法预览','','魏忠亮','',NULL,NULL,'处理中','','','7492','13718'),('m005011-3','阿里云生产-流程执行>全局交互事件命中后动作无法播放','严重','','','崔志伦','',NULL,NULL,'待测试','','','7492','13718'),('m005011-4','阿里云生产-时间轴编排页>新建智能交互事件时（包括全局与节点），校验时不强制要求选择动作，同时在选项后面增加垃圾筒图标用来删除当前动作','严重','业务场景考虑不到位>更改校验逻辑；新增删除选项','','李若谷','',NULL,NULL,'待测试','','','7492','13718'),('m005011-5','阿里云生产-流程执行>动作执行实现方式修改，引发以下问题：动作执行中，恢复初始状态前强行终止流程，则动作无法恢复，后续无法导航','严重','执行动作状态的模型和行走模型不同>流程编排节点判断当前执行动作次数为奇数/偶数，如果是奇数，下发上次/下次的动作完成配对','','邹浩东','',NULL,NULL,'处理中','','','7492','13718'),('m005011-6','阿里云生产-首页>首页应用卡片翻页规则：一页最多展示24个应用卡片，支持右侧区域滚动，少于24个应用时不展示翻页栏','严重','单屏显示范围未约束，需求变更>闲置最大个数','','李若谷','',NULL,NULL,'待测试','','','7492','13718'),('m005012-1','地图创建>地图绑定应用后，从地图编辑页进入重绘地图并保存，可能会造成原应用无法正常执行','严重','需求变更>屏蔽返回第二步的入口','','李若谷','',NULL,NULL,'待测试','','','7492','13718'),('m005012-2','阿里云生产-应用执行-开机自启>开机后，遥控器相关服务未正确启动','严重','遥控器不支持热插拔，需开机前插上遥控器的接收器','','邹浩东','',NULL,NULL,'待测试','','','7492','13718'),('m005012-3','阿里云生产-应用执行-开机自启>开机后，音频播放、音频唤醒相关服务未正确启动','严重','自启动脚本目前未加入音频设备权限，导致收到指令，却没有播放音频','','孙灿','',NULL,NULL,'待测试','','','7492','13718'),('m005012-4','阿里云生产-应用编排>动作没法拖最后一个字后面，每次都自动跑去最后一个字前面','一般','本地暂未复现，检查代码是否有更新','','杨霄','',NULL,NULL,'未开始','','','7492','13718'),('m005012-5','应用编排>先把组合拖动至时间轴，然后从时间轴移出；在从组合列表中删除该素材。但是通过时间轴 的撤销功能，还是能把组合素材显示在时间轴上。然后操作应用保存，报系统繁忙','一般','业务场景考虑不到位>转需求','','王志熙','',NULL,NULL,'转需求','','','7492','13718'),('m005012-6','阿里云生产-应用执行>语义匹配不准确。交互输入：请不要表演太极，结果仍然触发了太极表演','严重','模型对目前事件交互的提示词理解不行>更新事件交互提示词或跟换更好的模型','','唐柳','',NULL,NULL,'未开始','','','7492','13718'),('m005012-7','阿里云生产-应用执行>机器人行进过程中，进行语音交互，命中全局事件及相关动作，产生冲突，引发姿态不稳定','致命','','','邹浩东','',NULL,NULL,'待测试','','','7492','13718'),('m005012-8','阿里云生产-应用执行>本体执行过程中，动作完成之前，进行语音交互，命中全局事件及相关动作，结果：无法执行相关动作，只回复了语音；待原动作完成之后，单独播放了动作。此处流程可能需要优化','一般','','','邹浩东','',NULL,NULL,'待测试','','','7492','13718'),('m005012-9','阿里云生产-应用执行>m0323-2此前T3无需处理的问题，现在可能会影响流程：\n前提：（1）全局交互事件，选择动作“静太极”，时长达到一分钟以上；（2）当前流程打断后恢复只考虑音频，不考虑动作。\n场景1：应用设置为自动模型（非遥控器控制），某节点固定音频播放完成之后，触发交互，命中全局事件及太极表演。但音频时长不可能达到一分钟以上。则在音频结束会触发流程恢复，机器人需要行进至下一节点，此时太极表演还没有结束，则会产生动作冲突，可能会摔。\n场景2：本体执行过程中，进行语音交互，命中全局事件及相关动作，则在音频结束会触发流程恢复，本体必然会一边播放固定音频，一边表演交互事件指定的动作','严重','修改交互打断恢复时的判定规则：动作与语音需都已结束后视为交互事件结束，而非单独以语音结束作为判断条件','','李昊','',NULL,NULL,'未开始','','','7492','13718'),('m005012-10','阿里云生产-应用执行>应用执行过程中，本体重启，应用执行状态被清除，但平台感知不到，仍然显示了忙碌状态，且无法取消','致命','本体重启，不会把状态同步到云上>建议状态统一由本体上报，状态统一','','王志熙','',NULL,NULL,'未开始','','','7492','13718'),('m005012-11','应用部署>应用部署后，删除应用，导致该应用无法卸载','严重','目前基础数据删除，会导致很多地方有问题>统一规划梳理一下需求，对基础数据的删除做规则限制','','王志熙','',NULL,NULL,'转需求','','','7492','13718'),('m005013-1','应用部署>应用引用的动作、插件、知识库、人设、音色、素材被删除，保存、下发执行会出异常','严重','目前基础数据删除，会导致很多地方有问题>统一规划梳理一下需求，对基础数据的删除做规则限制','','郭秦逸','',NULL,NULL,'转需求','','','7492','13718'),('m005013-2','应用编排>本体打太极的时候需要同时播放音乐','优化','新增需求>转需求','','郭秦逸','',NULL,NULL,'转需求','','','7492','13718'),('m005013-3','语音合成>合成的语音需加上音量控制参数','严重','语音合成时目前使用的是默认参数>加入音量控制参数（待产品确定已合成音频音量处理方式）','','张逸玮','',NULL,NULL,'待测试','','','7492','13718'),('m005014-1','阿里云生产-应用执行>本体断网后无法重新联网','致命','','','邹浩东','',NULL,NULL,'处理中','','','7492','13718'),('m005014-2','阿里云生产-建图>打点时，偶发延迟严重，点位移动及成功消息反馈延迟2min','致命','需要前后端配合排查一下消息卡在哪，本体是瞬间打点成功的','网络可能有问题，暂未复现','邹浩东','',NULL,NULL,'处理中','','','7492','13718'),('m005014-3','阿里云生产>开机自启部分服务不可用','致命','','暂不解决','邹浩东','',NULL,NULL,'处理中','','','7492','13718'),('m005014-4','阿里云生产-应用执行>本体去往下一个点位时，出现无法到达点位，四处找路的情况','致命','导航到达检测节点和规控节点对于是否到达的判断依据一致且数据来源一致，但是存在不同步的风险，有可能一个节点认为已到达，但另一节点认为未到达，此时如果已提前进入调整朝向的状态，将永远无法同步触发真正到达>规控节点从导航到达检测节点中拿到判据变量，并且需要在已到达后才能进入原地旋转状态','','丁建勋','',NULL,NULL,'待测试','','','7492','13718'),('m005014-5','阿里云生产-应用执行>本体行进过程中，偶发站不稳，有摔跤趋势','致命','导航行走结束没有回到初始位姿，衔接后续动作会出现问题>云控讨论方案中','','李昊','',NULL,NULL,'处理中','','','7492','13718'),('m005014-6','阿里云生产-资源中心-音色管理>官方音色需根据音色更换封面图','严重','官方音色封面未设计>UI提供封面，前端替换','','石燕兵','',NULL,NULL,'未开始','','','7492','13718'),('m005014-7','阿里云生产-应用部署>取消执行成功后，经常报超时\ncurl \'https://eai-api.zvalley.com/botapi/botadp/applicationRelease/terminateExecute\' \\\n  -H \'accept: application/json\' \\\n  -H \'accept-language: zh\' \\\n  -H \'content-type: application/json\' \\\n  -H \'origin: https://eai-adp.zvalley.com\' \\\n  -H \'priority: u=1, i\' \\\n  -H \'referer: https://eai-adp.zvalley.com/\' \\\n  -H \'sec-ch-ua: \"Chromium\";v=\"148\", \"Google Chrome\";v=\"148\", \"Not/A)Brand\";v=\"99\"\' \\\n  -H \'sec-ch-ua-mobile: ?0\' \\\n  -H \'sec-ch-ua-platform: \"Windows\"\' \\\n  -H \'sec-fetch-dest: empty\' \\\n  -H \'sec-fetch-mode: cors\' \\\n  -H \'sec-fetch-site: same-site\' \\\n  -H \'timestamp: 1778746504122\' \\\n  -H \'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36\' \\\n  -H \'x-client-type: pc\' \\\n  -H \'x-sign: 3txsyc838719325ec47fa19abc8d8d5a9e36a4\' \\\n  -H \'x-timezone: Asia/Shanghai\' \\\n  -H \'x-user-token: 14cfb021629cd41be8a5a9e3167614b9f0x2\' \\\n  -H \'x-zas-starttime: 1778746504122\' \\\n  --data-raw \'{\"id\":\"2052998337960218624\",\"robotId\":\"robot-T4-002\",\"operateType\":\"terminate\"}\'','一般','目前接口层的超时时间是5s，如果5s内没返回接口就会超时>需要综合排查本体是否在一定时间返回，如果确实返回时间过长，有超时是正常现象','','王志熙','',NULL,NULL,'未开始','','','7492','13718'),('m005014-8','阿里云生产-应用执行>节点事件没有添加，本体执行，不应该命中','一般','历史对话数据影响，非交互事件命中>每个节点清理历史数据','开发环境已发版，先在开发环境验证','崔志伦','',NULL,NULL,'待测试','','','7492','13718'),('m005014-9','阿里云生产-应用执行>先播固定音频，然后打断交互，后来平台直接结束任务执行；后续再次下发任务执行，固定音频无法播放','严重','新任务下发时，未对老应用此时的交互状态进行判断和处理','','孙灿','',NULL,NULL,'待测试','','','7492','13718'),('m005014-10','阿里云生产-应用执行>固定音频现在是100 ，并且下发100参数，交互时还用了默认','严重','','','崔志伦','',NULL,NULL,'待测试','','','7492','13718'),('m005014-11','阿里云生产-应用执行>部署后，不关闭应用弹窗，直接点击卸载，抛错curl \'https://eai-api.zvalley.com/botapi/botadp/applicationIssueHistory/cancel\' \\\n  -H \'accept: application/json\' \\\n  -H \'accept-language: zh\' \\\n  -H \'content-type: application/json\' \\\n  -H \'origin: https://eai-adp.zvalley.com\' \\\n  -H \'priority: u=1, i\' \\\n  -H \'referer: https://eai-adp.zvalley.com/\' \\\n  -H \'sec-ch-ua: \"Chromium\";v=\"148\", \"Google Chrome\";v=\"148\", \"Not/A)Brand\";v=\"99\"\' \\\n  -H \'sec-ch-ua-mobile: ?0\' \\\n  -H \'sec-ch-ua-platform: \"Windows\"\' \\\n  -H \'sec-fetch-dest: empty\' \\\n  -H \'sec-fetch-mode: cors\' \\\n  -H \'sec-fetch-site: same-site\' \\\n  -H \'timestamp: 1778829532766\' \\\n  -H \'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36\' \\\n  -H \'x-client-type: pc\' \\\n  -H \'x-sign: 1yjm86a52c2fbfc18704b8f3b3d050f46af216\' \\\n  -H \'x-timezone: Asia/Shanghai\' \\\n  -H \'x-user-token: 15832f71ad11a49b09536ab383ad47d300x2\' \\\n  -H \'x-zas-starttime: 1778829532766\' \\\n  --data-raw \'{\"operate\":\"cancelForUninstall\"}\'','一般','','待发版验证','李若谷','',NULL,NULL,'待测试','','','7492','13718'),('m005018-1','阿里云生产-应用编排>已选择地图a的应用，再次打开地图选择页，地图不变，点击保存，初始点重复','严重','','','','',NULL,NULL,'未开始','','','7492','13718');
/*!40000 ALTER TABLE `rdm_doc_bug` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rdm_issue`
--

DROP TABLE IF EXISTS `rdm_issue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rdm_issue` (
  `issue_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'issueId',
  `sprint_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'sprintId',
  `sprint_name` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'sprint名称',
  `issue_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'issueKey',
  `issue_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'issue类型',
  `issue_name` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'issue名称',
  `reporter` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '报告人',
  `assignee` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '经办人',
  `created` datetime DEFAULT NULL COMMENT '创建时间',
  `updated` datetime DEFAULT NULL COMMENT '更新时间',
  `description` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT '描述',
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '状态',
  `resolution` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '解决结果',
  `priority` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '优先级',
  `require_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '需求类型',
  `callback` int DEFAULT NULL COMMENT '打回次数',
  `developer` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '开发负责人',
  `tester` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '测试负责人',
  `duedate` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '到期日',
  `module` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '模块',
  `bug_story` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '所属故事',
  `bug_type` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '故障类型',
  `bug_flag` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '故障标签',
  `bug_reason` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '故障原因',
  `bug_solver` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '故障修复人',
  `bug_maker` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '故障产生人',
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rdm_issue`
--

LOCK TABLES `rdm_issue` WRITE;
/*!40000 ALTER TABLE `rdm_issue` DISABLE KEYS */;
INSERT INTO `rdm_issue` VALUES ('930967','7629','JSST-1.0-Sprint-9','JSST-2206','故障','团队认证通过后，租户名称错误','罗丽辉','罗丽辉','2026-04-28 16:51:29','2026-04-28 16:51:46','【测试地址】\r\n【测试步骤】\r\n1、登录生态平台，进行团队认证\r\n2、登录运营后台，驳回申请\r\n3、重新进行团队认证\r\n4、审批通过\r\n【预期结果】\r\n租户名称为审批通过的名称\r\n【实际结果】\r\n为驳回的名称','完成','非问题','一般',NULL,0,NULL,NULL,NULL,NULL,NULL,'系统问题',NULL,NULL,NULL,NULL,1,'2026-04-09 13:59:28',NULL,NULL,NULL),('930892','7629','JSST-1.0-Sprint-9','JSST-2205','故障','后台新建账号，选择内部客户，创建后却是外部客户','罗丽辉','罗丽辉','2026-04-28 16:10:37','2026-04-28 16:57:45','【测试地址】\r\n【测试步骤】\r\n1、登录运营后台\r\n2、点击社区优化管理\r\n3、点击新建，选择内部客户\r\n【预期结果】\r\n新建后客户类型为内部客户\r\n【实际结果】\r\n显示为外部客户','完成','完成','严重',NULL,0,NULL,NULL,NULL,NULL,NULL,'系统问题',NULL,'代码实现 - 代码逻辑问题','杨辉煌','杨辉煌',1,'2026-04-09 13:59:28',NULL,NULL,NULL),('930740','7629','JSST-1.0-Sprint-9','JSST-2201','故障','后台新建的用户进行团队认证时未带入真实姓名，无法进行团队认证','罗丽辉','罗丽辉','2026-04-28 15:37:53','2026-04-28 16:26:18','【测试地址】\r\n【测试步骤】\r\n1、登录运营后台，点击社区用户管理，点击新建\r\n2、使用后台新建账号登录生态平台\r\n3、进行团队认证\r\n【预期结果】\r\n填写信息后可提交团队认证\r\n【实际结果】\r\n真实姓名未带入，无法提交','完成','完成','严重',NULL,0,NULL,NULL,NULL,NULL,NULL,'系统问题',NULL,NULL,NULL,NULL,1,'2026-04-09 13:59:28',NULL,NULL,NULL),('930697','7629','JSST-1.0-Sprint-9','JSST-2200','故障','账号新建后，未给注册手机号发送短信','罗丽辉','杨辉煌','2026-04-28 15:19:36','2026-04-28 16:52:41','【测试地址】\r\n【测试步骤】\r\n1、登录运营后台\r\n2、点击生态门户后台管理-社区用户管理\r\n3、点击新建\r\n【预期结果】\r\n手机号收到短信\r\n【实际结果】\r\n无短信','完成','完成','一般',NULL,0,NULL,NULL,NULL,NULL,NULL,'系统问题',NULL,NULL,NULL,NULL,1,'2026-04-09 13:59:28',NULL,NULL,NULL),('926595','7629','JSST-1.0-Sprint-9','JSST-2199','故障','无法进行实名认证、团队认证、账号状态搜索','罗丽辉','罗丽辉','2026-04-24 15:49:26','2026-04-24 16:05:39','【测试地址】\r\n【测试步骤】\r\n1、登录运营平台\r\n2、点击生态门户后台管理\r\n3、点击社区用户管理\r\n【预期结果】\r\n实名认证、团队认证、账号状态为下拉框搜索\r\n【实际结果】\r\n无实名认证、团队认证、账号状态搜索','完成','非问题','一般',NULL,0,NULL,NULL,NULL,NULL,NULL,'系统问题',NULL,NULL,NULL,NULL,1,'2026-04-09 13:59:28',NULL,NULL,NULL),('926592','7629','JSST-1.0-Sprint-9','JSST-2198','故障','真实姓名表头右侧无隐私保护开关','罗丽辉','罗丽辉','2026-04-24 15:46:04','2026-04-24 17:28:08','【测试地址】\r\n【测试步骤】\r\n1、登录运营平台\r\n2、点击生态门户后端管理\r\n3、点击社区用户管理\r\n【预期结果】\r\n隐私保护开关位于真实姓名表头右侧\r\n【实际结果】\r\n真实姓名表头右侧无隐私保护开关','完成','完成','一般',NULL,0,NULL,NULL,NULL,NULL,NULL,'系统问题',NULL,'其他 - 其他','段星宇','段星宇',1,'2026-04-09 13:59:28',NULL,NULL,NULL),('917933','7629','JSST-1.0-Sprint-9','JSST-2167','子任务','用户认证优化-后端','邓平','杨辉煌','2026-04-16 18:26:57','2026-04-24 09:31:23',NULL,'已完成','完成',NULL,NULL,0,NULL,NULL,'2026-04-24',NULL,'JSST-2162',NULL,NULL,NULL,NULL,NULL,1,'2026-04-09 13:59:28',NULL,NULL,NULL),('917932','7629','JSST-1.0-Sprint-9','JSST-2166','子任务','用户认证优化-前端','邓平','段星宇','2026-04-16 18:26:42','2026-04-27 16:17:00',NULL,'已完成','完成',NULL,NULL,0,NULL,NULL,'2026-04-28',NULL,'JSST-2162',NULL,NULL,NULL,NULL,NULL,1,'2026-04-09 13:59:28',NULL,NULL,NULL),('917861','7629','JSST-1.0-Sprint-9','JSST-2162','故事','【阿里云】用户认证优化','陈钊宏','陈钊宏','2026-04-16 17:09:28','2026-04-29 14:01:57','*租户名称合成规则优化：取用户填写的“团队名称”，作为其租户名称*\r\n\r\n团队认证不支持跨类型修改，已认证的高校用户不能修改为企业用户，已认证的企业用户不能修改为高校用户 \r\n\r\n \r\n\r\n*一、全局修改内容*\r\n 1、页面左上角标题改成——团队认证\r\n 2、团队认证类型区分为——高校用户、企业用户两类\r\n 3、两种类型的表单表头保持一致，对应修改成如图所示：团队认证申请、团队认证\r\n 4、课题组名称修改成：团队名称\r\n\r\n!image-2026-04-16-17-09-13-713.png|width=524,height=237!\r\n\r\n \r\n\r\n*二、企业用户说明*\r\n\r\n1、表单所有内容与高校用户保持一致，除了“所在企业”字段；\r\n\r\n2、企业认证的表单填写，需将“所在高校”下拉输入框修改成“所在企业”填写输入框\r\n {color:#de350b}3、该表单提交后，后台租户名称的生成规则不变，依旧是“所在企业+团队名称”的租户名称{color}\r\n 4、上传认证资料\r\n 1）最多可支持上传两份资料，上传完第一份后，第二个上传资料框才会出现\r\n 2）上传格式要求与之前保持一致，不做变更\r\n\r\n \r\n\r\n!image-2026-04-16-17-03-06-450.png|width=524,height=236!\r\n\r\n \r\n\r\n ','已完成','完成','Lowest','优化需求',0,'邓平','罗丽辉',NULL,'后端-邓平',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-04-09 13:59:28',NULL,NULL,NULL),('917633','7629','JSST-1.0-Sprint-9','JSST-2161','子任务','用户认证结果邮件通知-后端','邓平','杨辉煌','2026-04-16 15:36:22','2026-04-17 13:48:53',NULL,'已完成','完成',NULL,NULL,0,NULL,NULL,'2026-04-17',NULL,'JSST-2111',NULL,NULL,NULL,NULL,NULL,1,'2026-04-09 13:59:28',NULL,NULL,NULL),('917623','7629','JSST-1.0-Sprint-9','JSST-2157','子任务','社区用户管理：详情页-后端','邓平','杨辉煌','2026-04-16 15:34:30','2026-04-22 15:50:11',NULL,'已完成','完成',NULL,NULL,0,NULL,NULL,'2026-04-22',NULL,'JSST-2122',NULL,NULL,NULL,NULL,NULL,1,'2026-04-09 13:59:28',NULL,NULL,NULL),('917622','7629','JSST-1.0-Sprint-9','JSST-2156','子任务','社区用户管理：详情页-前端','邓平','段星宇','2026-04-16 15:34:18','2026-04-22 14:53:48',NULL,'已完成','完成',NULL,NULL,0,NULL,NULL,'2026-04-22',NULL,'JSST-2122',NULL,NULL,NULL,NULL,NULL,1,'2026-04-09 13:59:28',NULL,NULL,NULL),('917607','7629','JSST-1.0-Sprint-9','JSST-2148','子任务','社区用户管理：新建账号-后端','邓平','杨辉煌','2026-04-16 15:31:39','2026-04-23 08:38:15',NULL,'已完成','完成',NULL,NULL,0,NULL,NULL,'2026-04-23',NULL,'JSST-2121',NULL,NULL,NULL,NULL,NULL,1,'2026-04-09 13:59:28',NULL,NULL,NULL),('917606','7629','JSST-1.0-Sprint-9','JSST-2147','子任务','社区用户管理：新建账号-前端','邓平','段星宇','2026-04-16 15:31:26','2026-04-23 17:23:51',NULL,'已完成','完成',NULL,NULL,0,NULL,NULL,'2026-04-23',NULL,'JSST-2121',NULL,NULL,NULL,NULL,NULL,1,'2026-04-09 13:59:28',NULL,NULL,NULL),('917602','7629','JSST-1.0-Sprint-9','JSST-2143','子任务','社区用户管理：停启用账号-后端','邓平','杨辉煌','2026-04-16 15:29:48','2026-04-29 11:16:07',NULL,'已完成','完成',NULL,NULL,0,NULL,NULL,'2026-04-29',NULL,'JSST-2120',NULL,NULL,NULL,NULL,NULL,1,'2026-04-09 13:59:28',NULL,NULL,NULL),('917600','7629','JSST-1.0-Sprint-9','JSST-2142','子任务','社区用户管理：停启用账号-前端','邓平','段星宇','2026-04-16 15:29:30','2026-04-24 17:25:32',NULL,'已完成','完成',NULL,NULL,0,NULL,NULL,'2026-04-24',NULL,'JSST-2120',NULL,NULL,NULL,NULL,NULL,1,'2026-04-09 13:59:28',NULL,NULL,NULL),('917592','7629','JSST-1.0-Sprint-9','JSST-2138','子任务','社区用户管理：主列表-后端','邓平','杨辉煌','2026-04-16 15:27:27','2026-04-21 10:23:50',NULL,'已完成','完成',NULL,NULL,0,NULL,NULL,'2026-04-21',NULL,'JSST-2119',NULL,NULL,NULL,NULL,NULL,1,'2026-04-09 13:59:28',NULL,NULL,NULL),('917591','7629','JSST-1.0-Sprint-9','JSST-2137','子任务','社区用户管理：主列表-前端','邓平','段星宇','2026-04-16 15:27:11','2026-04-21 09:02:45',NULL,'已完成','完成',NULL,NULL,0,NULL,NULL,'2026-04-21',NULL,'JSST-2119',NULL,NULL,NULL,NULL,NULL,1,'2026-04-09 13:59:28',NULL,NULL,NULL),('917580','7629','JSST-1.0-Sprint-9','JSST-2133','子任务','用户认证结果短信通知-后端','邓平','杨辉煌','2026-04-16 15:24:01','2026-04-17 13:48:41',NULL,'已完成','完成',NULL,NULL,0,NULL,NULL,'2026-04-17',NULL,'JSST-2113',NULL,NULL,NULL,NULL,NULL,1,'2026-04-09 13:59:28',NULL,NULL,NULL),('917575','7629','JSST-1.0-Sprint-9','JSST-2129','子任务','计费验证遗留问题优化-后端','邓平','杨辉煌','2026-04-16 15:23:06','2026-04-27 09:25:00',NULL,'已完成','完成',NULL,NULL,0,NULL,NULL,'2026-04-27',NULL,'JSST-2057',NULL,NULL,NULL,NULL,NULL,1,'2026-04-09 13:59:28',NULL,NULL,NULL),('917574','7629','JSST-1.0-Sprint-9','JSST-2128','子任务','计费验证遗留问题优化-前端','邓平','段星宇','2026-04-16 15:22:48','2026-04-28 15:15:00',NULL,'已完成','完成',NULL,NULL,0,NULL,NULL,'2026-04-28',NULL,'JSST-2057',NULL,NULL,NULL,NULL,NULL,1,'2026-04-09 13:59:28',NULL,NULL,NULL),('915148','7629','JSST-1.0-Sprint-9','JSST-2122','故事','【阿里云-后台】社区用户管理：详情页','陈钊宏','陈钊宏','2026-04-14 17:59:04','2026-04-29 14:01:35','原型地址：https://ui.zvalley.com/goto/S8ySfGwU 邀请您进入《用户管理》，点击链接开始协作\r\n\r\n \r\n*一、整体说明* \r\n1）点击列表操作下的详情，进入该账号的详情页，在详情页表单存储查看当前账号的全部关联信息\r\n2）整体分为上下两栏，上栏显示包含账号头像、用户名在内的主体信息，下栏则表格展示各类详情信息，具体字段参见原型\r\n!image-2026-04-14-17-57-16-462.png!\r\n \r\n*二、编辑* \r\n1）点击编辑，跳出编辑弹窗\r\n2）可对用户的“用户类型”进行修改\r\n3）点击确认，立即生效\r\n!image-2026-04-14-17-57-39-158.png!','已完成','完成','Lowest','新需求',0,'邓平','罗丽辉',NULL,'java后端-杨辉煌',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-04-09 13:59:28',NULL,NULL,NULL),('915147','7629','JSST-1.0-Sprint-9','JSST-2121','故事','【阿里云-后台】社区用户管理：新建账号','陈钊宏','陈钊宏','2026-04-14 17:55:52','2026-04-29 14:01:26','原型地址：[https://ui.zvalley.com/goto/S8yKWvVJ] 邀请您进入《用户管理》，点击链接开始协作\r\n\r\n \r\n *1、功能说明*\r\n 按字段名完成信息输入，必填项为真实姓名、内外客户、手机号，创建对应用户账号\r\n !image-2026-04-14-17-55-36-291.png!\r\n *2、账号说明*\r\n 1）该创建账号免除实名认证，即该账号无需提交身份证，即可开通对应个人空间，相关材料以空白页显示。\r\n 2）团队空间则需要按正常流程进行\r\n  \r\n {color:#de350b}*3、账号短信提示*{color}\r\n 后台侧新建账户，需要把发送一条创建成功的信息给注册的手机号，信息内容如下： 您的Zvalley RobotOps账号已由管理员代为创建成功。账号：「手机号」，您可通过验证码或修改密码后使用密码登录，请妥善保管账号信息。官网地址:https://eai.zvalley.com','已完成','完成','Lowest','新需求',0,'邓平','罗丽辉',NULL,'java后端-杨辉煌',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-04-09 13:59:28',NULL,NULL,NULL),('915146','7629','JSST-1.0-Sprint-9','JSST-2120','故事','【阿里云-后台】社区用户管理：停启用账号','陈钊宏','陈钊宏','2026-04-14 17:53:48','2026-04-30 08:49:46','原型地址：https://ui.zvalley.com/goto/S8yuybau 邀请您进入《用户管理》，点击链接开始协作\r\n \r\n功能背景\r\n{color:#de350b} 用于社区违规治理、恶意行为控制、安全风险紧急处置，是平台运营与合规的基础能力，可保留用户数据并灵活控制服务权限{color}\r\n \r\n*一、整体说明*\r\n1、在管理员完成用户账号停用后，生态平台登录状态将立刻退出，关联子平台登录状态也将失效，同时给用户手机号发送短信提醒。\r\n2、{color:#de350b}账号停用后，该用户账号下所有数据、积分将被平台冻结保存，并不会删除。在执行的云任务也将继续执行，只是用户失去登录权限，{color}无法再进入平台内页。\r\n3、当账号启用后，用户可正常登录，所有功能正常运行。\r\n!image-2026-04-14-17-53-13-794.png!\r\n!image-2026-04-14-17-53-31-624.png!\r\n \r\n*二、交互说明*\r\n1、点击列表操作停用，跳出安全验证弹窗\r\n2、通过验证码验证当前管理员身份\r\n3、点击下一步，验证通过后跳转至账号停启用弹窗\r\n4、显示用户名、真实姓名、手机号信息，选择启用/停用，点击确认\r\n5、完成账号停用\r\n \r\n*{color:#de350b}三、短信提醒{color}* \r\n1、停用通知\r\n【Zvalley RobotOps】温馨提示：您的账号因涉嫌违规操作，现已被暂时停用。如有疑问，请联系平台客服核实处理。\r\n \r\n2、启用通知\r\n【Zvalley RobotOps】您好，您的账号异常已处理完毕，现已恢复正常启用，可正常登录使用平台功能。','已完成','完成','Lowest','新需求',0,'邓平','罗丽辉',NULL,'java后端-杨辉煌',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-04-09 13:59:28',NULL,NULL,NULL),('915145','7629','JSST-1.0-Sprint-9','JSST-2119','故事','【阿里云-后台】社区用户管理：主列表','陈钊宏','陈钊宏','2026-04-14 17:50:05','2026-04-29 14:06:25','原型地址：[https://ui.zvalley.com/goto/S8y5DSvi] 邀请您进入《用户管理》，点击链接开始协作\r\n  \r\n *一、整体说明* \r\n 社区用户菜单为生态运营管理的二级菜单，用于集中管理平台所有用户账号，包含注册、认证的各类型账号；*{color:#de350b}菜单名参照原型修改{color}*\r\n !image-2026-04-14-17-48-24-689.png!\r\n !image-2026-04-14-17-48-45-119.png!\r\n  \r\n *二、菜单列表说明*\r\n *1、字段包括：*\r\n 头像/用户名、真实姓名、 用户类型（内部用户/外部用户）、实名认证（已认证/未认证）、团队认证（已认证/未认证）、认证租户名称、手机号、账号状态（正常、禁言中、停用）、 最后登录IP、最后登录时间、 操作（详情、停用、注销）\r\n *2、用户排列*\r\n 按用户注册时间倒序排列，即最新注册的显示在第一条\r\n  \r\n *三、功能说明* \r\n *1、隐私保护开关* \r\n 位于真实姓名表头右侧，点击可星号处理列表中真实姓名、认证租户名称、手机号三个字段信息\r\n *2、搜索*\r\n 1）对用户名/真实姓名/手机号进行跨字段模糊搜索\r\n 2）内外客户为下拉框搜索\r\n 3）可一键清空当前搜索状态\r\n  ','已完成','完成','Lowest','新需求',0,'邓平','罗丽辉',NULL,'java后端-杨辉煌',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-04-09 13:59:28',NULL,NULL,NULL),('914500','7629','JSST-1.0-Sprint-9','JSST-2113','故事','【阿里云】用户认证结果短信通知','陈钊宏','陈钊宏','2026-04-14 10:14:23','2026-04-29 13:44:43','当用户提交实名认证/团队认证后，结果的审核通过或驳回需向用户注册的手机号发送短信提醒。\r\n\r\n{color:#de350b}短信内容需带用户名、租户名称等传参。{color}\r\n\r\n即在原有平台提醒的基础上，新增短信提醒方式，内容如下：\r\n||场景||内容||\r\n|实名认证成功|【中联重科】\\{用户名}，您好！您的实名认证已审核通过，租户空间：默认个人空间，可登录Zvalley RobotOps官网使用：[https://eai.zvalley.com|https://eai.zvalley.com/]|\r\n|-实名认证失败-|-【Zvalley RobotOps】\\{用户名}，您好！您的实名认证未通过审核，请核对信息后重新提交。官网地址：[https://eai.zvalley.com|https://eai.zvalley.com/]-|\r\n|团队认证成功|【中联重科】\\{用户名}，您好！您的团队认证已审核通过，租户空间：\\{租户空间名}，可登录Zvalley RobotOps官网使用：[https://eai.zvalley.com|https://eai.zvalley.com/]|\r\n|团队认证失败|【中联重科】\\{用户名}，您好！您的团队认证未通过审核，请核对信息后重新提交。Zvalley RobotOps官网地址：[https://eai.zvalley.com|https://eai.zvalley.com/]|','已完成','完成','Lowest','新需求',0,'邓平','罗丽辉',NULL,'java后端-杨辉煌',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-04-09 13:59:28',NULL,NULL,NULL),('913259','7629','JSST-1.0-Sprint-9','JSST-2111','故事','【AWS】用户认证结果邮件通知','陈钊宏','陈钊宏','2026-04-13 10:26:01','2026-04-29 13:49:47','当用户申请个人/团队空间后，审核通过或驳回需进行邮件提醒。\r\n\r\n即在原有平台提醒的基础上，新增邮件提醒方式，内容如下：\r\n||场景||邮件主题||内容||\r\n|个人认证成功|Subject: Your Personal Space Application Approved|Dear User,\r\nYour application for personal space has been approved. You may now log in and use it normally.\r\nBest regards,\r\nThe Zvalley RobotOps Team|\r\n|个人认证失败|Subject: Your Personal Space Application Rejected|Dear User,\r\nWe regret to inform you that your space application has been rejected. Please check your information and reapply if needed.\r\nBest regards,\r\nThe Zvalley RobotOps Team|\r\n|团队认证成功|Subject: Your Team Space Application Approved|Dear User,\r\nYour application for team space has been approved. You may now log in and use it normally.\r\nBest regards,\r\nThe Zvalley RobotOps Team|\r\n|团队认证失败|Subject: Your Team Space Application Rejected|Dear User,\r\nWe regret to inform you that your space application has been rejected. Please check your information and reapply if needed.\r\nBest regards,\r\nThe Zvalley RobotOps Team|','已完成','完成','Lowest','新需求',0,'邓平','罗丽辉',NULL,'java后端-杨辉煌',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-04-09 13:59:28',NULL,NULL,NULL),('911908','7629','JSST-1.0-Sprint-9','JSST-2108','子任务','java后端-杨辉煌子任务--【阿里云】租户审核通过时，默认开通生态平台应用','李昊','杨辉煌','2026-04-10 15:22:02','2026-04-14 18:15:13','java后端-杨辉煌子任务--【阿里云】租户审核通过时，默认开通生态平台应用','已完成','完成',NULL,NULL,NULL,NULL,NULL,'2026-04-15','java后端-杨辉煌','JSST-2105',NULL,NULL,NULL,NULL,NULL,1,'2026-04-09 13:59:28',NULL,NULL,NULL),('909994','7629','JSST-1.0-Sprint-9','JSST-2105','简单故事','【阿里云】租户审核通过时，默认开通生态平台应用','陈钊宏','陈钊宏','2026-04-09 13:58:09','2026-04-29 14:02:23','1、当租户在运营后台的申请审核通过时，需默认为其开通生态平台应用，以确保埋点数据可用\r\n\r\n2、对于当前已经开通工具链，但未开通生态平台应用的租户，需要手动开通下','已完成','完成','Lowest','新需求',0,'李昊','罗丽辉','2026-04-15','java后端-杨辉煌',NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-04-09 13:59:28',NULL,NULL,NULL),('907090','7629','JSST-1.0-Sprint-9','JSST-2064','故障','时间注解原因，平台时区未统一','罗丽辉','罗丽辉','2026-04-07 16:41:07','2026-04-13 16:35:18','【测试地址】\r\n【测试步骤】\r\n1、点击设置，修改时区\r\n2、AWS开发环境，进入生态平台，点击 projects ，点击Resource Management，点击rent\r\n3、选择起止时间，点击submit\r\n【预期结果】\r\nheader中参数正确，所选时间吻合\r\n【实际结果】\r\n参数正确，时间不吻合','完成','完成','一般',NULL,0,NULL,NULL,NULL,NULL,NULL,'系统问题',NULL,NULL,NULL,NULL,0,'2026-04-09 13:59:28',NULL,NULL,NULL),('904590','7629','JSST-1.0-Sprint-9','JSST-2057','简单故事','【阿里云】计费验证遗留问题优化','陈钊宏','陈钊宏','2026-04-02 11:05:33','2026-04-29 14:02:39','*1、生态平台**项目空间我的机器人、我的算力包中的“使用明细”弹窗页面中，积分前端显示与后端传值精度保持一致（即显示为保留五位小数）*\r\n\r\n \r\n\r\n*2、生态平台——消息弹窗问题*\r\n 问题描述：积分持续多日不足时，产生多条提醒；若用户多日未登录，则登录后提醒弹窗会多次弹出。\r\n *优化方案：全局弹窗仅累计提醒一次；累计的提醒消息需仅完整显示于消息中心***\r\n\r\n \r\n\r\n*3、运营后台——**ACS资源配置问题*\r\n\r\n问题描述：内存和CPU计费周期必须保持一致，现在没在代码层级做控制，实施配置时需要注意。\r\n\r\n*优化方案：表格下面添加固定提示文案：ACS资源类型最小计费的单元时间须保持一致！*\r\n\r\n ','已完成','完成','Lowest','优化需求',0,'邓平','罗丽辉',NULL,'java后端-杨辉煌',NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-04-09 13:59:28',NULL,NULL,NULL),('904153','7629','JSST-1.0-Sprint-9','JSST-2056','子任务','web前端-段星宇子任务--平台多时区处理','李昊','段星宇','2026-04-02 08:49:30','2026-04-07 08:53:04','web前端-段星宇子任务--平台多时区处理','已完成','完成',NULL,NULL,NULL,NULL,NULL,'2026-04-06','web前端-段星宇','JSST-2054',NULL,NULL,NULL,NULL,NULL,0,'2026-04-09 13:59:28',NULL,NULL,NULL),('904152','7629','JSST-1.0-Sprint-9','JSST-2055','子任务','java后端-杨辉煌子任务--平台多时区处理','李昊','杨辉煌','2026-04-02 08:49:30','2026-04-07 10:32:53','java后端-杨辉煌子任务--平台多时区处理','已完成','完成',NULL,NULL,NULL,NULL,NULL,'2026-04-06','java后端-杨辉煌','JSST-2054',NULL,NULL,NULL,NULL,NULL,0,'2026-04-09 13:59:28',NULL,NULL,NULL),('904149','7629','JSST-1.0-Sprint-9','JSST-2054','简单故事','平台多时区处理','李昊','李昊','2026-04-02 08:48:50','2026-04-14 17:26:05','平台需要支持多时区。\r\n\r\n预置条件：数据库、服务器设置为UTC时区。\r\n\r\n1、前端处理：header中传递客户端时区信息\r\n\r\n2、后端处理：数据保存和http返回相关类时间上打上注解，使得时间形式字段保存到数据库\r\n\r\n都为UTC时间，返回时自动按照客户端时区转换','已完成','完成','Lowest','优化需求',0,'李昊','罗丽辉','2026-04-06','java后端-杨辉煌, web前端-段星宇',NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-04-09 13:59:28',NULL,NULL,NULL);
/*!40000 ALTER TABLE `rdm_issue` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rdm_sprint`
--

DROP TABLE IF EXISTS `rdm_sprint`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rdm_sprint` (
  `board_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '看板id',
  `board_name` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '看板名称',
  `project_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '项目id',
  `project_name` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '项目名称',
  `sprint_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Sprint id',
  `origin_sprint_name` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '原Sprint名称',
  `sprint_name` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Sprint名称',
  `short_sprint_name` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '短Sprint名称',
  `startdate` datetime DEFAULT NULL COMMENT 'Sprint计划开始日期',
  `enddate` datetime DEFAULT NULL COMMENT 'Sprint计划结束日期',
  `activated_date` datetime DEFAULT NULL COMMENT 'Sprint激活日期',
  `complete_date` datetime DEFAULT NULL COMMENT 'Sprint完成日期',
  `state` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Sprint状态',
  `goal` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Sprint目标',
  KEY `idx_sprint_id_name` (`sprint_id`,`sprint_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='rdm sprint数据';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rdm_sprint`
--

LOCK TABLES `rdm_sprint` WRITE;
/*!40000 ALTER TABLE `rdm_sprint` DISABLE KEYS */;
INSERT INTO `rdm_sprint` VALUES ('1044','具身智能生态平台','13718','具身智能生态平台','6815','JSST-Sprint 1','JSST-Sprint1','Sprint1','2025-10-20 20:51:00','2025-11-03 20:51:00','2025-10-21 16:32:49','2025-10-27 19:17:03','closed','1, 内容中心\r\n2.租户入住\r\n3.开通项目'),('1044','具身智能生态平台','13718','具身智能生态平台','6845','JSST-1.0-Sprint-1','JSST-1.0-Sprint-1','Sprint','2025-10-24 15:38:00','2025-11-21 15:38:00','2025-10-27 10:06:55','2025-11-27 19:46:40','closed','跑通主流程,开发完成11.7'),('1044','具身智能生态平台','13718','具身智能生态平台','6924','JSST-1.0-Sprint-2','JSST-1.0-Sprint-2','Sprint','2025-11-07 09:34:00','2025-11-28 09:34:00','2025-11-07 14:44:45','2025-12-16 17:05:43','closed',NULL),('1044','具身智能生态平台','13718','具身智能生态平台','6954','JSST-1.0-Sprint-3','JSST-1.0-Sprint-3','Sprint','2025-11-27 11:53:00','2025-12-22 11:53:00','2025-11-26 14:32:38','2025-12-23 09:50:00','closed',NULL),('1044','具身智能生态平台','13718','具身智能生态平台','7071','JSST-1.0-Sprint-4','JSST-1.0-Sprint-4','Sprint','2025-12-12 11:03:00','2026-01-08 11:03:00','2025-12-16 17:06:02','2026-01-12 18:26:40','closed','1,评论管理\r\n2.资源池\r\n3.专有资源选择'),('1044','具身智能生态平台','13718','具身智能生态平台','7221','JSST-1.0-Sprint-5','JSST-1.0-Sprint-5','Sprint','2026-01-12 15:51:00','2026-02-12 15:51:00','2026-01-12 11:13:09','2026-02-12 16:47:20','closed','积分控制'),('1044','具身智能生态平台','13718','具身智能生态平台','7240','JSST-1.0-Sprint-6','JSST-1.0-Sprint-6','Sprint','2026-01-28 12:34:00','2026-02-12 18:34:00','2026-01-28 08:34:57','2026-02-12 16:49:13','closed','1.AWS版改造 2.配额规则优化 3.资源池'),('1044','具身智能生态平台','13718','具身智能生态平台','7410','JSST-1.0-Sprint-7','JSST-1.0-Sprint-7','Sprint','2026-02-25 17:00:00','2026-03-15 17:00:00','2026-02-25 11:49:23','2026-03-26 09:07:42','closed','1.国际化'),('1044','具身智能生态平台','13718','具身智能生态平台','7492','JSST-1.0-Sprint-8','JSST-1.0-Sprint-8','Sprint','2026-03-18 13:41:00','2026-04-10 13:41:00','2026-03-18 14:01:44','2026-04-16 14:25:02','closed','1、内容安全审核\r\n2、积分调整'),('1044','具身智能生态平台','13718','具身智能生态平台','7629','JSST-1.0-Sprint-9','JSST-1.0-Sprint-9','Sprint','2026-04-11 08:30:00','2026-04-30 17:30:00','2026-04-09 13:59:28','2026-04-30 17:34:07','closed',' 1、计费调整 2、用户管理'),('1044','具身智能生态平台','13718','具身智能生态平台','7818','JSST-1.0-Sprint-10','JSST-1.0-Sprint-10','Sprint','2026-05-06 08:30:00','2026-05-24 17:30:00',NULL,NULL,'future','1、阿里云服务 2、仿真评测计费 3、注销用户'),('1036','具身智能应用开发平台','13710','具身智能应用开发平台','6736','EMBODIED Sprint 1','EMBODIED-Sprint1','Sprint1','2025-10-09 08:30:00','2025-10-22 18:00:00','2025-10-09 10:16:38','2026-01-08 11:44:00','closed',NULL),('1036','具身智能应用开发平台','13710','具身智能应用开发平台','7136','botadp-Sprint-1','botadp-Sprint-1','Sprint','2025-12-22 11:05:00','2026-01-17 11:05:00','2025-12-22 16:30:48','2026-01-26 11:08:14','closed','音色维护、基础设置'),('1036','具身智能应用开发平台','13710','具身智能应用开发平台','7222','botadp-Sprint-2','botadp-Sprint-2','Sprint','2026-01-12 17:02:00','2026-01-31 17:02:00','2026-01-10 10:24:07','2026-02-04 17:26:26','closed','1.动作库\r\n2.知识库\r\n3.机器人类型\r\n4.地图'),('1036','具身智能应用开发平台','13710','具身智能应用开发平台','7328','botadp-Sprint-3','botadp-Sprint-3','Sprint','2026-01-28 16:16:00','2026-02-13 16:16:00','2026-01-29 14:15:58','2026-02-26 14:08:54','closed','交互事件\\地图\\人设'),('1036','具身智能应用开发平台','13710','具身智能应用开发平台','7409','botadp-Sprint-4','botadp-Sprint-4','Sprint','2026-02-25 16:49:00','2026-03-20 16:49:00','2026-02-26 14:09:36','2026-03-26 09:20:53','closed','1、汉诺威演示需求\r\n2、国际化、合规需求\r\n3 地图管理优化'),('1036','具身智能应用开发平台','13710','具身智能应用开发平台','7551','botadp-Sprint-5','botadp-Sprint-5','Sprint','2026-03-17 15:41:00','2026-04-10 15:41:00','2026-03-19 08:51:07','2026-04-26 21:51:42','closed','智能编排、地图'),('1036','具身智能应用开发平台','13710','具身智能应用开发平台','7607','botadp-Sprint-6','botadp-Sprint-6','Sprint','2026-04-13 23:24:00','2026-04-30 23:24:00','2026-04-08 14:43:20',NULL,'active','界面优化'),('1036','具身智能应用开发平台','13710','具身智能应用开发平台','7784','botadp-Sprint-7','botadp-Sprint-7','Sprint','2026-04-27 21:52:00','2026-05-18 21:52:00','2026-04-27 10:48:36',NULL,'active','工作流模式应用编排');
/*!40000 ALTER TABLE `rdm_sprint` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rdm_story_changelog`
--

DROP TABLE IF EXISTS `rdm_story_changelog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='故事变更记录';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rdm_story_changelog`
--

LOCK TABLES `rdm_story_changelog` WRITE;
/*!40000 ALTER TABLE `rdm_story_changelog` DISABLE KEYS */;
/*!40000 ALTER TABLE `rdm_story_changelog` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rdm_story_duration`
--

DROP TABLE IF EXISTS `rdm_story_duration`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rdm_story_duration` (
  `project_id` bigint DEFAULT NULL COMMENT '项目ID',
  `project_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '项目名称',
  `sprint_id` bigint DEFAULT NULL COMMENT 'Sprint ID',
  `sprint_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Sprint名称',
  `story_id` bigint DEFAULT NULL COMMENT '故事ID',
  `story_key` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '故事Key',
  `story_name` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '故事名称',
  `create_time` datetime DEFAULT NULL COMMENT '故事创建时间',
  `complete_time` datetime DEFAULT NULL COMMENT '故事完成时间',
  `duration` int DEFAULT NULL COMMENT '故事完成时长(工作日秒数)',
  `duration_str` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '故事完成时长(字符串格式)',
  `duration_all` int DEFAULT NULL COMMENT '故事完成时长(包含非工作日秒数)',
  `duration_all_str` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '故事完成时长(包含非工作日,字符串格式)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='RDM故事完成时长';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rdm_story_duration`
--

LOCK TABLES `rdm_story_duration` WRITE;
/*!40000 ALTER TABLE `rdm_story_duration` DISABLE KEYS */;
/*!40000 ALTER TABLE `rdm_story_duration` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_users`
--

DROP TABLE IF EXISTS `sys_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_users` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名',
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '密码(加密存储)',
  `is_admin` tinyint(1) DEFAULT '0' COMMENT '是否管理员(0:否,1:是)',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_users`
--

LOCK TABLES `sys_users` WRITE;
/*!40000 ALTER TABLE `sys_users` DISABLE KEYS */;
INSERT INTO `sys_users` VALUES (1,'admin','$2b$12$eo.dPF13lDkHxB7M8.OIiOzr47TrjioW.KEM7c.SZHzNmIsCNtUWy',1,'2026-05-07 13:57:04','2026-05-07 13:57:04'),(2,'user01','$2b$12$9YXCwmRP4TqllrqSKejuhecXkz8mv5BvYIANGzlWeGnWZ6VG1cvny',0,'2026-05-07 13:57:04','2026-05-07 13:57:04');
/*!40000 ALTER TABLE `sys_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_workday`
--

DROP TABLE IF EXISTS `sys_workday`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_workday` (
  `year` int DEFAULT NULL COMMENT '年份',
  `datestr` char(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '日期',
  UNIQUE KEY `uk_datestr` (`datestr`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='公共工作日表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_workday`
--

LOCK TABLES `sys_workday` WRITE;
/*!40000 ALTER TABLE `sys_workday` DISABLE KEYS */;
INSERT INTO `sys_workday` VALUES (2026,'2026-01-04'),(2026,'2026-01-05'),(2026,'2026-01-06'),(2026,'2026-01-07'),(2026,'2026-01-08'),(2026,'2026-01-09'),(2026,'2026-01-12'),(2026,'2026-01-13'),(2026,'2026-01-14'),(2026,'2026-01-15'),(2026,'2026-01-16'),(2026,'2026-01-19'),(2026,'2026-01-20'),(2026,'2026-01-21'),(2026,'2026-01-22'),(2026,'2026-01-23'),(2026,'2026-01-26'),(2026,'2026-01-27'),(2026,'2026-01-28'),(2026,'2026-01-29'),(2026,'2026-01-30'),(2026,'2026-02-02'),(2026,'2026-02-03'),(2026,'2026-02-04'),(2026,'2026-02-05'),(2026,'2026-02-06'),(2026,'2026-02-09'),(2026,'2026-02-10'),(2026,'2026-02-11'),(2026,'2026-02-12'),(2026,'2026-02-13'),(2026,'2026-02-14'),(2026,'2026-02-24'),(2026,'2026-02-25'),(2026,'2026-02-26'),(2026,'2026-02-27'),(2026,'2026-02-28'),(2026,'2026-03-02'),(2026,'2026-03-03'),(2026,'2026-03-04'),(2026,'2026-03-05'),(2026,'2026-03-06'),(2026,'2026-03-09'),(2026,'2026-03-10'),(2026,'2026-03-11'),(2026,'2026-03-12'),(2026,'2026-03-13'),(2026,'2026-03-16'),(2026,'2026-03-17'),(2026,'2026-03-18'),(2026,'2026-03-19'),(2026,'2026-03-20'),(2026,'2026-03-23'),(2026,'2026-03-24'),(2026,'2026-03-25'),(2026,'2026-03-26'),(2026,'2026-03-27'),(2026,'2026-03-30'),(2026,'2026-03-31'),(2026,'2026-04-01'),(2026,'2026-04-02'),(2026,'2026-04-03'),(2026,'2026-04-07'),(2026,'2026-04-08'),(2026,'2026-04-09'),(2026,'2026-04-10'),(2026,'2026-04-13'),(2026,'2026-04-14'),(2026,'2026-04-15'),(2026,'2026-04-16'),(2026,'2026-04-17'),(2026,'2026-04-20'),(2026,'2026-04-21'),(2026,'2026-04-22'),(2026,'2026-04-23'),(2026,'2026-04-24'),(2026,'2026-04-27'),(2026,'2026-04-28'),(2026,'2026-04-29'),(2026,'2026-04-30'),(2026,'2026-05-06'),(2026,'2026-05-07'),(2026,'2026-05-08'),(2026,'2026-05-09'),(2026,'2026-05-11'),(2026,'2026-05-12'),(2026,'2026-05-13'),(2026,'2026-05-14'),(2026,'2026-05-15'),(2026,'2026-05-18'),(2026,'2026-05-19'),(2026,'2026-05-20'),(2026,'2026-05-21'),(2026,'2026-05-22'),(2026,'2026-05-25'),(2026,'2026-05-26'),(2026,'2026-05-27'),(2026,'2026-05-28'),(2026,'2026-05-29'),(2026,'2026-06-01'),(2026,'2026-06-02'),(2026,'2026-06-03'),(2026,'2026-06-04'),(2026,'2026-06-05'),(2026,'2026-06-08'),(2026,'2026-06-09'),(2026,'2026-06-10'),(2026,'2026-06-11'),(2026,'2026-06-12'),(2026,'2026-06-15'),(2026,'2026-06-16'),(2026,'2026-06-17'),(2026,'2026-06-18'),(2026,'2026-06-22'),(2026,'2026-06-23'),(2026,'2026-06-24'),(2026,'2026-06-25'),(2026,'2026-06-26'),(2026,'2026-06-29'),(2026,'2026-06-30'),(2026,'2026-07-01'),(2026,'2026-07-02'),(2026,'2026-07-03'),(2026,'2026-07-06'),(2026,'2026-07-07'),(2026,'2026-07-08'),(2026,'2026-07-09'),(2026,'2026-07-10'),(2026,'2026-07-13'),(2026,'2026-07-14'),(2026,'2026-07-15'),(2026,'2026-07-16'),(2026,'2026-07-17'),(2026,'2026-07-20'),(2026,'2026-07-21'),(2026,'2026-07-22'),(2026,'2026-07-23'),(2026,'2026-07-24'),(2026,'2026-07-27'),(2026,'2026-07-28'),(2026,'2026-07-29'),(2026,'2026-07-30'),(2026,'2026-07-31'),(2026,'2026-08-03'),(2026,'2026-08-04'),(2026,'2026-08-05'),(2026,'2026-08-06'),(2026,'2026-08-07'),(2026,'2026-08-10'),(2026,'2026-08-11'),(2026,'2026-08-12'),(2026,'2026-08-13'),(2026,'2026-08-14'),(2026,'2026-08-17'),(2026,'2026-08-18'),(2026,'2026-08-19'),(2026,'2026-08-20'),(2026,'2026-08-21'),(2026,'2026-08-24'),(2026,'2026-08-25'),(2026,'2026-08-26'),(2026,'2026-08-27'),(2026,'2026-08-28'),(2026,'2026-08-31'),(2026,'2026-09-01'),(2026,'2026-09-02'),(2026,'2026-09-03'),(2026,'2026-09-04'),(2026,'2026-09-07'),(2026,'2026-09-08'),(2026,'2026-09-09'),(2026,'2026-09-10'),(2026,'2026-09-11'),(2026,'2026-09-14'),(2026,'2026-09-15'),(2026,'2026-09-16'),(2026,'2026-09-17'),(2026,'2026-09-18'),(2026,'2026-09-20'),(2026,'2026-09-21'),(2026,'2026-09-22'),(2026,'2026-09-23'),(2026,'2026-09-24'),(2026,'2026-09-28'),(2026,'2026-09-29'),(2026,'2026-09-30'),(2026,'2026-10-08'),(2026,'2026-10-09'),(2026,'2026-10-10'),(2026,'2026-10-12'),(2026,'2026-10-13'),(2026,'2026-10-14'),(2026,'2026-10-15'),(2026,'2026-10-16'),(2026,'2026-10-19'),(2026,'2026-10-20'),(2026,'2026-10-21'),(2026,'2026-10-22'),(2026,'2026-10-23'),(2026,'2026-10-26'),(2026,'2026-10-27'),(2026,'2026-10-28'),(2026,'2026-10-29'),(2026,'2026-10-30'),(2026,'2026-11-02'),(2026,'2026-11-03'),(2026,'2026-11-04'),(2026,'2026-11-05'),(2026,'2026-11-06'),(2026,'2026-11-09'),(2026,'2026-11-10'),(2026,'2026-11-11'),(2026,'2026-11-12'),(2026,'2026-11-13'),(2026,'2026-11-16'),(2026,'2026-11-17'),(2026,'2026-11-18'),(2026,'2026-11-19'),(2026,'2026-11-20'),(2026,'2026-11-23'),(2026,'2026-11-24'),(2026,'2026-11-25'),(2026,'2026-11-26'),(2026,'2026-11-27'),(2026,'2026-11-30'),(2026,'2026-12-01'),(2026,'2026-12-02'),(2026,'2026-12-03'),(2026,'2026-12-04'),(2026,'2026-12-07'),(2026,'2026-12-08'),(2026,'2026-12-09'),(2026,'2026-12-10'),(2026,'2026-12-11'),(2026,'2026-12-14'),(2026,'2026-12-15'),(2026,'2026-12-16'),(2026,'2026-12-17'),(2026,'2026-12-18'),(2026,'2026-12-21'),(2026,'2026-12-22'),(2026,'2026-12-23'),(2026,'2026-12-24'),(2026,'2026-12-25'),(2026,'2026-12-28'),(2026,'2026-12-29'),(2026,'2026-12-30'),(2026,'2026-12-31');
/*!40000 ALTER TABLE `sys_workday` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'rdmdb'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-19 13:34:12
