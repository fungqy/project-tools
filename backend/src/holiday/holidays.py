import json
import pandas as pd
from datetime import datetime, date
import calendar
from db.dboperator import DbOperator

# 加载节假日JSON数据（假设已保存为holiday_calendar.json）
with open('holidayAPI.json', 'r', encoding='utf-8') as f:
    holiday_data = json.load(f)

# 获取2024年节假日数据
holidays_2024 = holiday_data['Years']['2024']
comp_days_2024 = []
for holiday in holidays_2024:
    comp_days_2024.extend(holiday['CompDays'])

# 获取2025年节假日数据
holidays_2025 = holiday_data['Years']['2025']
comp_days_2025 = []
for holiday in holidays_2025:
    comp_days_2025.extend(holiday['CompDays'])

# 生成带节假日标记的日期数据
result = []
for year in (2024, 2025):
    if year == 2024:
        comp_days = comp_days_2024
        holidays = holidays_2024
    else:
        comp_days = comp_days_2025
        holidays = holidays_2025
    for month in range(1, 13):
        _, days_in_month = calendar.monthrange(year, month)

        for day in range(1, days_in_month + 1):
            current_date = date(year, month, day)
            datestr = current_date.strftime('%Y-%m-%d')
            weekday = current_date.weekday()

            # 判断是否是假日或补班日
            isholiday = 0
            iscompday = 0

            for holiday in holidays:
                start_date = datetime.strptime(holiday['StartDate'], '%Y-%m-%d').date()
                end_date = datetime.strptime(holiday['EndDate'], '%Y-%m-%d').date()
                if start_date <= current_date <= end_date:
                    isholiday = 1
                    break

            if datestr in comp_days:
                iscompday = 1

            result.append({
                "datestr": datestr,
                "weekday": weekday + 1,
                "isholiday": isholiday,
                "iscompday": iscompday
            })

# 清空库表
DbOperator.truncate_table('holidays')
# 写入库表
holidays_df = pd.DataFrame(result)
holidays_df.to_sql('holidays', con=DbOperator.get_engine(), if_exists='append', index=False)