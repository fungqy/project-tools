<script setup lang="ts">
import { ref, computed, watch, onMounted, nextTick } from 'vue'
import { reportsApi, type ProjectOption, type SprintOption, type SprintMetrics, type BugDetailResponse, type BugListItem, type ReopenBugItem } from '@/api/reports'
import { ElMessage } from 'element-plus'
import * as echarts from 'echarts'

const projects = ref<ProjectOption[]>([])
const sprints = ref<SprintOption[]>([])
const metrics = ref<SprintMetrics>({ story_count: 0, bug_count: 0, bug_reopen_count: 0 })
const avgTime = ref({ avg_dev_seconds: 0, avg_test_seconds: 0 })
const loadingAvgTime = ref(false)

const selectedProject = ref<number | null>(null)
const selectedSprint = ref<number | null>(null)
const loadingProjects = ref(false)
const loadingSprints = ref(false)
const loadingMetrics = ref(false)

// 故障详情弹窗
const bugDialogVisible = ref(false)
const bugDetail = ref<BugDetailResponse | null>(null)
const loadingBugDetail = ref(false)

// 故障明细弹窗
const bugListDialogVisible = ref(false)
const bugList = ref<BugListItem[]>([])
const loadingBugList = ref(false)
const bugListTitle = ref('')

// 故障重开弹窗
const reopenDialogVisible = ref(false)
const reopenBugs = ref<ReopenBugItem[]>([])
const loadingReopenBugs = ref(false)

const priorityChartRef = ref<HTMLElement | null>(null)
const tagChartRef = ref<HTMLElement | null>(null)
const developerChartRef = ref<HTMLElement | null>(null)
let chartInstance: echarts.ECharts | null = null
let tagChartInstance: echarts.ECharts | null = null
let developerChartInstance: echarts.ECharts | null = null

const PRIORITY_COLORS: Record<string, string> = {
  '致命': '#DC2626',
  '严重': '#EA580C',
  '一般': '#F59E0B',
  '轻微': '#22C55E',
  '优化': '#6B7280',
}

const TAG_COLORS = [
  '#6366F1', '#8B5CF6', '#EC4899', '#F43F5E',
  '#14B8A6', '#06B6D4', '#84CC16', '#F97316',
  '#64748B', '#A855F7',
]

const DEVELOPER_COLORS = [
  '#6366F1', '#EC4899', '#14B8A6', '#F97316',
  '#8B5CF6', '#F43F5E', '#06B6D4', '#84CC16',
  '#64748B', '#A855F7', '#DC2626', '#EA580C',
  '#F59E0B', '#22C55E', '#3B82F6', '#E11D48',
]

const priorityChartData = computed(() => {
  if (!bugDetail.value) return []
  const result: { name: string; value: number }[] = []
  for (const priority of bugDetail.value.priorities) {
    let total = 0
    for (const developer of bugDetail.value.developers) {
      const devData = bugDetail.value.data[developer.developer]
      if (devData && devData[priority]) {
        for (const tag of Object.keys(devData[priority])) {
          total += devData[priority][tag]
        }
      }
    }
    if (total > 0) {
      result.push({ name: priority, value: total })
    }
  }
  return result
})

function renderPriorityChart() {
  if (!priorityChartRef.value || priorityChartData.value.length === 0) return
  if (!chartInstance) {
    chartInstance = echarts.init(priorityChartRef.value)
  }
  const total = priorityChartData.value.reduce((sum, item) => sum + item.value, 0)
  chartInstance.setOption({
    tooltip: {
      trigger: 'item',
      backgroundColor: '#1A1A2E',
      borderColor: 'transparent',
      padding: [10, 16],
      textStyle: { color: '#fff', fontSize: 20 },
      formatter: '{b}: {c} ({d}%)',
    },
    legend: { show: false },
    series: [{
      type: 'pie',
      radius: ['55%', '80%'],
      center: ['50%', '45%'],
      avoidLabelOverlap: true,
      itemStyle: {
        borderRadius: 8,
        borderColor: '#F7F6F3',
        borderWidth: 3,
      },
      label: { show: false },
      emphasis: {
        scale: true,
        scaleSize: 8,
        label: { show: false },
      },
      data: priorityChartData.value.map(item => ({
        name: item.name,
        value: item.value,
        itemStyle: { color: PRIORITY_COLORS[item.name] || '#9CA3AF' },
      })),
    }],
    graphic: [{
      type: 'text',
      left: 'center',
      top: '36%',
      style: {
        text: `${total}`,
        fontSize: 80,
        fontWeight: 700,
        fill: '#1A1A2E',
        textAlign: 'center',
        fontFamily: 'Sora, sans-serif',
      },
    }],
  })
}

