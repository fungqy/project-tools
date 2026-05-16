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

function formatDateTime(iso: string | null): string {
  if (!iso) return '—'
  const d = new Date(iso)
  return d.toLocaleString('zh-CN', {
    month: '2-digit', day: '2-digit',
    hour: '2-digit', minute: '2-digit', hour12: false
  })
}

const jobMeta: Record<string, { label: string; desc: string }> = {
  story_reminder:   { label: '进度提醒',    desc: '同步 JIRA 故事状态并推送提醒' },
  task_reminder:   { label: '任务提醒',    desc: '检查未完成任务并发送企业微信' },
  sonar_reminder:  { label: '代码扫描',  desc: '执行 GitLab 代码质量扫描' },
  report_data:     { label: '报表数据',    desc: '汇总生成质量数据报表' },
}
</script>

<template>
  <div class="jobs-page">
    <!-- Page header -->
    <div class="page-header page-enter">
      <div class="page-header-left">
        <p></p>
      </div>
      <el-button @click="loadJobs" class="refresh-btn" :loading="loading">
        <svg width="14" height="14" viewBox="0 0 14 14" fill="none">
          <path d="M12.5 2.5v3.5H9M1.5 11.5v-3.5H5M12.5 6A6 6 0 1 1 7 1.5a6 6 0 0 1 4.5 2" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" stroke-linejoin="round"/>
        </svg>
        刷新状态
      </el-button>
    </div>

    <!-- Job cards -->
    <div class="jobs-grid page-enter" style="animation-delay: 0.06s">
      <div v-for="job in jobs" :key="job.id" class="job-card">
        <div class="job-card-header">
          <div class="job-icon-wrap">
            <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
              <circle cx="10" cy="10" r="7.5" stroke="currentColor" stroke-width="1.4"/>
              <path d="M10 6v4l2.5 2" stroke="currentColor" stroke-width="1.4" stroke-linecap="round"/>
            </svg>
          </div>
          <div class="job-title-group">
            <h3>{{ jobMeta[job.id]?.label || job.name }}</h3>
            <p>{{ jobMeta[job.id]?.desc || job.id }}</p>
          </div>
        </div>

        <div class="job-meta-grid">
          <div class="meta-item">
            <span class="meta-label">下次执行</span>
            <span class="meta-value">{{ formatDateTime(job.next_run_time) }}</span>
          </div>
          <div class="meta-item">
            <span class="meta-label">触发规则</span>
            <span class="meta-value trigger-text">{{ job.trigger }}</span>
          </div>
        </div>

        <div class="job-card-footer">
          <el-button type="primary" size="small" class="trigger-btn" @click="handleTrigger(job.id)">
            立即执行
          </el-button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped lang="scss">
.jobs-page {
  max-width: 100%;
}

// ── Page Header ───────────────────────────────────────────────
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

.refresh-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  border-radius: var(--radius-sm);
}

// ── Jobs Grid ─────────────────────────────────────────────────
.jobs-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 18px;
}

.job-card {
  background: var(--bg-surface);
  border-radius: var(--radius-lg);
  padding: 20px;
  box-shadow: var(--shadow-xs);
  transition: box-shadow 0.2s ease, transform 0.2s ease;
  display: flex;
  flex-direction: column;
  gap: 16px;

  &:hover {
    box-shadow: var(--shadow-md);
    transform: translateY(-2px);
  }

  &-header {
    display: flex;
    align-items: flex-start;
    gap: 16px;
  }

  &-footer {
    display: flex;
    justify-content: flex-end;
    padding-top: 4px;
    border-top: 1px solid var(--bg-muted);
  }
}

.job-icon-wrap {
  width: 44px;
  height: 44px;
  border-radius: 10px;
  background: var(--accent-soft);
  color: var(--accent);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.job-title-group {
  h3 {
    font-size: 16px;
    font-weight: 600;
    color: var(--ink-primary);
    margin-bottom: 4px;
    letter-spacing: -0.01em;
  }

  p {
    font-size: 13px;
    color: var(--ink-tertiary);
  }
}

.job-meta-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
  padding: 14px;
  background: var(--bg-muted);
  border-radius: var(--radius-md);
}

.meta-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.meta-label {
  font-size: 12px;
  font-weight: 600;
  color: var(--ink-tertiary);
  text-transform: uppercase;
  letter-spacing: 0.06em;
}

.meta-value {
  font-size: 14px;
  font-weight: 500;
  color: var(--ink-primary);
  font-variant-numeric: tabular-nums;
}

.trigger-text {
  font-size: 13px;
  color: var(--ink-secondary);
  font-family: 'SF Mono', 'Fira Code', monospace;
  letter-spacing: 0;
}

.trigger-btn {
  border-radius: var(--radius-sm);
  font-weight: 600;
}
</style>
