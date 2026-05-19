import api from "./index";

export interface JobInfo {
    id: string;
    name: string;
    next_run_time: string | null;
    trigger: string;
}

export interface JobsResponse {
    total: number;
    jobs: JobInfo[];
}

export interface TodayTask {
    project_name: string;
    task_type: string;
    scheduled_time: string;
    status: "pending" | "success" | "failed" | "expired";
    executed_at: string | null;
}

export interface TaskLogItem {
    id: number;
    project_name: string;
    task_type: string;
    executed_at: string | null;
    scheduled_time: string | null;
    status: string;
    error_message: string;
    task_exec_type: string;
}

export interface TaskLogsResponse {
    total: number;
    page: number;
    page_size: number;
    items: TaskLogItem[];
}

export interface ManualExecuteRequest {
    project_config_id: number;
}

export interface ManualReportDataRequest {
    project_config_id: number;
    sprint_id: string;
}

export interface TaskLogsQuery {
    page: number;
    page_size: number;
    project_name?: string;
    executed_date?: string;
    task_type?: string;
}

export const jobApi = {
    getJobs() {
        return api.get<JobsResponse>("/jobs") as unknown as Promise<JobsResponse>
    },

    getTodayTasks() {
        return api.get<TodayTask[]>("/scheduler/today-tasks") as unknown as Promise<TodayTask[]>
    },

    triggerJob(jobId: string) {
        return api.post(`/jobs/${jobId}/trigger`)
    },

    triggerStoryReminder() {
        return api.post("/jobs/story-reminder/trigger")
    },

    triggerTaskReminder() {
        return api.post("/jobs/task-reminder/trigger")
    },

    getLogs(params: TaskLogsQuery) {
        return api.get<TaskLogsResponse>("/scheduler/logs", { params }) as unknown as Promise<TaskLogsResponse>
    },

    manualStoryReminder(data: ManualExecuteRequest) {
        return api.post("/scheduler/manual/story-reminder", data)
    },

    manualTaskReminder(data: ManualExecuteRequest) {
        return api.post("/scheduler/manual/task-reminder", data)
    },

    manualSonarReminder(data: ManualExecuteRequest) {
        return api.post("/scheduler/manual/sonar-reminder", data)
    },

    checkReportDataExists(projectConfigId: number, sprintId: string) {
        return api.get<{ exists: boolean }>(
            `/scheduler/manual/report-data/check/${projectConfigId}/${sprintId}`
        ) as unknown as Promise<{ exists: boolean }>
    },

    manualReportData(data: ManualReportDataRequest) {
        return api.post("/scheduler/manual/report-data", data)
    },
};