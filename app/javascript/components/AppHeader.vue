<template>
  <AppHeader>
    <template #app-link>
      <a href="/">Z</a>
    </template>
    <template #navbar-links-right>
      <AppNavbar :currentUser="currentUser" />
    </template>
  </AppHeader>
</template>
<script setup lang="ts">
import { AppHeader } from "@umn-latis/cla-vue-template";
import AppNavbar from "@/components/AppNavbar.vue";
import type { User } from "@/types";

withDefaults(
  defineProps<{
    currentUser: User | null;
  }>(),
  {
    currentUser: null,
  }
);
</script>
<style scoped></style>
