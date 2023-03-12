<template>
  <div class="tw-relative">
    <Button
      class="tw-w-full tw-mb-4 sm:tw-w-auto sm:tw-absolute sm:tw-top-0 sm:tw-left-0 tw-z-10"
      @click="isCreating = true"
    >
      Add Member
    </Button>
    <DataTable
      :options="membersTableOptions"
      :columns="membersTableColumns"
      :data="members"
      :headers="['Name', 'Email', 'Created', 'Actions']"
      @mounted="handleDataTableMounted"
      @click="handleDataTableClick"
    />

    <Modal :isOpen="isCreating" @close="isCreating = false">
      <AddGroupMemberForm
        :group="group"
        @close="isCreating = false"
        @success="handleAddMemberSuccess"
      />
    </Modal>

    <ConfirmDangerModal
      :isOpen="isRemoveUserModalOpen"
      :title="`Remove User: ${userToChange?.display_name ?? 'Unknown'}`"
      @close="isRemoveUserModalOpen = false"
      @confirm="handleRemoveUserFromGroup"
    >
      Are you sure you want to remove
      <b>{{ userToChange?.display_name }}</b> from <b>{{ group.name }}</b
      >?
    </ConfirmDangerModal>
  </div>
</template>
<script setup lang="ts">
import { ref, reactive, watch } from "vue";
import DataTable from "@/components/DataTables/DataTable.vue";
import Button from "@/components/Button.vue";
import Modal from "../Modal.vue";
import ConfirmDangerModal from "@/components/ConfirmDangerModal.vue";
import * as api from "@/api";
import type {
  DataTableOptions,
  DataTableColumnOptions,
  DataTableApi,
  User,
  Collection,
} from "@/types";
import AddGroupMemberForm from "../AddGroupMemberForm.vue";

const props = defineProps<{
  members: User[];
  group: Collection;
}>();

const emit = defineEmits<{
  (event: "addMember", user: User): void;
  (event: "removeMember", userId: number): void;
}>();

watch(
  () => props.members,
  (members) => {
    console.log("members changed", members);

    if (!datatable.value) throw new Error("No datatable api found");

    // redraw the table with the new data
    datatable.value.clear().rows.add(members).draw();
  }
);

const isRemoveUserModalOpen = ref(false);
const userToChange = ref<Partial<User> | null>(null);
const rowToChange = ref<string | null>(null);
const datatable = ref<DataTableApi<User> | null>(null);
const isCreating = ref(false);

const actions = {
  CREATE_GROUP_MEMBER: "create-group-member",
  REMOVE_GROUP_MEMBER: "remove-group-member",
};

function handleDataTableMounted(dt: DataTableApi<User>) {
  datatable.value = dt;
}

function handleDataTableClick(event: MouseEvent) {
  if (!datatable.value) throw new Error("No datatable api found");

  const target = event.target as HTMLElement;
  const { action, row } = target.dataset;

  if (!action) return;

  if (!row) {
    throw new Error(
      `Row not found for action ${action}. Be sure to set the data-row attribute on the element.`
    );
  }

  if (action === actions.REMOVE_GROUP_MEMBER) {
    userToChange.value = datatable.value.row(row).data();
    isRemoveUserModalOpen.value = true;
    rowToChange.value = row;
  }
}

function handleAddMemberSuccess(user: User) {
  if (!datatable.value) throw new Error("No datatable api found");

  emit("addMember", user);
  // datatable.value.row.add(user).draw();
  isCreating.value = false;
}

async function handleRemoveUserFromGroup() {
  if (!datatable.value) throw new Error("No datatable api found");
  if (!rowToChange.value) throw new Error("No edited row found");
  if (!userToChange.value?.id) throw new Error("No edited item found");

  const userId = userToChange.value.id;

  const res = await api.removeUserFromCollection(userId, props.group.id);

  if (!res.success) {
    throw new Error(`Failed to remove user from group. ${res.message}`);
  }

  emit("removeMember", userToChange.value.id);

  // reset the edited row and item
  rowToChange.value = null;
  userToChange.value = null;
  isRemoveUserModalOpen.value = false;
}

const membersTableOptions: DataTableOptions = reactive({
  /**
   we're not doing using ajax with this datatable since some member attributes(like internet_id and display_name) are not columns in the db, but rather methods that do an ldap lookup so it gets complicated. We could do it with ajax, but then the column wouldn't be searchable or sortable. Instead, we opt to pass the members in as props.
  */
  serverSide: false,
  paging: false,
  info: false,
});

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
    data: "id",
    orderable: false,
    searchable: false,
    render(id, type, row, meta) {
      return `
          <div class="tw-flex tw-flex-wrap">
            <button
              id="delete-button"
              class="tw-uppercase tw-text-xs tw-font-medium tw-p-2 tw-text-red-700 tw-rounded hover:tw-bg-red-50"
              data-action="${actions.REMOVE_GROUP_MEMBER}"
              data-id="${id}"
              data-row="${meta.row}"
            >Remove</button>
          </div>
        `;
    },
  },
];
</script>
<style scoped></style>
