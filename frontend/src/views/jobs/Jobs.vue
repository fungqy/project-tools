<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { jobApi, type TaskLogItem } from '@/api/jobs'
import { projectApi, type ProjectConfig } from '@/api/projects'
import { reportsApi, type SprintOption } from '@/api/projects'
import { ElMessage, ElMessageBox } from 'element-plus'

const loading = ref(false)
const logs = ref<TaskLogItem[]>([])
const total = ref(0)
const currentPage = ref(1)
const pageSize = ref(10)

const filterProjectName = ref('')
const filterExecutedDate = ref(new Date().toISOString().slice(0, 10))
const filterTaskType = ref('')

const projects = ref<ProjectConfig[]>([])
const dialogVisible = ref(false)
const dialogTaskType = ref('')
const dialogProjectId = ref<number | null>(null)
const dialogSprintId = ref('')
const sprints = ref<SprintOption[]>([])
const dialogLoading = ref(false)

const taskTypeLabels: Record<string, string> = {
  story_reminder: '进度提醒',
  task_reminder: '任务提醒',
  sonar_reminder: 'Sonar扫描',
  report_data: '报表数据',
}

const taskTypeOptions = [
  { value: '', label: '全部' },
  { value: 'story_reminder', label: '进度提醒' },
  { value: 'task_reminder', label: '任务提醒' },
  { value: 'sonar_reminder', label: 'Sonar扫描' },
  { value: 'report_data', label: '报表数据' },
]

const manualButtons = [
  { type: 'story_reminder', label: '进度提醒', icon: 'notebook' },
  { type: 'task_reminder', label: '任务提醒', icon: 'tasks' },
  { type: 'sonar_reminder', label: '代码扫描', icon: 'monitor' },
  { type: 'report_data', label: '报表数据', icon: 'data-analysis' },
]

const execTypeMap: Record<string, string> = {
  automatic: '自动',
  manual: '手动',
}

onMounted(async () => {
  await Promise.all([loadLogs(), loadProjects()])
})

async function loadLogs() {
  loading.value = true
  try {
    const res = await jobApi.getLogs({
      page: currentPage.value,
      page_size: pageSize.value,
      project_name: filterProjectName.value || undefined,
      executed_date: filterExecutedDate.value || undefined,
      task_type: filterTaskType.value || undefined,
    })
    logs.value = res.items
    total.value = res.total
  } finally {
    loading.value = false
  }
}

async function loadProjects() {
  try {
    projects.value = await projectApi.getList()
  } catch {
    // handled by interceptor
  }
}

async function loadSprints(projectConfigId: number) {
  try {
    sprints.value = await reportsApi.getSprints(projectConfigId)
  } catch {
    sprints.value = []
  }
}

function handleSearch() {
  currentPage.value = 1
  loadLogs()
}

function handleReset() {
  filterProjectName.value = ''
  filterExecutedDate.value = new Date().toISOString().slice(0, 10)
  filterTaskType.value = ''
  currentPage.value = 1
  loadLogs()
}

function openManualDialog(taskType: string) {
  dialogTaskType.value = taskType
  dialogProjectId.value = null
  dialogSprintId.value = ''
  sprints.value = []
  dialogVisible.value = true
}

async function onProjectChange(projectId: number | null) {
  dialogSprintId.value = ''
  sprints.value = []
  if (projectId && dialogTaskType.value === 'report_data') {
    await loadSprints(projectId)
  }
}

