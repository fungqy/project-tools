<script setup lang="ts">
import { ref, watch } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { UploadFilled } from '@element-plus/icons-vue'
import { dataImportApi, type DocBugRecord } from '@/api/dataImport'
import { reportsApi, type ProjectOption } from '@/api/reports'

const props = defineProps<{
  visible: boolean
}>()

const emit = defineEmits<{
  (e: 'close'): void
}>()

const currentStep = ref(1)

const projects = ref<ProjectOption[]>([])
const selectedProjectId = ref<number | null>(null)
const selectedJiraProjectId = ref<string>('')
const loadingProjects = ref(false)

const sprints = ref<{ sprint_id: number; sprint_name: string }[]>([])
const selectedSprintId = ref<string>('')
const selectedSprintName = ref<string>('')
const loadingSprints = ref(false)

const existingData = ref<DocBugRecord[]>([])
const existingTotal = ref(0)
const currentPage = ref(1)
const pageSize = ref(20)
const loadingData = ref(false)

const uploading = ref(false)
const uploadFile = ref<File | null>(null)
const importResult = ref<{ success: boolean; imported?: number; total_count?: number; errors?: string[] } | null>(null)

async function loadProjects() {
  loadingProjects.value = true
  try {
    projects.value = await reportsApi.getProjects()
  } finally {
    loadingProjects.value = false
  }
}

async function onProjectChange(projectId: number) {
  selectedSprintId.value = ''
  selectedSprintName.value = ''
  sprints.value = []
  existingData.value = []
  existingTotal.value = 0
  currentPage.value = 1
  importResult.value = null
  uploadFile.value = null

  const project = projects.value.find(p => p.id === projectId)
  selectedJiraProjectId.value = project?.project_id || ''

  loadingSprints.value = true
  try {
    sprints.value = await dataImportApi.getClosedSprints(projectId)
  } finally {
    loadingSprints.value = false
  }
}

async function onSprintChange(sprintId: string) {
  const sprint = sprints.value.find(s => String(s.sprint_id) === sprintId)
  selectedSprintName.value = sprint?.sprint_name || ''
  existingData.value = []
  existingTotal.value = 0
  currentPage.value = 1
  importResult.value = null
  uploadFile.value = null

  await loadExistingData()
}

async function loadExistingData() {
  if (!selectedJiraProjectId.value || !selectedSprintId.value) return

  loadingData.value = true
  try {
    const res = await dataImportApi.getDocBugs(
      selectedJiraProjectId.value,
      selectedSprintId.value,
      currentPage.value,
      pageSize.value
    )
    existingData.value = res.items
    existingTotal.value = res.total
  } finally {
    loadingData.value = false
  }
}

async function onPageChange(page: number) {
  currentPage.value = page
  await loadExistingData()
}

async function handleReimport() {
  try {
    await ElMessageBox.confirm(
      `将清空该项目和 Sprint 下已有的 ${existingTotal.value} 条数据并重新导入，是否继续？`,
      '确认重新导入',
      { confirmButtonText: '确认', cancelButtonText: '取消', type: 'warning' }
    )
    await dataImportApi.clearDocBugs(selectedJiraProjectId.value, selectedSprintId.value)
    existingData.value = []
    existingTotal.value = 0
    currentPage.value = 1
    uploadFile.value = null
    importResult.value = null
    currentStep.value = 3
  } catch {
    // user cancelled
  }
}

function handleNewImport() {
  uploadFile.value = null
  importResult.value = null
  currentStep.value = 3
}

function handleFileChange(file: File) {
  uploadFile.value = file
  importResult.value = null
}

async function handleUpload() {
  if (!uploadFile.value) {
    ElMessage.warning('请先选择文件')
    return
  }

  uploading.value = true
  try {
    const res = await dataImportApi.uploadDocBugs(
      selectedJiraProjectId.value,
      selectedSprintId.value,
      uploadFile.value
    )
    importResult.value = res

    if (res.success) {
      ElMessage.success(`成功导入 ${res.imported} 条数据`)
      currentPage.value = 1
      await loadExistingData()
      currentStep.value = 4
    } else {
      ElMessage.warning(`数据校验未通过，共 ${res.errors?.length || 0} 个错误`)
    }
  } finally {
    uploading.value = false
  }
}

function handleReset() {
  currentStep.value = 1
  selectedProjectId.value = null
  selectedJiraProjectId.value = ''
  selectedSprintId.value = ''
  selectedSprintName.value = ''
  sprints.value = []
  existingData.value = []
  existingTotal.value = 0
  currentPage.value = 1
  uploadFile.value = null
  importResult.value = null
}

function handleClose() {
  handleReset()
  emit('close')
}

function formatTime(val: string | null) {
  if (!val) return '-'
  return val.replace('T', ' ').substring(0, 19)
}

watch(() => props.visible, (val) => {
  if (val) {
    loadProjects()
  }
})
</script>

