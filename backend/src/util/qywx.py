import json

import requests


def post(robot_key: str, message: str | None = None) -> None:
    """发送企业微信群通知"""
    url = f"https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key={robot_key}"
    # 发送消息
    try:
        response = requests.post(
            url,
            headers={"Content-Type": "application/json"},
            json={"msgtype": "markdown", "markdown": {"content": message}},
        )
        errcode = json.loads(response.content.decode("utf-8")).get("errcode")
        errmsg = json.loads(response.content.decode("utf-8")).get("errmsg")
        print(
            "消息已发送"
            if response.status_code == 200 and errcode == 0
            else "发送失败: " + errmsg
        )
    except Exception as e:
        print("发送失败: " + str(e))


if __name__ == "__main__":
    post("你好")
