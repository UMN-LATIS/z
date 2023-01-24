<template>
  <div class="z-app">
    <AppHeader />
    <slot />
  </div>
</template>
<script setup lang="ts">
import { AppHeader } from "@umn-latis/cla-vue-template";

interface User {
  name: string;
}

defineProps<{
  currentUser: User;
}>();
</script>
<style scoped></style>
