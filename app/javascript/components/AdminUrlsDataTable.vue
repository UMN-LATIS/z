<template>
  <DropDownMenu label="Bulk Actions" align="left">
    <DropDownMenuItem
      :disabled="hasNoSelectedRows"
      @click="isBulkTransferModalOpen = true"
    >
      Transfer to a different user
    </DropDownMenuItem>
    <DropDownMenuItem :disabled="hasNoSelectedRows">Delete</DropDownMenuItem>
  </DropDownMenu>

  <DataTable
    ref="table"
    class="table table-striped table-bordered"
    :options="options"
    :columns="columns"
    :headers="['Z-link', 'Owner', 'Clicks', 'Created', 'Actions']"
    :selectable="true"
    @select="handleSelect"
    @click="handleDataTableClick"
    data-cy="admin-urls-table"
  />

  <Modal
    :isOpen="isBulkTransferModalOpen"
    @close="isBulkTransferModalOpen = false"
  >
    <TransferUrlForm
      :selectedRows="selectedRows"
      :datatable="datatable"
      @success="handleTransferSuccess"
    />
  </Modal>

  <EditUrlModal
    :isOpen="isEditModalOpen"
    :url="urlToChange"
    @close="handleEditUrlClose"
    @success="handleEditSuccess"
  />

  <ConfirmDangerModal
    :isOpen="isDeleteModalOpen"
    :title="`Delete Z-Link: ${urlToChange?.keyword}`"
    @close="isDeleteModalOpen = false"
    @confirm="handleDeleteUrl"
  />
</template>
<script setup lang="ts">
import { ref, computed } from "vue";
import DataTable from "@/components/DataTable.vue";
import {
  type Config as DataTableOptions,
  type ConfigColumns as DataTableColumnOptions,
  type Api as DataTableApi,
} from "datatables.net";
import DropDownMenu from "./DropDownMenu.vue";
import DropDownMenuItem from "./DropDownMenuItem.vue";
import Modal from "./Modal.vue";
import { Zlink } from "@/types";
import TransferUrlForm from "./TransferUrlForm.vue";
import EditUrlModal from "./EditUrlModal.vue";
import ConfirmDangerModal from "./ConfirmDangerModal.vue";
import * as api from "@/api";

const selectedRows = ref<Zlink[]>([]);
const datatable = ref<DataTableApi<Zlink> | null>(null);
const isBulkTransferModalOpen = ref(false);
const isEditModalOpen = ref(false);
const isDeleteModalOpen = ref(false);
const urlToChange = ref<Partial<Zlink> | null>(null);
const rowToChange = ref<string | null>(null);

function handleSelect(rows: Zlink[], dt: DataTableApi<Zlink>) {
  selectedRows.value = rows;
  datatable.value = dt;
}

function rerenderTable() {
  datatable.value?.ajax.reload();
}

function handleTransferSuccess() {
  rerenderTable();
  isBulkTransferModalOpen.value = false;
}

function resetEditModal() {
  isEditModalOpen.value = false;
  urlToChange.value = null;
  rowToChange.value = null;
}

function handleEditUrlClose() {
  resetEditModal();
}

function handleEditSuccess(updatedUrl: Zlink) {
  if (!datatable.value) {
    throw new Error("Datatable not found");
  }

  if (!rowToChange.value) {
    throw new Error("Row to change not found");
  }

  rerenderTable();
  resetEditModal();
}

async function handleDeleteUrl() {
  if (!datatable.value) throw new Error("No datatable api found");
  if (!rowToChange.value) throw new Error("No edited row found");
  if (!urlToChange.value?.id) throw new Error("No edited item found");

  const urlId = urlToChange.value.id;

  await api.deleteUrl(urlId);
  datatable.value.row(rowToChange.value).remove().draw(false);

  // reset the edited row and item
  rowToChange.value = null;
  urlToChange.value = null;
  isDeleteModalOpen.value = false;
}

