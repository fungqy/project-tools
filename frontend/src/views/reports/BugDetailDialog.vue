<script setup lang="ts">
import { ref, computed, watch, nextTick } from 'vue'
import { reportsApi, type BugDetailResponse, type BugListItem } from '@/api/reports'
import { ElMessage } from 'element-plus'
import * as echarts from 'echarts'

const props = defineProps<{
  visible: boolean
  sprintId: number | null
}>()

const emit = defineEmits<{
  'update:visible': [value: boolean]
  'charts-resize': []
}>()

const bugDetail = ref<BugDetailResponse | null>(null)
const loadingBugDetail = ref(false)

async function loadBugDetails() {
  if (!props.sprintId) return
  loadingBugDetail.value = true
  try {
    const res = await reportsApi.getBugDetails(props.sprintId)
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

const priorityChartRef = ref<HTMLElement | null>(null)
const tagChartRef = ref<HTMLElement | null>(null)
const developerChartRef = ref<HTMLElement | null>(null)
let chartInstance: echarts.ECharts | null = null
let tagChartInstance: echarts.ECharts | null = null
let developerChartInstance: echarts.ECharts | null = null

function handleChartsResize() {
  chartInstance?.resize()
  tagChartInstance?.resize()
  developerChartInstance?.resize()
  emit('charts-resize')
}

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

function getRowTotal(developer: string): number {
  if (!bugDetail.value) return 0
  const devRow = bugDetail.value.developers.find(d => d.developer === developer)
  return devRow?.total ?? 0
}

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
      formatter: '{b}: {c} ({d}%)' 
    },
    legend: { show: false },
    series: [{
      type: 'pie', 
      radius: ['55%', '80%'], 
      center: ['50%', '50%'], 
      avoidLabelOverlap: true,
      itemStyle: { borderRadius: 8, borderColor: '#F7F6F3', borderWidth: 3 },
      label: { show: false },
      emphasis: { scale: true, scaleSize: 8, label: { show: false } },
      data: priorityChartData.value.map(item => ({ 
        name: item.name, 
        value: item.value, 
        itemStyle: { color: PRIORITY_COLORS[item.name] || '#9CA3AF' } 
      })),
    }],
    graphic: [{ 
      type: 'text', 
      left: 'center', 
      top: '40%', 
      style: { 
        text: `${total}`, 
        fontSize: 80, 
        fontWeight: 700, 
        fill: '#1A1A2E', 
        textAlign: 'center', 
        fontFamily: 'Sora, sans-serif' 
      } 
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
    tooltip: { trigger: 'item', backgroundColor: '#1A1A2E', borderColor: 'transparent', padding: [10, 16], textStyle: { color: '#fff', fontSize: 20 }, formatter: '{b}: {c} ({d}%)' },
    legend: { show: false },
    series: [{
      type: 'pie', radius: ['55%', '80%'], center: ['50%', '50%'], avoidLabelOverlap: true,
      itemStyle: { borderRadius: 8, borderColor: '#F7F6F3', borderWidth: 3 },
      label: { show: false },
      emphasis: { scale: true, scaleSize: 8, label: { show: false } },
      data: tagChartData.value.map((item, idx) => ({ name: item.name, value: item.value, itemStyle: { color: TAG_COLORS[idx % TAG_COLORS.length] } })),
    }],
    graphic: [{ type: 'text', left: 'center', top: '40%', style: { text: `${total}`, fontSize: 80, fontWeight: 700, fill: '#1A1A2E', textAlign: 'center', fontFamily: 'Sora, sans-serif' } }],
  })
}

const developerChartData = computed(() => {
  if (!bugDetail.value) return []
  return bugDetail.value.developers.map((dev) => ({ name: dev.developer, value: getRowTotal(dev.developer) })).filter(item => item.value > 0)
})

