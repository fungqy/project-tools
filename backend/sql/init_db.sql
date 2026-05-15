-- ================================================
-- 项目管理工具数据库初始化脚本
-- 数据库: rdmdb
-- ================================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS rdmdb DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 创建数据库用户
CREATE USER IF NOT EXISTS 'rdmuser'@'%' IDENTIFIED BY 'rdmpass123';
CREATE USER IF NOT EXISTS 'rdmuser'@'localhost' IDENTIFIED BY 'rdmpass123';

-- 授权
GRANT ALL PRIVILEGES ON rdmdb.* TO 'rdmuser'@'%';
GRANT ALL PRIVILEGES ON rdmdb.* TO 'rdmuser'@'localhost';
