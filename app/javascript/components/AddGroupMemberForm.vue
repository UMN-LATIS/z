<template>
  <form @submit.prevent="handleSubmit">
    <div v-if="errors">
      <div v-for="error in errors" :key="error">
        {{ error }}
      </div>
    </div>

    <h1 class="tw-text-xl tw-mb-4 tw-font-bold tw-pb-2 tw-border-b-2">
      Add Group Member
    </h1>

    <div class="tw-my-4">
      <Label for="person-search">New Member</Label>
      <button
        v-show="userToAdd"
        type="button"
        class="tw-text-sky-700 hover:tw-sky-600 tw-p-4 tw-bg-sky-50 tw-border-sky-300 tw-border tw-rounded tw-full hover:tw-shadow-lg hover:tw-shadow-sky-100 tw-transition-all tw-flex tw-gap-2 tw-justify-between tw-items-center tw-w-full"
        @click="userToAdd = null"
      >
        <div class="tw-flex tw-gap-2">
          <UserCicleIcon />
          <div class="tw-flex tw-flex-col tw-text-left">
            <div>{{ userToAdd?.display_name }}</div>
            <div class="tw-sky-400 tw-text-xs">
              {{ userToAdd?.internet_id }}
            </div>
          </div>
        </div>
        <span class="tw-uppercase tw-text-sm tw-font-semibold tw-tracking-wide"
          >Change</span
        >
      </button>
      <PersonSearch v-show="!userToAdd" @selectUser="handleSelect" />
    </div>

    <div class="tw-flex tw-justify-end tw-mt-4 tw-pt-4 tw-gap-2">
      <button
        class="tw-uppercase tw-font-semibold tw-text-sky-700 hover:tw-text-sky-600 tw-px-4 tw-py-2 tw-text-sm tw-tracking-wide"
        @click="handleCancel"
      >
        Cancel
      </button>
      <Button type="submit" :disabled="!userToAdd" class="tw-px-4 tw-py-2">
        Add Member
      </Button>
    </div>
  </form>
</template>
<script setup lang="ts">
import { ref } from "vue";
import {
  LookupUserResponse,
  Zlink,
  TransferRequest,
  Collection,
} from "@/types";
import PersonSearch from "./PersonSearch.vue";
import UserCicleIcon from "@/icons/UserCircleIcon.vue";
import { SimpleTable, SimpleTh, SimpleTd } from "./SimpleTable";
import Label from "./Label.vue";
import Button from "./Button.vue";
import * as api from "@/api";

const props = defineProps<{
  group: Collection;
}>();

const emit = defineEmits<{
  (event: "close"): void;
  (event: "success", transferRequest: TransferRequest): void;
}>();

const errors = ref<string[] | null>(null);

const userToAdd = ref<LookupUserResponse | null>(null);

function handleCancel() {
  userToAdd.value = null;
  emit("close");
}

function handleSelect(user: LookupUserResponse) {
  userToAdd.value = user;
}

async function handleSubmit() {
  if (!userToAdd.value) return;
  errors.value = [];

  const res = await api.addUserToCollection({
    umndid: userToAdd.value.umndid,
    collectionId: props.group.id,
  });

  if (res.success && "data" in res) {
    emit("success", res.data);
    userToAdd.value = null;
    return;
  }

  console.error("Transfer error", { res });
  alert("Something went wrong with the transfer");
}
</script>
<style scoped></style>
