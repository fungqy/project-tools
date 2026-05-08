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

export const jobApi = {
    getJobs() {
        return api.get<JobsResponse>("/jobs");
    },

    getTodayTasks() {
        return api.get<TodayTask[]>("/scheduler/today-tasks");
    },

    triggerJob(jobId: string) {
        return api.post(`/jobs/${jobId}/trigger`);
    },

    triggerStoryReminder() {
        return api.post("/jobs/story-reminder/trigger");
    },

    triggerTaskReminder() {
        return api.post("/jobs/task-reminder/trigger");
    },
};