const tagChartData = computed(() => {
  if (!bugDetail.value) return []
  const result: { name: string; value: number }[] = []
  for (const tag of bugDetail.value.tags) {
    let total = 0
    for (const developer of bugDetail.value.developers) {
      const devData = bugDetail.value.data[developer.developer]
      if (!devData) continue
      for (const priority of Object.keys(devData)) {
        if (devData[priority] && devData[priority][tag]) {
          total += devData[priority][tag]
        }
      }
    }
    if (total > 0) {
      result.push({ name: tag, value: total })
    }
  }
  return result
})

function renderTagChart() {
  if (!tagChartRef.value || tagChartData.value.length === 0) return
  if (!tagChartInstance) {
    tagChartInstance = echarts.init(tagChartRef.value)
  }
  const total = tagChartData.value.reduce((sum, item) => sum + item.value, 0)
  tagChartInstance.setOption({
    tooltip: {
      trigger: 'item',
      backgroundColor: '#1A1A2E',
      borderColor: 'transparent',
      padding: [10, 16],
      textStyle: { color: '#fff', fontSize: 20 },
      formatter: '{b}: {c} ({d}%)',
    },
    legend: { show: false },
    series: [{
      type: 'pie',
      radius: ['55%', '80%'],
      center: ['50%', '45%'],
      avoidLabelOverlap: true,
      itemStyle: {
        borderRadius: 8,
        borderColor: '#F7F6F3',
        borderWidth: 3,
      },
      label: { show: false },
      emphasis: {
        scale: true,
        scaleSize: 8,
        label: { show: false },
      },
      data: tagChartData.value.map((item, idx) => ({
        name: item.name,
        value: item.value,
        itemStyle: { color: TAG_COLORS[idx % TAG_COLORS.length] },
      })),
    }],
    graphic: [{
      type: 'text',
      left: 'center',
      top: '36%',
      style: {
        text: `${total}`,
        fontSize: 80,
        fontWeight: 700,
        fill: '#1A1A2E',
        textAlign: 'center',
        fontFamily: 'Sora, sans-serif',
      },
    }],
  })
}

const developerChartData = computed(() => {
  if (!bugDetail.value) return []
  return bugDetail.value.developers.map((dev) => ({
    name: dev.developer,
    value: getRowTotal(dev.developer),
  })).filter(item => item.value > 0)
})

function renderDeveloperChart() {
  if (!developerChartRef.value || developerChartData.value.length === 0) return
  if (!developerChartInstance) {
    developerChartInstance = echarts.init(developerChartRef.value)
  }
  const total = developerChartData.value.reduce((sum, item) => sum + item.value, 0)
  developerChartInstance.setOption({
    tooltip: {
      trigger: 'item',
      backgroundColor: '#1A1A2E',
      borderColor: 'transparent',
      padding: [10, 16],
      textStyle: { color: '#fff', fontSize: 20 },
      formatter: '{b}: {c} ({d}%)',
    },
    legend: { show: false },
    series: [{
      type: 'pie',
      radius: ['55%', '80%'],
      center: ['50%', '45%'],
      avoidLabelOverlap: true,
      itemStyle: {
        borderRadius: 8,
        borderColor: '#F7F6F3',
        borderWidth: 3,
      },
      label: { show: false },
      emphasis: {
        scale: true,
        scaleSize: 8,
        label: { show: false },
      },
      data: developerChartData.value.map((item, idx) => ({
        name: item.name,
        value: item.value,
        itemStyle: { color: DEVELOPER_COLORS[idx % DEVELOPER_COLORS.length] },
      })),
    }],
    graphic: [{
      type: 'text',
      left: 'center',
      top: '36%',
      style: {
        text: `${total}`,
        fontSize: 80,
        fontWeight: 700,
        fill: '#1A1A2E',
        textAlign: 'center',
        fontFamily: 'Sora, sans-serif',
      },
    }],
  })
}

function onBugDialogClose() {
  if (chartInstance) {
    chartInstance.dispose()
    chartInstance = null
  }
  if (tagChartInstance) {
    tagChartInstance.dispose()
    tagChartInstance = null
  }
  if (developerChartInstance) {
    developerChartInstance.dispose()
    developerChartInstance = null
  }
}

