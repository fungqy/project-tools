<script setup lang="ts">
import { ref, computed, watch, onMounted, nextTick } from 'vue'
import { reportsApi, type ProjectOption, type SprintOption, type SprintMetrics, type BugDetailResponse, type BugListItem } from '@/api/reports'
import { ElMessage } from 'element-plus'
import * as echarts from 'echarts'

const projects = ref<ProjectOption[]>([])
const sprints = ref<SprintOption[]>([])
const metrics = ref<SprintMetrics>({ story_count: 0, bug_count: 0 })

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

const priorityChartRef = ref<HTMLElement | null>(null)
const tagChartRef = ref<HTMLElement | null>(null)
let chartInstance: echarts.ECharts | null = null
let tagChartInstance: echarts.ECharts | null = null

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
      formatter: '{b}: {c} ({d}%)',
    },
    legend: {
      orient: 'horizontal',
      bottom: 0,
      textStyle: { fontSize: 12, color: '#6B7280' },
    },
    series: [{
      type: 'pie',
      radius: ['45%', '72%'],
      center: ['50%', '45%'],
      avoidLabelOverlap: true,
      itemStyle: {
        borderRadius: 6,
        borderColor: '#fff',
        borderWidth: 2,
      },
      label: {
        show: true,
        formatter: '{b}\n{c}',
        fontSize: 12,
      },
      emphasis: {
        label: { show: true, fontSize: 14, fontWeight: 'bold' },
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
      top: '38%',
      style: {
        text: `${total}`,
        fontSize: 24,
        fontWeight: 700,
        fill: '#111827',
        textAlign: 'center',
      },
    }, {
      type: 'text',
      left: 'center',
      top: '48%',
      style: {
        text: '故障总数',
        fontSize: 12,
        fill: '#9CA3AF',
        textAlign: 'center',
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
      formatter: '{b}: {c} ({d}%)',
    },
    legend: {
      orient: 'horizontal',
      bottom: 0,
      textStyle: { fontSize: 12, color: '#6B7280' },
    },
    series: [{
      type: 'pie',
      radius: ['45%', '72%'],
      center: ['50%', '45%'],
      avoidLabelOverlap: true,
      itemStyle: {
        borderRadius: 6,
        borderColor: '#fff',
        borderWidth: 2,
      },
      label: {
        show: true,
        formatter: '{b}\n{c}',
        fontSize: 12,
      },
      emphasis: {
        label: { show: true, fontSize: 14, fontWeight: 'bold' },
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
      top: '38%',
      style: {
        text: `${total}`,
        fontSize: 24,
        fontWeight: 700,
        fill: '#111827',
        textAlign: 'center',
      },
    }, {
      type: 'text',
      left: 'center',
      top: '48%',
      style: {
        text: '故障总数',
        fontSize: 12,
        fill: '#9CA3AF',
        textAlign: 'center',
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

async function loadProjects() {
  loadingProjects.value = true
  try {
    projects.value = await reportsApi.getProjects()
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
    sprints.value = await reportsApi.getSprints(projectId)
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
    metrics.value = await reportsApi.getMetrics(sprintId)
  } catch {
    ElMessage.error('加载指标数据失败')
  } finally {
    loadingMetrics.value = false
  }
}

async function openBugDetail() {
  if (!selectedSprint.value || metrics.value.bug_count === 0) return
  bugDialogVisible.value = true
  loadingBugDetail.value = true
  try {
    bugDetail.value = await reportsApi.getBugDetails(selectedSprint.value)
    await nextTick()
    renderPriorityChart()
    renderTagChart()
  } catch {
    ElMessage.error('加载故障详情失败')
  } finally {
    loadingBugDetail.value = false
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
    bugList.value = await reportsApi.getBugList(selectedSprint.value, developer, priority, tag)
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
        const items = await reportsApi.getBugList(selectedSprint.value, developer, priority, tag)
        allItems.push(...items)
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

// 点击横向合计（某priority+tag组合的所有故障）
async function openBugListByCol(priority: string, tag: string) {
  if (!selectedSprint.value || !bugDetail.value) return
  const allDevelopers = bugDetail.value.developers.map(d => d.developer)
  bugListTitle.value = `全部开发 - ${priority} - ${tag}`
  bugListDialogVisible.value = true
  loadingBugList.value = true
  try {
    const allItems: BugListItem[] = []
    for (const developer of allDevelopers) {
      const items = await reportsApi.getBugList(selectedSprint.value, developer, priority, tag)
      allItems.push(...items)
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

function getColTotal(priority: string, tag: string): number {
  if (!bugDetail.value) return 0
  let total = 0
  for (const developer of bugDetail.value.developers) {
    total += getCellCount(developer.developer, priority, tag)
  }
  return total
}

function getAllTotal(): number {
  if (!bugDetail.value) return 0
  let total = 0
  for (const developer of bugDetail.value.developers) {
    total += getRowTotal(developer.developer)
  }
  return total
}

watch(selectedProject, (newVal) => {
  if (newVal) {
    loadSprints(newVal)
  }
})

watch(selectedSprint, (newVal) => {
  if (newVal) {
    loadMetrics(newVal)
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
        <div class="metric-icon story-icon">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
            <path d="M4 6h16M4 12h16M4 18h10" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
          </svg>
        </div>
        <div class="metric-info">
          <span class="metric-value">{{ metrics.story_count }}</span>
          <span class="metric-label">故事数</span>
        </div>
      </div>

      <div class="metric-card clickable" @click="openBugDetail">
        <div class="metric-icon bug-icon">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
            <path d="M12 8v4M12 16h.01M9 3L7 5M15 3l2 2M5 9l-2 2M5 15l-2-2M19 15l-2-2M19 9l2 2" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
            <circle cx="12" cy="12" r="3" stroke="currentColor" stroke-width="1.8"/>
          </svg>
        </div>
        <div class="metric-info">
          <span class="metric-value">{{ metrics.bug_count }}</span>
          <span class="metric-label">故障数</span>
        </div>
        <div class="click-hint" v-if="metrics.bug_count > 0">点击查看详情</div>
      </div>

      <div class="metric-card">
        <div class="metric-icon rate-icon">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
            <path d="M12 2v4M12 18v4M4.93 4.93l2.83 2.83M16.24 16.24l2.83 2.83M2 12h4M18 12h4M4.93 19.07l2.83-2.83M16.24 7.76l2.83-2.83" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
          </svg>
        </div>
        <div class="metric-info">
          <span class="metric-value">{{ bugRate }}</span>
          <span class="metric-label">缺陷率</span>
        </div>
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
      width="100%"
      class="bug-detail-dialog"
      fullscreen
      @close="onBugDialogClose"
    >
      <div v-loading="loadingBugDetail" class="bug-detail-content">
        <div class="bug-detail-table" v-if="bugDetail">
          <el-table
            :data="bugDetail.developers"
            border
            stripe
            style="width: 100%"
          >
            <el-table-column prop="developer" label="开发" fixed width="120" />

            <el-table-column
              v-for="priority in bugDetail.priorities"
              :key="priority"
              :label="priority"
              align="center"
            >
              <el-table-column
                v-for="tag in bugDetail.tags"
                :key="tag"
                :label="tag"
                align="center"
                min-width="80"
              >
                <template #default="{ row }">
                  <span class="cell-count">
                    {{ getCellCount(row.developer, priority, tag) }}
                  </span>
                </template>
              </el-table-column>
            </el-table-column>

            <el-table-column label="合计" fixed="right" width="80" align="center">
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

          <div class="summary-row">
            <div class="summary-cell label-cell">合计</div>
            <div
              v-for="priority in bugDetail.priorities"
              :key="priority"
              class="summary-cell-group"
            >
              <div
                v-for="tag in bugDetail.tags"
                :key="tag"
                class="summary-cell clickable-total"
                :class="{ 'has-data': getColTotal(priority, tag) > 0 }"
                @click="openBugListByCol(priority, tag)"
              >
                <span class="cell-total">{{ getColTotal(priority, tag) }}</span>
              </div>
            </div>
            <div class="summary-cell label-cell">
              <span class="cell-total">{{ getAllTotal() }}</span>
            </div>
          </div>
        </div>

        <div class="bug-detail-chart" v-if="bugDetail && (priorityChartData.length > 0 || tagChartData.length > 0)">
          <div class="chart-item" v-if="priorityChartData.length > 0">
            <h4 class="chart-title">故障级别分布</h4>
            <div ref="priorityChartRef" class="chart-container"></div>
          </div>
          <div class="chart-item" v-if="tagChartData.length > 0">
            <h4 class="chart-title">故障原因分布</h4>
            <div ref="tagChartRef" class="chart-container"></div>
          </div>
        </div>
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
  </div>
</template>

<style scoped lang="scss">
.reports-page {
  max-width: 1280px;
}

// ── Page Header ───────────────────────────────────────────────
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
  font-size: 12px;
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
  padding: 24px;
  box-shadow: var(--shadow-xs);
  display: flex;
  align-items: center;
  gap: 20px;
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

.metric-icon {
  width: 56px;
  height: 56px;
  border-radius: 14px;
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

  &.rate-icon {
    background: #FFF7ED;
    color: #EA580C;
  }
}

.metric-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.metric-value {
  font-size: 32px;
  font-weight: 700;
  color: var(--ink-primary);
  font-family: 'Sora', sans-serif;
  letter-spacing: -0.02em;
  line-height: 1;
}

.metric-label {
  font-size: 13px;
  color: var(--ink-tertiary);
  font-weight: 500;
}

.click-hint {
  position: absolute;
  right: 24px;
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
.bug-detail-content {
  display: flex;
  gap: 24px;
  min-height: 400px;
}

.bug-detail-table {
  flex: 1;
  min-width: 0;
}

.bug-detail-chart {
  flex: 0 0 360px;
  display: flex;
  flex-direction: column;
  gap: 24px;
  align-items: center;
}

.chart-item {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.chart-title {
  font-size: 14px;
  font-weight: 600;
  color: var(--ink-primary);
  margin: 0 0 12px;
}

.chart-container {
  width: 360px;
  height: 360px;
}

.cell-count {
  font-weight: 500;
  color: var(--ink-primary);
}

.cell-total {
  font-weight: 700;
  color: var(--accent);
}

.clickable-total {
  cursor: pointer;
  padding: 4px 8px;
  border-radius: 4px;
  transition: background-color 0.2s;
  display: inline-block;

  &:hover {
    background-color: var(--bg-muted);
  }

  &.has-data {
    color: var(--accent);
    font-weight: 600;
  }
}

// ── Summary Row ───────────────────────────────────────────────
.summary-row {
  display: flex;
  align-items: center;
  border: 1px solid var(--border-color);
  border-top: none;
  background: var(--bg-surface);
  font-size: 13px;
}

.summary-cell-group {
  display: flex;
  flex: 1;
}

.summary-cell {
  flex: 1;
  padding: 12px 8px;
  text-align: center;
  border-right: 1px solid var(--border-color);
  display: flex;
  align-items: center;
  justify-content: center;

  &:last-child {
    border-right: none;
  }

  &.label-cell {
    font-weight: 600;
    color: var(--ink-primary);
    flex: 0 0 120px;
  }
}
</style>
