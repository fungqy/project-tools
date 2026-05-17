import { defineConfig, loadEnv } from "vite";
import vue from "@vitejs/plugin-vue";
import AutoImport from "unplugin-auto-import/vite";
import Components from "unplugin-vue-components/vite";
import { ElementPlusResolver } from "unplugin-vue-components/resolvers";
// @ts-ignore - Node.js built-in modules
import { resolve, dirname } from "path";
// @ts-ignore - Node.js built-in modules
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

export default defineConfig(({ mode }) => {
    const env = loadEnv(mode, process.cwd(), "");
    const apiHost = env.VITE_API_HOST || "http://localhost:8000";

    return {
        plugins: [
            vue(),
            AutoImport({
                imports: ["vue", "vue-router", "pinia"],
                resolvers: [ElementPlusResolver()],
                dts: "src/auto-imports.d.ts",
            }),
            Components({
                resolvers: [ElementPlusResolver()],
                dts: "src/components.d.ts",
            }),
        ],
        resolve: {
            alias: {
                "@": resolve(__dirname, "src"),
            },
        },
        server: {
            port: parseInt(env.PORT || "3000"),
            proxy: {
                "/api": {
                    target: apiHost,
                    changeOrigin: true,
                },
            },
        },
    };
});
