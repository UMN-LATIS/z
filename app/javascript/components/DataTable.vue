<template>
  <DataTable
    ref="table"
    class="table table-striped table-bordered"
    :options="mergedOpts"
    :columns="mergedCols"
    @click="handleDataTableClick"
  >
    <slot name="thead">
      <thead>
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

DataTable.use(DataTablesLib);

const props = withDefaults(
  defineProps<{
    options: DataTableOptions;
    columns: DataTableColumnOptions[];
    headers: string[];
    selectable?: boolean;
  }>(),
  { selectable: false }
);

const emit = defineEmits<{
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

onMounted(() => {
  if (!table.value) throw new Error("No dataTableRef found");
  dt.value = table.value.dt() as DataTableApi<object>;

  selectAllCheckbox.value?.addEventListener("click", handleSelectAllClick);
  dt.value.on("select", setSelectAllCheckboxState);
  dt.value.on("deselect", setSelectAllCheckboxState);

  dt.value.on("select", emitSelectedRows);
  dt.value.on("deselect", emitSelectedRows);
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
  paging: false,
  scrollY: "50vh",
  scrollCollapse: true,
  language: {
    emptyTable: "None",
    searchPlaceholder: "Search...",
    search: '<span class="tw-sr-only">Search</span>',
  },
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
<style scoped></style>
