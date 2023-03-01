<template>
  <div class="tw-relative">
    <div class="tw-relative">
      <SearchIcon
        class="tw-absolute tw-top-1/2 tw--translate-y-1/2 tw-left-2"
      />
      <Input
        :id="id"
        :value="searchQuery"
        placeholder="Search for User..."
        class="tw-pl-10"
        @input="handleInputChange"
      />
      <button>
        <XCircleIcon
          class="tw-absolute tw-top-1/2 tw--translate-y-1/2 tw-right-2 tw-text-neutral-500 hover:tw-text-white hover:tw-bg-neutral-900 tw-rounded-full"
          @click="handleClear"
        />
      </button>
    </div>
    <ul class="tw-max-h-[50vh] tw-overflow-y-scroll" data-cy="person-search-list">
      <li v-for="user in users" :key="user.umndid" class="tw-my-2">
        <button
          class="tw-text-left tw-p-2 tw-w-full tw-bg-sky-100 hover:tw-shadow-sm hover:tw-shadow-sky-100 hover:tw-bg-sky-50 tw-transition-all tw-rounded"
          @click="handleUserSelect(user)"
        >
          <p class="tw-text-sky-700">
            {{ user.display_name }}
          </p>
          <p class="tw-text-gray-500 tw-text-sm">
            {{ user.internet_id }}
          </p>
        </button>
      </li>
    </ul>
  </div>
</template>
<script setup lang="ts">
import { ref } from "vue";
import Input from "./Input.vue";
import { LookupUserResponse } from "@/types";
import pDebounce from "p-debounce";
import { lookupUsers } from "@/api";
import SearchIcon from "@/icons/SearchIcon.vue";
import XCircleIcon from "@/icons/XCircleIcon.vue";

const props = withDefaults(
  defineProps<{
    id?: string;
    query?: string;
  }>(),
  {
    id: "person-search",
    query: "",
  }
);

const emit = defineEmits<{
  (event: "selectUser", user: LookupUserResponse): void;
}>();

const searchQuery = ref(props.query);
const users = ref<LookupUserResponse[]>([]);

const debouncedLookup = pDebounce(lookupUsers, 200);

async function handleInputChange(event: Event) {
  const query = (event.target as HTMLInputElement).value;
  searchQuery.value = query;
  const res = await debouncedLookup(query);

  if (!res.success) {
    return console.error(res.errors);
  }

  users.value = res.data!;
}

function handleUserSelect(user: LookupUserResponse) {
  emit("selectUser", user);
  searchQuery.value = "";
  users.value = [];
}

function handleClear() {
  searchQuery.value = "";
  users.value = [];
}
</script>
<style scoped></style>
