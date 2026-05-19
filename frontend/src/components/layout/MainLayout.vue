<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import {
  FolderOpened,
  Timer,
  Monitor,
  DataAnalysis,
  FullScreen,
  Odometer,
} from '@element-plus/icons-vue'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()

const isCollapse = ref(false)
const activeMenu = computed(() => route.path)
const pageTitle = computed(() => route.meta.title as string || '工作台')

const menuItems = [
  { path: '/dashboard', title: '工作台', icon: Odometer },
  { path: '/projects', title: '项目配置', icon: FolderOpened },
  { path: '/jobs', title: '任务调度', icon: Timer },
  { path: '/sonar', title: '代码扫描', icon: Monitor },
  { path: '/reports', title: '质量报表', icon: DataAnalysis },
  { path: '/screen', title: '文档导入', icon: FullScreen },
]

function handleMenuClick(path: string) {
  router.push(path)
}

function handleLogout() {
  authStore.logout()
}

function toggleCollapse() {
  isCollapse.value = !isCollapse.value
}
</script>

<template>
  <el-container class="layout-container">
    <!-- Sidebar -->
    <el-aside :class="['sidebar', { collapsed: isCollapse }]">
      <div class="sidebar-top">
        <div class="logo-mark">
          <svg width="28" height="28" viewBox="0 0 28 28" fill="none">
            <rect width="28" height="28" rx="8" fill="#2D5BFF"/>
            <rect x="7" y="7" width="6" height="6" rx="1.5" fill="white"/>
            <rect x="15" y="7" width="6" height="6" rx="1.5" fill="white" opacity="0.6"/>
            <rect x="7" y="15" width="6" height="6" rx="1.5" fill="white" opacity="0.6"/>
            <rect x="15" y="15" width="6" height="6" rx="1.5" fill="white" opacity="0.3"/>
          </svg>
        </div>
        <transition name="logo-text">
          <span v-if="!isCollapse" class="logo-text">项目工具</span>
        </transition>
      </div>

      <nav class="sidebar-nav">
        <router-link
          v-for="item in menuItems"
          :key="item.path"
          :to="item.path"
          :class="['nav-item', { active: activeMenu === item.path }]"
        >
          <el-icon class="nav-icon"><component :is="item.icon" /></el-icon>
          <transition name="nav-text">
            <span v-if="!isCollapse" class="nav-text">{{ item.title }}</span>
          </transition>
        </router-link>
      </nav>

      <div class="sidebar-footer">
        <button class="collapse-btn" @click="toggleCollapse" :title="isCollapse ? '展开' : '收起'">
          <svg v-if="!isCollapse" width="16" height="16" viewBox="0 0 16 16" fill="none">
            <path d="M10 3L5 8L10 13" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
          <svg v-else width="16" height="16" viewBox="0 0 16 16" fill="none">
            <path d="M6 3L11 8L6 13" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
        </button>
      </div>
    </el-aside>

    <!-- Main -->
    <el-container class="main-container">
      <!-- Header -->
      <el-header class="header">
        <div class="header-left">
          <span class="page-breadcrumb">{{ pageTitle }}</span>
        </div>
        <div class="header-right">
          <el-dropdown @command="handleLogout" trigger="click">
            <button class="user-btn">
              <div class="user-avatar">
                {{ authStore.user?.username?.charAt(0)?.toUpperCase() }}
              </div>
              <span class="user-name">{{ authStore.user?.username }}</span>
              <el-tag v-if="authStore.user?.is_admin" type="warning" size="small">管理员</el-tag>
            </button>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="logout">
                  <svg width="14" height="14" viewBox="0 0 14 14" fill="none" style="margin-right:6px">
                    <path d="M5 2H3a1 1 0 0 0-1 1v8a1 1 0 0 0 1 1h2M9 10l3-3-3-3M12 7H5" stroke="currentColor" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/>
                  </svg>
                  退出登录
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </el-header>

      <!-- Content -->
      <el-main class="main-content">
        <router-view v-slot="{ Component }">
          <transition name="fade" mode="out-in">
            <component :is="Component" />
          </transition>
        </router-view>
      </el-main>
    </el-container>
  </el-container>
</template>

<style scoped lang="scss">
.layout-container {
  height: 100vh;
  display: flex;
}

