from datetime import date

import pandas as pd

from db.dboperator import DbOperator
from holiday.holiday_service import get_holiday_data_for_db


def update_holidays_table(years: list[int] | None = None):
    """更新节假日数据库表

    Args:
        years: 要更新的年份列表，默认为当前年份和下一年
    """
    if years is None:
        today = date.today()
        years = [today.year, today.year + 1]

    for year in years:
        print(f"正在处理 {year} 年的节假日数据...")
        result = get_holiday_data_for_db(year)
        if not result:
            print(f"  获取 {year} 年数据失败，跳过")
            continue

        print(f"  获取到 {len(result)} 条数据")

        # 清空库表并写入数据
        DbOperator.truncate_table("holidays")
        holidays_df = pd.DataFrame(result)
        holidays_df.to_sql(
            "holidays", con=DbOperator.get_engine(), if_exists="append", index=False
        )
        print(f"  {year} 年数据写入完成")


def main():
    """主函数"""
    try:
        update_holidays_table()
        print("节假日表更新完成!")
    except Exception as err:
        print(f"脚本执行出错: {err}")


if __name__ == "__main__":
    main()
