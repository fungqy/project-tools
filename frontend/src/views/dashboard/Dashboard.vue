<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { projectApi } from '@/api/projects'
import { jobApi, type TodayTask } from '@/api/jobs'
import { useAuthStore } from '@/stores/auth'

const authStore = useAuthStore()
const projects = ref<any[]>([])
const todayTasks = ref<TodayTask[]>([])
const loading = ref(false)
const currentPage = ref(1)
const pageSize = ref(10)

const jobCurrentPage = ref(1)
const jobPageSize = ref(10)

onMounted(async () => {
  loading.value = true
  try {
    const [projectsRes, tasksRes] = await Promise.all([
      projectApi.getList(),
      jobApi.getTodayTasks(),
    ])
    projects.value = projectsRes
    todayTasks.value = tasksRes
  } finally {
    loading.value = false
  }
})

const taskTypeMap: Record<string, string> = {
  story_reminder: '进度提醒',
  task_reminder: '任务提醒',
  sonar_reminder: 'Sonar扫描',
  report_data: '报表数据',
}

const statusMap: Record<string, { text: string; cls: string }> = {
  pending: { text: '待执行', cls: 'status-pending' },
  success: { text: '成功', cls: 'status-success' },
  failed:  { text: '失败',  cls: 'status-failed'  },
  expired: { text: '已过期', cls: 'status-expired' },
}

