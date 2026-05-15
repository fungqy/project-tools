"""节假日数据服务模块

提供统一的节假日数据获取和缓存功能，被 dateattr.py 和 holidays.py 共用
"""

import logging
from datetime import date
from typing import Optional

import requests

logger = logging.getLogger("Holiday")

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


def _get_year_holiday(year: int) -> Optional[dict[str, set[str]]]:
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


def check_isworkday(d: date) -> bool:
    """判断指定日期是否为工作日

    Args:
        d: 日期

    Returns:
        bool: 是否为工作日
    """

    # 加载节假日数据
    holiday_data = _get_year_holiday(d.year)

    if holiday_data is None:
        return True

    holidays = holiday_data["holidays"]
    workdays = holiday_data["workdays"]

    weekday = d.weekday() + 1

    # 判断是否是假日或补班日
    date_str = d.strftime("%Y-%m-%d")
    isholiday = date_str in holidays
    iscompday = date_str in workdays

    # 判断是否为工作日
    return (weekday <= 5 and not isholiday) or iscompday


def get_year_workdays(year: int) -> list[dict]:
    """获取指定年份的工作日数据，用于写入数据库

    Returns:
        list: 包含 year, datestr, isworkday, isholiday, iscompday 的字典列表
    """
    import calendar

    result = []
    for month in range(1, 13):
        _, days_in_month = calendar.monthrange(year, month)

        for day in range(1, days_in_month + 1):
            current_date = date(year, month, day)
            isworkday = check_isworkday(current_date)

            if isworkday:
                result.append(
                    {
                        "year": year,
                        "datestr": current_date.strftime("%Y-%m-%d"),
                    }
                )

    return result
