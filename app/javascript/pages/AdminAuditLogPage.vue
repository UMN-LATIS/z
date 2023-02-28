<template>
  <PageLayout>
    <template #header>
      <p class="tw-uppercase tw-text-center">Admin</p>
      <h1 data-cy="page-name">Audit Logs</h1>
    </template>
  </PageLayout>
  <PostIt>
    <DataTable
      ref="table"
      class="table table-striped table-bordered !tw-w-full"
      :options="options"
    >
      <thead data-cy="audits-table-head">
        <tr>
          <th>Item</th>
          <th>Event</th>
          <th>Whodunnit</th>
          <th>Change History</th>
          <th>As Of</th>
        </tr>
      </thead>
      <tbody></tbody>
    </DataTable>
  </PostIt>
</template>
<script setup lang="ts">
import PageLayout from "@/layouts/PageLayout.vue";
import { PostIt } from "@umn-latis/cla-vue-template";
import DataTable from "datatables.net-vue3";
import DataTablesLib, { type Config as DataTableOptions } from "datatables.net";

DataTable.use(DataTablesLib);

function decodeHTML(html: string) {
  const txt = document.createElement("textarea");
  txt.innerHTML = html;
  return txt.value;
}

const options: DataTableOptions = {
  ajax: `/shortener/admin/audits/datatable.json`,
  columns: [
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
  ],
  serverSide: true, // enable server-side processing
  paging: false, // disable pagination, use infinite scroll instead
  scrollY: "50vh", // scroll body height
  scrollCollapse: true, // reduce table height when smaller than scrollY
  language: {
    emptyTable: "None",
    searchPlaceholder: "Search...",
    search: '<span class="tw-sr-only">Search</span>',
  },
};
</script>
<style scoped></style>
