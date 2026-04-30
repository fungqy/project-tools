"""节假日数据服务模块

提供统一的节假日数据获取和缓存功能，被 dateattr.py 和 holidays.py 共用
"""

import logging
from datetime import date
from typing import Optional

import requests

logger = logging.getLogger(__name__)

# 节假日数据缓存
# {year: {"holidays": set(), "workdays": set()}}
_holidays_cache: dict[int, dict[str, set[str]]] = {}
_cache_year: Optional[int] = None


def _fetch_holidays_from_url(year: int) -> Optional[dict[str, set[str]]]:
    """从URL获取指定年份的节假日数据并缓存"""
    url = f"https://cdn.jsdelivr.net/gh/NateScarlet/holiday-cn@master/{year}.json"
    try:
        resp = requests.get(url, timeout=10)
        if resp.status_code == 200:
            data = resp.json()
            holidays = set()
            workdays = set()

            for day in data.get("days", []):
                day_date = day["date"]
                is_off_day = day.get("isOffDay", False)
                if is_off_day:
                    holidays.add(day_date)
                else:
                    workdays.add(day_date)

            _holidays_cache[year] = {"holidays": holidays, "workdays": workdays}
            logger.info(
                f"成功从URL获取 {year} 年节假日数据: {len(holidays)} 个节假日, {len(workdays)} 个工作日"
            )
            return _holidays_cache[year]
        else:
            logger.warning(f"获取节假日数据失败: HTTP {resp.status_code}")
            return None
    except requests.RequestException as e:
        logger.error(f"获取节假日数据失败: {e}")
        return None


def get_holidays_for_year(year: int) -> Optional[dict[str, set[str]]]:
    """获取指定年份的节假日数据（优先使用缓存）"""
    global _cache_year

    # 如果已经有缓存且年份匹配，直接返回
    if _cache_year == year and year in _holidays_cache:
        return _holidays_cache[year]

    # 尝试从URL获取
    holiday_data = _fetch_holidays_from_url(year)
    if holiday_data:
        _cache_year = year
        return holiday_data

    # 如果URL获取失败，尝试使用本地缓存（如果有）
    if year in _holidays_cache:
        _cache_year = year
        return _holidays_cache[year]

    return None


def is_holiday_or_compday(d: date) -> tuple[bool, bool]:
    """判断指定日期是否为节假日或补班日

    Args:
        d: 日期

    Returns:
        tuple: (is_holiday, is_compday)
            - is_holiday=True, is_compday=False: 节假日
            - is_holiday=False, is_compday=True: 补班日
            - is_holiday=False, is_compday=False: 普通工作日
    """
    date_str = d.strftime("%Y-%m-%d")
    year = d.year

    # 加载节假日数据
    holiday_data = get_holidays_for_year(year)

    if holiday_data is None:
        # 如果获取失败，默认按工作日处理
        return False, False

    holidays = holiday_data["holidays"]
    workdays = holiday_data["workdays"]

    # 节假日（isOffDay=true）
    if date_str in holidays:
        return True, False

    # 补班日（isOffDay=false但在节假日数据中，表示需要上班）
    if date_str in workdays:
        return False, True

    # 不在节假日数据中，按周末判断
    if d.weekday() in (5, 6):
        return False, False

    return False, False


def get_holiday_data_for_db(year: int) -> list[dict]:
    """获取指定年份的节假日数据，用于写入数据库

    Returns:
        list: 包含 datestr, weekday, isholiday, iscompday 的字典列表
    """
    import calendar

    holiday_data = get_holidays_for_year(year)
    if holiday_data is None:
        logger.error(f"无法获取 {year} 年的节假日数据")
        return []

    holidays = holiday_data["holidays"]
    workdays = holiday_data["workdays"]

    result = []
    for month in range(1, 13):
        _, days_in_month = calendar.monthrange(year, month)

        for day in range(1, days_in_month + 1):
            current_date = date(year, month, day)
            datestr = current_date.strftime("%Y-%m-%d")
            weekday = current_date.weekday() + 1  # 周一=1, 周日=7

            # 判断是否是假日或补班日
            isholiday = 0
            iscompday = 0

            if datestr in holidays:
                isholiday = 1
            elif datestr in workdays:
                iscompday = 1

            result.append(
                {
                    "datestr": datestr,
                    "weekday": weekday,
                    "isholiday": isholiday,
                    "iscompday": iscompday,
                }
            )

    return result