// 点击的筛选条件
const currentDeveloper = ref('')
const currentPriority = ref('')
const currentTag = ref('')

const bugRate = computed(() => {
  if (metrics.value.story_count === 0) return '0%'
  const rate = (metrics.value.bug_count / metrics.value.story_count * 100).toFixed(1)
  return `${rate}%`
})

const bugReopenRate = computed(() => {
  if (metrics.value.bug_count === 0) return '0%'
  const rate = (metrics.value.bug_reopen_count / metrics.value.bug_count * 100).toFixed(1)
  return `${rate}%`
})

async function loadProjects() {
  loadingProjects.value = true
  try {
    const res = await reportsApi.getProjects()
    projects.value = res
    if (projects.value.length > 0 && !selectedProject.value) {
      selectedProject.value = projects.value[0].id
    }
  } catch {
    ElMessage.error('加载项目列表失败')
  } finally {
    loadingProjects.value = false
  }
}

async function loadSprints(projectId: number) {
  loadingSprints.value = true
  selectedSprint.value = null
  sprints.value = []
  try {
    const res = await reportsApi.getSprints(projectId)
    sprints.value = res
    if (sprints.value.length > 0) {
      selectedSprint.value = sprints.value[0].sprint_id
    }
  } catch {
    ElMessage.error('加载Sprint列表失败')
  } finally {
    loadingSprints.value = false
  }
}

async function loadMetrics(sprintId: number) {
  loadingMetrics.value = true
  try {
    const res = await reportsApi.getMetrics(sprintId)
    metrics.value = res
  } catch {
    ElMessage.error('加载指标数据失败')
  } finally {
    loadingMetrics.value = false
  }
}

function formatDuration(seconds: number): string {
  if (seconds <= 0) return '—'
  const h = Math.floor(seconds / 3600)
  const m = Math.floor((seconds % 3600) / 60)
  if (h > 0) return `${h}h ${m}m`
  return `${m}m`
}

async function loadAvgTime(sprintId: number) {
  loadingAvgTime.value = true
  try {
    const res = await reportsApi.getBugAvgTime(sprintId)
    avgTime.value = res
  } catch {
    avgTime.value = { avg_dev_seconds: 0, avg_test_seconds: 0 }
  } finally {
    loadingAvgTime.value = false
  }
}

async function openBugDetail() {
  if (!selectedSprint.value || metrics.value.bug_count === 0) return
  bugDialogVisible.value = true
  loadingBugDetail.value = true
  try {
    const res = await reportsApi.getBugDetails(selectedSprint.value)
    bugDetail.value = res
    await nextTick()
    renderPriorityChart()
    renderTagChart()
    renderDeveloperChart()
  } catch {
    ElMessage.error('加载故障详情失败')
  } finally {
    loadingBugDetail.value = false
  }
}

async function openReopenBugs() {
  if (!selectedSprint.value || metrics.value.bug_reopen_count === 0) return
  reopenDialogVisible.value = true
  loadingReopenBugs.value = true
  try {
    const res = await reportsApi.getReopenBugs(selectedSprint.value)
    reopenBugs.value = res
  } catch {
    ElMessage.error('加载故障重开列表失败')
  } finally {
    loadingReopenBugs.value = false
  }
}

async function openBugList(developer: string, priority: string, tag: string) {
  if (!selectedSprint.value) return
  currentDeveloper.value = developer
  currentPriority.value = priority
  currentTag.value = tag
  bugListTitle.value = `${developer} - ${priority} - ${tag}`
  bugListDialogVisible.value = true
  loadingBugList.value = true
  try {
    const res = await reportsApi.getBugList(selectedSprint.value, priority, tag, developer)
    bugList.value = res
  } catch {
    ElMessage.error('加载故障明细失败')
  } finally {
    loadingBugList.value = false
  }
}

// 点击纵向合计（某开发的所有故障）
async function openBugListByRow(developer: string) {
  if (!selectedSprint.value || !bugDetail.value) return
  const allTags = bugDetail.value.tags
  const allPriorities = bugDetail.value.priorities
  bugListTitle.value = `${developer} - 全部`
  bugListDialogVisible.value = true
  loadingBugList.value = true
  try {
    const allItems: BugListItem[] = []
    for (const priority of allPriorities) {
      for (const tag of allTags) {
        const res = await reportsApi.getBugList(selectedSprint.value, priority, tag, developer)
        allItems.push(...res)
      }
    }
    // 重新编号
    allItems.forEach((item, idx) => item.index = idx + 1)
    bugList.value = allItems
  } catch {
    ElMessage.error('加载故障明细失败')
  } finally {
    loadingBugList.value = false
  }
}

