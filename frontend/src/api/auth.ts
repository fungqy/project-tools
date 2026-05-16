import api from './index'

export interface LoginRequest {
  username: string
  password: string
}

export interface UserInfo {
  id: number
  username: string
  is_admin: boolean
  created_at?: string
  updated_at?: string
}

export interface LoginResponse {
  access_token: string
  token_type: string
  user: UserInfo
}

export const authApi = {
  login(data: LoginRequest) {
    return api.post<LoginResponse>('/auth/login', data) as unknown as Promise<LoginResponse>
  },

  getCurrentUser() {
    return api.get<UserInfo>('/auth/me') as unknown as Promise<UserInfo>
  },

  register(username: string, password: string) {
    return api.post<UserInfo>('/auth/register', null, {
      params: { username, password },
    }) as unknown as Promise<UserInfo>
  },
}
