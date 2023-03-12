<template>
  <PageLayout>
    <template #header>
      <p class="tw-uppercase tw-text-center">Admin</p>
      <h1>All Collections</h1>
    </template>
    <PostIt>
      <div class="tw-relative">
        <AdminGroupsDataTable />
      </div>
    </PostIt>
  </PageLayout>
</template>
<script setup lang="ts">
import PageLayout from "@/layouts/PageLayout.vue";
import { PostIt } from "@umn-latis/cla-vue-template";
import AdminGroupsDataTable from "@/components/DataTables/AdminGroupsDataTable.vue";
</script>
<style scoped></style>
