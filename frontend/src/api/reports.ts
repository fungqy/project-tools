import api from './index'

export interface ProjectOption {
  id: number
  project_id: string
  project_name: string
  board_name: string
}

export interface SprintOption {
  sprint_id: number
  sprint_name: string
  start_date: string | null
  end_date: string | null
  state: string | null
}

export interface SprintMetrics {
  story_count: number
  bug_count: number
}

export interface BugDetailResponse {
  developers: { developer: string; total: number }[]
  priorities: string[]
  tags: string[]
  data: Record<string, Record<string, Record<string, number>>>
}

export interface BugListItem {
  index: number
  issue_key: string
  developer: string
  priority: string
  issue_name: string
  reason_analysis: string
  is_typical: string
  source: string
  tag: string
}

export const reportsApi = {
  getProjects() {
    return api.get<ProjectOption[]>('/reports/projects')
  },

  getSprints(projectId: number) {
    return api.get<SprintOption[]>(`/reports/sprints/${projectId}`)
  },

  getMetrics(sprintId: number) {
    return api.get<SprintMetrics>('/reports/metrics', {
      params: { sprint_id: sprintId },
    })
  },

  getBugDetails(sprintId: number) {
    return api.get<BugDetailResponse>('/reports/bugs/detail', {
      params: { sprint_id: sprintId },
    })
  },

  getBugList(sprintId: number, developer: string, priority: string, tag: string) {
    return api.get<BugListItem[]>('/reports/bugs/list', {
      params: { sprint_id: sprintId, developer, priority, tag },
    })
  },
}
