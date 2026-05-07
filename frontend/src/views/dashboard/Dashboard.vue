<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { jobApi } from '@/api/jobs'
import { projectApi } from '@/api/projects'
import { useAuthStore } from '@/stores/auth'
import { ElCard, ElEmpty } from 'element-plus'

const authStore = useAuthStore()
const jobs = ref<any[]>([])
const projects = ref<any[]>([])
const loading = ref(false)

onMounted(async () => {
  loading.value = true
  try {
    const [jobsRes, projectsRes] = await Promise.all([
      jobApi.getJobs(),
      projectApi.getList(),
    ])
    jobs.value = jobsRes.jobs
    projects.value = projectsRes
  } finally {
    loading.value = false
  }
})

async function handleTriggerJob(jobId: string) {
  await jobApi.triggerJob(jobId)
}
</script>

<template>
  <div class="dashboard">
    <div class="welcome-card">
      <div class="welcome-content">
        <h2>欢迎回来，{{ authStore.user?.username }}</h2>
        <p>今天是个美好的一天，让我们开始工作吧！</p>
      </div>
    </div>

    <el-row :gutter="20" class="stats-row">
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-icon projects">
            <el-icon :size="32"><FolderOpened /></el-icon>
          </div>
          <div class="stat-info">
            <span class="stat-value">{{ projects.length }}</span>
            <span class="stat-label">项目总数</span>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-icon active">
            <el-icon :size="32"><Bell /></el-icon>
          </div>
          <div class="stat-info">
            <span class="stat-value">{{ projects.filter(p => p.need_story_remind).length }}</span>
            <span class="stat-label">已启用提醒</span>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-icon jobs">
            <el-icon :size="32"><Timer /></el-icon>
          </div>
          <div class="stat-info">
            <span class="stat-value">{{ jobs.length }}</span>
            <span class="stat-label">定时任务</span>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-icon sonar">
            <el-icon :size="32"><Monitor /></el-icon>
          </div>
          <div class="stat-info">
            <span class="stat-value">{{ projects.filter(p => p.need_sonar_scan_remind).length }}</span>
            <span class="stat-label">Sonar扫描</span>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20">
      <el-col :span="12">
        <el-card class="jobs-card">
          <template #header>
            <div class="card-header">
              <span>定时任务</span>
            </div>
          </template>
          <el-table :data="jobs" v-loading="loading">
            <el-table-column prop="name" label="任务名称" />
            <el-table-column prop="next_run_time" label="下次执行时间">
              <template #default="{ row }">
                {{ row.next_run_time ? new Date(row.next_run_time).toLocaleString() : '-' }}
              </template>
            </el-table-column>
            <el-table-column label="操作" width="120">
              <template #default="{ row }">
                <el-button type="primary" link @click="handleTriggerJob(row.id)">
                  立即执行
                </el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>

      <el-col :span="12">
        <el-card class="projects-card">
          <template #header>
            <div class="card-header">
              <span>我的项目</span>
            </div>
          </template>
          <el-table :data="projects.slice(0, 5)" v-loading="loading">
            <el-table-column prop="project_name" label="项目名称" />
            <el-table-column prop="board_name" label="JIRA面板" />
            <el-table-column label="进度提醒" width="100">
              <template #default="{ row }">
                <el-tag :type="row.need_story_remind ? 'success' : 'info'" size="small">
                  {{ row.need_story_remind ? '已启用' : '未启用' }}
                </el-tag>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<style scoped lang="scss">
.dashboard {
  .welcome-card {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border-radius: 16px;
    padding: 30px;
    margin-bottom: 20px;
    color: #fff;

    .welcome-content {
      h2 {
        font-size: 24px;
        margin-bottom: 8px;
      }

      p {
        opacity: 0.8;
      }
    }
  }

  .stats-row {
    margin-bottom: 20px;
  }

  .stat-card {
    :deep(.el-card__body) {
      display: flex;
      align-items: center;
      gap: 20px;
      padding: 20px;
    }

    .stat-icon {
      width: 60px;
      height: 60px;
      border-radius: 12px;
      display: flex;
      align-items: center;
      justify-content: center;
      color: #fff;

      &.projects { background: linear-gradient(135deg, #409eff, #53a8ff); }
      &.active { background: linear-gradient(135deg, #67c23a, #85ce61); }
      &.jobs { background: linear-gradient(135deg, #e6a23c, #ebb563); }
      &.sonar { background: linear-gradient(135deg, #909399, #a6a9ad); }
    }

    .stat-info {
      display: flex;
      flex-direction: column;

      .stat-value {
        font-size: 28px;
        font-weight: 600;
        color: #333;
      }

      .stat-label {
        font-size: 14px;
        color: #999;
      }
    }
  }

  .jobs-card,
  .projects-card {
    .card-header {
      font-weight: 600;
      font-size: 16px;
    }
  }
}
</style>
