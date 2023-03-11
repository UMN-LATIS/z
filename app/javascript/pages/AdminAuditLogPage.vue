<template>
  <PageLayout>
    <template #header>
      <p class="tw-uppercase tw-text-center">Admin</p>
      <h1 data-cy="page-name">Audit Logs</h1>
    </template>
  </PageLayout>
  <PostIt>
    <DataTable
      :columns="columns"
      :headers="['Item', 'Event', 'Whodunnit', 'Change History', 'As Of']"
      ref="table"
      class="table table-striped table-bordered !tw-w-full"
      :options="options"
    />
  </PostIt>
</template>
<script setup lang="ts">
import PageLayout from "@/layouts/PageLayout.vue";
import { PostIt } from "@umn-latis/cla-vue-template";
import DataTable from "@/components/DataTable.vue";
import type { DataTableOptions, DataTableColumnOptions } from "@/types";

function decodeHTML(html: string) {
  const txt = document.createElement("textarea");
  txt.innerHTML = html;
  return txt.value;
}

const columns: DataTableColumnOptions[] = [
  { data: "item_type" },
  { data: "event" },
  { data: "whodunnit" },
  {
    data: "audit_history",
    render: (data: string) => {
      return decodeHTML(data);
    },
  },
  { data: "created_at" },
];

const options: DataTableOptions = {
  ajax: `/shortener/admin/audits.json`,
  serverSide: true, // enable server-side processing
  order: [[4, "desc"]], // default order by created_at desc
};
</script>
<style scoped></style>
