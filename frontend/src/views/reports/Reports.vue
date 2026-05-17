<script setup lang="ts">
import { ref, watch, onMounted, onBeforeUnmount, nextTick } from 'vue'
import { reportsApi, type ProjectOption, type ReopenBugItem, type SprintMetricsItem } from '@/api/reports'
import { ElMessage } from 'element-plus'
import * as echarts from 'echarts'
import BugDetailDialog from './BugDetailDialog.vue'

const projectMetrics = ref<SprintMetricsItem[]>([])
const loadingProjectMetrics = ref(false)

const selectedProjectForMetrics = ref<number | null>(null)
const loadingProjectsForMetrics = ref(false)

const storyChartFullscreen = ref(false)
const bugChartFullscreen = ref(false)
const reopenChartFullscreen = ref(false)
const devTimeFullscreen = ref(false)
const testTimeFullscreen = ref(false)

const storyChartRef = ref<HTMLElement | null>(null)
const bugChartRef = ref<HTMLElement | null>(null)
const reopenChartRef = ref<HTMLElement | null>(null)
const devTimeRef = ref<HTMLElement | null>(null)
const testTimeRef = ref<HTMLElement | null>(null)

let storyChartInstance: echarts.ECharts | null = null
let bugChartInstance: echarts.ECharts | null = null
let reopenChartInstance: echarts.ECharts | null = null
let devTimeChartInstance: echarts.ECharts | null = null
let testTimeChartInstance: echarts.ECharts | null = null

const bugDialogVisible = ref(false)
const currentSprintForBug = ref<number | null>(null)

function openBugDetailBySprint(sprintId: number) {
  currentSprintForBug.value = sprintId
  bugDialogVisible.value = true
}

function handleChartsResize() {
  storyChartInstance?.resize()
  bugChartInstance?.resize()
  reopenChartInstance?.resize()
  devTimeChartInstance?.resize()
  testTimeChartInstance?.resize()
}

async function loadProjectMetrics(projectId: number) {
  loadingProjectMetrics.value = true
  try {
    const res = await reportsApi.getProjectMetrics(projectId)
    projectMetrics.value = res
    await nextTick()
    renderAllCharts()
  } catch {
    ElMessage.error('加载项目指标数据失败')
  } finally {
    loadingProjectMetrics.value = false
  }
}

function renderAllCharts() {
  renderStoryChart()
  renderBugChart()
  renderReopenChart()
  renderDevTimeChart()
  renderTestTimeChart()
}

function renderStoryChart() {
  if (!storyChartRef.value) return
  if (projectMetrics.value.length === 0) {
    storyChartInstance?.clear()
    return
  }
  if (!storyChartInstance) {
    storyChartInstance = echarts.init(storyChartRef.value)
  }
  const xData = projectMetrics.value.map(s => s.sprint_name)
  const yData = projectMetrics.value.map(s => s.story_count)
  storyChartInstance.setOption({
    tooltip: { trigger: 'axis', backgroundColor: '#1A1A2E', borderColor: 'transparent', textStyle: { color: '#fff' }, formatter: (params: any) => `${params[0].name}: ${params[0].value}` },
    grid: { left: '3%', right: '4%', bottom: '3%', top: '15%', containLabel: true },
    xAxis: { type: 'category', data: xData, axisLabel: { fontSize: 12, color: '#666' } },
    yAxis: { type: 'value', axisLabel: { fontSize: 12, color: '#666' } },
    series: [{
      type: 'bar',
      data: yData,
      itemStyle: { color: '#6366F1', borderRadius: [4, 4, 0, 0] },
      barWidth: '50%',
    }],
    graphic: [{
      type: 'text',
      left: '3%',
      top: '3%',
      style: { text: '故事数', fontSize: 14, fontWeight: 600, fill: '#333' }
    }]
  })
  nextTick(() => {
    storyChartInstance?.resize()
  })
}

