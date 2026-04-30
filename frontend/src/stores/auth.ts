import { defineStore } from "pinia";
import { ref } from "vue";
import { authApi, type UserInfo } from "@/api/auth";
import router from "@/router";

export const useAuthStore = defineStore("auth", () => {
    const user = ref<UserInfo | null>(null);
    const token = ref<string>("");

    async function login(username: string, password: string) {
        const response = await authApi.login({ username, password });
        token.value = response.data.access_token;
        user.value = response.data.user;
        localStorage.setItem("token", response.data.access_token);
        localStorage.setItem("user", JSON.stringify(response.data.user));
        return response;
    }

    async function fetchCurrentUser() {
        try {
            const response = await authApi.getCurrentUser();
            user.value = response.data;
            return response.data;
        } catch {
            logout();
            throw new Error("Token已过期");
        }
    }

    function logout() {
        user.value = null;
        token.value = "";
        localStorage.removeItem("token");
        localStorage.removeItem("user");
        router.push("/login");
    }

    function initFromStorage() {
        const storedToken = localStorage.getItem("token");
        const storedUser = localStorage.getItem("user");
        if (storedToken && storedUser) {
            token.value = storedToken;
            user.value = JSON.parse(storedUser);
        }
    }

    return {
        user,
        token,
        login,
        logout,
        fetchCurrentUser,
        initFromStorage,
    };
});
