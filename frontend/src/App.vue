<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import MainLayout from '@/components/layout/MainLayout.vue'

const route = useRoute()

// 直接从 localStorage 检查 token
const hasToken = localStorage.getItem('token') !== null

// 如果没有 token 且不在登录页，不显示布局（防止闪屏）
const showLayout = computed(() => hasToken && route.path !== '/login')
</script>

<template>
  <MainLayout v-if="showLayout" />
  <router-view v-else />
</template>

<style>
/* 全局样式，防止登录页滚动 */
html, body {
  margin: 0;
  padding: 0;
  height: 100%;
  overflow: hidden;
}

#app {
  height: 100%;
}

.app-loading {
  height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.loading-spinner {
  width: 40px;
  height: 40px;
  border: 3px solid rgba(255, 255, 255, 0.3);
  border-top-color: #fff;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}
</style>
