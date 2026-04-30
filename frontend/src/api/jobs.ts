import api from './index'

export interface JobInfo {
  id: string
  name: string
  next_run_time: string | null
  trigger: string
}

export interface JobsResponse {
  total: number
  jobs: JobInfo[]
}

export const jobApi = {
  getJobs() {
    return api.get<JobsResponse>('/jobs')
  },

  triggerJob(jobId: string) {
    return api.post(`/jobs/${jobId}/trigger`)
  },

  triggerStoryReminder() {
    return api.post('/jobs/story-reminder/trigger')
  },

  triggerTaskReminder() {
    return api.post('/jobs/task-reminder/trigger')
  },
}
