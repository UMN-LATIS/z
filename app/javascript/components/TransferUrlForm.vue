<template>
  <form @submit.prevent="handleSubmit">
    <div v-if="errors">
      <div v-for="error in errors" :key="error">
        {{ error }}
      </div>
    </div>

    <h1 class="tw-text-xl tw-mb-4 tw-font-bold tw-pb-2 tw-border-b-2">
      Transfer {{ selectedRows.length }}
      {{ pluralize(selectedRows.length, "link", "links") }}
    </h1>

    <div class="tw-my-4">
      <Label for="person-search">To</Label>
      <button
        v-show="userToTransferTo"
        type="button"
        class="tw-text-sky-700 hover:tw-sky-600 tw-p-4 tw-bg-sky-50 tw-border-sky-300 tw-border tw-rounded tw-full hover:tw-shadow-lg hover:tw-shadow-sky-100 tw-transition-all tw-flex tw-gap-2 tw-justify-between tw-items-center tw-w-full"
        @click="userToTransferTo = null"
      >
        <div class="tw-flex tw-gap-2">
          <UserCicleIcon />
          <div class="tw-flex tw-flex-col tw-text-left">
            <div>{{ userToTransferTo?.display_name }}</div>
            <div class="tw-sky-400 tw-text-xs">
              {{ userToTransferTo?.internet_id }}
            </div>
          </div>
        </div>
        <span class="tw-uppercase tw-text-sm tw-font-semibold tw-tracking-wide"
          >Change</span
        >
      </button>
      <PersonSearch v-show="!userToTransferTo" @selectUser="handleSelect" />
    </div>

    <SimpleTable>
      <template #thead>
        <tr>
          <SimpleTh>Z-Link</SimpleTh>
          <SimpleTh>Long Url</SimpleTh>
          <SimpleTh>Current Owner</SimpleTh>
        </tr>
      </template>
      <template #tbody>
        <tr v-for="row in selectedRows" :key="row.id">
          <SimpleTd>{{ row.keyword }}</SimpleTd>
          <SimpleTd>{{ row.url }}</SimpleTd>
          <SimpleTd>{{ row.group_name }}</SimpleTd>
        </tr>
      </template>
    </SimpleTable>

    <div class="tw-flex tw-justify-end tw-mt-4 tw-pt-4 tw-gap-2">
      <button
        class="tw-uppercase tw-font-semibold tw-text-sky-700 hover:tw-text-sky-600 tw-p-4 tw-text-sm tw-tracking-wide"
        @click="$emit('close')"
      >
        Cancel
      </button>
      <Button type="submit" :disabled="!userToTransferTo">Transfer</Button>
    </div>
  </form>
</template>
<script setup lang="ts">
import { ref } from "vue";
import { pluralize } from "@/utils";
import { LookupUserResponse, Zlink, TransferRequest } from "@/types";
import PersonSearch from "./PersonSearch.vue";
import UserCicleIcon from "@/icons/UserCircleIcon.vue";
import { SimpleTable, SimpleTh, SimpleTd } from "./SimpleTable";
import Label from "./Label.vue";
import Button from "./Button.vue";
import * as api from "@/api";

const props = defineProps<{
  selectedRows: Zlink[];
}>();

const emit = defineEmits<{
  (event: "close"): void;
  (event: "success", transferRequest: TransferRequest): void;
}>();

const errors = ref<string[] | null>(null);

const userToTransferTo = ref<LookupUserResponse | null>(null);

function handleSelect(user: LookupUserResponse) {
  userToTransferTo.value = user;
}

async function handleSubmit() {
  if (!userToTransferTo.value) return;
  errors.value = [];

  const res = await api.bulkTransferUrlsToUser(
    props.selectedRows.map((row) => row.keyword),
    userToTransferTo.value
  );

  if (res.success) {
    emit("success", res.data as TransferRequest);
    userToTransferTo.value = null;
    return;
  }

  console.error(res);
  alert("Something went wrong with the transfer");
}
</script>
<style scoped></style>
