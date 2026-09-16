<template>
  <DropDownMenu label="Bulk Actions" align="left">
    <DropDownMenuItem
      :disabled="hasNoSelectedRows"
      @click="isBulkTransferModalOpen = true"
    >
      Transfer to a different user
    </DropDownMenuItem>
  </DropDownMenu>

  <DataTable
    ref="table"
    class="table table-striped table-bordered admin-urls-data-table"
    :options="urlsTableOptions"
    :columns="urlsTableColumns"
    :headers="['Z-link', 'Long Url', 'Owner', 'Clicks', 'Created', 'Actions']"
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
</template>
<script setup lang="ts">
import { ref, computed } from "vue";
import { renderOwnerCell } from "@/components/DataTables/renderOwnerCell";
import DataTable from "@/components/DataTables/DataTable.vue";
import DropDownMenu from "../DropDownMenu.vue";
import DropDownMenuItem from "../DropDownMenuItem.vue";
import Modal from "../Modal.vue";
import {
  Zlink,
  DataTableApi,
  DataTableColumnOptions,
  DataTableOptions,
  Collection,
} from "@/types";
import TransferUrlForm from "../TransferUrlForm.vue";
import EditUrlModal from "../EditUrlModal.vue";
import ConfirmDangerModal from "../ConfirmDangerModal.vue";
import * as api from "@/api";

const selectedRows = ref<Zlink[]>([]);
const datatable = ref<DataTableApi<Zlink> | null>(null);
const isBulkTransferModalOpen = ref(false);
const isEditModalOpen = ref(false);
const isRemoveModalOpen = ref(false);
const urlToChange = ref<Partial<Zlink> | null>(null);
const rowToChange = ref<string | null>(null);

const props = defineProps<{
  group: Collection;
}>();

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

  if (action === "remove-from-group") {
    urlToChange.value = dt.row(row).data();
    isRemoveModalOpen.value = true;
    rowToChange.value = row;
  }
}

const hasNoSelectedRows = computed(() => selectedRows.value.length === 0);

const urlsTableOptions: DataTableOptions = {
  ajax: `/shortener/admin/groups/${props.group.id}/urls.json`,
  serverSide: true,
  order: [[1, "asc"]],
};

const urlsTableColumns: DataTableColumnOptions[] = [
  {
    data: "keyword",
    render: (keyword: string, _, row) => {
      return `
        <div class="tw-flex tw-flex-col keyword-col">
          <a href="/shortener/urls/${keyword}">
            ${keyword}
          </a>
        </div>
      `;
    },
  },
  {
    data: "url",
    render: (url: string) => {
      return `
        <a class="tw-block tw-text-neutral-500 hover:tw-underline tw-text-xs admin-urls-datatable__long-url-col" href="${url}" title="${url}">${url}</a>
      `;
    },
  },
  {
    data: "group_name",
    render: (_data, _type, row) => renderOwnerCell(row),
  },
  {
    data: "total_clicks",
    searchable: false,
    render(data: number, type: string, row: Zlink) {
      const href = `/shortener/urls/${row.keyword}`;
      const conditionalClasses =
        data > 0 ? "tw-bg-sky-100" : "tw-bg-[rgba(0,0,0,0.05)]";
      return `
    <a href="${href}" class="${conditionalClasses} tw-py-1 tw-px-2 tw-rounded-full tw-text-sky-700 hover:tw-no-underline hover:tw-bg-sky-600 hover:tw-text-sky-100 tw-whitespace-nowrap">
      ${data} click${data != 1 ? "s" : ""}
    </a>
  `;
    },
  },
  {
    data: "created_at",
    searchable: false,
  },
  {
    data: "id",
    render(id, type, row, meta) {
      return `
          <div class="tw-flex tw-flex-wrap">
            <button
              class="tw-uppercase tw-text-xs tw-font-medium tw-p-2 hover:tw-bg-sky-50 tw-text-sky-700  tw-rounded tw-transition-colors tw-whitespace-nowrap"
              data-action="edit"
              data-id="${id}"
              data-row="${meta.row}"
            >Edit</button>
          </div>
        `;
    },
    orderable: false,
    searchable: false,
  },
];
</script>
<style>
.admin-urls-datatable__group-col {
  display: block;
  max-width: 8rem;
  overflow: hidden;
  white-space: nowrap;
  text-overflow: ellipsis;
}

.admin-urls-datatable__group-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 1rem;
  height: 1rem;
  /* need min-width and min-height to prevent icon from shrinking */
  min-width: 1rem;
  min-height: 1rem;
}

.admin-urls-datatable__long-url-col {
  display: block;
  max-width: 16rem;
}
</style>
