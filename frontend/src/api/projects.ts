import api from './index'

export interface ProjectConfig {
  id?: number
  board_id: string
  board_name: string
  project_id: string
  project_name: string
  gitlab_group_key: string
  need_progress_remind: boolean
  need_sonar_scan_remind: boolean
  need_report_data: boolean
  sonar_key_prefix: string
  sonar_scan_remind_default_person: string
  robot_key: string
  jira_user: string
  jira_token?: string
  created_by?: number
  created_at?: string
  updated_at?: string
  updated_by?: number
}

export const projectApi = {
  getList() {
    return api.get<ProjectConfig[]>('/projects')
  },

  getById(id: number) {
    return api.get<ProjectConfig>(`/projects/${id}`)
  },

  create(data: ProjectConfig) {
    return api.post<ProjectConfig>('/projects', data)
  },

  update(id: number, data: Partial<ProjectConfig>) {
    return api.put<ProjectConfig>(`/projects/${id}`, data)
  },

  delete(id: number) {
    return api.delete(`/projects/${id}`)
  },
}
