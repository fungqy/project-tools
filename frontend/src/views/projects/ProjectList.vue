<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { projectApi, type ProjectConfig } from '@/api/projects'
import { useAuthStore } from '@/stores/auth'
import { ElMessage, ElMessageBox } from 'element-plus'

const authStore = useAuthStore()
const projects = ref<ProjectConfig[]>([])
const loading = ref(false)
const dialogVisible = ref(false)
const isEdit = ref(false)
const formData = ref<Partial<ProjectConfig>>({})

const isAdmin = computed(() => authStore.user?.is_admin)

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
    need_progress_remind: false,
    need_sonar_scan_remind: false,
    need_report_data: false,
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
        <el-table-column label="进度提醒" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="row.need_progress_remind ? 'success' : 'info'" size="small">
              {{ row.need_progress_remind ? '已启用' : '未启用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="Sonar扫描" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="row.need_sonar_scan_remind ? 'success' : 'info'" size="small">
              {{ row.need_sonar_scan_remind ? '已启用' : '未启用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="报表数据" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="row.need_report_data ? 'success' : 'info'" size="small">
              {{ row.need_report_data ? '已启用' : '未启用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="150" align="center" v-if="isAdmin">
          <template #default="{ row }">
            <el-button type="primary" link @click="openEditDialog(row)">编辑</el-button>
            <el-button type="danger" link @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="dialogVisible" :title="isEdit ? '编辑项目' : '新建项目'" width="600px">
      <el-form :model="formData" label-width="140px">
        <el-form-item label="JIRA Board ID" required>
          <el-input v-model="formData.board_id" :disabled="isEdit" />
        </el-form-item>
        <el-form-item label="JIRA面板名称" required>
          <el-input v-model="formData.board_name" />
        </el-form-item>
        <el-form-item label="JIRA Project ID" required>
          <el-input v-model="formData.project_id" :disabled="isEdit" />
        </el-form-item>
        <el-form-item label="JIRA项目名称" required>
          <el-input v-model="formData.project_name" />
        </el-form-item>
        <el-form-item label="GitLab Group Key">
          <el-input v-model="formData.gitlab_group_key" />
        </el-form-item>
        <el-form-item label="JIRA 用户名">
          <el-input v-model="formData.jira_user" />
        </el-form-item>
        <el-form-item label="JIRA Token">
          <el-input v-model="formData.jira_token" type="password" show-password />
        </el-form-item>
        <el-form-item label="企业微信机器人Key">
          <el-input v-model="formData.robot_key" />
        </el-form-item>
        <el-form-item label="Sonar Key 前缀">
          <el-input v-model="formData.sonar_key_prefix" />
        </el-form-item>
        <el-form-item label="Sonar默认提醒人">
          <el-input v-model="formData.sonar_scan_remind_default_person" />
        </el-form-item>
        <el-form-item label="启用进度提醒">
          <el-switch v-model="formData.need_progress_remind" />
        </el-form-item>
        <el-form-item label="启用Sonar扫描提醒">
          <el-switch v-model="formData.need_sonar_scan_remind" />
        </el-form-item>
        <el-form-item label="启用报表数据">
          <el-switch v-model="formData.need_report_data" />
        </el-form-item>
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
  }
}
</style>