function formatDateTime(iso: string): string {
  const d = new Date(iso)
  return d.toLocaleString('zh-CN', { month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit', hour12: false })
}

const paginatedProjects = computed(() => {
  const filtered = projects.value.filter(p =>
    p.need_story_remind || p.need_task_remind || p.need_sonar_scan_remind || p.need_report_data
  )
  const start = (currentPage.value - 1) * pageSize.value
  return filtered.slice(start, start + pageSize.value)
})

const paginatedJobs = computed(() => {
  const start = (jobCurrentPage.value - 1) * jobPageSize.value
  return todayTasks.value.slice(start, start + jobPageSize.value)
})

const totalPages = computed(() => {
  const filtered = projects.value.filter(p =>
    p.need_story_remind || p.need_task_remind || p.need_sonar_scan_remind || p.need_report_data
  )
  return Math.ceil(filtered.length / pageSize.value)
})

const jobTotalPages = computed(() => Math.ceil(todayTasks.value.length / jobPageSize.value))

const enabledProjects = computed(() =>
  projects.value.filter(p => p.need_story_remind || p.need_task_remind || p.need_sonar_scan_remind || p.need_report_data).length
)
const activeAlerts = computed(() =>
  projects.value.filter(p => p.need_story_remind).length +
  projects.value.filter(p => p.need_task_remind).length +
  projects.value.filter(p => p.need_sonar_scan_remind).length
)
</script>

<template>
  <div class="dashboard">
    <!-- Greeting -->
    <section class="greeting page-enter">
      <div class="greeting-inner">
        <div class="greeting-text">
          <h1>你好，{{ authStore.user?.username }}</h1>
          <p>今天共有 <strong>{{ todayTasks.length }}</strong> 个任务待执行</p>
        </div>
        <div class="greeting-decoration">
          <svg width="120" height="120" viewBox="0 0 120 120" fill="none">
            <circle cx="60" cy="60" r="55" fill="#2D5BFF" opacity="0.06"/>
            <circle cx="60" cy="60" r="38" fill="#2D5BFF" opacity="0.08"/>
            <circle cx="60" cy="60" r="22" fill="#2D5BFF" opacity="0.10"/>
          </svg>
        </div>
      </div>
    </section>

    <!-- Stats -->
    <section class="stats-row page-enter" style="animation-delay: 0.06s">
      <div class="stat-card">
        <div class="stat-icon-wrap">
          <svg width="22" height="22" viewBox="0 0 22 22" fill="none">
            <path d="M3 7a2 2 0 0 1 2-2h3l2 3h8a2 2 0 0 1 2 2v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V7z" stroke="#2D5BFF" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
        </div>
        <div class="stat-body">
          <span class="stat-value">{{ projects.length }}</span>
          <span class="stat-label">项目总数</span>
        </div>
        <div class="stat-accent"></div>
      </div>

      <div class="stat-card">
        <div class="stat-icon-wrap">
          <svg width="22" height="22" viewBox="0 0 22 22" fill="none">
            <path d="M11 3a7 7 0 1 0 0 14A7 7 0 0 0 11 3z" stroke="#22C55E" stroke-width="1.5"/>
            <path d="M11 8v4l3 2" stroke="#22C55E" stroke-width="1.5" stroke-linecap="round"/>
          </svg>
        </div>
        <div class="stat-body">
          <span class="stat-value">{{ enabledProjects }}</span>
          <span class="stat-label">已启用提醒</span>
        </div>
        <div class="stat-accent stat-accent--green"></div>
      </div>

      <div class="stat-card">
        <div class="stat-icon-wrap">
          <svg width="22" height="22" viewBox="0 0 22 22" fill="none">
            <path d="M4 12h14M4 6h10M4 18h6" stroke="#F59E0B" stroke-width="1.5" stroke-linecap="round"/>
          </svg>
        </div>
        <div class="stat-body">
          <span class="stat-value">{{ activeAlerts }}</span>
          <span class="stat-label">活跃提醒项</span>
        </div>
        <div class="stat-accent stat-accent--amber"></div>
      </div>

      <div class="stat-card">
        <div class="stat-icon-wrap">
          <svg width="22" height="22" viewBox="0 0 22 22" fill="none">
            <circle cx="11" cy="11" r="7" stroke="#9CA3AF" stroke-width="1.5"/>
            <path d="M11 7v4M11 14h.01" stroke="#9CA3AF" stroke-width="1.5" stroke-linecap="round"/>
          </svg>
        </div>
        <div class="stat-body">
          <span class="stat-value">{{ todayTasks.length }}</span>
          <span class="stat-label">今日任务</span>
        </div>
        <div class="stat-accent stat-accent--gray"></div>
      </div>
    </section>

    <!-- Tables -->
    <section class="tables-row page-enter" style="animation-delay: 0.12s">
      <!-- Today's Tasks -->
      <div class="table-card">
        <div class="table-card-header">
          <div>
            <h3>今日任务</h3>
            <p>共 {{ todayTasks.length }} 个任务</p>
          </div>
          <div class="header-dot"></div>
        </div>
        <el-table :data="paginatedJobs" v-loading="loading" class="minimal-table">
          <el-table-column prop="project_name" label="项目名称" min-width="140" />
          <el-table-column prop="task_type" label="类型" width="110">
            <template #default="{ row }">
              <span class="type-badge">{{ taskTypeMap[row.task_type] || row.task_type }}</span>
            </template>
          </el-table-column>
          <el-table-column prop="scheduled_time" label="计划时间" width="140" align="center">
            <template #default="{ row }">
              <span class="time-text">{{ formatDateTime(row.scheduled_time) }}</span>
            </template>
          </el-table-column>
          <el-table-column prop="status" label="状态" width="90" align="center">
            <template #default="{ row }">
              <span :class="['status-badge', statusMap[row.status]?.cls]">
                {{ statusMap[row.status]?.text || row.status }}
              </span>
            </template>
          </el-table-column>
        </el-table>
        <div class="table-footer" v-if="jobTotalPages > 1">
          <el-pagination
            v-model:current-page="jobCurrentPage"
            :page-size="jobPageSize"
            :total="todayTasks.length"
            layout="prev, pager, next"
            small
          />
        </div>
      </div>

      <!-- Project Reminders -->
      <div class="table-card">
        <div class="table-card-header">
          <div>
            <h3>项目提醒配置</h3>
            <p>{{ enabledProjects }} 个项目已配置</p>
          </div>
          <div class="header-dot header-dot--green"></div>
        </div>
        <el-table :data="paginatedProjects" v-loading="loading" class="minimal-table">
          <el-table-column prop="project_name" label="项目名称" min-width="140" />
          <el-table-column label="进度" width="90" align="center">
            <template #default="{ row }">
              <span v-if="row.need_story_remind" class="reminder-active">
                {{ row.story_remind_time }}
                <span class="reminder-time">提醒</span>
              </span>
              <span v-else class="reminder-off">—</span>
            </template>
          </el-table-column>
          <el-table-column label="任务" width="90" align="center">
            <template #default="{ row }">
              <span v-if="row.need_task_remind" class="reminder-active">
                {{ row.task_remind_time }}
                <span class="reminder-time">提醒</span>
              </span>
              <span v-else class="reminder-off">—</span>
            </template>
          </el-table-column>
          <el-table-column label="Sonar" width="100" align="center">
            <template #default="{ row }">
              <span v-if="row.need_sonar_scan_remind" class="reminder-active">
                {{ row.sonar_remind_time }}
                <span class="reminder-time">提醒</span>
              </span>
              <span v-else class="reminder-off">—</span>
            </template>
          </el-table-column>
          <el-table-column label="报表" width="90" align="center">
            <template #default="{ row }">
              <span v-if="row.need_report_data" class="reminder-active">
                {{ row.report_data_time }}
                <span class="reminder-time">生成</span>
              </span>
              <span v-else class="reminder-off">—</span>
            </template>
          </el-table-column>
        </el-table>
        <div class="table-footer" v-if="totalPages > 1">
          <el-pagination
            v-model:current-page="currentPage"
            :page-size="pageSize"
            :total="projects.filter(p => p.need_story_remind || p.need_task_remind || p.need_sonar_scan_remind || p.need_report_data).length"
            layout="prev, pager, next"
            small
          />
        </div>
      </div>
    </section>
  </div>
</template>

<style scoped lang="scss">
.dashboard {
  max-width: 100%;
}

// ── Greeting ───────────────────────────────────────────────────
.greeting {
  margin-bottom: 24px;

  &-inner {
    background: var(--bg-surface);
    border-radius: var(--radius-lg);
    padding: 24px 28px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    box-shadow: var(--shadow-sm);
    position: relative;
    overflow: hidden;
  }

  &-text {
    h1 {
      font-size: 28px;
      font-weight: 700;
      color: var(--ink-primary);
      margin-bottom: 8px;
      letter-spacing: -0.03em;
    }

    p {
      font-size: 15px;
      color: var(--ink-secondary);

      strong {
        color: var(--accent);
        font-weight: 600;
      }
    }
  }

  &-decoration {
    position: absolute;
    right: 20px;
    top: 50%;
    transform: translateY(-50%);
    opacity: 0.6;
  }
}

// ── Stats Row ──────────────────────────────────────────────────
.stats-row {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
  margin-bottom: 24px;
}

.stat-card {
  background: var(--bg-surface);
  border-radius: var(--radius-md);
  padding: 18px 20px;
  display: flex;
  align-items: center;
  gap: 16px;
  box-shadow: var(--shadow-xs);
  position: relative;
  overflow: hidden;
  transition: box-shadow 0.2s ease, transform 0.2s ease;

  &:hover {
    box-shadow: var(--shadow-md);
    transform: translateY(-2px);
  }
}

.stat-icon-wrap {
  width: 44px;
  height: 44px;
  border-radius: 10px;
  background: var(--bg-muted);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.stat-body {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.stat-value {
  font-family: 'Sora', sans-serif;
  font-size: 28px;
  font-weight: 700;
  color: var(--ink-primary);
  line-height: 1;
  letter-spacing: -0.03em;
}

.stat-label {
  font-size: 12px;
  color: var(--ink-tertiary);
  font-weight: 500;
  text-transform: uppercase;
  letter-spacing: 0.06em;
}

.stat-accent {
  position: absolute;
  right: 0;
  top: 0;
  bottom: 0;
  width: 3px;
  background: var(--accent);
  border-radius: 0 0 0 3px;

  &--green { background: #22C55E; }
  &--amber { background: #F59E0B; }
  &--gray  { background: #9CA3AF; }
}

// ── Tables Row ─────────────────────────────────────────────────
.tables-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
}

.table-card {
  background: var(--bg-surface);
  border-radius: var(--radius-lg);
  padding: 20px;
  box-shadow: var(--shadow-xs);
  min-width: 0;
  overflow: hidden;

  &-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 16px;

    h3 {
      font-size: 16px;
      font-weight: 600;
      color: var(--ink-primary);
      margin-bottom: 4px;
    }

    p {
      font-size: 13px;
      color: var(--ink-tertiary);
    }
  }
}

.header-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: var(--accent);
  margin-top: 6px;

  &--green { background: #22C55E; }
}

// ── Minimal Table ─────────────────────────────────────────────
.minimal-table {
  :deep(.el-table__header th) {
    background: var(--bg-muted);
    font-weight: 600;
    font-size: 13px;
    color: var(--ink-secondary);
    text-transform: uppercase;
    letter-spacing: 0.05em;
    padding: 10px 12px;
    white-space: nowrap;
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

.type-badge {
  display: inline-block;
  padding: 2px 8px;
  border-radius: var(--radius-xs);
  background: var(--accent-soft);
  color: var(--accent);
  font-size: 13px;
  font-weight: 500;
  white-space: nowrap;
}

.time-text {
  font-size: 13px;
  color: var(--ink-secondary);
  font-variant-numeric: tabular-nums;
  white-space: nowrap;
}

.status-badge {
  display: inline-block;
  white-space: nowrap;
  padding: 2px 8px;
  border-radius: var(--radius-xs);
  font-size: 13px;
  font-weight: 500;

  &.status-pending { background: #F3F4F6; color: #6B7280; }
  &.status-success  { background: #DCFCE7; color: #16A34A; }
  &.status-failed   { background: #FEE2E2; color: #DC2626; }
  &.status-expired  { background: #FEF3C7; color: #D97706; }
}

.reminder-active {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 2px;
  font-size: 13px;
  font-weight: 500;
  color: var(--ink-primary);
  font-variant-numeric: tabular-nums;
}

.reminder-time {
  font-size: 11px;
  color: var(--accent);
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.04em;
}

.reminder-off {
  color: var(--ink-tertiary);
}

.table-footer {
  display: flex;
  justify-content: center;
  margin-top: 16px;
}
</style>