function handleDataTableClick(event, dt) {
  datatable.value = dt;
  const target = event.target as HTMLElement;
  const { action, row } = target.dataset;

  if (!action) return;

  if (!row) {
    throw new Error(
      `Row not found for action ${action}. Be sure to set the data-row attribute on the element.`
    );
  }

  if (action === "edit") {
    urlToChange.value = dt.row(row).data();
    isEditModalOpen.value = true;
    rowToChange.value = row;
  }

  if (action === "delete") {
    urlToChange.value = dt.row(row).data();
    isDeleteModalOpen.value = true;
    rowToChange.value = row;
  }
}

const hasNoSelectedRows = computed(() => selectedRows.value.length === 0);

const options: DataTableOptions = {
  ajax: "/shortener/admin/urls.json",
  serverSide: true,
  order: [[1, "asc"]],
};

const columns: DataTableColumnOptions[] = [
  {
    data: "keyword",
    render: (keyword: string, _, row) => {
      return `
        <div class="tw-flex tw-flex-col">
          <a href="/shortener/urls/${keyword}">
            <span>${window.location.host}/</span>${keyword}
          </a>
          <a class="tw-block tw-text-neutral-500 hover:tw-underline tw-text-xs" href="/${keyword}">${row.url}</a>
        </div>
      `;
    },
  },
  {
    data: "group_name",
    render: (group_name: string, _, row) => {
      const groupMembersHref = `/shortener/groups/${row.group_id}/members`;

      // casting as boolean because the server returns a string
      const isDefaultGroup = row.is_default_group === "true";

      // default groups have only one member and should be named for the owner's internet id
      return isDefaultGroup
        ? `<a href="${groupMembersHref}">${group_name}</a>`
        : `<a href="${groupMembersHref}" class="tw-flex tw-gap-1">
               <!-- user group icon -->
              <svg 
                xmlns="http://www.w3.org/2000/svg" 
                class="tw-h-4 tw-w-4"
                fill="currentColor"
                stroke-width="1.5"
                stroke="currentColor"
                height="48" viewBox="0 96 960 960" width="48"><path d="M38 896v-94q0-35 18-63.5t50-42.5q73-32 131.5-46T358 636q62 0 120 14t131 46q32 14 50.5 42.5T678 802v94H38Zm700 0v-94q0-63-32-103.5T622 633q69 8 130 23.5t99 35.5q33 19 52 47t19 63v94H738ZM358 575q-66 0-108-42t-42-108q0-66 42-108t108-42q66 0 108 42t42 108q0 66-42 108t-108 42Zm360-150q0 66-42 108t-108 42q-11 0-24.5-1.5T519 568q24-25 36.5-61.5T568 425q0-45-12.5-79.5T519 282q11-3 24.5-5t24.5-2q66 0 108 42t42 108ZM98 836h520v-34q0-16-9.5-31T585 750q-72-32-121-43t-106-11q-57 0-106.5 11T130 750q-14 6-23 21t-9 31v34Zm260-321q39 0 64.5-25.5T448 425q0-39-25.5-64.5T358 335q-39 0-64.5 25.5T268 425q0 39 25.5 64.5T358 515Zm0 321Zm0-411Z"/></svg>
                ${group_name}
              </a>`;
    },
  },
  {
    data: "total_clicks",
  },
  {
    data: "created_at",
  },
  {
    data: "id",
    render(id, type, row, meta) {
      return `
          <div class="tw-flex tw-flex-wrap">
            <button
              class="tw-uppercase tw-text-xs tw-font-medium tw-p-2 hover:tw-bg-sky-50 tw-text-sky-700  tw-rounded tw-transition-colors tw-"
              data-action="edit"
              data-id="${id}"
              data-row="${meta.row}"
            >Edit</button>
            <button
              id="delete-button"
              class="tw-uppercase tw-text-xs tw-font-medium tw-p-2 tw-text-red-700 tw-rounded hover:tw-bg-red-50"
              data-action="delete"
              data-id="${id}"
              data-row="${meta.row}"
            >Delete</button>
          </div>
        `;
    },
    orderable: false,
    searchable: false,
  },
];
</script>
<style scoped></style>
