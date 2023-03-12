<template>
  <DataTable
    ref="table"
    class="vue-datatable table table-striped table-bordered !tw-w-full"
    :data="data"
    :options="mergedOpts"
    :columns="mergedCols"
    @click="handleDataTableClick"
  >
    <slot name="thead">
      <thead>
        <tr>
          <!-- hack: use td on the filter cells within the head to prevent datatables from doing weird resizing -->
          <td v-if="selectable" class="!tw-border-none"></td>
          <td
            v-for="(col, index) in columns"
            :key="index"
            class="!tw-p-1 !tw-pl-0 first:!tw-pl-1 !tw-border-none"
          >
            <div
              v-if="col?.searchable ?? true"
              class="tw-flex tw-items-center tw-px-2 tw-gap-2 focus-within:tw-border-blue-700 tw-border tw-border-transparent tw-bg-neutral-100 tw-rounded"
            >
              <input
                type="text"
                placeholder="Filter..."
                spellcheck="false"
                class="tw-border-none tw-max-w-full focus:tw-shadow-none focus:tw-outline-none focus:tw-border-none tw-bg-transparent tw-px-0 focus:tw-ring-0 tw-text-xs tw-flex-1"
                @input="
                  debouncedFilterInput(
                    $event,
                    // if this table has a checkbox column, we need to offset the index by 1
                    selectable ? index + 1 : index
                  )
                "
              />
            </div>
          </td>
        </tr>
        <tr>
          <th v-if="props.selectable" class="select-checkbox">
            <input id="select-all" ref="selectAllCheckbox" type="checkbox" />
            <label for="select-all" class="sr-only"> Select all </label>
          </th>
          <th v-for="header in headers" :key="header">{{ header }}</th>
        </tr>
      </thead>
    </slot>
    <slot>
      <tbody></tbody>
    </slot>
  </DataTable>
</template>
<script setup lang="ts">
import { ref, onMounted } from "vue";
import { deepmerge } from "deepmerge-ts";
import DataTable from "datatables.net-vue3";
import DataTablesLib, {
  type Config as DataTableOptions,
  type Api as DataTableApi,
  type ConfigColumns as DataTableColumnOptions,
} from "datatables.net";
import "datatables.net-select";
import "datatables.net-buttons";
import "datatables.net-bs4";
import debounce from "lodash/debounce";

DataTable.use(DataTablesLib);

const props = withDefaults(
  defineProps<{
    data?: any[];
    options: DataTableOptions;
    columns: DataTableColumnOptions[];
    headers: string[];
    selectable?: boolean;
  }>(),
  { selectable: false }
);

const emit = defineEmits<{
  (event: "mounted", dt: DataTableApi<any>): void;
  (event: "click", e: MouseEvent, dt: DataTableApi<any>): void;
  (event: "select", rows: any[], dt: DataTableApi<any>): void;
}>();

const table = ref<typeof DataTable | null>(null);
const dt = ref<DataTableApi<object> | null>(null);
const selectAllCheckbox = ref<HTMLInputElement | null>(null);

function setAllCheckboxes(checked: boolean) {
  const checkboxes = document.querySelectorAll(".select-checkbox");
  checkboxes.forEach((checkbox) => {
    (checkbox as HTMLInputElement).checked = checked;
  });
}

function selectAllRows() {
  if (!dt.value) throw new Error("No datatable api found");
  dt.value
    .rows({
      page: "current",
    })
    .select();

  setAllCheckboxes(true);
}

function deselectAllRows() {
  if (!dt.value) throw new Error("No datatable api found");
  dt.value
    .rows({
      page: "current",
    })
    .deselect();

  setAllCheckboxes(false);
}

function handleSelectAllClick(e: MouseEvent) {
  if (!dt.value) throw new Error("No datatable api found");
  const checked = (e.target as HTMLInputElement).checked;
  checked ? selectAllRows() : deselectAllRows();
}

function setSelectAllCheckboxState() {
  if (!dt.value) throw new Error("No datatable api found");
  const selectedRows = dt.value.rows({ selected: true } as any);
  const allRows = dt.value.rows();
  const isAllSelected = selectedRows.count() === allRows.count();

  selectAllCheckbox.value!.checked = isAllSelected;
}

function emitSelectedRows(e: Event, dt: DataTableApi<any>) {
  const selectedRows = dt
    .rows({ selected: true } as any)
    .data()
    .toArray();
  emit("select", selectedRows, dt);
}

function handleFilterInput(e: Event, colIndex: number) {
  if (!dt.value) throw new Error("No datatable api found");
  const input = e.target as HTMLInputElement;
  console.log("filteringInput", input.value);
  dt.value.column(colIndex).search(input.value).draw();
}

const debouncedFilterInput = debounce(handleFilterInput, 250);

onMounted(() => {
  if (!table.value) throw new Error("No dataTableRef found");
  dt.value = table.value.dt() as DataTableApi<object>;

  selectAllCheckbox.value?.addEventListener("click", handleSelectAllClick);
  dt.value.on("select", setSelectAllCheckboxState);
  dt.value.on("deselect", setSelectAllCheckboxState);

  dt.value.on("select", emitSelectedRows);
  dt.value.on("deselect", emitSelectedRows);

  emit("mounted", dt.value);
});

// passes both the event and the datatable instance's
// api to the listener
function handleDataTableClick(event: MouseEvent) {
  if (!dt.value) throw new Error("No datatable api found");
  emit("click", event, dt.value);
}

const defaultOptions: DataTableOptions = {
  select: props.selectable
    ? {
        style: "multi",
        selector: ".select-checkbox",
      }
    : false,
  buttons: props.selectable && ["selectAll", "selectNone"],
  pageLength: 25,
  scrollCollapse: true,
  language: {
    emptyTable: "None",
    searchPlaceholder: "Search...",
    search: '<span class="tw-sr-only">Search</span>',
    processing: `<div class="tw-inline-flex tw-p-4 tw-shadow-lg tw-border tw-bg-neutral-100 tw-max-w-sm tw-mx-auto">Loading...</div>`,
  },
  processing: true,
};

const checkboxCol: DataTableColumnOptions = {
  data: "id", // this presumes there's always an id column on the server side
  orderable: false,
  render: (id) =>
    `<input type="checkbox" class="select-checkbox" value="${id}" />`,
  defaultContent: "",
};

const mergedOpts = deepmerge(defaultOptions, props.options);
const mergedCols = props.selectable
  ? [checkboxCol, ...props.columns]
  : props.columns;
</script>
<style>
div.dataTables_wrapper div.dataTables_processing {
  position: absolute;
  margin: 0;
  width: 100%;
  top: 3rem;
  left: 0;
  right: 0;
  z-index: 10;
  display: flex;
  align-items: center;
  justify-content: center;
}
</style>