async function openBugListBySummary(priority: string, tag: string) {
  if (!selectedSprint.value) return
  bugListTitle.value = `合计 - ${priority} - ${tag}`
  bugListDialogVisible.value = true
  loadingBugList.value = true
  try {
    const res = await reportsApi.getBugList(selectedSprint.value, priority, tag)
    res.forEach((item, idx) => item.index = idx + 1)
    bugList.value = res
  } catch {
    ElMessage.error('加载故障明细失败')
  } finally {
    loadingBugList.value = false
  }
}

function onTableSectionClick(e: MouseEvent) {
  const target = e.target as HTMLElement
  const td = target.closest('td')
  if (!td) return
  const footer = target.closest('.el-table__footer')
  if (!footer) return

  const row = td.parentElement
  if (!row) return
  const cells = Array.from(row.children)
  const colIdx = cells.indexOf(td)
  if (colIdx <= 0) return

  const priorities = bugDetail.value?.priorities ?? []
  const tags = bugDetail.value?.tags ?? []
  const colPerPriority = tags.length
  const totalCols = priorities.length * colPerPriority

  if (colIdx > totalCols) return

  const priorityIdx = colIdx - 1
  const pIdx = Math.floor(priorityIdx / colPerPriority)
  const tIdx = priorityIdx % colPerPriority

  if (pIdx < priorities.length && tIdx < tags.length) {
    const text = td.textContent?.trim() || ''
    if (text && text !== '—') {
      openBugListBySummary(priorities[pIdx], tags[tIdx])
    }
  }
}

function getCellCount(developer: string, priority: string, tag: string): number {
  if (!bugDetail.value) return 0
  const devData = bugDetail.value.data[developer]
  if (!devData) return 0
  const priorityData = devData[priority]
  if (!priorityData) return 0
  return priorityData[tag] || 0
}

function getRowTotal(developer: string): number {
  if (!bugDetail.value) return 0
  const devData = bugDetail.value.data[developer]
  if (!devData) return 0
  let total = 0
  for (const priority of Object.keys(devData)) {
    for (const tag of Object.keys(devData[priority])) {
      total += devData[priority][tag]
    }
  }
  return total
}

function getTableSummary({ columns }: { columns: any[]; data: any[] }) {
  const sums: string[] = []
  const priorities = bugDetail.value?.priorities ?? []
  const tags = bugDetail.value?.tags ?? []
  const colPerPriority = tags.length

  columns.forEach((_column: any, idx: number) => {
    if (idx === 0) {
      sums[idx] = '合计'
      return
    }
    if (idx === columns.length - 1) {
      let rowTotalSum = 0
      if (bugDetail.value) {
        for (const dev of bugDetail.value.developers) {
          rowTotalSum += getRowTotal(dev.developer)
        }
      }
      sums[idx] = rowTotalSum > 0 ? String(rowTotalSum) : '—'
      return
    }
    const priorityIdx = idx - 1
    const pIdx = Math.floor(priorityIdx / colPerPriority)
    const tIdx = priorityIdx % colPerPriority
    let total = 0
    if (bugDetail.value && pIdx < priorities.length && tIdx < tags.length) {
      for (const dev of bugDetail.value.developers) {
        total += getCellCount(dev.developer, priorities[pIdx], tags[tIdx])
      }
    }
    sums[idx] = total > 0 ? String(total) : '—'
  })
  return sums
}

watch(selectedProject, (newVal) => {
  if (newVal) {
    loadSprints(newVal)
  }
})

watch(selectedSprint, (newVal) => {
  if (newVal) {
    loadMetrics(newVal)
    loadAvgTime(newVal)
  }
})

onMounted(() => {
  loadProjects()
})
</script>

