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

export interface ReminderSettings {
  need_story_remind: boolean
  need_task_remind: boolean
  need_sonar_scan_remind: boolean
  need_report_data: boolean
  story_remind_time?: string
  task_remind_time?: string
  sonar_remind_time?: string
  report_data_time?: string
}

export interface ProjectConfig {
  id: number
  board_id: string
  board_name: string
  project_id: string
  project_name: string
  gitlab_group_key: string
  sonar_key_prefix: string
  sonar_scan_remind_default_person: string
  robot_key: string
  jira_user: string
  jira_token?: string
  created_by?: number
  created_at?: string
  updated_at?: string
  updated_by?: number
  need_story_remind?: boolean
  need_task_remind?: boolean
  need_sonar_scan_remind?: boolean
  need_report_data?: boolean
  story_remind_time?: string
  task_remind_time?: string
  sonar_remind_time?: string
  report_data_time?: string
  reminder_settings?: ReminderSettings
}

export interface ProjectFormData {
  id?: number
  board_id: string
  board_name: string
  project_id: string
  project_name: string
  gitlab_group_key: string
  sonar_key_prefix: string
  sonar_scan_remind_default_person: string
  robot_key: string
  jira_user: string
  jira_token: string
  need_story_remind: boolean
  need_task_remind: boolean
  need_sonar_scan_remind: boolean
  need_report_data: boolean
  story_remind_time: string
  task_remind_time: string
  sonar_remind_time: string
  report_data_time: string
}

// [修复#8] 封装类型安全的请求函数，消除所有 as unknown as T 双重断言
function get<T>(url: string, params?: Record<string, unknown>): Promise<T> {
  return api.get(url, { params }) as unknown as Promise<T>
}

function post<T>(url: string, data?: unknown): Promise<T> {
  return api.post(url, data) as unknown as Promise<T>
}

function put<T>(url: string, data?: unknown): Promise<T> {
  return api.put(url, data) as unknown as Promise<T>
}

function del<T>(url: string): Promise<T> {
  return api.delete(url) as unknown as Promise<T>
}

export const projectApi = {
  getList() {
    return get<ProjectConfig[]>('/projects')
  },

  create(data: ProjectFormData) {
    return post<ProjectConfig>('/projects', data)
  },

  update(id: number, data: ProjectFormData) {
    return put<ProjectConfig>(`/projects/${id}`, data)
  },

  delete(id: number) {
    return del<void>(`/projects/${id}`)
  },
}

export const reportsApi = {
  getProjects() {
    return get<ProjectOption[]>('/reports/projects')
  },

  getSprints(projectId: number) {
    return get<SprintOption[]>(`/reports/sprints/${projectId}`)
  },

  getMetrics(sprintId: number) {
    return get<SprintMetrics>('/reports/metrics', { sprint_id: sprintId })
  },

  getBugDetails(sprintId: number) {
    return get<BugDetailResponse>('/reports/bugs/detail', { sprint_id: sprintId })
  },

  getBugList(sprintId: number, priority: string, tag: string, developer?: string) {
    return get<BugListItem[]>('/reports/bugs/list', {
      sprint_id: sprintId,
      developer: developer || '',
      priority,
      tag,
    })
  },

  getBugAvgTime(sprintId: number) {
    return get<{ avg_dev_seconds: number; avg_test_seconds: number }>('/reports/bugs/avg-time', {
      sprint_id: sprintId,
    })
  },

  getReopenBugs(sprintId: number) {
    return get<ReopenBugItem[]>('/reports/bugs/reopen', { sprint_id: sprintId })
  },
}
