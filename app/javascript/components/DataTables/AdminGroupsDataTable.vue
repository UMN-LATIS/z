<template>
  <div class="">
    <DataTable
      ref="table"
      data-cy="groups-table"
      class="table table-striped table-bordered !tw-w-full"
      :options="options"
      :columns="columns"
      :headers="['ID', 'Name', 'Urls', 'Members', 'Actions']"
      @mounted="handleDataTableMounted"
      @click="handleDataTableClick"
    />

    <Modal :isOpen="isEditing" @close="isEditing = false">
      <EditGroupForm
        v-if="collectionToChange"
        data-cy="update-group"
        :group="collectionToChange"
        @save="handleSave"
      />
    </Modal>

    <Modal :isOpen="isCreating" @close="isCreating = false">
      <EditGroupForm
        data-cy="create-group"
        :group="{
          name: '',
          description: '',
        }"
        @save="handleCreate"
      />
    </Modal>

    <ConfirmDangerModal
      :isOpen="isDeleting"
      :title="`Delete collection: '${collectionToChange?.name}'`"
      @close="isDeleting = false"
      @confirm="handleDelete"
    />
  </div>
</template>
<script setup lang="ts">
import DataTable from "@/components/DataTables/DataTable.vue";
import Modal from "@/components/Modal.vue";
import ConfirmDangerModal from "@/components/ConfirmDangerModal.vue";
import EditGroupForm from "@/components/EditGroupForm.vue";
import type {
  Collection,
  DataTableApi,
  DataTableOptions,
  DataTableColumnOptions,
} from "@/types";
import { ref } from "vue";
import * as api from "@/api";

const isEditing = ref(false);
const isDeleting = ref(false);
const isCreating = ref(false);
const tableRow = ref<string | null>(null);
const collectionToChange = ref<Collection | null>(null);
const datatable = ref<DataTableApi<Collection> | null>(null);

function handleDataTableMounted(dt: DataTableApi<Collection>) {
  datatable.value = dt;
}

function handleDataTableClick(
  event: MouseEvent,
  dtApi: DataTableApi<Collection>
) {
  datatable.value = dtApi;

  const clickedElement = event.target as HTMLElement;
  const { row, action } = clickedElement.dataset;

  // if we have no row data, then there's nothing we can do
  if (!row) return;

  if (action === "edit") {
    tableRow.value = row;
    collectionToChange.value = dtApi.row(row).data();
    isEditing.value = true;
  }

  if (action === "delete") {
    tableRow.value = row;
    collectionToChange.value = dtApi.row(row).data();
    isDeleting.value = true;
  }
}

async function handleSave(updatedGroup: Partial<Collection>) {
  if (!datatable.value) throw new Error("No datatable api found");
  if (!tableRow.value) throw new Error("No edited row found");
  if (!collectionToChange.value) throw new Error("No edited item found");

  await api.updateCollection(updatedGroup);
  datatable.value.row(tableRow.value).data(updatedGroup).draw(false);

  // reset the edited row and item
  tableRow.value = null;
  collectionToChange.value = null;
  isEditing.value = false;
}

async function handleCreate(newGroup: Partial<Collection>) {
  if (!datatable.value) throw new Error("No datatable api found");

  await api.createCollection(newGroup);
  datatable.value.draw(false);

  isCreating.value = false;
}

async function handleDelete() {
  if (!datatable.value) throw new Error("No datatable api found");
  if (!tableRow.value) throw new Error("No edited row found");
  if (!collectionToChange.value) throw new Error("No edited item found");

  const collectionId = Number.parseInt(collectionToChange.value.id, 10);

  await api.deleteCollection(collectionId);
  datatable.value.row(tableRow.value).remove().draw(false);

  // reset the edited row and item
  tableRow.value = null;
  collectionToChange.value = null;
  isDeleting.value = false;
}

const options: DataTableOptions = {
  ajax: "/shortener/admin/groups.json",
  serverSide: true, // enable server-side processing
  language: {
    emptyTable: "None",
    searchPlaceholder: "Search...",
    search: '<span class="tw-sr-only">Search</span>',
  },
};

const columns: DataTableColumnOptions[] = [
  { data: "id" },
  {
    data: "name",
    render(data: string, type: string, row: Collection) {
      const href = `/shortener/admin/groups/${row.id}`;
      return `
        <a href="${href}" class="tw-text-sky-700 hover:tw-underline hover:tw-text-sky-600">
          ${data}
        </a>
        <div class="tw-text-xs tw-text-gray-500 tw-mt-1">
          ${row.description}
        </div>
      `;
    },
  },
  {
    data: "urls",
    render(data: number, type: string, row: Collection) {
      const href = `/shortener/urls?collection=${row.id}`;
      const conditionalClasses =
        data > 0 ? "tw-bg-sky-100" : "tw-bg-neutral-100";
      return `
        <a href="${href}" class="${conditionalClasses} tw-py-1 tw-px-2 tw-rounded-full tw-text-sky-700 hover:tw-no-underline hover:tw-bg-sky-600 hover:tw-text-sky-100 tw-whitespace-nowrap">
          ${data} url${data != 1 ? "s" : ""}
        </a>
      `;
    },
    orderable: false,
    searchable: false,
  },
  {
    data: "users",
    render(data: number, type: string, row: Collection) {
      return `
        <a href="/shortener/groups/${row.id}/members" class="${
        data > 0 ? "tw-bg-sky-100" : "tw-bg-neutral-100"
      } tw-py-1 tw-px-2 tw-rounded-full tw-text-sky-700 hover:tw-no-underline hover:tw-bg-sky-600 hover:tw-text-sky-100 tw-whitespace-nowrap">
          ${data} member${data != 1 ? "s" : ""}
        </a>
      `;
    },
    searchable: false,
    orderable: false,
  },

  {
    data: "actions",
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
