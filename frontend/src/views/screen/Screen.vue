<script setup lang="ts">
import { ref } from 'vue'
import { ArrowRight, DocumentAdd } from '@element-plus/icons-vue'
import DocBugImport from './DocBugImport.vue'

const showDocBugImport = ref(false)
</script>

<template>
  <div class="data-import-page">
    <div class="module-grid">
      <div class="module-card" @click="showDocBugImport = true">
        <div class="module-icon">
          <el-icon :size="60"><DocumentAdd /></el-icon>
        </div>
        <div class="module-info">
          <h3>文档故障导入</h3>
          <p>从 Excel 导入文档中记录的故障数据，支持校验规则和已有数据管理</p>
        </div>
        <div class="module-arrow">
          <el-icon><ArrowRight /></el-icon>
        </div>
      </div>
    </div>

    <DocBugImport
      :visible="showDocBugImport"
      @close="showDocBugImport = false"
    />
  </div>
</template>

<style scoped lang="scss">
.data-import-page {
  max-width: 960px;
  margin: 0 auto;
}

.page-header {
  margin-bottom: 32px;

  h2 {
    font-size: 22px;
    font-weight: 600;
    color: var(--ink-primary);
    margin: 0 0 8px;
  }

  .page-desc {
    font-size: 14px;
    color: var(--ink-secondary);
    margin: 0;
  }
}

.module-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(360px, 1fr));
  gap: 16px;
}

.module-card {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 20px;
  background: var(--bg-card);
  border: 1px solid var(--border-color);
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.2s ease;

  &:hover {
    border-color: var(--el-color-primary);
    box-shadow: 0 2px 12px rgba(45, 91, 255, 0.08);
    transform: translateY(-1px);
  }
}

.module-icon {
  width: 56px;
  height: 56px;
  border-radius: 12px;
  background: linear-gradient(135deg, rgba(45, 91, 255, 0.1), rgba(45, 91, 255, 0.05));
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--el-color-primary);
  flex-shrink: 0;
}

.module-info {
  flex: 1;
  min-width: 0;

  h3 {
    font-size: 20px;
    font-weight: 600;
    color: var(--ink-primary);
    margin: 0 0 4px;
  }

  p {
    font-size: 15px;
    color: var(--ink-tertiary);
    margin: 0;
    line-height: 1.5;
  }
}

.module-arrow {
  color: var(--ink-quaternary);
  flex-shrink: 0;
}
</style>