function renderBugChart() {
  if (!bugChartRef.value) return
  if (projectMetrics.value.length === 0) {
    bugChartInstance?.clear()
    return
  }
  if (!bugChartInstance) {
    bugChartInstance = echarts.init(bugChartRef.value)
  }
  const xData = projectMetrics.value.map(s => s.sprint_name)
  const yData = projectMetrics.value.map(s => ({ value: s.bug_count, sprintId: s.sprint_id }))
  bugChartInstance.setOption({
    tooltip: { trigger: 'axis', backgroundColor: '#1A1A2E', borderColor: 'transparent', textStyle: { color: '#fff' }, formatter: (params: any) => `${params[0].name}: ${params[0].value}` },
    grid: { left: '3%', right: '4%', bottom: '15%', top: '15%', containLabel: true },
    xAxis: { type: 'category', data: xData, axisLabel: { fontSize: 12, color: '#666', rotate: 45, interval: 0 } },
    yAxis: { type: 'value', axisLabel: { fontSize: 12, color: '#666' } },
    series: [{
      type: 'line',
      data: yData,
      smooth: true,
      lineStyle: { color: '#6366F1', width: 3 },
      itemStyle: { color: '#6366F1' },
      areaStyle: { color: { type: 'linear', x: 0, y: 0, x2: 0, y2: 1, colorStops: [{ offset: 0, color: 'rgba(99, 102, 241, 0.3)' }, { offset: 1, color: 'rgba(99, 102, 241, 0.05)' }] } },
    }],
    graphic: [{ type: 'text', left: '3%', top: '3%', style: { text: '故障数', fontSize: 14, fontWeight: 600, fill: '#333' } }]
  })
  bugChartInstance.off('click')
  bugChartInstance.on('click', (params: any) => {
    if (params.data?.sprintId && params.data.value > 0) {
      openBugDetailBySprint(params.data.sprintId)
    }
  })
  nextTick(() => {
    bugChartInstance?.resize()
  })
}

function renderReopenChart() {
  if (!reopenChartRef.value) return
  if (projectMetrics.value.length === 0) {
    reopenChartInstance?.clear()
    return
  }
  if (!reopenChartInstance) {
    reopenChartInstance = echarts.init(reopenChartRef.value)
  }
  const xData = projectMetrics.value.map(s => s.sprint_name)
  const yData = projectMetrics.value.map(s => ({ value: s.bug_reopen_count, sprintId: s.sprint_id }))
  reopenChartInstance.setOption({
    tooltip: { trigger: 'axis', backgroundColor: '#1A1A2E', borderColor: 'transparent', textStyle: { color: '#fff' }, formatter: (params: any) => `${params[0].name}: ${params[0].value}` },
    grid: { left: '3%', right: '4%', bottom: '15%', top: '15%', containLabel: true },
    xAxis: { type: 'category', data: xData, axisLabel: { fontSize: 12, color: '#666', rotate: 45, interval: 0 } },
    yAxis: { type: 'value', axisLabel: { fontSize: 12, color: '#666' } },
    series: [{
      type: 'line',
      data: yData,
      smooth: true,
      lineStyle: { color: '#EC4899', width: 3 },
      itemStyle: { color: '#EC4899' },
      areaStyle: { color: { type: 'linear', x: 0, y: 0, x2: 0, y2: 1, colorStops: [{ offset: 0, color: 'rgba(236, 72, 153, 0.3)' }, { offset: 1, color: 'rgba(236, 72, 153, 0.05)' }] } },
    }],
    graphic: [{ type: 'text', left: '3%', top: '3%', style: { text: '故障重开数', fontSize: 14, fontWeight: 600, fill: '#333' } }]
  })
  reopenChartInstance.off('click')
  reopenChartInstance.on('click', (params: any) => {
    if (params.data?.sprintId && params.data.value > 0) {
      openReopenBySprint(params.data.sprintId)
    }
  })
}

function renderDevTimeChart() {
  if (!devTimeRef.value) return
  if (projectMetrics.value.length === 0) {
    devTimeChartInstance?.clear()
    return
  }
  if (!devTimeChartInstance) {
    devTimeChartInstance = echarts.init(devTimeRef.value)
  }
  const xData = projectMetrics.value.map(s => s.sprint_name)
  const yData = projectMetrics.value.map(s => s.avg_dev_seconds > 0 ? parseFloat((s.avg_dev_seconds / 3600).toFixed(1)) : 0)
  devTimeChartInstance.setOption({
    tooltip: { trigger: 'axis', backgroundColor: '#1A1A2E', borderColor: 'transparent', formatter: (params: any) => `${params[0].name}: ${params[0].value}h`, textStyle: { color: '#fff' } },
    grid: { left: '3%', right: '4%', bottom: '15%', top: '15%', containLabel: true },
    xAxis: { type: 'category', data: xData, axisLabel: { fontSize: 12, color: '#666', rotate: 45, interval: 0 } },
    yAxis: { type: 'value', axisLabel: { fontSize: 12, color: '#666', formatter: '{value}h' } },
    series: [{
      type: 'bar',
      data: yData,
      itemStyle: { color: '#14B8A6', borderRadius: [4, 4, 0, 0] },
      barWidth: '50%',
    }],
    graphic: [{ type: 'text', left: '3%', top: '3%', style: { text: '故障平均Dev时长', fontSize: 14, fontWeight: 600, fill: '#333' } }]
  })
  nextTick(() => {
    devTimeChartInstance?.resize()
  })
}

