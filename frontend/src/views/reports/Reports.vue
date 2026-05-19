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

const storyChartRef = ref<HTMLElement | null>(null)
const bugChartRef = ref<HTMLElement | null>(null)
const reopenChartRef = ref<HTMLElement | null>(null)
const timeChartRef = ref<HTMLElement | null>(null)

let storyChartInstance: echarts.ECharts | null = null
let bugChartInstance: echarts.ECharts | null = null
let reopenChartInstance: echarts.ECharts | null = null
let timeChartInstance: echarts.ECharts | null = null

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
  timeChartInstance?.resize()
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
  renderTimeChart()
}

const tooltipFormatter = (params: any) => {
  const filtered = Array.isArray(params) ? params.filter((p: any) => !p.seriesName.includes('趋势')) : [params]
  let html = `<div style="font-size:13px">${params[0]?.axisValue || ''}</div>`
  for (const p of filtered) {
    html += `<div style="display:flex;align-items:center;gap:4px;margin-top:4px">
      <span style="display:inline-block;width:8px;height:8px;border-radius:50%;background:${p.color};flex-shrink:0"></span>
      <span>${p.seriesName}: ${p.value}</span>
    </div>`
  }
  return html
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
    tooltip: { trigger: 'axis', backgroundColor: '#1A1A2E', borderColor: 'transparent', textStyle: { color: '#fff' }, formatter: tooltipFormatter },
    legend: { show: false },
    grid: { left: '3%', right: '4%', bottom: '3%', top: '12%', containLabel: true },
    xAxis: { type: 'category', data: xData, axisLabel: { fontSize: 12, color: '#666' } },
    yAxis: { type: 'value', minInterval: 1, max: (value: any) => value.max < 5 ? 5 : undefined, axisLabel: { fontSize: 12, color: '#666' } },
    series: [{
      name: '故事数',
      type: 'bar',
      data: yData,
      itemStyle: { color: 'rgba(99, 102, 241, 0.35)', borderRadius: [4, 4, 0, 0] },
      barWidth: '30%',
      label: { show: true, position: 'top', color: '#666', fontSize: 16, formatter: (p: any) => p.value > 0 ? p.value : '' },
    }, {
      name: '故事趋势',
      type: 'line',
      data: yData,
      smooth: true,
      lineStyle: { color: '#6366F1', width: 3 },
      itemStyle: { color: '#6366F1' },
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
    tooltip: { trigger: 'axis', backgroundColor: '#1A1A2E', borderColor: 'transparent', textStyle: { color: '#fff' }, formatter: tooltipFormatter },
    legend: { show: false },
    grid: { left: '3%', right: '4%', bottom: '3%', top: '12%', containLabel: true },
    xAxis: { type: 'category', data: xData, axisLabel: { fontSize: 12, color: '#666' } },
    yAxis: { type: 'value', minInterval: 1, max: (value: any) => value.max < 5 ? 5 : undefined, axisLabel: { fontSize: 12, color: '#666' } },
    series: [{
      name: '故障趋势',
      type: 'line',
      data: yData,
      smooth: true,
      lineStyle: { color: '#F97316', width: 3 },
      itemStyle: { color: '#F97316' },
    }, {
      name: '故障数',
      type: 'bar',
      data: yData,
      itemStyle: { color: 'rgba(249, 115, 22, 0.35)', borderRadius: [4, 4, 0, 0] },
      barWidth: '30%',
      label: { show: true, position: 'top', color: '#666', fontSize: 16, formatter: (p: any) => p.value > 0 ? p.value : '' },
    }]
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
    tooltip: { trigger: 'axis', backgroundColor: '#1A1A2E', borderColor: 'transparent', textStyle: { color: '#fff' }, formatter: tooltipFormatter },
    legend: { show: false },
    grid: { left: '3%', right: '4%', bottom: '3%', top: '12%', containLabel: true },
    xAxis: { type: 'category', data: xData, axisLabel: { fontSize: 12, color: '#666' } },
    yAxis: { type: 'value', minInterval: 1, max: (value: any) => value.max < 5 ? 5 : undefined, axisLabel: { fontSize: 12, color: '#666' } },
    series: [{
      name: '故障重开数',
      type: 'bar',
      data: yData,
      itemStyle: { color: 'rgba(236, 72, 153, 0.35)', borderRadius: [4, 4, 0, 0] },
      barWidth: '30%',
      label: { show: true, position: 'top', color: '#666', fontSize: 16, formatter: (p: any) => p.value > 0 ? p.value : '' },
    }, {
      name: '重开趋势',
      type: 'line',
      data: yData,
      smooth: true,
      lineStyle: { color: '#EC4899', width: 3 },
      itemStyle: { color: '#EC4899' },
    }]
  })
  reopenChartInstance.off('click')
  reopenChartInstance.on('click', (params: any) => {
    if (params.data?.sprintId && params.data.value > 0) {
      openReopenBySprint(params.data.sprintId)
    }
  })
  nextTick(() => {
    reopenChartInstance?.resize()
  })
}

