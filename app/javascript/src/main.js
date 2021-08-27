import { createApp } from "vue";
import TurbolinksAdapter from "vue-turbolinks";
import {
  UMNHeader,
} from "@umn-latis/latis-vue-components";

const components = {
  "umn-header": UMNHeader,
};
const createMyApp = () =>
  createApp({ components })
    .use(TurbolinksAdapter)
    .mount('[data-behavior="vue"]');

const onReady = (fn) =>
  document.readyState != "loading"
    ? fn()
    : document.addEventListener("DOMContentLoaded", fn);

export default () => {
  // Datatables and Vue and Turbolinks seem to not play well together
  // Loading a Vue component using `onReady` will only work for the First
  // page render as Turbolinks takes over after that.
  // listening for `turbolinks:load` event seems to interfere with datatables
  // loading
  // `turbolinks:before-render` causes Vue not to load.
  // `turbolinks:render` will be called after every non-initial page load.
  // SO, we load Vue using onReady and `turbolinks:render` to cover all
  // cases.

  // My suspicion is that this is a quirk of some legacy event listener
  // elsewhere in the app. Once that's resolved, Turbolinks probably won't
  // be so fussy.

  // Called on first page load
  onReady(() => {
    createMyApp();
  });

  // Called after every non-initial page load
  document.addEventListener("turbolinks:render", () => {
    createMyApp();
  });
};
