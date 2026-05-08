<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import MainLayout from '@/components/layout/MainLayout.vue'
import { useAuthStore } from '@/stores/auth'

const route = useRoute()
const authStore = useAuthStore()
const showLayout = computed(() => authStore.token && route.path !== '/login')
</script>

<template>
  <MainLayout v-if="showLayout" />
  <router-view v-else />
</template>

<style>
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
  background: #F7F6F3;
}

.loading-spinner {
  width: 32px;
  height: 32px;
  border: 2.5px solid #E5E7EB;
  border-top-color: #2D5BFF;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}
</style>
