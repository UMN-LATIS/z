<template>
  <Modal :isOpen="isOpen" @close="handleCancel">
    <form v-if="url" @submit.prevent="handleSubmit">
      <h1 class="tw-text-xl tw-mb-4 tw-font-bold tw-pb-2">
        <span>Edit Z-link {{ url.keyword }}</span>
      </h1>
      <div class="tw-flex tw-flex-col tw-gap-4">
        <div>
          <Label required>Z-link</Label>
          <div
            class="tw-flex tw-items-baseline tw-bg-neutral-100 tw-rounded-md tw-shadow"
          >
            <span
              class="tw-py-2 tw-pl-4 tw-whitespace-nowrap tw-text-neutral-500"
            >
              {{ origin }}/
            </span>

            <Input
              :value="keyword"
              required
              type="text"
              placeholder="your z-link"
              data-cy="keyword-input"
              class="tw-shadow-none tw-bg-transparent tw-px-1"
              @input="handleKeywordChange($event.target.value)"
            />
          </div>
          <p v-if="errors.keyword" class="tw-mt-2">
            <span class="tw-text-red-500 tw-text-sm tw-ml-2">
              Z-Link {{ errors.keyword }}
            </span>
          </p>
        </div>

        <div>
          <Label required>Long Url</Label>
          <Input
            :value="longUrl"
            data-cy="longurl-input"
            required
            type="text"
            placeholder="your long url"
            @input="handleLongUrlChange($event.target.value)"
          />
        </div>

        <div class="tw-flex tw-justify-end">
          <Button type="submit" :disabled="!keyword || !longUrl"> Save </Button>
        </div>
      </div>
    </form>
  </Modal>
</template>
<script setup lang="ts">
import { ref, watch, reactive } from "vue";
import type { Zlink } from "@/types";
import Button from "./Button.vue";
import Input from "./Input.vue";
import Label from "./Label.vue";
import Modal from "./Modal.vue";
import * as api from "@/api";

const props = defineProps<{
  url: Partial<Zlink> | null;
  isOpen: boolean;
}>();

const emit = defineEmits<{
  (event: "close");
  (event: "success", zlink: Zlink);
}>();

const origin = window.location.origin;
const keyword = ref(props.url?.keyword ?? "");
const longUrl = ref(props.url?.url ?? "");
const errors = reactive<Record<string, string>>({
  keyword: "",
  url: "",
});

function handleKeywordChange(value: string) {
  keyword.value = value;
}
function handleLongUrlChange(value: string) {
  longUrl.value = value;
}

watch(
  () => props.url,
  (newUrl) => {
    keyword.value = newUrl?.keyword ?? "";
    longUrl.value = newUrl?.url ?? "";
  },
  { immediate: true }
);

async function handleSubmit() {
  if (!props.url?.id) throw new Error("Cannot update url without id");

  errors.keyword = "";
  errors.url = "";

  const res = await api.updateUrl(props.url.id, {
    url: longUrl.value,
    keyword: keyword.value,
  });

  if (res.success) {
    emit("success", {
      id: props.url.id,
      url: longUrl.value,
      keyword: keyword.value,
    } as Zlink);
    keyword.value = "";
    longUrl.value = "";
    return;
  }

  if (res.errors) {
    errors.keyword = res.errors.keyword?.join(". ") ?? "";
    errors.url = res.errors.url?.join(". ") ?? "";
  }
}

function handleCancel() {
  emit("close");
  keyword.value = "";
  longUrl.value = "";
}
</script>
<style scoped></style>
