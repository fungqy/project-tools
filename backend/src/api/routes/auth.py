from fastapi import APIRouter, Depends, Header, HTTPException
from pydantic import BaseModel

from api.auth import create_access_token, decode_access_token
from db.database import get_password_hash, get_session, verify_password
from db.models import JiraAuthConfig, User

router = APIRouter(prefix="/api/auth", tags=["认证"])


class LoginRequest(BaseModel):
    username: str
    password: str


class LoginResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: dict


class UserResponse(BaseModel):
    id: int
    username: str
    is_admin: bool


class RegisterRequest(BaseModel):
    username: str
    password: str
    jira_url: str = "http://rdm.zvos.zoomlion.com"
    jira_user: str
    jira_token: str


def get_current_user_from_header(authorization: str = Header(None)):
    """从 Authorization header 获取当前用户"""
    if not authorization:
        raise HTTPException(status_code=401, detail="未提供认证信息")

    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="无效的认证格式")

    token = authorization.replace("Bearer ", "")
    payload = decode_access_token(token)
    if not payload:
        raise HTTPException(status_code=401, detail="Token已过期或无效")

    return payload


@router.post("/login", response_model=LoginResponse)
async def login(request: LoginRequest):
    """用户登录"""
    session = get_session()
    try:
        user = session.query(User).filter(User.username == request.username).first()
        if not user:
            raise HTTPException(status_code=401, detail="用户名或密码错误")

        if not verify_password(request.password, str(user.password)):
            raise HTTPException(status_code=401, detail="用户名或密码错误")

        # 创建 token
        token_data = {
            "sub": str(user.id),
            "username": user.username,
            "is_admin": user.is_admin,
        }
        access_token = create_access_token(token_data)

        return LoginResponse(access_token=access_token, user=user.to_dict())
    finally:
        session.close()


@router.post("/register", response_model=LoginResponse)
async def register(request: RegisterRequest):
    """用户注册（必须提供JIRA认证信息）"""
    session = get_session()
    try:
        # 检查用户名是否已存在
        existing_user = (
            session.query(User).filter(User.username == request.username).first()
        )
        if existing_user:
            raise HTTPException(status_code=400, detail="用户名已存在")

        # 创建新用户
        new_user = User(
            username=request.username,
            password=get_password_hash(request.password),
            is_admin=False,
        )
        session.add(new_user)
        session.flush()  # 获取用户ID

        # 创建用户的JIRA认证配置
        jira_auth = JiraAuthConfig(
            user_id=int(new_user.id),  # type: ignore
            jira_url=request.jira_url,
            jira_user=request.jira_user,
            jira_token=request.jira_token,
        )
        session.add(jira_auth)
        session.commit()
        session.refresh(new_user)

        # 创建 token
        token_data = {
            "sub": str(new_user.id),
            "username": new_user.username,
            "is_admin": new_user.is_admin,
        }
        access_token = create_access_token(token_data)

        return LoginResponse(access_token=access_token, user=new_user.to_dict())
    finally:
        session.close()


@router.get("/me", response_model=UserResponse)
async def get_current_user_info(
    current_user: dict = Depends(get_current_user_from_header),
):
    """获取当前用户信息"""
    session = get_session()
    try:
        user_id = int(current_user.get("sub"))  # type: ignore
        user = session.query(User).filter(User.id == user_id).first()
        if not user:
            raise HTTPException(status_code=404, detail="用户不存在")
        return user.to_dict()
    finally:
        session.close()
