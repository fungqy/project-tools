<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { projectApi, type ProjectConfig, type ProjectFormData } from '@/api/projects'
import { useAuthStore } from '@/stores/auth'
import { ElMessage, ElMessageBox } from 'element-plus'

const authStore = useAuthStore()
const projects = ref<ProjectConfig[]>([])
const loading = ref(false)
const dialogVisible = ref(false)
const isEdit = ref(false)
const formData = ref<ProjectFormData>({
  board_id: '',
  board_name: '',
  project_id: '',
  project_name: '',
  gitlab_group_key: '',
  need_story_remind: false,
  need_task_remind: false,
  need_sonar_scan_remind: false,
  need_report_data: false,
  story_remind_time: '',
  task_remind_time: '',
  sonar_remind_time: '',
  report_data_time: '',
  sonar_key_prefix: '',
  sonar_scan_remind_default_person: '',
  robot_key: '',
  jira_user: '',
  jira_token: ''
})

const isAdmin = computed(() => authStore.user?.is_admin)
const currentUserId = computed(() => authStore.user?.id)

function canEditProject(row: ProjectConfig) {
  return isAdmin.value || row.created_by === currentUserId.value
}

function canDeleteProject(row: ProjectConfig) {
  return isAdmin.value || row.created_by === currentUserId.value
}

onMounted(() => {
  loadProjects()
})

async function loadProjects() {
  loading.value = true
  try {
    projects.value = await projectApi.getList()
  } finally {
    loading.value = false
  }
}

function openAddDialog() {
  isEdit.value = false
  formData.value = {
    board_id: '',
    board_name: '',
    project_id: '',
    project_name: '',
    gitlab_group_key: '',
    need_story_remind: false,
    need_task_remind: false,
    need_sonar_scan_remind: false,
    need_report_data: false,
    story_remind_time: '',
    task_remind_time: '',
    sonar_remind_time: '',
    report_data_time: '',
    sonar_key_prefix: '',
    sonar_scan_remind_default_person: '',
    robot_key: '',
    jira_user: '',
    jira_token: '',
  }
  dialogVisible.value = true
}

function openEditDialog(row: ProjectConfig) {
  isEdit.value = true
  formData.value = {
    id: row.id,
    board_id: row.board_id,
    board_name: row.board_name,
    project_id: row.project_id,
    project_name: row.project_name,
    gitlab_group_key: row.gitlab_group_key,
    sonar_key_prefix: row.sonar_key_prefix,
    sonar_scan_remind_default_person: row.sonar_scan_remind_default_person,
    robot_key: row.robot_key,
    jira_user: row.jira_user,
    jira_token: row.jira_token ?? '',
    need_story_remind: row.need_story_remind,
    need_task_remind: row.need_task_remind,
    need_sonar_scan_remind: row.need_sonar_scan_remind,
    need_report_data: row.need_report_data,
    story_remind_time: row.reminder_settings?.story_remind_time ?? '',
    task_remind_time: row.reminder_settings?.task_remind_time ?? '',
    sonar_remind_time: row.reminder_settings?.sonar_remind_time ?? '',
    report_data_time: row.reminder_settings?.report_data_time ?? '',
  }
  dialogVisible.value = true
}

async function handleSave() {
  if (!formData.value.board_id || !formData.value.project_id) {
    ElMessage.warning('请填写必填项')
    return
  }

  try {
    if (isEdit.value) {
      await projectApi.update(formData.value.id!, formData.value)
      ElMessage.success('更新成功')
    } else {
      await projectApi.create(formData.value)
      ElMessage.success('创建成功')
    }
    dialogVisible.value = false
    loadProjects()
  } catch (error) {
    // error already handled by interceptor
  }
}

async function handleDelete(row: ProjectConfig) {
  try {
    await ElMessageBox.confirm('确定要删除该项目吗？', '提示', {
      type: 'warning',
    })
    await projectApi.delete(row.id!)
    ElMessage.success('删除成功')
    loadProjects()
  } catch {
    // cancelled
  }
}
</script>

