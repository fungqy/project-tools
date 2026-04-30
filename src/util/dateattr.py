from datetime import date, timedelta, datetime, timezone
import json
from pathlib import Path

class DateAttr:
    """ 日期相关工具类 """
    # 全局共享的节假日文件路径
    HOLIDAY_FILE = Path(__file__).parent.parent/"holiday/holidayAPI.json"
    _holidays = None  # 类属性缓存节假日数据

    @classmethod
    def get_holidays(cls):
        """用于加载节假日数据文件"""
        if cls._holidays is None:
            with open(cls.HOLIDAY_FILE, "r", encoding="utf-8") as f:
                cls._holidays = json.load(f)  # 延迟加载并缓存
        return cls._holidays

    def __init__(self) -> None:
        self._date = date.today()
        # 加载节假日JSON文件
        self.get_holidays()

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
        return DateAttr.is_holiday_or_compday(self._date)

    @property
    def tomorrow_is_workday(self):
        tomorrow = self._date + timedelta(days=1)
        _is_holiday, _is_compday = DateAttr.is_holiday_or_compday(tomorrow)
        if _is_holiday or (tomorrow.weekday() in (5, 6) and not _is_compday):
            return False
        else:
            return True

    @property
    def is_workday(self):
        _is_holiday, _is_compday = DateAttr.is_holiday_or_compday(self._date)
        if _is_holiday or (self._date.weekday() in (5, 6) and not _is_compday):
            # print("今天是节假日或周末, 无需执行...")
            return False
        else:
            # print("今天是正常工作日或补班日, 需要执行...")
            return True

    @staticmethod
    def firstdayofweek(d=date.today()):
        return d - timedelta(days=d.weekday())

    @staticmethod
    def lastdayofweek(d=date.today()):
        days_to_go = 6 - d.weekday()
        if days_to_go < 0:
            days_to_go += 7
        return d+ timedelta(days=days_to_go)


    @staticmethod
    def is_holiday_or_compday(d):
        def get_holiday_from_api(year, target_date):
            import requests
            url = f"https://holiday.cyi.me/api/holidays?year={year}"
            try:
                resp = requests.get(url, timeout=10)
                if resp.status_code == 200:
                    result = next((day for day in resp.json()['days'] if day['date'] == target_date), None)
                    return (result['isOffDay'], not result['isOffDay']) if result else (False, False)
                else:
                    return False, False
            except requests.RequestException:
                return False, False

        date_str = d.__str__()
        year_str = d.year.__str__()
        # 判断指定日期是否为节假日或补班日
        if int(year_str) > 2020:
            # 调用API判断
            return get_holiday_from_api(d.year, d.strftime("%Y-%m-%d"))
        else:
            # 调用缓存的节假日JSON文件判断
            for holiday in DateAttr._holidays["Years"].get(year_str, {}):
                # 检查节假日区间
                start_date = holiday["StartDate"]
                end_date = holiday["EndDate"]
                if start_date <= date_str <= end_date:
                    return True, False # {'isholiday': True, 'iscompday': False}

                # 检查补班日
                for compday in holiday["CompDays"]:
                    if date_str == compday:
                        return  False, True # {'isholiday': False, 'iscompday': True}

            return False, False # {'isholiday': False, 'iscompday': False}

    @staticmethod
    def remove_timezone(datetime_str):
        """""移除时间中的时区信息"""
        """if not datetime_str:
            return datetime_str"""
        return datetime.strptime(datetime_str, "%Y-%m-%dT%H:%M:%S.%f%z").strftime("%Y-%m-%dT%H:%M:%S.%f")[:-3]

    @staticmethod
    def convert_timezone(datetime_str):
        """将UTC+0时区转换为UTC+8时区"""
        return datetime.strptime(datetime_str[0:19], '%Y-%m-%dT%H:%M:%S') + timedelta(hours=8)

    @staticmethod
    def to_beijing_mysql_datetime(iso_str: str) -> str:
        # 修正时区格式（+0800 -> +08:00）
        if "+" in iso_str and ":" not in iso_str[-5:]:
            iso_str = f"{iso_str[:-2]}:{iso_str[-2:]}"

        dt = datetime.fromisoformat(iso_str)  # 此时格式为 "2025-02-28T14:40:58.000+08:00"
        beijing_tz = timezone(timedelta(hours=8))
        beijing_time = dt.astimezone(beijing_tz)
        return beijing_time.strftime("%Y-%m-%d %H:%M:%S")


if __name__ == "__main__":
    print(DateAttr.is_holiday_or_compday(date(2022, 1, 2)))

    isholiday, iscompday = DateAttr.is_holiday_or_compday(date(2022, 1, 2))
    if isholiday or (date(2022, 1, 2).weekday() in (5, 6) and not iscompday):
        print("今天是节假日或周末, 无需执行...")
    else:
        print("今天是正常工作日或补班日, 需要执行...")