function renderTestTimeChart() {
  if (!testTimeRef.value) return
  if (projectMetrics.value.length === 0) {
    testTimeChartInstance?.clear()
    return
  }
  if (!testTimeChartInstance) {
    testTimeChartInstance = echarts.init(testTimeRef.value)
  }
  const xData = projectMetrics.value.map(s => s.sprint_name)
  const yData = projectMetrics.value.map(s => s.avg_test_seconds > 0 ? parseFloat((s.avg_test_seconds / 3600).toFixed(1)) : 0)
  testTimeChartInstance.setOption({
    tooltip: { trigger: 'axis', backgroundColor: '#1A1A2E', borderColor: 'transparent', formatter: (params: any) => `${params[0].name}: ${params[0].value}h`, textStyle: { color: '#fff' } },
    grid: { left: '3%', right: '4%', bottom: '15%', top: '15%', containLabel: true },
    xAxis: { type: 'category', data: xData, axisLabel: { fontSize: 12, color: '#666', rotate: 45, interval: 0 } },
    yAxis: { type: 'value', axisLabel: { fontSize: 12, color: '#666', formatter: '{value}h' } },
    series: [{
      type: 'bar',
      data: yData,
      itemStyle: { color: '#F97316', borderRadius: [4, 4, 0, 0] },
      barWidth: '50%',
    }],
    graphic: [{ type: 'text', left: '3%', top: '3%', style: { text: '故障平均Test时长', fontSize: 14, fontWeight: 600, fill: '#333' } }]
  })
  nextTick(() => {
    testTimeChartInstance?.resize()
  })
}

function toggleFullscreen(type: 'story' | 'bug' | 'reopen' | 'dev' | 'test') {
  switch (type) {
    case 'story': storyChartFullscreen.value = !storyChartFullscreen.value; break
    case 'bug': bugChartFullscreen.value = !bugChartFullscreen.value; break
    case 'reopen': reopenChartFullscreen.value = !reopenChartFullscreen.value; break
    case 'dev': devTimeFullscreen.value = !devTimeFullscreen.value; break
    case 'test': testTimeFullscreen.value = !testTimeFullscreen.value; break
  }
  setTimeout(() => {
    storyChartInstance?.resize()
    bugChartInstance?.resize()
    reopenChartInstance?.resize()
    devTimeChartInstance?.resize()
    testTimeChartInstance?.resize()
  }, 100)
}

const reopenDialogVisible = ref(false)
const reopenBugs = ref<ReopenBugItem[]>([])
const loadingReopenBugs = ref(false)
const currentSprintForReopen = ref<number | null>(null)

async function openReopenBySprint(sprintId: number) {
  currentSprintForReopen.value = sprintId
  reopenDialogVisible.value = true
  loadingReopenBugs.value = true
  try {
    const res = await reportsApi.getReopenBugs(sprintId)
    reopenBugs.value = res
  } catch {
    ElMessage.error('加载故障重开列表失败')
  } finally {
    loadingReopenBugs.value = false
  }
}

const projects = ref<ProjectOption[]>([])
const loadingProjectsForMetrics = ref(false)

async function loadProjectsForMetrics() {
  loadingProjectsForMetrics.value = true
  try {
    const res = await reportsApi.getProjects()
    if (res.length > 0) {
      selectedProjectForMetrics.value = res[0].id
    }
  } catch {
    ElMessage.error('加载项目列表失败')
  } finally {
    loadingProjectsForMetrics.value = false
  }
}

watch(selectedProjectForMetrics, (newVal) => {
  if (newVal) {
    loadProjectMetrics(newVal)
  }
})

onMounted(() => {
  loadProjectsForMetrics()
})

onBeforeUnmount(() => {
  window.removeEventListener('resize', handleChartsResize)
  storyChartInstance?.dispose()
  bugChartInstance?.dispose()
  reopenChartInstance?.dispose()
  devTimeChartInstance?.dispose()
  testTimeChartInstance?.dispose()
})
</script>