<template>
  <div class="projects-page">
    <!-- Page header -->
    <div class="page-header page-enter">
      <div class="page-header-left">
        <p></p>
      </div>
      <el-button v-if="isAdmin" type="primary" class="add-btn" @click="openAddDialog">
        <svg width="14" height="14" viewBox="0 0 14 14" fill="none">
          <path d="M7 2v10M2 7h10" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
        </svg>
        新建项目
      </el-button>
    </div>

    <!-- Projects table card -->
    <div class="projects-card page-enter" style="animation-delay: 0.06s">
      <el-table :data="projects" v-loading="loading" stripe class="projects-table">
        <el-table-column prop="project_name" label="项目名称" min-width="150" />
        <el-table-column prop="board_name" label="JIRA 面板" min-width="120" />
        <el-table-column prop="gitlab_group_key" label="GitLab Group" width="130" />
        <el-table-column label="进度提醒" width="120" align="center">
          <template #default="{ row }">
            <span v-if="row.need_story_remind" class="reminder-on">
              {{ row.story_remind_time }}
            </span>
            <span v-else class="reminder-off">未启用</span>
          </template>
        </el-table-column>
        <el-table-column label="任务提醒" width="120" align="center">
          <template #default="{ row }">
            <span v-if="row.need_task_remind" class="reminder-on">
              {{ row.task_remind_time }}
            </span>
            <span v-else class="reminder-off">未启用</span>
          </template>
        </el-table-column>
        <el-table-column label="SONAR检查" width="120" align="center">
          <template #default="{ row }">
            <span v-if="row.need_sonar_scan_remind" class="reminder-on">
              {{ row.sonar_remind_time }}
            </span>
            <span v-else class="reminder-off">未启用</span>
          </template>
        </el-table-column>
        <el-table-column label="报表数据" width="120" align="center">
          <template #default="{ row }">
            <span v-if="row.need_report_data" class="reminder-on">
              {{ row.report_data_time }}
            </span>
            <span v-else class="reminder-off">未启用</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="140" align="center">
          <template #default="{ row }">
            <el-button v-if="canEditProject(row)" type="primary" link @click="openEditDialog(row)">编辑</el-button>
            <el-button v-if="canDeleteProject(row)" type="danger" link @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </div>

    <!-- Dialog -->
    <el-dialog v-model="dialogVisible" :title="isEdit ? '编辑项目' : '新建项目'" width="640px" class="project-dialog">
      <el-form :model="formData" label-width="108px" class="project-form">
        <!-- RDM Section -->
        <div class="form-section">
          <div class="section-title">RDM 配置</div>
          <div class="form-grid">
            <el-form-item label="面板 ID" required>
              <el-input v-model="formData.board_id" :disabled="isEdit" />
            </el-form-item>
            <el-form-item label="面板名称" required>
              <el-input v-model="formData.board_name" />
            </el-form-item>
            <el-form-item label="项目 ID" required>
              <el-input v-model="formData.project_id" :disabled="isEdit" />
            </el-form-item>
            <el-form-item label="项目名称" required>
              <el-input v-model="formData.project_name" />
            </el-form-item>
            <el-form-item label="JIRA 用户">
              <el-input v-model="formData.jira_user" />
            </el-form-item>
            <el-form-item label="JIRA 密码">
              <el-input v-model="formData.jira_token" type="password" show-password />
            </el-form-item>
          </div>
        </div>

        <!-- GitLab Section -->
        <div class="form-section">
          <div class="section-title">GitLab 配置</div>
          <div class="form-grid">
            <el-form-item label="Group Key" class="full-width">
              <el-input v-model="formData.gitlab_group_key" />
            </el-form-item>
          </div>
        </div>

        <!-- Sonar Section -->
        <div class="form-section">
          <div class="section-title">SONAR 配置</div>
          <div class="form-grid">
            <el-form-item label="项目 Key 前缀">
              <el-input v-model="formData.sonar_key_prefix" />
            </el-form-item>
            <el-form-item label="默认提醒人">
              <el-input v-model="formData.sonar_scan_remind_default_person" />
            </el-form-item>
          </div>
        </div>

        <!-- Reminder Section -->
        <div class="form-section">
          <div class="section-title">定时任务提醒</div>
          <el-form-item label="企微机器人 Key" class="full-width">
            <el-input v-model="formData.robot_key" />
          </el-form-item>
          <div class="reminder-cards">
            <div class="reminder-card">
              <div class="reminder-card-header">
                <el-switch v-model="formData.need_story_remind" />
                <span>进度提醒</span>
              </div>
              <el-time-select v-if="formData.need_story_remind" v-model="formData.story_remind_time" :step="'00:10'" :start="'00:00'" :end="'23:50'" style="width: 100%" />
            </div>
            <div class="reminder-card">
              <div class="reminder-card-header">
                <el-switch v-model="formData.need_task_remind" />
                <span>任务提醒</span>
              </div>
              <el-time-select v-if="formData.need_task_remind" v-model="formData.task_remind_time" :step="'00:10'" :start="'00:00'" :end="'23:50'" style="width: 100%" />
            </div>
            <div class="reminder-card">
              <div class="reminder-card-header">
                <el-switch v-model="formData.need_sonar_scan_remind" />
                <span>扫描提醒</span>
              </div>
              <el-time-select v-if="formData.need_sonar_scan_remind" v-model="formData.sonar_remind_time" :step="'00:10'" :start="'00:00'" :end="'23:50'" style="width: 100%" />
            </div>
            <div class="reminder-card">
              <div class="reminder-card-header">
                <el-switch v-model="formData.need_report_data" />
                <span>报表生成</span>
              </div>
              <el-time-select v-if="formData.need_report_data" v-model="formData.report_data_time" :step="'00:10'" :start="'00:00'" :end="'23:50'" style="width: 100%" />
            </div>
          </div>
        </div>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false" class="cancel-btn">取消</el-button>
        <el-button type="primary" @click="handleSave" class="save-btn">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped lang="scss">
