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
const formData = ref<ProjectFormData>({})

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
  formData.value = { ...row }
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
      await projectApi.create(formData.value as ProjectConfig)
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
    <div class="page-header">
      <h2>项目管理</h2>
      <el-button v-if="isAdmin" type="primary" @click="openAddDialog">
        <el-icon><Plus /></el-icon>
        新建项目
      </el-button>
    </div>

    <el-card class="projects-card">
      <el-table :data="projects" v-loading="loading" stripe>
        <el-table-column prop="project_name" label="项目名称" min-width="150" />
        <el-table-column prop="board_name" label="JIRA面板" min-width="120" />
        <el-table-column prop="gitlab_group_key" label="GitLab Group" width="120" />
        <el-table-column label="进度提醒" width="120" align="center">
          <template #default="{ row }">
            <el-tag :type="row.need_story_remind ? 'success' : 'info'" size="small">
              {{ row.need_story_remind ? '已启用' : '未启用' }}
            </el-tag>
            <span v-if="row.need_story_remind && row.story_remind_time" class="remind-time">{{ row.story_remind_time }}</span>
          </template>
        </el-table-column>
        <el-table-column label="任务提醒" width="120" align="center">
          <template #default="{ row }">
            <el-tag :type="row.need_task_remind ? 'success' : 'info'" size="small">
              {{ row.need_task_remind ? '已启用' : '未启用' }}
            </el-tag>
            <span v-if="row.need_task_remind && row.task_remind_time" class="remind-time">{{ row.task_remind_time }}</span>
          </template>
        </el-table-column>
        <el-table-column label="Sonar扫描" width="120" align="center">
          <template #default="{ row }">
            <el-tag :type="row.need_sonar_scan_remind ? 'success' : 'info'" size="small">
              {{ row.need_sonar_scan_remind ? '已启用' : '未启用' }}
            </el-tag>
            <span v-if="row.need_sonar_scan_remind && row.sonar_remind_time" class="remind-time">{{ row.sonar_remind_time }}</span>
          </template>
        </el-table-column>
        <el-table-column label="报表数据" width="120" align="center">
          <template #default="{ row }">
            <el-tag :type="row.need_report_data ? 'success' : 'info'" size="small">
              {{ row.need_report_data ? '已启用' : '未启用' }}
            </el-tag>
            <span v-if="row.need_report_data && row.report_data_time" class="remind-time">{{ row.report_data_time }}</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="150" align="center">
          <template #default="{ row }">
            <el-button v-if="canEditProject(row)" type="primary" link @click="openEditDialog(row)">编辑</el-button>
            <el-button v-if="canDeleteProject(row)" type="danger" link @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
  </el-table>
    </el-card>

    <el-dialog v-model="dialogVisible" :title="isEdit ? '编辑项目' : '新建项目'" width="700px">
      <el-form :model="formData" label-width="130px" class="project-form">
        <div class="form-row">
          <el-form-item label="JIRA面板ID" required class="flex-1">
            <el-input v-model="formData.board_id" :disabled="isEdit" />
          </el-form-item>
          <el-form-item label="JIRA面板名称" required class="flex-1">
            <el-input v-model="formData.board_name" />
          </el-form-item>
        </div>
        <div class="form-row">
          <el-form-item label="JIRA项目ID" required class="flex-1">
            <el-input v-model="formData.project_id" :disabled="isEdit" />
          </el-form-item>
          <el-form-item label="JIRA项目名称" required class="flex-1">
            <el-input v-model="formData.project_name" />
          </el-form-item>
        </div>
        <el-form-item label="GitLab Group Key">
          <el-input v-model="formData.gitlab_group_key" />
        </el-form-item>
        <div class="form-row">
          <el-form-item label="JIRA 用户名" class="flex-1">
            <el-input v-model="formData.jira_user" />
          </el-form-item>
          <el-form-item label="JIRA Token" class="flex-1">
            <el-input v-model="formData.jira_token" type="password" show-password />
          </el-form-item>
        </div>
        <el-form-item label="企微机器人Key">
          <el-input v-model="formData.robot_key" />
        </el-form-item>
        <div class="form-row">
          <el-form-item label="Sonar Key 前缀" class="flex-1">
            <el-input v-model="formData.sonar_key_prefix" />
          </el-form-item>
          <el-form-item label="Sonar默认提醒人" class="flex-1">
            <el-input v-model="formData.sonar_scan_remind_default_person" />
          </el-form-item>
        </div>
        <div class="form-row">
          <el-form-item label="启用进度提醒" class="inline-switch">
            <el-switch v-model="formData.need_story_remind" />
          </el-form-item>
          <el-form-item v-if="formData.need_story_remind" label="提醒时间" class="inline-time">
            <el-input v-model="formData.story_remind_time" placeholder="HH:MM" style="width: 100px;" />
          </el-form-item>
        </div>
        <div class="form-row">
          <el-form-item label="启用任务提醒" class="inline-switch">
            <el-switch v-model="formData.need_task_remind" />
          </el-form-item>
          <el-form-item v-if="formData.need_task_remind" label="提醒时间" class="inline-time">
            <el-input v-model="formData.task_remind_time" placeholder="HH:MM" style="width: 100px;" />
          </el-form-item>
        </div>
        <div class="form-row">
          <el-form-item label="启用Sonar提醒" class="inline-switch">
            <el-switch v-model="formData.need_sonar_scan_remind" />
          </el-form-item>
          <el-form-item v-if="formData.need_sonar_scan_remind" label="提醒时间" class="inline-time">
            <el-input v-model="formData.sonar_remind_time" placeholder="HH:MM" style="width: 100px;" />
          </el-form-item>
        </div>
        <div class="form-row">
          <el-form-item label="启用报表数据" class="inline-switch">
            <el-switch v-model="formData.need_report_data" />
          </el-form-item>
          <el-form-item v-if="formData.need_report_data" label="生成时间" class="inline-time">
            <el-input v-model="formData.report_data_time" placeholder="HH:MM" style="width: 100px;" />
          </el-form-item>
        </div>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSave">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped lang="scss">
.projects-page {
  .page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;

    h2 {
      margin: 0;
      font-size: 20px;
      font-weight: 600;
    }
  }

  .projects-card {
    :deep(.el-table) {
      .el-table__header th {
        background: #f5f7fa;
      }
    }

    .remind-time {
      display: block;
      font-size: 11px;
      color: #909399;
      margin-top: 2px;
    }
  }

  .project-form {
    .form-row {
      display: flex;
      gap: 16px;

      :deep(.el-form-item) {
        margin-bottom: 18px;
        flex: 1;

        &.inline-switch {
          flex: 0 0 auto;
        }

        &.inline-time {
          flex: 0 0 180px;
        }
      }
    }
  }
}
</style>