async function confirmExecute() {
  if (!dialogProjectId.value) {
    ElMessage.warning('请选择项目')
    return
  }

  if (dialogTaskType.value === 'report_data') {
    if (!dialogSprintId.value) {
      ElMessage.warning('请选择 Sprint')
      return
    }

    try {
      const { exists } = await jobApi.checkReportDataExists(
        dialogProjectId.value,
        dialogSprintId.value
      )
      if (exists) {
        await ElMessageBox.confirm(
          '该 Sprint 的相关表中已有数据，继续执行数据将被覆盖，是否继续？',
          '确认覆盖',
          {
            confirmButtonText: '继续执行',
            cancelButtonText: '取消',
            type: 'warning',
          }
        )
      }
    } catch {
      return
    }
  }

  dialogLoading.value = true
  try {
    switch (dialogTaskType.value) {
      case 'story_reminder':
        await jobApi.manualStoryReminder({ project_config_id: dialogProjectId.value })
        break
      case 'task_reminder':
        await jobApi.manualTaskReminder({ project_config_id: dialogProjectId.value })
        break
      case 'sonar_reminder':
        await jobApi.manualSonarReminder({ project_config_id: dialogProjectId.value })
        break
      case 'report_data':
        await jobApi.manualReportData({
          project_config_id: dialogProjectId.value,
          sprint_id: dialogSprintId.value,
        })
        break
    }
    ElMessage.success('任务执行成功')
    dialogVisible.value = false
    loadLogs()
  } catch {
    // handled by interceptor
  } finally {
    dialogLoading.value = false
  }
}

function formatDateTime(iso: string | null): string {
  if (!iso) return '—'
  const d = new Date(iso)
  return d.toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
    hour12: false,
  })
}

function handlePageChange(page: number) {
  currentPage.value = page
  loadLogs()
}

function handleSizeChange(size: number) {
  pageSize.value = size
  currentPage.value = 1
  loadLogs()
}
</script>

