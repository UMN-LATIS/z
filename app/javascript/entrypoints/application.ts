import { createApp } from 'vue';
import Test from '../components/Test.vue';

// To see this message, add the following to the `<head>` section in your
// views/layouts/application.html.erb
//
//    <%= vite_client_tag %>
//    <%= vite_javascript_tag 'application' %>
console.log("Vite ⚡️ Rails");


const app = createApp(Test).mount('#test');


