from datetime import date, datetime, timedelta, timezone

from holiday.holiday_service import is_holiday_or_compday as _check_holiday


class DateAttr:
    """日期相关工具类"""

    def __init__(self) -> None:
        self._date = date.today()

    @property
    def weekday(self):
        return self._date.weekday() + 1

    @property
    def is_weekend(self):
        return self._date.weekday() in (5, 6)

    @property
    def firstday_of_week(self):
        return DateAttr.firstdayofweek(self._date)

    @property
    def lastday_of_week(self):
        return DateAttr.lastdayofweek(self._date)

    @property
    def holiday_or_compday(self):
        return _check_holiday(self._date)

    @property
    def is_workday(self):
        _is_holiday, _is_compday = _check_holiday(self._date)
        if _is_holiday or (self._date.weekday() in (5, 6) and not _is_compday):
            return False
        else:
            return True

    @staticmethod
    def firstdayofweek(d=date.today()):
        return d - timedelta(days=d.weekday())

    @staticmethod
    def lastdayofweek(d=date.today()):
        days_to_go = 6 - d.weekday()
        if days_to_go < 0:
            days_to_go += 7
        return d + timedelta(days=days_to_go)

    @staticmethod
    def is_holiday_or_compday(d) -> tuple[bool, bool]:
        """判断指定日期是否为节假日或补班日

        Returns:
            tuple: (is_holiday, is_compday)
                - is_holiday=True, is_compday=False: 节假日
                - is_holiday=False, is_compday=True: 补班日
                - is_holiday=False, is_compday=False: 普通工作日
        """
        return _check_holiday(d)

    @staticmethod
    def remove_timezone(datetime_str):
        """ ""移除时间中的时区信息"""
        """if not datetime_str:
            return datetime_str"""
        return datetime.strptime(datetime_str, "%Y-%m-%dT%H:%M:%S.%f%z").strftime(
            "%Y-%m-%dT%H:%M:%S.%f"
        )[:-3]

    @staticmethod
    def convert_timezone(datetime_str):
        """将UTC+0时区转换为UTC+8时区"""
        return datetime.strptime(datetime_str[0:19], "%Y-%m-%dT%H:%M:%S") + timedelta(
            hours=8
        )

    @staticmethod
    def to_beijing_mysql_datetime(iso_str: str) -> str:
        # 修正时区格式（+0800 -> +08:00）
        if "+" in iso_str and ":" not in iso_str[-5:]:
            iso_str = f"{iso_str[:-2]}:{iso_str[-2:]}"

        dt = datetime.fromisoformat(
            iso_str
        )  # 此时格式为 "2025-02-28T14:40:58.000+08:00"
        beijing_tz = timezone(timedelta(hours=8))
        beijing_time = dt.astimezone(beijing_tz)
        return beijing_time.strftime("%Y-%m-%d %H:%M:%S")


if __name__ == "__main__":
    from holiday.holiday_service import is_holiday_or_compday

    print(is_holiday_or_compday(date(2025, 1, 1)))  # 元旦，应该返回 (True, False)
    print(is_holiday_or_compday(date(2025, 1, 26)))  # 春节补班，应该返回 (False, True)
    print(is_holiday_or_compday(date(2025, 1, 27)))  # 春节，应该返回 (True, False)

    # 测试今天
    today = date.today()
    isholiday, iscompday = is_holiday_or_compday(today)
    print(f"今天 ({today}): 节假日={isholiday}, 补班日={iscompday}")
