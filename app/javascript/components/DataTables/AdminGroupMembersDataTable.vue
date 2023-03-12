<template>
  <div>
    <DataTable
      :options="membersTableOptions"
      :columns="membersTableColumns"
      :headers="['Name', 'Email', 'Created', 'Actions']"
    />
  </div>
</template>
<script setup lang="ts">
import DataTable from "@/components/DataTables/DataTable.vue";
import type {
  DataTableOptions,
  DataTableColumnOptions,
  User,
  Collection,
} from "@/types";

const props = defineProps<{
  members: User[];
  group: Collection;
}>();

const membersTableOptions: DataTableOptions = {
  /**
   we're not doing using ajax with this datatable since some member attributes(like internet_id and display_name) are not columns in the db, but rather methods that do an ldap lookup so it gets complicated. We could do it with ajax, but then the column wouldn't be searchable or sortable. Instead, we opt to pass the members in as props.
  */
  serverSide: false,
  data: props.members,
  paging: false,
  info: false,
};

const membersTableColumns: DataTableColumnOptions[] = [
  {
    data: "display_name",
    render(data: string, _, row: User) {
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
          class="tw-w-4 tw-h-4 tw-stroke-sky-700 tw-fill-sky-100"
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
    searchable: false,
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