.projects-page {
  max-width: 100%;
}

// ── Page Header ──────────────────────────────────────────────
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  margin-bottom: 24px;

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

.add-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  font-weight: 600;
}

// ── Projects Card ─────────────────────────────────────────────
.projects-card {
  background: var(--bg-surface);
  border-radius: var(--radius-lg);
  padding: 20px;
  box-shadow: var(--shadow-xs);
}

.projects-table {
  :deep(.el-table__header th) {
    background: var(--bg-muted);
    font-weight: 600;
    font-size: 13px;
    color: var(--ink-secondary);
    text-transform: uppercase;
    letter-spacing: 0.05em;
    padding: 10px 12px;
  }

  :deep(.el-table__row td) {
    padding: 10px 12px;
    font-size: 14px;
    color: var(--ink-primary);
  }

  :deep(.el-table__row:hover td) {
    background: var(--bg-base) !important;
  }
}

.reminder-on {
  font-size: 13px;
  color: var(--accent);
  font-weight: 600;
  font-variant-numeric: tabular-nums;
}

.reminder-off {
  font-size: 13px;
  color: var(--ink-tertiary);
}

// ── Dialog Form ────────────────────────────────────────────────
.project-form {
  :deep(.el-form-item) {
    margin-bottom: 12px;
  }
}

.form-section {
  margin-bottom: 14px;
  padding: 14px;
  background: var(--bg-muted);
  border-radius: var(--radius-md);

  .section-title {
    font-family: 'Sora', sans-serif;
    font-size: 14px;
    font-weight: 600;
    color: var(--ink-primary);
    margin-bottom: 12px;
    padding-bottom: 8px;
    border-bottom: 1px solid #D1D5DB;
  }
}

.form-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px 16px;

  .el-form-item {
    margin-bottom: 0;

    :deep(.el-form-item__label) {
      width: 108px;
      font-weight: 500;
      font-size: 14px;
    }
  }

  .full-width {
    grid-column: 1 / -1;
  }
}

.reminder-cards {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
  margin-top: 12px;
}

.reminder-card {
  background: var(--bg-surface);
  border-radius: var(--radius-sm);
  padding: 12px;
  border: 1px solid #E5E7EB;
  display: flex;
  flex-direction: column;
  gap: 8px;

  &-header {
    display: flex;
    align-items: center;
    gap: 10px;

    span {
      font-size: 14px;
      font-weight: 600;
      color: var(--ink-primary);
    }
  }
}

.cancel-btn {
  border-radius: var(--radius-sm);
}

.save-btn {
  border-radius: var(--radius-sm);
  font-weight: 600;
}

:global(.project-dialog) {
  .el-dialog__body {
    padding: 20px 24px;
    max-height: 58vh;
    overflow-y: auto;
  }
}
</style>