<template>
  <div class="reports-page">
    <!-- Page header with filters -->
    <div class="page-header page-enter">
      <div class="filter-group">
        <div class="filter-item">
          <label class="filter-label">项目</label>
          <el-select
            v-model="selectedProjectForMetrics"
            placeholder="请选择项目"
            :loading="loadingProjectsForMetrics"
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
      </div>
    </div>

    <!-- Charts Grid -->
    <div class="metrics-grid page-enter" style="animation-delay: 0.06s">
      <div class="metrics-row">
        <!-- 故事数 - 柱状图 -->
        <div :class="['metric-card', { 'metric-card--fullscreen': storyChartFullscreen }]">
          <div class="metric-card-header">
            <span class="metric-card-title">故事数</span>
            <el-button
              :icon="storyChartFullscreen ? 'Close' : 'FullScreen'"
              circle
              size="small"
              @click="toggleFullscreen('story')"
            />
          </div>
          <div v-loading="loadingProjectMetrics" element-loading-text="加载中..." class="metric-card-body">
            <div ref="storyChartRef" class="metric-container"></div>
            <div v-if="projectMetrics.length === 0 && !loadingProjectMetrics" class="metric-empty">暂无数据</div>
          </div>
        </div>

        <!-- 故障数 - 折线图 -->
        <div :class="['metric-card', { 'metric-card--fullscreen': bugChartFullscreen }]">
          <div class="metric-card-header">
            <span class="metric-card-title">故障数</span>
            <div class="metric-header-actions">
              <el-button
                :icon="bugChartFullscreen ? 'Close' : 'FullScreen'"
                circle
                size="small"
                @click="toggleFullscreen('bug')"
              />
            </div>
          </div>
          <div v-loading="loadingProjectMetrics" element-loading-text="加载中..." class="metric-card-body">
            <div ref="bugChartRef" class="metric-container"></div>
            <div v-if="projectMetrics.length === 0 && !loadingProjectMetrics" class="metric-empty">暂无数据</div>
          </div>
        </div>
      </div>

      <div class="metrics-row">
        <!-- 故障重开数 - 折线图 -->
        <div :class="['metric-card', { 'metric-card--fullscreen': reopenChartFullscreen }]">
          <div class="metric-card-header">
            <span class="metric-card-title">故障重开数</span>
            <div class="metric-header-actions">
              <el-button
                :icon="reopenChartFullscreen ? 'Close' : 'FullScreen'"
                circle
                size="small"
                @click="toggleFullscreen('reopen')"
              />
            </div>
          </div>
          <div v-loading="loadingProjectMetrics" element-loading-text="加载中..." class="metric-card-body">
            <div ref="reopenChartRef" class="metric-container"></div>
            <div v-if="projectMetrics.length === 0 && !loadingProjectMetrics" class="metric-empty">暂无数据</div>
          </div>
        </div>

        <!-- 故障平均Dev时长 - 柱状图 -->
        <div :class="['metric-card', { 'metric-card--fullscreen': devTimeFullscreen }]">
          <div class="metric-card-header">
            <span class="metric-card-title">故障平均Dev时长</span>
            <div class="metric-header-actions">
              <el-button
                :icon="devTimeFullscreen ? 'Close' : 'FullScreen'"
                circle
                size="small"
                @click="toggleFullscreen('dev')"
              />
            </div>
          </div>
          <div v-loading="loadingProjectMetrics" element-loading-text="加载中..." class="metric-card-body">
            <div ref="devTimeRef" class="metric-container"></div>
            <div v-if="projectMetrics.length === 0 && !loadingProjectMetrics" class="metric-empty">暂无数据</div>
          </div>
        </div>
      </div>

      <div class="metrics-row">
        <!-- 故障平均Test时长 - 柱状图 -->
        <div :class="['metric-card', { 'metric-card--fullscreen': testTimeFullscreen }]">
          <div class="metric-card-header">
            <span class="metric-card-title">故障平均Test时长</span>
            <div class="metric-header-actions">
              <el-button
                :icon="testTimeFullscreen ? 'Close' : 'FullScreen'"
                circle
                size="small"
                @click="toggleFullscreen('test')"
              />
            </div>
          </div>
          <div v-loading="loadingProjectMetrics" element-loading-text="加载中..." class="metric-card-body">
            <div ref="testTimeRef" class="metric-container"></div>
            <div v-if="projectMetrics.length === 0 && !loadingProjectMetrics" class="metric-empty">暂无数据</div>
          </div>
        </div>
      </div>
    </div>

    <!-- Bug Detail Dialog -->
    <BugDetailDialog
      v-model:visible="bugDialogVisible"
      :sprint-id="currentSprintForBug"
      @charts-resize="handleChartsResize"
    />

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
  width: 100%;
  min-height: 100%;
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
  letter-spacing: 0.05em;
}

.filter-select {
  width: 220px;
}

// ── Charts Grid ──────────────────────────────────────────────
.charts-grid {
  display: block;
  width: 100%;
  margin-bottom: 24px;
}

.charts-row {
  display: flex;
  gap: 18px;
  width: 100%;

  .chart-card {
    flex: 1;
    min-width: 0;
  }

  @media (max-width: 1200px) {
    flex-direction: column;
    
    .chart-card {
      width: 100%;
    }
  }
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
