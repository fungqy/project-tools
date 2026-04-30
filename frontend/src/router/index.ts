import { createRouter, createWebHistory } from "vue-router";
import type { RouteRecordRaw } from "vue-router";

const routes: RouteRecordRaw[] = [
    {
        path: "/login",
        name: "Login",
        component: () => import("@/views/auth/Login.vue"),
        meta: { title: "登录", hidden: true },
    },
    {
        path: "/",
        redirect: "/dashboard",
    },
    {
        path: "/dashboard",
        name: "Dashboard",
        component: () => import("@/views/dashboard/Dashboard.vue"),
        meta: { title: "工作台", icon: "Odometer" },
    },
    {
        path: "/projects",
        name: "Projects",
        component: () => import("@/views/projects/ProjectList.vue"),
        meta: { title: "项目管理", icon: "FolderOpened" },
    },
    {
        path: "/jobs",
        name: "Jobs",
        component: () => import("@/views/jobs/Jobs.vue"),
        meta: { title: "任务调度", icon: "Timer" },
    },
    {
        path: "/sonar",
        name: "Sonar",
        component: () => import("@/views/sonar/Sonar.vue"),
        meta: { title: "Sonar扫描", icon: "Monitor" },
    },
    {
        path: "/reports",
        name: "Reports",
        component: () => import("@/views/reports/Reports.vue"),
        meta: { title: "质量报表", icon: "DataAnalysis" },
    },
    {
        path: "/screen",
        name: "Screen",
        component: () => import("@/views/screen/Screen.vue"),
        meta: { title: "数据大屏", icon: "FullScreen" },
    },
];

const router = createRouter({
    history: createWebHistory(),
    routes,
});

router.beforeEach((to, _from, next) => {
    const token = localStorage.getItem("token");
    if (to.path !== "/login" && !token) {
        next("/login");
    } else {
        next();
    }
});

export default router;
