import { defineStore } from "pinia";
import { ref } from "vue";
import { authApi, type UserInfo } from "@/api/auth";
import router from "@/router";

export const useAuthStore = defineStore("auth", () => {
    const user = ref<UserInfo | null>(null);
    const token = ref<string>("");

    async function login(username: string, password: string) {
        const response = await authApi.login({ username, password });
        token.value = response.access_token;
        user.value = response.user;
        localStorage.setItem("token", response.access_token);
        localStorage.setItem("user", JSON.stringify(response.user));
        return response;
    }

    async function fetchCurrentUser() {
        try {
            const response = await authApi.getCurrentUser();
            user.value = response;
            return response;
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