function renderDeveloperChart() {
  if (!developerChartRef.value || developerChartData.value.length === 0) return
  if (!developerChartInstance) {
    developerChartInstance = echarts.init(developerChartRef.value)
  }
  const total = developerChartData.value.reduce((sum, item) => sum + item.value, 0)
  developerChartInstance.setOption({
    tooltip: { trigger: 'item', backgroundColor: '#1A1A2E', borderColor: 'transparent', padding: [10, 16], textStyle: { color: '#fff', fontSize: 20 }, formatter: '{b}: {c} ({d}%)' },
    legend: { show: false },
    series: [{
      type: 'pie', radius: ['55%', '80%'], center: ['50%', '50%'], avoidLabelOverlap: true,
      itemStyle: { borderRadius: 8, borderColor: '#F7F6F3', borderWidth: 3 },
      label: { show: false },
      emphasis: { scale: true, scaleSize: 8, label: { show: false } },
      data: developerChartData.value.map((item, idx) => ({ name: item.name, value: item.value, itemStyle: { color: DEVELOPER_COLORS[idx % DEVELOPER_COLORS.length] } })),
    }],
    graphic: [{ type: 'text', left: 'center', top: '40%', style: { text: `${total}`, fontSize: 80, fontWeight: 700, fill: '#1A1A2E', textAlign: 'center', fontFamily: 'Sora, sans-serif' } }],
  })
}

function onBugDialogClose() {
  window.removeEventListener('resize', handleChartsResize)
  if (chartInstance) { chartInstance.dispose(); chartInstance = null }
  if (tagChartInstance) { tagChartInstance.dispose(); tagChartInstance = null }
  if (developerChartInstance) { developerChartInstance.dispose(); developerChartInstance = null }
  bugDetail.value = null
}

const currentDeveloper = ref('')
const currentPriority = ref('')
const currentTag = ref('')

const summaryRow = computed(() => {
  if (!bugDetail.value) return []
  const row: Record<string, string | number> = { developer: '合计' }
  for (const priority of bugDetail.value.priorities) {
    for (const tag of bugDetail.value.tags) {
      row[`${priority}-${tag}`] = getTableColumnTotal(priority, tag)
    }
  }
  row['total'] = bugDetail.value.developers.reduce((sum, d) => sum + d.total, 0)
  return [row]
})

const bugListDialogVisible = ref(false)
const bugList = ref<BugListItem[]>([])
const loadingBugList = ref(false)
const bugListTitle = ref('')

async function openBugList(developer: string, priority: string, tag: string) {
  if (!props.sprintId) return
  currentDeveloper.value = developer
  currentPriority.value = priority
  currentTag.value = tag
  bugListTitle.value = `${developer} - ${priority} - ${tag}`
  bugListDialogVisible.value = true
  loadingBugList.value = true
  try {
    const res = await reportsApi.getBugList(props.sprintId, priority, tag, developer)
    bugList.value = res
  } catch {
    ElMessage.error('加载故障明细失败')
  } finally {
    loadingBugList.value = false
  }
}

async function openBugListByRow(developer: string) {
  if (!props.sprintId || !bugDetail.value) return
  const allTags = bugDetail.value.tags
  const allPriorities = bugDetail.value.priorities
  bugListTitle.value = `${developer} - 全部`
  bugListDialogVisible.value = true
  loadingBugList.value = true
  try {
    const promises = []
    for (const priority of allPriorities) {
      for (const tag of allTags) {
        promises.push(reportsApi.getBugList(props.sprintId, priority, tag, developer))
      }
    }
    const results = await Promise.all(promises)
    const allItems: BugListItem[] = results.flat()
    allItems.forEach((item, idx) => item.index = idx + 1)
    bugList.value = allItems
  } catch {
    ElMessage.error('加载故障明细失败')
  } finally {
    loadingBugList.value = false
  }
}

