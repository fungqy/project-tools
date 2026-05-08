<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { ElMessage } from 'element-plus'

const router = useRouter()
const authStore = useAuthStore()

const loginForm = ref({
  username: '',
  password: '',
})
const registerForm = ref({
  username: '',
  password: '',
  jira_url: 'http://rdm.zvos.zoomlion.com',
  jira_user: '',
  jira_token: '',
})
const loading = ref(false)
const isRegister = ref(false)

async function handleLogin() {
  if (!loginForm.value.username || !loginForm.value.password) {
    ElMessage.warning('请输入用户名和密码')
    return
  }

  loading.value = true
  try {
    await authStore.login(loginForm.value.username, loginForm.value.password)
    ElMessage.success('登录成功')
    router.push('/dashboard')
  } catch (error) {
    ElMessage.error('登录失败，请检查用户名和密码')
  } finally {
    loading.value = false
  }
}

async function handleRegister() {
  if (!registerForm.value.username || !registerForm.value.password) {
    ElMessage.warning('请输入用户名和密码')
    return
  }
  if (!registerForm.value.jira_user || !registerForm.value.jira_token) {
    ElMessage.warning('请输入JIRA认证信息')
    return
  }

  loading.value = true
  try {
    const response = await fetch('/api/auth/register', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(registerForm.value),
    })
    const data = await response.json()

    if (!response.ok) {
      throw new Error(data.detail || '注册失败')
    }

    ElMessage.success('注册成功')
    isRegister.value = false
    loginForm.value.username = registerForm.value.username
    loginForm.value.password = registerForm.value.password
    await handleLogin()
  } catch (error: any) {
    ElMessage.error(error.message || '注册失败')
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="login-root">
    <div class="login-split">
      <!-- Left panel: brand -->
      <div class="brand-panel">
        <div class="brand-content">
          <div class="brand-mark">
            <svg width="56" height="56" viewBox="0 0 56 56" fill="none">
              <rect width="56" height="56" rx="16" fill="white" fill-opacity="0.12"/>
              <rect x="14" y="14" width="12" height="12" rx="3" fill="white"/>
              <rect x="30" y="14" width="12" height="12" rx="3" fill="white" opacity="0.6"/>
              <rect x="14" y="30" width="12" height="12" rx="3" fill="white" opacity="0.6"/>
              <rect x="30" y="30" width="12" height="12" rx="3" fill="white" opacity="0.3"/>
            </svg>
          </div>
          <h1>项目工具</h1>
          <p>统一管理项目进度提醒、任务调度与质量分析</p>
          <div class="brand-features">
            <div class="feature-item">
              <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                <path d="M3 8l3 3 7-7" stroke="white" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
              <span>JIRA 进度自动同步</span>
            </div>
            <div class="feature-item">
              <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                <path d="M3 8l3 3 7-7" stroke="white" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
              <span>SonarQube 扫描提醒</span>
            </div>
            <div class="feature-item">
              <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                <path d="M3 8l3 3 7-7" stroke="white" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
              <span>企业微信机器人推送</span>
            </div>
          </div>
        </div>
        <div class="brand-bg-circle"></div>
      </div>

      <!-- Right panel: form -->
      <div class="form-panel">
        <div class="form-card">
          <div class="form-header">
            <h2>{{ isRegister ? '创建账号' : '欢迎回来' }}</h2>
            <p>{{ isRegister ? '填写以下信息完成注册' : '请输入您的账号信息' }}</p>
          </div>

          <!-- Login -->
          <el-form v-if="!isRegister" class="auth-form" @submit.prevent="handleLogin">
            <div class="field-group">
              <label class="field-label">用户名</label>
              <el-input
                v-model="loginForm.username"
                placeholder="请输入用户名"
                size="large"
                class="clean-input"
              >
                <template #prefix>
                  <svg width="16" height="16" viewBox="0 0 16 16" fill="none" style="opacity:0.4">
                    <circle cx="8" cy="5" r="3" stroke="currentColor" stroke-width="1.2"/>
                    <path d="M2 13c0-3.3 2.7-6 6-6s6 2.7 6 6" stroke="currentColor" stroke-width="1.2" stroke-linecap="round"/>
                  </svg>
                </template>
              </el-input>
            </div>
            <div class="field-group">
              <label class="field-label">密码</label>
              <el-input
                v-model="loginForm.password"
                type="password"
                placeholder="请输入密码"
                size="large"
                class="clean-input"
                show-password
                @keyup.enter="handleLogin"
              >
                <template #prefix>
                  <svg width="16" height="16" viewBox="0 0 16 16" fill="none" style="opacity:0.4">
                    <rect x="3" y="7" width="10" height="7" rx="1.5" stroke="currentColor" stroke-width="1.2"/>
                    <path d="M5 7V5a3 3 0 0 1 6 0v2" stroke="currentColor" stroke-width="1.2" stroke-linecap="round"/>
                  </svg>
                </template>
              </el-input>
            </div>
            <el-button
              type="primary"
              size="large"
              :loading="loading"
              class="submit-btn"
              native-type="submit"
            >
              登 录
            </el-button>
            <div class="form-switch">
              还没有账号？<button type="button" @click="isRegister = true">立即注册</button>
            </div>
          </el-form>

          <!-- Register -->
          <el-form v-else class="auth-form" @submit.prevent="handleRegister">
            <div class="field-group">
              <label class="field-label">用户名</label>
              <el-input
                v-model="registerForm.username"
                placeholder="选择用户名"
                size="large"
                class="clean-input"
              >
                <template #prefix>
                  <svg width="16" height="16" viewBox="0 0 16 16" fill="none" style="opacity:0.4">
                    <circle cx="8" cy="5" r="3" stroke="currentColor" stroke-width="1.2"/>
                    <path d="M2 13c0-3.3 2.7-6 6-6s6 2.7 6 6" stroke="currentColor" stroke-width="1.2" stroke-linecap="round"/>
                  </svg>
                </template>
              </el-input>
            </div>
            <div class="field-group">
              <label class="field-label">密码</label>
              <el-input
                v-model="registerForm.password"
                type="password"
                placeholder="设置密码"
                size="large"
                class="clean-input"
                show-password
              >
                <template #prefix>
                  <svg width="16" height="16" viewBox="0 0 16 16" fill="none" style="opacity:0.4">
                    <rect x="3" y="7" width="10" height="7" rx="1.5" stroke="currentColor" stroke-width="1.2"/>
                    <path d="M5 7V5a3 3 0 0 1 6 0v2" stroke="currentColor" stroke-width="1.2" stroke-linecap="round"/>
                  </svg>
                </template>
              </el-input>
            </div>

            <div class="divider">
              <span>JIRA 认证信息</span>
            </div>

            <div class="field-group">
              <label class="field-label">JIRA 地址</label>
              <el-input
                v-model="registerForm.jira_url"
                placeholder="http://rdm.zvos.zoomlion.com"
                size="large"
                class="clean-input"
              />
            </div>
            <div class="field-group">
              <label class="field-label">JIRA 用户名</label>
              <el-input
                v-model="registerForm.jira_user"
                placeholder="JIRA 登录用户名"
                size="large"
                class="clean-input"
              />
            </div>
            <div class="field-group">
              <label class="field-label">JIRA Token</label>
              <el-input
                v-model="registerForm.jira_token"
                type="password"
                placeholder="JIRA API Token"
                size="large"
                class="clean-input"
                show-password
              />
            </div>

            <el-button
              type="primary"
              size="large"
              :loading="loading"
              class="submit-btn"
              native-type="submit"
            >
              注 册
            </el-button>
            <div class="form-switch">
              已有账号？<button type="button" @click="isRegister = false">立即登录</button>
            </div>
          </el-form>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped lang="scss">
.login-root {
  height: 100vh;
  overflow: hidden;
}

.login-split {
  display: flex;
  height: 100vh;
}

// ── Brand Panel ────────────────────────────────────────────────
.brand-panel {
  flex: 0 0 45%;
  background: var(--ink-primary);
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  overflow: hidden;
  padding: 60px;

  &::before {
    content: '';
    position: absolute;
    top: -200px;
    right: -200px;
    width: 600px;
    height: 600px;
    border-radius: 50%;
    background: #2D5BFF;
    opacity: 0.08;
  }

  &::after {
    content: '';
    position: absolute;
    bottom: -150px;
    left: -150px;
    width: 400px;
    height: 400px;
    border-radius: 50%;
    background: #2D5BFF;
    opacity: 0.06;
  }
}

.brand-content {
  position: relative;
  z-index: 1;
  max-width: 380px;
  animation: fadeSlideUp 0.6s cubic-bezier(0.22, 1, 0.36, 1) both;
}

.brand-mark {
  margin-bottom: 32px;
}

.brand-content h1 {
  font-family: 'Sora', sans-serif;
  font-size: 36px;
  font-weight: 700;
  color: #fff;
  margin-bottom: 16px;
  letter-spacing: -0.03em;
}

.brand-content p {
  font-size: 15px;
  color: rgba(255,255,255,0.6);
  line-height: 1.6;
  margin-bottom: 40px;
}

.brand-features {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.feature-item {
  display: flex;
  align-items: center;
  gap: 12px;
  color: rgba(255,255,255,0.75);
  font-size: 14px;

  svg {
    opacity: 0.9;
  }
}

.brand-bg-circle {
  position: absolute;
  right: -80px;
  top: 50%;
  transform: translateY(-50%);
  width: 300px;
  height: 300px;
  border-radius: 50%;
  border: 1px solid rgba(255,255,255,0.06);
}

// ── Form Panel ─────────────────────────────────────────────────
.form-panel {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--bg-base);
  padding: 40px;
}

.form-card {
  width: 100%;
  max-width: 400px;
  animation: fadeSlideUp 0.5s cubic-bezier(0.22, 1, 0.36, 1) 0.1s both;
}

.form-header {
  margin-bottom: 36px;

  h2 {
    font-size: 28px;
    font-weight: 700;
    color: var(--ink-primary);
    margin-bottom: 8px;
    letter-spacing: -0.03em;
  }

  p {
    font-size: 14px;
    color: var(--ink-secondary);
  }
}

// ── Auth Form ─────────────────────────────────────────────────
.auth-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.field-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.field-label {
  font-size: 13px;
  font-weight: 600;
  color: var(--ink-primary);
}

.clean-input {
  :deep(.el-input__wrapper) {
    border-radius: var(--radius-sm);
    box-shadow: none;
    border: 1.5px solid #E5E7EB;
    background: var(--bg-surface);
    padding: 4px 14px;
    transition: border-color 0.18s ease, box-shadow 0.18s ease;

    &:hover { border-color: #D1D5DB; }

    &.is-focus {
      border-color: var(--accent);
      box-shadow: 0 0 0 3px rgba(45, 91, 255, 0.08);
    }
  }
}

.submit-btn {
  width: 100%;
  height: 48px;
  font-size: 15px;
  font-weight: 600;
  border-radius: var(--radius-sm);
  letter-spacing: 0.02em;
  margin-top: 4px;
}

.form-switch {
  text-align: center;
  font-size: 13px;
  color: var(--ink-secondary);

  button {
    background: none;
    border: none;
    color: var(--accent);
    font-weight: 600;
    cursor: pointer;
    font-size: 13px;
    padding: 0;
    margin-left: 4px;

    &:hover { text-decoration: underline; }
  }
}

.divider {
  display: flex;
  align-items: center;
  gap: 12px;
  margin: 4px 0;

  &::before, &::after {
    content: '';
    flex: 1;
    height: 1px;
    background: #E5E7EB;
  }

  span {
    font-size: 12px;
    font-weight: 600;
    color: var(--ink-tertiary);
    text-transform: uppercase;
    letter-spacing: 0.08em;
    white-space: nowrap;
  }
}

@keyframes fadeSlideUp {
  from { opacity: 0; transform: translateY(20px); }
  to   { opacity: 1; transform: translateY(0); }
}
</style>