<template>
  <div class="reports-page">
    <!-- Page header with filters -->
    <div class="page-header page-enter">
      <div class="filter-group">
        <div class="filter-item">
          <label class="filter-label">选择项目</label>
          <el-select
            v-model="selectedProject"
            placeholder="请选择项目"
            :loading="loadingProjects"
            class="filter-select"
          >
            <el-option
              v-for="project in projects"
              :key="project.id"
              :label="project.project_name"
              :value="project.id"
            />
          </el-select>
        </div>
        <div class="filter-item">
          <label class="filter-label">选择Sprint</label>
          <el-select
            v-model="selectedSprint"
            placeholder="请选择Sprint"
            :loading="loadingSprints"
            :disabled="!selectedProject || sprints.length === 0"
            class="filter-select"
          >
            <el-option
              v-for="sprint in sprints"
              :key="sprint.sprint_id"
              :label="sprint.sprint_name"
              :value="sprint.sprint_id"
            />
          </el-select>
        </div>
      </div>
    </div>

    <!-- Metrics cards -->
    <div class="metrics-grid page-enter" style="animation-delay: 0.06s">
      <div class="metric-card">
        <div class="metric-header">
          <span class="metric-name">故事数</span>
          <div class="metric-icon story-icon">
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
              <path d="M4 6h16M4 12h16M4 18h10" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
            </svg>
          </div>
        </div>
        <span class="metric-value">{{ metrics.story_count }}</span>
      </div>

      <div class="metric-card clickable" @click="openBugDetail">
        <div class="metric-header">
          <span class="metric-name">故障数</span>
          <div class="metric-icon bug-icon">
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
              <path d="M12 8v4M12 16h.01M9 3L7 5M15 3l2 2M5 9l-2 2M5 15l-2-2M19 15l-2-2M19 9l2 2" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
              <circle cx="12" cy="12" r="3" stroke="currentColor" stroke-width="1.8"/>
            </svg>
          </div>
        </div>
        <span class="metric-value">{{ metrics.bug_count }}</span>
        <div class="click-hint" v-if="metrics.bug_count > 0">点击查看详情</div>
      </div>

      <div class="metric-card clickable" @click="openReopenBugs">
        <div class="metric-header">
          <span class="metric-name">故障重开数</span>
          <div class="metric-icon reopen-icon">
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
              <path d="M1 4v6h6" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
              <path d="M3.51 15a9 9 0 1 0 2.13-9.36L1 10" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
          </div>
        </div>
        <div class="metric-value-row">
          <span class="metric-value">{{ metrics.bug_reopen_count }}</span>
          <span class="metric-sub" v-if="metrics.bug_count > 0">重开率 {{ bugReopenRate }}</span>
        </div>
        <div class="click-hint" v-if="metrics.bug_reopen_count > 0">点击查看详情</div>
      </div>

      <div class="metric-card">
        <div class="metric-header">
          <span class="metric-name">缺陷率</span>
          <div class="metric-icon rate-icon">
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
              <path d="M12 2v4M12 18v4M4.93 4.93l2.83 2.83M16.24 16.24l2.83 2.83M2 12h4M18 12h4M4.93 19.07l2.83-2.83M16.24 7.76l2.83-2.83" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
            </svg>
          </div>
        </div>
        <span class="metric-value">{{ bugRate }}</span>
      </div>

      <div class="metric-card" v-loading="loadingAvgTime" element-loading-text=" " element-loading-background="transparent">
        <div class="metric-header">
          <span class="metric-name">故障平均Dev时长</span>
          <div class="metric-icon dev-icon">
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
              <path d="M12 20h9M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
          </div>
        </div>
        <span class="metric-value">{{ formatDuration(avgTime.avg_dev_seconds) }}</span>
      </div>

      <div class="metric-card" v-loading="loadingAvgTime" element-loading-text=" " element-loading-background="transparent">
        <div class="metric-header">
          <span class="metric-name">故障平均Test时长</span>
          <div class="metric-icon test-icon">
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
              <path d="M9 11l3 3L22 4M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
          </div>
        </div>
        <span class="metric-value">{{ formatDuration(avgTime.avg_test_seconds) }}</span>
      </div>
    </div>

    <!-- Empty state -->
    <div v-if="!selectedSprint" class="empty-state page-enter" style="animation-delay: 0.1s">
      <el-empty description="请选择项目和Sprint查看报表数据" />
    </div>

    <!-- Bug Detail Dialog -->
    <el-dialog
      v-model="bugDialogVisible"
      title="故障分布统计"
      width="95%"
      class="bug-detail-dialog"
      fullscreen
      align-center
      @close="onBugDialogClose"
    >
      <div v-loading="loadingBugDetail" class="bug-detail-content" v-if="bugDetail">
        <!-- Charts Row -->
        <div class="charts-row" v-if="priorityChartData.length > 0 || tagChartData.length > 0 || developerChartData.length > 0">
          <div class="chart-card" v-if="priorityChartData.length > 0">
            <div class="chart-card-header">
              <span class="chart-card-title">级别分布</span>
              <div class="chart-legend">
                <div
                  v-for="item in priorityChartData"
                  :key="item.name"
                  class="legend-item"
                >
                  <span class="legend-dot" :style="{ background: PRIORITY_COLORS[item.name] || '#9CA3AF' }"></span>
                  <span class="legend-label">{{ item.name }}</span>
                  <span class="legend-value">{{ item.value }}</span>
                </div>
              </div>
            </div>
            <div ref="priorityChartRef" class="chart-container"></div>
          </div>

          <div class="chart-card" v-if="tagChartData.length > 0">
            <div class="chart-card-header">
              <span class="chart-card-title">原因分布</span>
              <div class="chart-legend">
                <div
                  v-for="(item, idx) in tagChartData"
                  :key="item.name"
                  class="legend-item"
                >
                  <span class="legend-dot" :style="{ background: TAG_COLORS[idx % TAG_COLORS.length] }"></span>
                  <span class="legend-label">{{ item.name }}</span>
                  <span class="legend-value">{{ item.value }}</span>
                </div>
              </div>
            </div>
            <div ref="tagChartRef" class="chart-container"></div>
          </div>

          <div class="chart-card" v-if="developerChartData.length > 0">
            <div class="chart-card-header">
              <span class="chart-card-title">人员分布</span>
              <div class="chart-legend">
                <div
                  v-for="(item, idx) in developerChartData"
                  :key="item.name"
                  class="legend-item"
                >
                  <span class="legend-dot" :style="{ background: DEVELOPER_COLORS[idx % DEVELOPER_COLORS.length] }"></span>
                  <span class="legend-label">{{ item.name }}</span>
                  <span class="legend-value">{{ item.value }}</span>
                </div>
              </div>
            </div>
            <div ref="developerChartRef" class="chart-container"></div>
          </div>
        </div>

        <!-- Table Section -->
        <div class="table-section" @click="onTableSectionClick">
          <h3 class="section-title">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M3 9h18M3 15h18M9 3v18M15 3v18"/></svg>
            分布明细
          </h3>
          <el-table
            :data="bugDetail.developers"
            border
            stripe
            style="width: 100%"
            table-layout="fixed"
            :summary-method="getTableSummary"
            show-summary
            class="bug-table"
          >
            <el-table-column prop="developer" label="开发" fixed width="160">
              <template #default="{ row }">
                <div class="developer-cell">
                  <span class="developer-avatar">{{ row.developer.slice(0, 1) }}</span>
                  <span class="developer-name">{{ row.developer }}</span>
                </div>
              </template>
            </el-table-column>

            <el-table-column
              v-for="priority in bugDetail.priorities"
              :key="priority"
              :label="priority"
              align="center"
              :label-class-name="'priority-col-header priority-' + priority"
            >
              <el-table-column
                v-for="tag in bugDetail.tags"
                :key="tag"
                :label="tag"
                align="center"
                min-width="90"
              >
                <template #default="{ row }">
                  <span
                    class="cell-count"
                    :class="{ 'has-data': getCellCount(row.developer, priority, tag) > 0 }"
                    @click="openBugList(row.developer, priority, tag)"
                  >
                    {{ getCellCount(row.developer, priority, tag) || '—' }}
                  </span>
                </template>
              </el-table-column>
            </el-table-column>

            <el-table-column label="合计" fixed="right" width="90" align="center" class-name="total-col">
              <template #default="{ row }">
                <span
                  class="cell-total clickable-total"
                  @click="openBugListByRow(row.developer)"
                >
                  {{ getRowTotal(row.developer) }}
                </span>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </div>
      <div v-else-if="!loadingBugDetail" class="empty-dialog">
        <el-empty description="暂无故障数据" />
      </div>
    </el-dialog>

    <!-- Bug List Dialog -->
    <el-dialog
      v-model="bugListDialogVisible"
      :title="bugListTitle"
      width="900px"
      class="bug-list-dialog"
    >
      <div v-loading="loadingBugList">
        <el-table
          v-if="bugList.length > 0"
          :data="bugList"
          border
          stripe
          style="width: 100%"
        >
          <el-table-column prop="index" label="序号" width="60" align="center" />
          <el-table-column prop="issue_key" label="编号" width="120" />
          <el-table-column prop="developer" label="开发" width="100" />
          <el-table-column prop="issue_name" label="名称" min-width="200" show-overflow-tooltip />
          <el-table-column prop="reason_analysis" label="原因及分析" width="120" />
          <el-table-column prop="priority" label="级别" width="80" align="center" />
          <el-table-column prop="tag" label="标签" width="100" align="center" />
          <el-table-column prop="is_typical" label="是否典型" width="90" align="center" />
          <el-table-column prop="source" label="来源" width="80" align="center" />
        </el-table>
        <el-empty v-else description="暂无数据" />
      </div>
    </el-dialog>

    <!-- Reopen Bugs Dialog -->
    <el-dialog
      v-model="reopenDialogVisible"
      title="故障重开列表"
      width="95%"
      class="bug-detail-dialog"
      fullscreen
      align-center
    >
      <div v-loading="loadingReopenBugs">
        <el-table
          v-if="reopenBugs.length > 0"
          :data="reopenBugs"
          border
          stripe
          style="width: 100%"
        >
          <el-table-column prop="index" label="序号" width="80" align="center" />
          <el-table-column prop="issue_key" label="编码" width="130" />
          <el-table-column prop="issue_name" label="名称" min-width="180" show-overflow-tooltip />
          <el-table-column prop="bug_maker" label="开发" width="100" />
          <el-table-column prop="reporter" label="提出" width="100" />
          <el-table-column prop="bug_type" label="类型" width="150" align="center" />
          <el-table-column prop="priority" label="级别" width="80" align="center" />
          <el-table-column prop="bug_reason" label="原因" width="200" show-overflow-tooltip />
          <el-table-column prop="resolution" label="结果" width="150" align="center" />
        </el-table>
        <el-empty v-else description="暂无重开故障数据" />
      </div>
    </el-dialog>
  </div>
