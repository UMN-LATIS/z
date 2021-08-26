import { createApp } from "vue/dist/vue.esm-bundler";
import TurbolinksAdapter from "vue-turbolinks";
import HelloWorld from "@/components/HelloWorld.vue";

const app = createApp({ components: { HelloWorld } }).use(TurbolinksAdapter);

export default () => {
  document.addEventListener("DOMContentLoaded", () =>
    app.mount('[data-behavior="vue"]')
  );
};
