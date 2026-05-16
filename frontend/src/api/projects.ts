import api from "./index";

export interface ReminderSettings {
    need_story_remind: boolean;
    need_task_remind: boolean;
    need_sonar_scan_remind: boolean;
    need_report_data: boolean;
    story_remind_time?: string;
    task_remind_time?: string;
    sonar_remind_time?: string;
    report_data_time?: string;
}

export interface ProjectConfig {
    id?: number;
    board_id: string;
    board_name: string;
    project_id: string;
    project_name: string;
    gitlab_group_key: string;
    sonar_key_prefix: string;
    sonar_scan_remind_default_person: string;
    robot_key: string;
    jira_user: string;
    jira_token?: string;
    need_story_remind: boolean;
    need_task_remind: boolean;
    need_sonar_scan_remind: boolean;
    need_report_data: boolean;
    created_by?: number;
    created_at?: string;
    updated_at?: string;
    updated_by?: number;
    reminder_settings?: ReminderSettings;
}

// 用于前端表单，扁平结构便于绑定
export interface ProjectFormData {
    id?: number;
    board_id: string;
    board_name: string;
    project_id: string;
    project_name: string;
    gitlab_group_key: string;
    sonar_key_prefix: string;
    sonar_scan_remind_default_person: string;
    robot_key: string;
    jira_user: string;
    jira_token: string;
    need_story_remind: boolean;
    need_task_remind: boolean;
    need_sonar_scan_remind: boolean;
    need_report_data: boolean;
    story_remind_time: string;
    task_remind_time: string;
    sonar_remind_time: string;
    report_data_time: string;
}

export const projectApi = {
    getList() {
        return api.get<ProjectConfig[]>("/projects") as unknown as Promise<ProjectConfig[]>
    },

    getById(id: number) {
        return api.get<ProjectConfig>(`/projects/${id}`) as unknown as Promise<ProjectConfig>
    },

    create(data: ProjectFormData) {
        const {
            need_story_remind,
            need_task_remind,
            need_sonar_scan_remind,
            need_report_data,
            story_remind_time,
            task_remind_time,
            sonar_remind_time,
            report_data_time,
            ...rest
        } = data;
        const payload: any = { ...rest };
        payload.reminder_settings = {
            need_story_remind,
            need_task_remind,
            need_sonar_scan_remind,
            need_report_data,
            story_remind_time: story_remind_time || null,
            task_remind_time: task_remind_time || null,
            sonar_remind_time: sonar_remind_time || null,
            report_data_time: report_data_time || null,
        };
        return api.post<ProjectConfig>("/projects", payload) as unknown as Promise<ProjectConfig>
    },

    update(id: number, data: ProjectFormData) {
        const {
            need_story_remind,
            need_task_remind,
            need_sonar_scan_remind,
            need_report_data,
            story_remind_time,
            task_remind_time,
            sonar_remind_time,
            report_data_time,
            ...rest
        } = data;
        const payload: any = { ...rest };
        payload.reminder_settings = {
            need_story_remind,
            need_task_remind,
            need_sonar_scan_remind,
            need_report_data,
            story_remind_time: story_remind_time || null,
            task_remind_time: task_remind_time || null,
            sonar_remind_time: sonar_remind_time || null,
            report_data_time: report_data_time || null,
        };
        return api.put<ProjectConfig>(`/projects/${id}`, payload) as unknown as Promise<ProjectConfig>
    },

    delete(id: number) {
        return api.delete(`/projects/${id}`)
    },
};