</template>

<style scoped lang="scss">
.reports-page {
  max-width: 100%;
}

// ── Page Header ──────────────────────────────────────────────
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  margin-bottom: 24px;
}

.filter-group {
  display: flex;
  gap: 16px;
}

.filter-item {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.filter-label {
  font-size: 13px;
  font-weight: 600;
  color: var(--ink-secondary);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.filter-select {
  width: 220px;
}

// ── Metrics Grid ──────────────────────────────────────────────
.metrics-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 18px;
  margin-bottom: 24px;
}

.metric-card {
  background: var(--bg-surface);
  border-radius: var(--radius-lg);
  padding: 20px 24px;
  box-shadow: var(--shadow-xs);
  display: flex;
  flex-direction: column;
  gap: 12px;
  transition: box-shadow 0.2s ease, transform 0.2s ease;
  position: relative;

  &:hover {
    box-shadow: var(--shadow-md);
    transform: translateY(-2px);
  }

  &.clickable {
    cursor: pointer;
  }
}

.metric-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.metric-name {
  font-size: 16px;
  font-weight: 600;
  color: var(--ink-primary);
  letter-spacing: -0.01em;
}

.metric-icon {
  width: 40px;
  height: 40px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;

  &.story-icon {
    background: #EEF2FF;
    color: #4F46E5;
  }

  &.bug-icon {
    background: #FEF2F2;
    color: #DC2626;
  }

  &.reopen-icon {
    background: #FEF3C7;
    color: #D97706;
  }

  &.rate-icon {
    background: #FFF7ED;
    color: #EA580C;
  }

  &.dev-icon {
    background: #EFF6FF;
    color: #2563EB;
  }

  &.test-icon {
    background: #F0FDF4;
    color: #16A34A;
  }
}

.metric-value-row {
  display: flex;
  align-items: baseline;
  gap: 10px;
}

.metric-sub {
  font-size: 13px;
  color: var(--ink-tertiary);
  font-weight: 500;
}

.metric-value {
  font-size: 36px;
  font-weight: 700;
  color: var(--ink-primary);
  font-family: 'Sora', sans-serif;
  letter-spacing: -0.02em;
  line-height: 1;
}

.click-hint {
  position: absolute;
  right: 24px;
  bottom: 20px;
  font-size: 12px;
  color: var(--ink-tertiary);
  opacity: 0;
  transition: opacity 0.2s ease;
}

.metric-card.clickable:hover .click-hint {
  opacity: 1;
}

// ── Empty State ───────────────────────────────────────────────
.empty-state {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 300px;
}

// ── Bug Detail Dialog ────────────────────────────────────────
// ── Charts Row ───────────────────────────────────────────────
.charts-row {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  gap: 20px;
  margin-bottom: 28px;
}

.chart-card {
  background: var(--bg-surface);
  border-radius: var(--radius-md);
  padding: 20px 24px;
  box-shadow: var(--shadow-sm);
  border: 1px solid var(--bg-muted);
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.chart-card-header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 16px;
}

.chart-card-title {
  font-size: 25px;
  font-weight: 600;
  color: var(--ink-primary);
  font-family: 'Sora', sans-serif;
  letter-spacing: -0.01em;
  flex-shrink: 0;
}

.chart-legend {
  display: flex;
  flex-wrap: wrap;
  gap: 8px 16px;
  align-items: center;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 13px;
}

.legend-dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  flex-shrink: 0;
}

