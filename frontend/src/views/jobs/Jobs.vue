<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { jobApi, type JobInfo } from '@/api/jobs'
import { ElMessage } from 'element-plus'

const jobs = ref<JobInfo[]>([])
const loading = ref(false)

onMounted(() => {
  loadJobs()
})

async function loadJobs() {
  loading.value = true
  try {
    const res = await jobApi.getJobs()
    jobs.value = res.jobs
  } finally {
    loading.value = false
  }
}

async function handleTrigger(jobId: string) {
  await jobApi.triggerJob(jobId)
  ElMessage.success('任务已触发')
}
</script>

<template>
  <div class="jobs-page">
    <div class="page-header">
      <h2>任务调度</h2>
      <el-button @click="loadJobs">
        <el-icon><Refresh /></el-icon>
        刷新状态
      </el-button>
    </div>

    <el-row :gutter="20">
      <el-col :span="12" v-for="job in jobs" :key="job.id">
        <el-card class="job-card">
          <div class="job-header">
            <el-icon :size="24" class="job-icon">
              <Timer v-if="job.id === 'story_reminder'" />
              <Bell v-else />
            </el-icon>
            <div class="job-info">
              <h3>{{ job.name }}</h3>
              <p class="job-id">ID: {{ job.id }}</p>
            </div>
          </div>
          <div class="job-body">
            <div class="job-next">
              <span class="label">下次执行时间</span>
              <span class="value">
                {{ job.next_run_time ? new Date(job.next_run_time).toLocaleString() : '未设置' }}
              </span>
            </div>
            <div class="job-trigger">
              <span class="label">触发规则</span>
              <span class="value">{{ job.trigger }}</span>
            </div>
          </div>
          <div class="job-footer">
            <el-button type="primary" @click="handleTrigger(job.id)">
              立即执行
            </el-button>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<style scoped lang="scss">
.jobs-page {
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

  .job-card {
    margin-bottom: 20px;

    .job-header {
      display: flex;
      align-items: center;
      gap: 15px;
      margin-bottom: 20px;

      .job-icon {
        width: 50px;
        height: 50px;
        background: linear-gradient(135deg, #409eff, #53a8ff);
        border-radius: 10px;
        color: #fff;
        display: flex;
        align-items: center;
        justify-content: center;
      }

      .job-info {
        h3 {
          margin: 0;
          font-size: 16px;
          font-weight: 600;
        }

        .job-id {
          margin: 5px 0 0;
          color: #999;
          font-size: 12px;
        }
      }
    }

    .job-body {
      display: flex;
      gap: 40px;
      margin-bottom: 20px;
      padding: 15px;
      background: #f5f7fa;
      border-radius: 8px;

      .label {
        display: block;
        font-size: 12px;
        color: #999;
        margin-bottom: 5px;
      }

      .value {
        font-size: 14px;
        color: #333;
      }
    }
  }
}
</style>
