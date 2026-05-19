import api from './index'

export interface DocBugRecord {
  key: string | null
  name: string | null
  priority: string | null
  reason: string | null
  resolve_method: string | null
  maker: string | null
  propose: string | null
  propose_time: string | null
  resolve_time: string | null
  status: string | null
  type: string | null
  original_type: string | null
  sprint_id: string | null
  project_id: string | null
}

export interface DocBugListResponse {
  total: number
  page: number
  page_size: number
  items: DocBugRecord[]
}

export interface UploadResponse {
  success: boolean
  imported?: number
  total_count?: number
  errors?: string[]
}

export const dataImportApi = {
  getClosedSprints(projectId: number) {
    return api.get<{ sprint_id: number; sprint_name: string }[]>(
      `/data-import/sprints/${projectId}`
    ) as unknown as Promise<{ sprint_id: number; sprint_name: string }[]>
  },

  getDocBugs(projectId: string, sprintId: string, page: number, pageSize: number) {
    return api.get<DocBugListResponse>('/data-import/doc-bugs', {
      params: { project_id: projectId, sprint_id: sprintId, page, page_size: pageSize },
    }) as unknown as Promise<DocBugListResponse>
  },

  clearDocBugs(projectId: string, sprintId: string) {
    return api.delete<{ deleted: number }>('/data-import/doc-bugs', {
      data: { project_id: projectId, sprint_id: sprintId },
    }) as unknown as Promise<{ deleted: number }>
  },

  uploadDocBugs(projectId: string, sprintId: string, file: File) {
    const formData = new FormData()
    formData.append('file', file)
    return api.post<UploadResponse>(
      `/data-import/doc-bugs/upload?project_id=${projectId}&sprint_id=${sprintId}`,
      formData,
      {
        headers: { 'Content-Type': 'multipart/form-data' },
      }
    ) as unknown as Promise<UploadResponse>
  },
}