// ── Sidebar ───────────────────────────────────────────────────
.sidebar {
  width: 220px;
  background: var(--ink-primary);
  display: flex;
  flex-direction: column;
  transition: width 0.3s cubic-bezier(0.22, 1, 0.36, 1);
  overflow: hidden;
  position: relative;
  z-index: 10;

  &.collapsed { width: 72px; }

  &-top {
    height: 64px;
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 0 20px;
    border-bottom: 1px solid rgba(255,255,255,0.06);
    flex-shrink: 0;
  }

  &-nav {
    flex: 1;
    padding: 16px 12px;
    display: flex;
    flex-direction: column;
    gap: 4px;
    overflow-y: auto;
    overflow-x: hidden;
  }

  &-footer {
    padding: 12px;
    border-top: 1px solid rgba(255,255,255,0.06);
    display: flex;
    justify-content: flex-end;
    flex-shrink: 0;
  }
}

.logo-mark {
  flex-shrink: 0;
  display: flex;
  align-items: center;
}

.logo-text {
  font-family: 'Sora', sans-serif;
  font-size: 16px;
  font-weight: 600;
  color: #fff;
  white-space: nowrap;
  letter-spacing: -0.01em;
}

// ── Nav Items ─────────────────────────────────────────────────
.nav-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 0 12px;
  height: 44px;
  border-radius: 10px;
  color: rgba(255,255,255,0.5);
  text-decoration: none;
  transition: all 0.2s ease;
  cursor: pointer;
  white-space: nowrap;
  position: relative;

  &:hover {
    background: rgba(255,255,255,0.06);
    color: rgba(255,255,255,0.85);
  }

  &.active {
    background: rgba(255,255,255,0.10);
    color: #fff;

    &::before {
      content: '';
      position: absolute;
      left: 0;
      top: 50%;
      transform: translateY(-50%);
      width: 3px;
      height: 20px;
      background: #2D5BFF;
      border-radius: 0 3px 3px 0;
    }
  }
}

.nav-icon {
  flex-shrink: 0;
  font-size: 18px;
}

.nav-text {
  font-size: 15px;
  font-weight: 500;
  white-space: nowrap;
}

// ── Collapse Button ───────────────────────────────────────────
.collapse-btn {
  width: 32px;
  height: 32px;
  border-radius: 8px;
  border: none;
  background: rgba(255,255,255,0.06);
  color: rgba(255,255,255,0.5);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s ease;

  &:hover {
    background: rgba(255,255,255,0.12);
    color: #fff;
  }
}

// ── Transitions ───────────────────────────────────────────────
.logo-text-enter-active,
.logo-text-leave-active,
.nav-text-enter-active,
.nav-text-leave-active {
  transition: opacity 0.2s ease, transform 0.2s ease;
}
.logo-text-enter-from,
.logo-text-leave-to,
.nav-text-enter-from,
.nav-text-leave-to {
  opacity: 0;
  transform: translateX(-6px);
}

// ── Header ────────────────────────────────────────────────────
.main-container {
  flex: 1;
  display: flex;
  flex-direction: column;
  min-width: 0;
}

.header {
  height: 64px;
  background: var(--bg-surface);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 24px;
  border-bottom: 1px solid #EDECEA;
  flex-shrink: 0;

  &-left {
    display: flex;
    align-items: center;
  }

  &-right {
    display: flex;
    align-items: center;
    gap: 16px;
  }
}

.page-breadcrumb {
  font-family: 'Sora', sans-serif;
  font-size: 17px;
  font-weight: 600;
  color: var(--ink-primary);
}

.user-btn {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 5px 12px 5px 5px;
  border-radius: 10px;
  border: 1px solid #EDECEA;
  background: transparent;
  cursor: pointer;
  transition: all 0.18s ease;

  &:hover {
    background: var(--bg-muted);
    border-color: #D1D5DB;
  }
}

.user-avatar {
  width: 30px;
  height: 30px;
  border-radius: 8px;
  background: var(--accent);
  color: #fff;
  font-size: 13px;
  font-weight: 600;
  font-family: 'Sora', sans-serif;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.user-name {
  font-size: 14px;
  font-weight: 500;
  color: var(--ink-primary);
}

// ── Main Content ──────────────────────────────────────────────
.main-content {
  background: var(--bg-base);
  padding: 12px;
  overflow-y: auto;
  flex: 1;
}
</style>
