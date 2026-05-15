<script setup lang="ts">
import { ElResult, ElButton } from 'element-plus'
</script>

<template>
  <div class="page-placeholder">
    <el-result
      title="SONAR 检查模块"
      sub-title="该模块正在规划中，敬请期待..."
    >
      <template #extra>
        <el-button type="primary">功能规划中</el-button>
      </template>
    </el-result>
  </div>
</template>

<style scoped lang="scss">
.page-placeholder {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100%;
  min-height: 400px;
}
</style>