async function openBugListBySummary(priority: string, tag: string) {
  if (!props.sprintId) return
  bugListTitle.value = `合计 - ${priority} - ${tag}`
  bugListDialogVisible.value = true
  loadingBugList.value = true
  try {
    const res = await reportsApi.getBugList(props.sprintId, priority, tag)
    res.forEach((item, idx) => item.index = idx + 1)
    bugList.value = res
  } catch {
    ElMessage.error('加载故障明细失败')
  } finally {
    loadingBugList.value = false
  }
}

function onSummaryCellClick(priority: string, tag: string) {
  openBugListBySummary(priority, tag)
}

async function openBugListAll() {
  if (!props.sprintId || !bugDetail.value) return
  const allTags = bugDetail.value.tags
  const allPriorities = bugDetail.value.priorities
  const allDevelopers = bugDetail.value.developers.map(d => d.developer)
  bugListTitle.value = `全部故障`
  bugListDialogVisible.value = true
  loadingBugList.value = true
  try {
    const promises = []
    for (const developer of allDevelopers) {
      for (const priority of allPriorities) {
        for (const tag of allTags) {
          promises.push(reportsApi.getBugList(props.sprintId, priority, tag, developer))
        }
      }
    }
    const results = await Promise.all(promises)
    const allItems: BugListItem[] = results.flat()
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

function getTableColumnTotal(priority: string, tag: string): number {
  if (!bugDetail.value) return 0
  let total = 0
  for (const dev of bugDetail.value.developers) {
    total += getCellCount(dev.developer, priority, tag)
  }
  return total
}

const bugDetailFullscreen = ref(false)

function toggleBugDetailFullscreen() {
  bugDetailFullscreen.value = !bugDetailFullscreen.value
}

watch(() => props.visible, (val) => {
  if (val) {
    window.addEventListener('resize', handleChartsResize)
    loadBugDetails()
  } else {
    onBugDialogClose()
  }
})
</script>

<template>
  <el-dialog
    :model-value="visible"
    title="故障分布统计"
    width="95%"
    class="bug-detail-dialog"
    fullscreen
    align-center
    @update:model-value="emit('update:visible', $event)"
  >
    <div v-loading="loadingBugDetail" class="bug-detail-content">
      <template v-if="bugDetail">
      <div class="charts-row" v-if="priorityChartData.length > 0 || tagChartData.length > 0 || developerChartData.length > 0">
        <div class="chart-card" v-if="priorityChartData.length > 0">
          <div class="chart-main">
            <span class="chart-card-title">级别分布</span>
            <div class="chart-body">
              <div ref="priorityChartRef" class="chart-container"></div>
            </div>
          </div>
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

        <div class="chart-card" v-if="tagChartData.length > 0">
          <div class="chart-main">
            <span class="chart-card-title">原因分布</span>
            <div class="chart-body">
              <div ref="tagChartRef" class="chart-container"></div>
            </div>
          </div>
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

        <div class="chart-card" v-if="developerChartData.length > 0">
          <div class="chart-main">
            <span class="chart-card-title">人员分布</span>
            <div class="chart-body">
              <div ref="developerChartRef" class="chart-container"></div>
            </div>
          </div>
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
      </div>

      <div class="table-section">
        <div v-if="bugDetailFullscreen" class="fullscreen-header">
          <h3 class="fullscreen-title">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M3 9h18M3 15h18M9 3v18M15 3v18"/></svg>
            分布明细
          </h3>
          <el-button
            icon="Close"
            circle
            size="small"
            @click="toggleBugDetailFullscreen"
          />
        </div>
        <div :class="['table-container', { 'table-container--fullscreen': bugDetailFullscreen }]">
          <div v-if="!bugDetailFullscreen" class="section-title-row">
            <h3 class="section-title">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M3 9h18M3 15h18M9 3v18M15 3v18"/></svg>
              分布明细
            </h3>
            <el-button
              icon="FullScreen"
              circle
              size="small"
              @click="toggleBugDetailFullscreen"
            />
          </div>
          <el-table
            :data="bugDetail.developers"
            border
            stripe
            style="width: 100%"
            table-layout="fixed"
            :class="['bug-table', { 'bug-table--fullscreen': bugDetailFullscreen }]"
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
                  @click="getCellCount(row.developer, priority, tag) > 0 && openBugList(row.developer, priority, tag)"
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
                {{ row.total }}
              </span>
            </template>
          </el-table-column>
          </el-table>

          <el-table
            :data="summaryRow"
            border
            stripe
            style="width: 100%; margin-top: 0;"
            table-layout="fixed"
            :show-header="false"
            :class="['bug-table', 'summary-table', { 'bug-table--fullscreen': bugDetailFullscreen }]"
          >
          <el-table-column prop="developer" fixed width="160" class-name="summary-cell">
            <template #default>
              <span class="cell-summary">合计</span>
            </template>
          </el-table-column>

          <el-table-column
            v-for="priority in bugDetail.priorities"
            :key="'summary-' + priority"
            :label="priority"
            align="center"
          >
            <el-table-column
              v-for="tag in bugDetail.tags"
              :key="'summary-' + priority + '-' + tag"
              :label="tag"
              align="center"
              min-width="90"
            >
              <template #default="{ row }">
                <span
                  class="cell-summary"
                  :class="{ 'clickable-total': row[`${priority}-${tag}`] > 0 }"
                  @click="row[`${priority}-${tag}`] > 0 && onSummaryCellClick(priority, tag)"
                >
                  {{ row[`${priority}-${tag}`] || '—' }}
                </span>
              </template>
            </el-table-column>
          </el-table-column>

          <el-table-column fixed="right" width="90" align="center" class-name="total-col">
            <template #default="{ row }">
              <span class="cell-summary clickable-total" @click="openBugListAll()">
                {{ row.total }}
              </span>
            </template>
          </el-table-column>
          </el-table>
        </div>
      </div>
      </template>
      <div v-else-if="!loadingBugDetail" class="empty-dialog">
        <el-empty description="暂无故障数据" />
      </div>
    </div>

    <el-dialog
      v-model="bugListDialogVisible"
      :title="bugListTitle"
      width="1300px"
      class="bug-list-dialog"
      append-to-body
    >
      <div v-loading="loadingBugList">
        <el-table
          v-if="bugList.length > 0"
          :data="bugList"
          border
          stripe
          style="width: 100%"
        >
          <el-table-column prop="index" label="序号" width="85" align="center" />
          <el-table-column prop="issue_key" label="编号" width="130" />
          <el-table-column prop="issue_name" label="名称" min-width="180" show-overflow-tooltip />
          <el-table-column prop="developer" label="开发" width="100" />
          <el-table-column prop="reason_analysis" label="原因及分析" width="120" />
          <el-table-column prop="priority" label="级别" width="90" align="center">
            <template #default="{ row }">
              <span
                class="priority-tag"
                :style="{ color: PRIORITY_COLORS[row.priority] || '#6B7280' }"
              >{{ row.priority }}</span>
            </template>
          </el-table-column>
          <el-table-column prop="tag" label="标签" width="100" align="center" />
          <el-table-column prop="is_typical" label="是否典型" width="90" align="center" />
          <el-table-column prop="source" label="来源" width="80" align="center" />
        </el-table>
        <el-empty v-else description="暂无数据" />
      </div>
    </el-dialog>
  </el-dialog>
</template>

<style scoped lang="scss">
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

.chart-card {
  background: var(--bg-surface);
  border-radius: var(--radius-md);
  padding: 16px 20px;
  box-shadow: var(--shadow-sm);
  border: 1px solid var(--bg-muted);
  display: flex;
  flex-direction: row;
  gap: 16px;
  min-height: 280px;
  transition: box-shadow 0.2s ease, transform 0.2s ease;
  width: 100%;
  box-sizing: border-box;

  &:hover {
    box-shadow: var(--shadow-md);
    transform: translateY(-2px);
  }

  .chart-main {
    flex: 1;
    min-width: 0;
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  .chart-card-title {
    font-size: 18px;
    font-weight: 500;
    color: var(--ink-primary);
    font-family: 'Sora', sans-serif;
    letter-spacing: -0.01em;
    flex-shrink: 0;
  }

  .chart-body {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    min-height: 0;
    width: 100%;
  }

  .chart-container {
    width: 100%;
    height: 220px;
  }

  .chart-legend {
    display: flex;
    flex-direction: column;
    gap: 6px;
    width: 160px;
    flex-shrink: 0;
    overflow-y: auto;
  }
}

.legend-item {
  display: flex;
  align-items: center;
  justify-content: center;
  flex: 1;
  color: var(--ink-tertiary);
  font-size: 14px;
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

.table-section {
  flex: 1;
  min-width: 0;
  margin-top: 24px;
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

  :deep(.el-table-column--selection) {
    .cell {
      padding: 0;
    }
  }
}

.summary-table {
  border-radius: 0;
  box-shadow: none;
  border-top: none;

  :deep(.el-table__row td) {
    background: var(--bg-muted) !important;
    padding: 10px 8px;
  }
}

.summary-cell {
  background: var(--bg-muted) !important;
}

.section-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 18px;
  font-weight: 500;
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

.section-title-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 14px;
  padding-bottom: 10px;
  border-bottom: 1px solid var(--bg-muted);

  .section-title {
    margin: 0;
    padding: 0;
    border: none;
  }
}

.fullscreen-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 10000;
  padding: 12px 20px;
  background: var(--bg-surface);
  border-bottom: 1px solid var(--bg-muted);
  box-shadow: var(--shadow-sm);
}

.fullscreen-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 18px;
  font-weight: 600;
  color: var(--ink-primary);
  font-family: 'Sora', sans-serif;
  margin: 0;

  svg {
    color: var(--accent);
    flex-shrink: 0;
  }
}

.table-container--fullscreen {
  position: fixed;
  top: 60px;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 9999;
  background: var(--bg-base);
  padding: 20px;
  overflow: auto;
}

.bug-table--fullscreen {
  :deep(.el-table__header th) {
    font-size: 16px;
    padding: 8px;
  }

  :deep(.el-table__row td) {
    font-size: 16px;
    padding: 8px;
  }

  :deep(.el-table__footer td) {
    font-size: 16px;
    padding: 10px 8px;
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
  font-size: 18px;
}

.clickable-total {
  cursor: pointer;
  padding: 3px 8px;
  border-radius: 4px;
  transition: background-color 0.2s;
  display: inline-block;

  &:hover {
    background-color: var(--accent-soft);
  }
}

.cell-summary {
  font-weight: 700;
  color: var(--accent);
  font-size: 18px;
  cursor: pointer;
  padding: 3px 8px;
  border-radius: 4px;
  transition: color 0.15s, background-color 0.15s;
  display: inline-block;
  font-family: 'Sora', sans-serif;

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
</style>

<style lang="scss">
.bug-list-dialog {
  .el-dialog__header {
    padding: 16px 20px;
    border-bottom: 1px solid var(--bg-muted);
    margin-right: 0;
  }

  .el-dialog__title {
    font-family: 'Sora', sans-serif;
    font-weight: 600;
    font-size: 15px;
    color: var(--ink-primary);
  }

  .el-table__header th {
    font-size: 18px;
    font-weight: 500;
    color: var(--ink-secondary);
  }

  .el-table__row td {
    font-size: 16px;
  }

  .el-table__row:hover td {
    background-color: var(--accent-soft) !important;
  }

  .priority-tag {
    font-weight: 600;
    font-size: 13px;
  }
}

.el-tooltip__content {
  font-size: 14px !important;
}

.el-tooltip__popper {
  font-size: 14px !important;
}

.el-popper.is-dark {
  font-size: 25px !important;
}
</style>
