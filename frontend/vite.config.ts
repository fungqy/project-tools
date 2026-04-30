import { defineConfig } from "vite";
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

export default defineConfig({
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
        port: 3000,
        proxy: {
            "/api": {
                target: "http://localhost:8000",
                changeOrigin: true,
            },
        },
    },
});
