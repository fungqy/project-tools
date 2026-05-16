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
  bug_reopen_count: number
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

export interface ReopenBugItem {
  index: number
  issue_key: string
  issue_name: string
  bug_maker: string
  reporter: string
  bug_type: string
  priority: string
  bug_reason: string
  resolution: string
}

export const reportsApi = {
  getProjects() {
    return api.get<ProjectOption[]>('/reports/projects') as unknown as Promise<ProjectOption[]>
  },

  getSprints(projectId: number) {
    return api.get<SprintOption[]>(`/reports/sprints/${projectId}`) as unknown as Promise<SprintOption[]>
  },

  getMetrics(sprintId: number) {
    return api.get<SprintMetrics>('/reports/metrics', {
      params: { sprint_id: sprintId },
    }) as unknown as Promise<SprintMetrics>
  },

  getBugDetails(sprintId: number) {
    return api.get<BugDetailResponse>('/reports/bugs/detail', {
      params: { sprint_id: sprintId },
    }) as unknown as Promise<BugDetailResponse>
  },

  getBugList(sprintId: number, priority: string, tag: string, developer?: string) {
    return api.get<BugListItem[]>('/reports/bugs/list', {
      params: { sprint_id: sprintId, developer: developer || '', priority, tag },
    }) as unknown as Promise<BugListItem[]>
  },

  getBugAvgTime(sprintId: number) {
    return api.get<{ avg_dev_seconds: number; avg_test_seconds: number }>('/reports/bugs/avg-time', {
      params: { sprint_id: sprintId },
    }) as unknown as Promise<{ avg_dev_seconds: number; avg_test_seconds: number }>
  },

  getReopenBugs(sprintId: number) {
    return api.get<ReopenBugItem[]>('/reports/bugs/reopen', {
      params: { sprint_id: sprintId },
    }) as unknown as Promise<ReopenBugItem[]>
  },
}