.legend-label {
  color: var(--ink-secondary);
  font-weight: 500;
  font-size: 18px;
}

.legend-value {
  color: var(--ink-primary);
  font-weight: 700;
  font-family: 'Sora', sans-serif;
  font-size: 18px;
}

.chart-container {
  width: 100%;
  height: 260px;
  min-height: 220px;
}

// ── Table Section ────────────────────────────────────────────
.table-section {
  flex: 1;
  min-width: 0;
}

.bug-table {
  border-radius: var(--radius-md);
  overflow: hidden;
  box-shadow: var(--shadow-sm);

  :deep(.el-table__header th) {
    background: var(--bg-muted);
    font-size: 18px;
    font-weight: 600;
    color: var(--ink-secondary);
    text-transform: uppercase;
    letter-spacing: 0.05em;
    padding: 10px 8px;
  }

  :deep(.el-table__row td) {
    padding: 10px 8px;
    font-size: 18px;
  }

  :deep(.el-table__footer td) {
    background: var(--bg-muted);
    font-weight: 700;
    color: var(--ink-primary);
    font-size: 18px;
    padding: 12px 8px;

    .cell {
      cursor: default;
      transition: color 0.15s, background-color 0.15s;
      padding: 3px 8px;
      border-radius: 4px;
      display: inline-block;
    }

    &:not(:first-child) .cell:not(:empty):hover {
      background-color: var(--accent-soft);
      color: var(--accent);
      cursor: pointer;
    }
  }

  :deep(.el-table-column--selection) {
    .cell {
      padding: 0;
    }
  }
}

