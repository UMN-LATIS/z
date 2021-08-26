import { createApp } from "vue";
import TurbolinksAdapter from "vue-turbolinks";
import HelloWorld from "@/components/HelloWorld.vue";

const app = createApp({ components: { HelloWorld } }).use(TurbolinksAdapter);

const onReady = (fn) =>
  document.readyState != "loading"
    ? fn()
    : document.addEventListener("DOMContentLoaded", fn);

export default () => {
  onReady(() => app.mount('[data-behavior="vue"]'));
};