<template>
  <div class="jobs-page">
    <div class="page-header page-enter">
      <div class="page-header-left">
        <h1>任务执行记录</h1>
        <p>查看和手动执行定时任务</p>
      </div>
      <el-button @click="loadLogs" class="refresh-btn" :loading="loading">
        <svg width="14" height="14" viewBox="0 0 14 14" fill="none">
          <path
            d="M12.5 2.5v3.5H9M1.5 11.5v-3.5H5M12.5 6A6 6 0 1 1 7 1.5a6 6 0 0 1 4.5 2"
            stroke="currentColor"
            stroke-width="1.4"
            stroke-linecap="round"
            stroke-linejoin="round"
          />
        </svg>
        刷新
      </el-button>
    </div>

    <div class="filter-bar page-enter" style="animation-delay: 0.04s">
      <div class="filter-row">
        <div class="filter-item">
          <label>项目名称</label>
          <el-input
            v-model="filterProjectName"
            placeholder="输入项目名称搜索"
            clearable
            @keyup.enter="handleSearch"
          />
        </div>
        <div class="filter-item">
          <label>执行日期</label>
          <el-date-picker
            v-model="filterExecutedDate"
            type="date"
            placeholder="选择日期"
            format="YYYY-MM-DD"
            value-format="YYYY-MM-DD"
          />
        </div>
        <div class="filter-item">
          <label>任务类型</label>
          <el-select v-model="filterTaskType" placeholder="全部" clearable>
            <el-option
              v-for="opt in taskTypeOptions"
              :key="opt.value"
              :label="opt.label"
              :value="opt.value"
            />
          </el-select>
        </div>
        <div class="filter-actions">
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </div>
      </div>
    </div>

    <div class="manual-bar page-enter" style="animation-delay: 0.06s">
      <span class="manual-label">手动执行：</span>
      <el-button
        v-for="btn in manualButtons"
        :key="btn.type"
        :icon="btn.icon"
        @click="openManualDialog(btn.type)"
      >
        {{ btn.label }}
      </el-button>
    </div>

    <div class="table-section page-enter" style="animation-delay: 0.08s">
      <el-table :data="logs" v-loading="loading" stripe class="log-table">
        <el-table-column type="index" label="序号" width="80" :index="(idx: number) => (currentPage - 1) * pageSize + idx + 1" />
        <el-table-column prop="project_name" label="项目名称" min-width="140" />
        <el-table-column prop="task_type" label="任务类型" width="110">
          <template #default="{ row }">
            <el-tag size="small" type="info">{{ taskTypeLabels[row.task_type] || row.task_type }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="执行时间" width="180">
          <template #default="{ row }">
            <span class="mono-text">{{ formatDateTime(row.executed_at) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="调度时间" width="180">
          <template #default="{ row }">
            <span class="mono-text">{{ formatDateTime(row.scheduled_time) }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="执行状态" width="90">
          <template #default="{ row }">
            <el-tag :type="row.status === 'success' ? 'success' : 'danger'" size="small">
              {{ row.status === 'success' ? '成功' : '失败' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="error_message" label="错误信息" min-width="200">
          <template #default="{ row }">
            <span class="error-text">{{ row.error_message || '—' }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="task_exec_type" label="执行类型" width="90">
          <template #default="{ row }">
            <el-tag :type="row.task_exec_type === 'manual' ? 'warning' : 'info'" size="small">
              {{ execTypeMap[row.task_exec_type] || row.task_exec_type }}
            </el-tag>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-wrap" v-if="total > 0">
        <el-pagination
          v-model:current-page="currentPage"
          v-model:page-size="pageSize"
          :page-sizes="[10, 20, 50]"
          :total="total"
          layout="total, sizes, prev, pager, next, jumper"
          @current-change="handlePageChange"
          @size-change="handleSizeChange"
        />
      </div>
    </div>

    <el-dialog
      v-model="dialogVisible"
      :title="'手动执行 - ' + taskTypeLabels[dialogTaskType]"
      width="480px"
      :close-on-click-modal="false"
      @closed="dialogTaskType = ''"
    >
      <el-form label-position="top">
        <el-form-item label="选择项目">
          <el-select
            v-model="dialogProjectId"
            placeholder="请选择项目"
            style="width: 100%"
            @change="onProjectChange"
          >
            <el-option
              v-for="p in projects"
              :key="p.id"
              :label="p.project_name"
              :value="p.id"
            />
          </el-select>
        </el-form-item>

        <el-form-item v-if="dialogTaskType === 'report_data'" label="选择 Sprint">
          <el-select
            v-model="dialogSprintId"
            placeholder="请选择 Sprint"
            style="width: 100%"
            :disabled="!dialogProjectId"
          >
            <el-option
              v-for="s in sprints"
              :key="s.sprint_id"
              :label="s.sprint_name"
              :value="String(s.sprint_id)"
            />
          </el-select>
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="confirmExecute" :loading="dialogLoading">
          确认执行
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped lang="scss">
.jobs-page {
  max-width: 100%;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  margin-bottom: 20px;

  &-left {
    h1 {
      font-size: 22px;
      font-weight: 700;
      color: var(--ink-primary);
      margin-bottom: 4px;
      letter-spacing: -0.02em;
    }

    p {
      font-size: 13px;
      color: var(--ink-tertiary);
    }
  }
}

.refresh-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  border-radius: var(--radius-sm);
}

.filter-bar {
  background: var(--bg-surface);
  border-radius: var(--radius-md);
  padding: 16px 18px;
  margin-bottom: 16px;
  box-shadow: var(--shadow-xs);
}

.filter-row {
  display: flex;
  align-items: flex-end;
  gap: 16px;
  flex-wrap: wrap;
}

.filter-item {
  display: flex;
  flex-direction: column;
  gap: 6px;

  label {
    font-size: 13px;
    font-weight: 600;
    color: var(--ink-secondary);
  }

  .el-input,
  .el-select,
  .el-date-editor {
    width: 180px;
  }
}

.filter-actions {
  display: flex;
  gap: 8px;
  padding-bottom: 1px;
}

.manual-bar {
  display: flex;
  align-items: center;
  gap: 10px;
  background: var(--bg-surface);
  border-radius: var(--radius-md);
  padding: 14px 18px;
  margin-bottom: 16px;
  box-shadow: var(--shadow-xs);
}

.manual-label {
  font-size: 14px;
  font-weight: 600;
  color: var(--ink-secondary);
  white-space: nowrap;
}

.table-section {
  background: var(--bg-surface);
  border-radius: var(--radius-md);
  padding: 4px;
  box-shadow: var(--shadow-xs);
}

.log-table {
  border-radius: var(--radius-md);
}

.mono-text {
  font-family: 'SF Mono', 'Fira Code', monospace;
  font-size: 13px;
  color: var(--ink-secondary);
}

.error-text {
  font-size: 13px;
  color: var(--el-color-danger);
  word-break: break-all;
}

.pagination-wrap {
  display: flex;
  justify-content: flex-end;
  padding: 16px 12px 8px;
}
</style>