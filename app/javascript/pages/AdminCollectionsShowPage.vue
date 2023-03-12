<template>
  <PageLayout>
    <template #header>
      <p class="tw-uppercase tw-text-center">Admin</p>
      <h1>Collection: {{ group.name }}</h1>
    </template>
    <PostIt>
      <div class="tw-relative">
        <section class="tw-mb-8">
          <h2 class="tw-text-2xl tw-mb-4">Urls</h2>

          <AdminGroupUrlsDataTable :group="group" :options="urlsTableOptions" />
        </section>

        <section class="tw-mb-8">
          <h2 class="tw-text-2xl tw-mb-4">Members</h2>
          <DataTable
            :options="membersTableOptions"
            :columns="membersTableColumns"
            :headers="['Name', 'Email', 'Created', 'Actions']"
          />
        </section>
      </div>
    </PostIt>
  </PageLayout>
</template>
<script setup lang="ts">
import DataTable from "@/components/DataTable.vue";
import PageLayout from "@/layouts/PageLayout.vue";
import { PostIt } from "@umn-latis/cla-vue-template";
import type {
  Collection,
  User,
  DataTableOptions,
  DataTableColumnOptions,
} from "@/types";
import AdminGroupUrlsDataTable from "@/components/AdminGroupUrlsDataTable.vue";

const props = defineProps<{
  group: Collection;
  members: User[];
}>();

const urlsTableOptions: DataTableOptions = {
  ajax: `/shortener/admin/groups/${props.group.id}/urls.json`,
  serverSide: true,
  order: [[1, "asc"]],
};

const membersTableOptions: DataTableOptions = {
  serverSide: false,
  data: props.members,
  paging: false,
  info: false,
  searching: false,
};

const membersTableColumns: DataTableColumnOptions[] = [
  {
    data: "display_name",
    render(data: string, type: string, row: User) {
      if (!row.admin) return data;

      return `
      <div class="tw-flex tw-items-center tw-gap-1">
        ${data}
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class="tw-w-6 tw-h-6 tw-stroke-sky-700 tw-fill-sky-100"
          >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="M9 12.75L11.25 15 15 9.75m-3-7.036A11.959 11.959 0 013.598 6 11.99 11.99 0 003 9.749c0 5.592 3.824 10.29 9 11.623 5.176-1.332 9-6.03 9-11.622 0-1.31-.21-2.571-.598-3.751h-.152c-3.196 0-6.1-1.248-8.25-3.285z"
          />
        </svg>
      </div>
      `;
    },
  },
  {
    data: "email",
  },
  {
    data: "created_at",
    render(data) {
      return new Date(data).toLocaleString();
    },
  },
  {
    data: "actions",
    orderable: false,
    searchable: false,
    title: "Actions",
    render: (data: any, type: any, row: User) => {
      return ``;
    },
  },
];
</script>
<style scoped></style>
