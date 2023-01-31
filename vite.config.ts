import { defineConfig } from "vite";
import RubyPlugin from "vite-plugin-ruby";
import vue from "@vitejs/plugin-vue";
import FullReload from "vite-plugin-full-reload";

export default defineConfig({
  plugins: [
    RubyPlugin(),
    vue(),
    FullReload([
      "config/routes.rb",
      "app/views/**/*",
      "app/assets/javascripts/**/*",
      "app/assets/stylesheets/**/*",
    ]),
  ],
  resolve: {
    alias: {
      // use vue's runtime compiler to support vue components
      // directly within blade templates
      vue: "vue/dist/vue.esm-bundler.js",
    },
  },
  server: {
    fs: {
      strict: false,
    },
  },
});
