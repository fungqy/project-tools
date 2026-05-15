import logging
from datetime import date

import pandas as pd
from sqlalchemy import text

from ..db.dboperator import DbOperator
from .holiday_service import get_year_workdays

logger = logging.getLogger("Holiday")


def update_holidays_table():
    """更新工作日数据库表"""

    year = date.today().year

    # 检查当前年份数据是否已存在
    engine = DbOperator.get_engine()
    check_query = text("SELECT COUNT(*) FROM sys_workday WHERE year = :year")

    with engine.connect() as conn:
        count = conn.execute(check_query, {"year": year}).scalar()

    if count and count > 0:
        logger.info(f"{year} 年的工作日数据已存在，跳过获取和写入")
        return

    logger.info(f"正在处理 {year} 年的工作日数据...")
    result = get_year_workdays(year)
    if not result:
        logger.error(f"获取 {year} 年数据失败，跳过")
        return

    logger.info(f"获取到 {len(result)} 条数据")

    # 写入数据
    holidays_df = pd.DataFrame(result)
    holidays_df.to_sql("sys_workday", con=engine, if_exists="append", index=False)
    logger.info(f"{year} 年数据写入完成")


def main():
    """主函数"""
    try:
        update_holidays_table()
    except Exception as err:
        logger.error(f"脚本执行出错: {err}")


if __name__ == "__main__":
    main()
