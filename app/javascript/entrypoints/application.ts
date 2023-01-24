import { createApp } from "vue";
import App from "@/components/App.vue";
import "@umn-latis/cla-vue-template/dist/style.css";

const components = {
  "z-app": App,
};

createApp({ components }).mount("#app");
