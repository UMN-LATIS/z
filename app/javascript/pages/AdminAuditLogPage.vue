<template>
  <PageLayout>
    <template #header>
      <p class="tw-uppercase tw-text-center">Admin</p>
      <h1 data-cy="page-name">Audit Logs</h1>
    </template>
    <PostIt>
      <DataTable
        :columns="columns"
        :headers="['Item', 'Event', 'Whodunnit', 'Change History', 'As Of']"
        ref="table"
        class="admin-audit-log-datatable table table-striped table-bordered !tw-w-full"
        :options="options"
      />
    </PostIt>
  </PageLayout>
</template>
<script setup lang="ts">
import PageLayout from "@/layouts/PageLayout.vue";
import { PostIt } from "@umn-latis/cla-vue-template";
import DataTable from "@/components/DataTables/DataTable.vue";
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
<style lang="scss">
/* format change history */
.admin-audit-log-datatable td:nth-child(4) {
  font-size: 0.8rem;
  color: #111;

  // bolding is a bit much
  b {
    font-weight: normal;
  }

  h3 {
    font-size: 1em;
    line-height: 1.4;
    margin-top: 1em;
    border-bottom: 1px solid #ddd;
    margin-bottom: 0.25em;
    text-transform: uppercase;
  }

  // use border-bottom instead of hr
  hr {
    display: none;
  }

  // 3 line breaks seems excessive
  br + br + br {
    display: none;
  }
}
</style>