function renderTimeChart() {
  if (!timeChartRef.value) return
  if (projectMetrics.value.length === 0) {
    timeChartInstance?.clear()
    return
  }
  if (!timeChartInstance) {
    timeChartInstance = echarts.init(timeChartRef.value)
  }
  const xData = projectMetrics.value.map(s => s.sprint_name)
  const devData = projectMetrics.value.map(s => s.avg_dev_seconds > 0 ? parseFloat((s.avg_dev_seconds / 3600).toFixed(1)) : 0)
  const testData = projectMetrics.value.map(s => s.avg_test_seconds > 0 ? parseFloat((s.avg_test_seconds / 3600).toFixed(1)) : 0)
  const totalData = devData.map((v, i) => parseFloat((v + testData[i]).toFixed(1)))
  timeChartInstance.setOption({
    tooltip: { trigger: 'axis', backgroundColor: '#1A1A2E', borderColor: 'transparent', textStyle: { color: '#fff' }, formatter: tooltipFormatter },
    legend: { show: false },
    grid: { left: '3%', right: '4%', bottom: '3%', top: '12%', containLabel: true },
    xAxis: { type: 'category', data: xData, axisLabel: { fontSize: 12, color: '#666' } },
    yAxis: { type: 'value', axisLabel: { fontSize: 12, color: '#666', formatter: '{value}h' } },
    series: [
      {
        name: 'Dev',
        type: 'bar',
        stack: 'time',
        data: devData,
        itemStyle: { color: 'rgba(20, 184, 166, 0.35)', borderRadius: [0, 0, 0, 0] },
        barWidth: '30%',
      },
      {
        name: 'Test',
        type: 'bar',
        stack: 'time',
        data: testData,
        itemStyle: { color: 'rgba(249, 115, 22, 0.35)', borderRadius: [4, 4, 0, 0] },
        label: { show: true, position: 'top', color: '#666', fontSize: 16, formatter: (p: any) => totalData[p.dataIndex] > 0 ? totalData[p.dataIndex] + 'h' : '' },
      },
      {
        name: 'Dev趋势',
        type: 'line',
        data: devData,
        smooth: true,
        lineStyle: { color: '#14B8A6', width: 3 },
        itemStyle: { color: '#14B8A6' },
      },
      {
        name: 'Test趋势',
        type: 'line',
        data: testData,
        smooth: true,
        lineStyle: { color: '#F97316', width: 3 },
        itemStyle: { color: '#F97316' },
      },
    ]
  })
  nextTick(() => {
    timeChartInstance?.resize()
  })
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

async function loadProjectsForMetrics() {
  loadingProjectsForMetrics.value = true
  try {
    const res = await reportsApi.getProjects()
    projects.value = res
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
  window.addEventListener('resize', handleChartsResize)
})

onBeforeUnmount(() => {
  window.removeEventListener('resize', handleChartsResize)
  storyChartInstance?.dispose()
  bugChartInstance?.dispose()
  reopenChartInstance?.dispose()
  timeChartInstance?.dispose()
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
        <div class="metric-card">
          <div class="metric-card-header">
            <span class="metric-card-title">故事数</span>
            <span class="chart-legend"><i class="legend-dot" style="background:#6366F1"></i>故事数</span>
          </div>
          <div v-loading="loadingProjectMetrics" element-loading-text="加载中..." class="metric-card-body">
            <div ref="storyChartRef" class="metric-container"></div>
            <div v-if="projectMetrics.length === 0 && !loadingProjectMetrics" class="metric-empty">暂无数据</div>
          </div>
        </div>

        <!-- 故障数 - 折线图 -->
        <div class="metric-card">
          <div class="metric-card-header">
            <span class="metric-card-title">故障数</span>
            <span class="chart-legend"><i class="legend-dot" style="background:#F97316"></i>故障数</span>
          </div>
          <div v-loading="loadingProjectMetrics" element-loading-text="加载中..." class="metric-card-body">
            <div ref="bugChartRef" class="metric-container"></div>
            <div v-if="projectMetrics.length === 0 && !loadingProjectMetrics" class="metric-empty">暂无数据</div>
          </div>
        </div>
      </div>

      <div class="metrics-row">
        <!-- 故障重开数 - 柱状图 -->
        <div class="metric-card">
          <div class="metric-card-header">
            <span class="metric-card-title">故障重开数</span>
            <span class="chart-legend"><i class="legend-dot" style="background:#EC4899"></i>故障重开数</span>
          </div>
          <div v-loading="loadingProjectMetrics" element-loading-text="加载中..." class="metric-card-body">
            <div ref="reopenChartRef" class="metric-container"></div>
            <div v-if="projectMetrics.length === 0 && !loadingProjectMetrics" class="metric-empty">暂无数据</div>
          </div>
        </div>

        <!-- 故障平均时长 - 折线图 -->
        <div class="metric-card">
          <div class="metric-card-header">
            <span class="metric-card-title">故障平均时长</span>
            <span class="chart-legend"><i class="legend-dot" style="background:#14B8A6"></i>Dev</span>
            <span class="chart-legend"><i class="legend-dot" style="background:#F97316"></i>Test</span>
          </div>
          <div v-loading="loadingProjectMetrics" element-loading-text="加载中..." class="metric-card-body">
            <div ref="timeChartRef" class="metric-container"></div>
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
  height: 100%;
  display: flex;
  flex-direction: column;
}

// ── Page Header ──────────────────────────────────────────────
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  margin-bottom: 24px;
  flex-shrink: 0;
}

.filter-group {
  display: flex;
  gap: 16px;
}

.filter-item {
  display: flex;           /* 开启 Flex 布局，让子元素横向排列 */
  align-items: center;     /* 让 label 和下拉框在垂直方向居中对齐 */
  gap: 12px;               /* 设置 label 和下拉框之间的间距（比用 margin 更方便） */
}

.filter-label {
  font-weight: 600;
  color: var(--ink-secondary);
  letter-spacing: 0.05em;
  white-space: nowrap; 
  flex-shrink: 0;
  margin-left: 20px;
}

.filter-select {
  width: 220px;
}

// ── Metrics Grid ──────────────────────────────────────────────
.metrics-grid {
  flex: 1;
  display: flex;
  flex-direction: column;
  margin-bottom: 24px;
}

.metrics-row {
  display: flex;
  gap: 18px;
  flex: 1;

  & + & {
    margin-top: 18px;
  }

  @media (max-width: 1200px) {
    flex-direction: column;
  }
}

.metric-card {
  flex: 1;
  min-width: 0;
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
}

.metric-card-header {
  display: flex;
  align-items: center;
  gap: 12px;
}

.metric-card-title {
  font-size: 16px;
  font-weight: 600;
  color: var(--ink-primary);
  letter-spacing: -0.01em;
}

.chart-legend {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  font-size: 14px;
  color: #666;
}

.legend-dot {
  display: inline-block;
  width: 8px;
  height: 8px;
  border-radius: 50%;
  flex-shrink: 0;
}

.metric-card-body {
  flex: 1;
  min-height: 0;
  position: relative;
}

.metric-container {
  width: 100%;
  height: 100%;
  min-height: 250px;
}

.metric-empty {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 250px;
  font-size: 14px;
  color: var(--ink-tertiary);
}
</style>