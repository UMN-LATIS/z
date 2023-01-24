import { createApp, type App as VueApp } from "vue";
import AppHeader from "@/components/AppHeader.vue";
import AppFooter from "@/components/AppFooter.vue";
import "@umn-latis/cla-vue-template/dist/style.css";

const components = {
  "app-header": AppHeader,
  "app-footer": AppFooter,
};

const createMyApp = () => {
  const apps: VueApp[] = [];
  const vueMountEls = document.querySelectorAll('[data-behavior="vue"]');
  [...Array.from(vueMountEls)].forEach((el) => {
    const app = createApp({ components });
    apps.push(app);
    app.mount(el);
  });
  return apps;
};

// active vue apps on the page
// we need to keep track of them so that we can unmount them
// when the page changes with turbolinks events
let vueApps: VueApp[] = [];

// this lets vue components play nicely with turbolinks
// so that they get re-mounted when the page changes
document.addEventListener("turbolinks:load", () => {
  vueApps = createMyApp();
});

// this event listener is executed as soon as
// the new body was fetched successfully but
// before replacing the `document.body`
document.addEventListener("turbolinks:before-render", () => {
  vueApps.forEach((app) => app.unmount());
});