<template>
  <el-dialog
    :model-value="visible"
    title="文档故障导入"
    width="900px"
    :close-on-click-modal="false"
    @close="handleClose"
  >
    <div class="import-workflow">
      <el-steps :active="currentStep" finish-status="success" align-center>
        <el-step title="选择项目" />
        <el-step title="选择 Sprint" />
        <el-step title="上传文件" />
        <el-step title="完成导入" />
      </el-steps>

      <div class="step-content">
        <div v-if="currentStep === 1" class="step-panel">
          <el-form label-position="top">
            <el-form-item label="选择项目">
              <el-select
                v-model="selectedProjectId"
                placeholder="请选择项目"
                :loading="loadingProjects"
                style="width: 400px"
                @change="onProjectChange"
              >
                <el-option
                  v-for="project in projects"
                  :key="project.id"
                  :label="`${project.project_name}`"
                  :value="project.id"
                />
              </el-select>
            </el-form-item>
          </el-form>
          <div class="step-actions">
            <el-button type="primary" :disabled="!selectedProjectId" @click="currentStep = 2">
              下一步
            </el-button>
          </div>
        </div>

        <div v-if="currentStep === 2" class="step-panel">
          <el-form label-position="top">
            <el-form-item label="选择 Sprint">
              <el-select
                v-model="selectedSprintId"
                placeholder="请选择 Sprint"
                :loading="loadingSprints"
                style="width: 400px"
                @change="onSprintChange"
              >
                <el-option
                  v-for="sprint in sprints"
                  :key="sprint.sprint_id"
                  :label="sprint.sprint_name"
                  :value="String(sprint.sprint_id)"
                />
              </el-select>
            </el-form-item>
          </el-form>

          <div v-if="existingTotal > 0" class="existing-section">
            <el-alert
              :title="`该项目和 Sprint 下已有 ${existingTotal} 条数据`"
              type="info"
              :closable="false"
              show-icon
            />
            <el-table :data="existingData" border stripe max-height="300" v-loading="loadingData">
              <el-table-column prop="key" label="编码" width="120" />
              <el-table-column prop="name" label="名称" min-width="200" show-overflow-tooltip />
              <el-table-column prop="priority" label="优先级" width="100" />
              <el-table-column prop="maker" label="产生人" width="100" />
              <el-table-column prop="status" label="状态" width="100" />
              <el-table-column label="提出时间" width="160">
                <template #default="{ row }">
                  {{ formatTime(row.propose_time) }}
                </template>
              </el-table-column>
            </el-table>
            <div class="pagination-wrap">
              <el-pagination
                :current-page="currentPage"
                :page-size="pageSize"
                :total="existingTotal"
                layout="total, prev, pager, next"
                @current-change="onPageChange"
              />
            </div>
            <div class="import-actions">
              <el-button type="warning" @click="handleReimport">重新导入</el-button>
              <el-button type="primary" @click="handleNewImport">直接新增导入</el-button>
            </div>
          </div>

          <div v-else-if="selectedSprintId && !loadingData" class="no-data-section">
            <el-empty description="该项目和 Sprint 下暂无数据">
              <el-button type="primary" @click="handleNewImport">开始导入</el-button>
            </el-empty>
          </div>

          <div class="step-actions">
            <el-button @click="currentStep = 1">上一步</el-button>
          </div>
        </div>

        <div v-if="currentStep === 3" class="step-panel">
          <el-alert
            type="info"
            :closable="false"
            show-icon
            style="margin-bottom: 16px"
          >
            <template #title>
              上传 Excel 文件 (.xlsx / .xls)，表头需包含：问题编号、功能点、问题详述、优先级、原因分析、处理意见、处理方式、处理人、提出人、提出时间、完成时间、处理状态、问题类型
            </template>
          </el-alert>

          <el-upload
            drag
            :auto-upload="false"
            :limit="1"
            accept=".xlsx,.xls"
            :on-change="(file: any) => handleFileChange(file.raw)"
            :on-remove="() => { uploadFile = null; importResult = null }"
          >
            <el-icon class="el-icon--upload"><UploadFilled /></el-icon>
            <div class="el-upload__text">将 Excel 文件拖到此处，或<em>点击上传</em></div>
          </el-upload>

          <div v-if="importResult && !importResult.success" class="import-errors">
            <el-alert
              title="数据校验失败"
              type="error"
              :closable="false"
              show-icon
            />
            <div class="error-list">
              <div v-for="(err, idx) in importResult.errors" :key="idx" class="error-item">
                {{ err }}
              </div>
            </div>
          </div>

          <div class="step-actions">
            <el-button @click="currentStep = 2">上一步</el-button>
            <el-button
              type="primary"
              :loading="uploading"
              :disabled="!uploadFile"
              @click="handleUpload"
            >
              开始导入
            </el-button>
          </div>
        </div>

        <div v-if="currentStep === 4" class="step-panel">
          <el-result
            icon="success"
            :title="`成功导入 ${importResult?.imported || 0} 条数据`"
            sub-title="数据已保存到数据库"
          >
            <template #extra>
              <el-button type="primary" @click="handleReset">导入新的数据</el-button>
              <el-button @click="handleClose">关闭</el-button>
            </template>
          </el-result>
        </div>
      </div>
    </div>
  </el-dialog>
</template>

<style scoped lang="scss">
.import-workflow {
  .step-content {
    margin-top: 32px;
    min-height: 300px;
  }

  .step-panel {
    max-width: 100%;
  }

  .step-actions {
    margin-top: 24px;
    display: flex;
    gap: 12px;
    justify-content: center;
  }
}

.existing-section {
  margin-top: 16px;

  .el-table {
    margin-top: 12px;
  }

  .pagination-wrap {
    margin-top: 12px;
    display: flex;
    justify-content: flex-end;
  }

  .import-actions {
    margin-top: 16px;
    display: flex;
    gap: 12px;
    justify-content: center;
  }
}

.no-data-section {
  margin-top: 24px;
}

.import-errors {
  margin-top: 16px;

  .error-list {
    margin-top: 12px;
    max-height: 200px;
    overflow-y: auto;
    border: 1px solid var(--el-border-color-light);
    border-radius: 4px;
    padding: 8px 12px;
  }

  .error-item {
    padding: 4px 0;
    font-size: 13px;
    color: var(--el-color-danger);
    border-bottom: 1px solid var(--el-border-color-lighter);

    &:last-child {
      border-bottom: none;
    }
  }
}
</style>