.section-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 25px;
  font-weight: 600;
  color: var(--ink-primary);
  font-family: 'Sora', sans-serif;
  margin: 0 0 14px;
  padding-bottom: 10px;
  border-bottom: 1px solid var(--bg-muted);

  svg {
    color: var(--accent);
    flex-shrink: 0;
  }
}

.developer-cell {
  display: flex;
  align-items: center;
  gap: 8px;
  padding-left: 4px;
}

.developer-avatar {
  width: 28px;
  height: 28px;
  border-radius: 50%;
  background: var(--accent-soft);
  color: var(--accent);
  font-weight: 700;
  font-size: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  font-family: 'Sora', sans-serif;
  text-transform: uppercase;
}

.developer-name {
  font-weight: 600;
  color: var(--ink-primary);
  font-size: 18px;
}

.cell-count {
  font-weight: 500;
  color: var(--ink-tertiary);
  transition: color 0.15s, background-color 0.15s;
  padding: 3px 8px;
  border-radius: 4px;
  cursor: default;
  display: inline-block;

  &.has-data {
    color: var(--ink-primary);
    font-weight: 600;
    cursor: pointer;

    &:hover {
      background-color: var(--accent-soft);
      color: var(--accent);
    }
  }
}

.cell-total {
  font-weight: 700;
  color: var(--accent);
  font-family: 'Sora', sans-serif;
}

.clickable-total {
  cursor: pointer;
  padding: 4px 10px;
  border-radius: 4px;
  transition: background-color 0.2s;
  display: inline-block;

  &:hover {
    background-color: var(--accent-soft);
  }
}

.empty-dialog {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 400px;
}

// ── Bug List Dialog ─────────────────────────────────────────
.bug-list-dialog {
  :deep(.el-dialog__header) {
    padding: 16px 20px;
    border-bottom: 1px solid var(--bg-muted);
    margin-right: 0;
  }

  :deep(.el-dialog__title) {
    font-family: 'Sora', sans-serif;
    font-weight: 600;
    font-size: 15px;
    color: var(--ink-primary);
  }

  :deep(.el-table__row:hover td) {
    background-color: var(--accent-soft) !important;
  }
}
</style>
