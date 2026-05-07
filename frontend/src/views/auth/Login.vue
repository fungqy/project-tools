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
  <div class="login-container">
    <div class="login-box">
      <div class="login-header">
        <el-icon :size="48" color="#409eff"><Monitor /></el-icon>
        <h1>项目工具平台</h1>
        <p>Project Tools Platform</p>
      </div>

      <!-- 登录表单 -->
      <el-form v-if="!isRegister" class="login-form" @submit.prevent="handleLogin">
        <el-form-item>
          <el-input
            v-model="loginForm.username"
            placeholder="用户名"
            size="large"
            prefix-icon="User"
          />
        </el-form-item>
        <el-form-item>
          <el-input
            v-model="loginForm.password"
            type="password"
            placeholder="密码"
            size="large"
            prefix-icon="Lock"
            show-password
            @keyup.enter="handleLogin"
          />
        </el-form-item>
        <el-form-item>
          <el-button
            type="primary"
            size="large"
            :loading="loading"
            class="login-btn"
            native-type="submit"
          >
            登 录
          </el-button>
        </el-form-item>
        <div class="form-footer">
          <el-link type="primary" @click="isRegister = true">没有账号？立即注册</el-link>
        </div>
      </el-form>

      <!-- 注册表单 -->
      <el-form v-else class="login-form" @submit.prevent="handleRegister">
        <el-form-item>
          <el-input
            v-model="registerForm.username"
            placeholder="用户名"
            size="large"
            prefix-icon="User"
          />
        </el-form-item>
        <el-form-item>
          <el-input
            v-model="registerForm.password"
            type="password"
            placeholder="密码"
            size="large"
            prefix-icon="Lock"
            show-password
          />
        </el-form-item>
        <el-divider content-position="left">JIRA 认证信息</el-divider>
        <el-form-item>
          <el-input
            v-model="registerForm.jira_url"
            placeholder="JIRA 地址（默认 http://rdm.zvos.zoomlion.com）"
            size="large"
            prefix-icon="Link"
          />
        </el-form-item>
        <el-form-item>
          <el-input
            v-model="registerForm.jira_user"
            placeholder="JIRA 用户名"
            size="large"
            prefix-icon="User"
          />
        </el-form-item>
        <el-form-item>
          <el-input
            v-model="registerForm.jira_token"
            type="password"
            placeholder="JIRA Token"
            size="large"
            prefix-icon="Key"
            show-password
          />
        </el-form-item>
        <el-form-item>
          <el-button
            type="primary"
            size="large"
            :loading="loading"
            class="login-btn"
            native-type="submit"
          >
            注 册
          </el-button>
        </el-form-item>
        <div class="form-footer">
          <el-link type="primary" @click="isRegister = false">已有账号？立即登录</el-link>
        </div>
      </el-form>
    </div>
  </div>
</template>

<style scoped lang="scss">
.login-container {
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.login-box {
  width: 420px;
  padding: 40px;
  background: #fff;
  border-radius: 20px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);

  .login-header {
    text-align: center;
    margin-bottom: 40px;

    h1 {
      margin: 20px 0 10px;
      font-size: 28px;
      color: #333;
      font-weight: 600;
    }

    p {
      color: #999;
      font-size: 14px;
    }
  }

  .login-form {
    .login-btn {
      width: 100%;
      height: 48px;
      font-size: 16px;
      border-radius: 8px;
    }

    .form-footer {
      text-align: center;
      margin-top: 16px;
    }
  }

  .login-footer {
    text-align: center;
    margin-top: 20px;
    color: #999;
    font-size: 12px;
  }
}
</style>
