<template>
  <form @submit.prevent="handleSubmit">
    <h1 class="tw-text-xl tw-mb-4 tw-font-bold tw-pb-2">
      <span v-if="group?.id">Edit Collection {{ group.id }}</span>
      <span v-else>New Collection</span>
    </h1>
    <div>
      <Label required>Name</Label>
      <Input v-model="name" required type="text" />
    </div>

    <div>
      <Label>Description</Label>
      <Input v-model="description" type="text" />
    </div>

    <div class="tw-flex tw-justify-end">
      <Button type="submit" :disabled="!name"> Save </Button>
    </div>
  </form>
</template>
<script setup lang="ts">
import { ref, watch } from "vue";
import type { Collection } from "@/types";
import Button from "./Button.vue";
import Input from "./Input.vue";
import Label from "./Label.vue";

const props = defineProps<{
  group: Partial<Collection>;
}>();

const emit = defineEmits<{
  (
    event: "save",
    updatedGroup: Collection | { name: string; description?: string }
  ): void;
}>();

const name = ref(props.group?.name ?? "");
const description = ref(props.group?.description ?? "");

// if props change, update the form with new values
watch(
  () => props.group,
  (newGroup) => {
    name.value = newGroup?.name ?? "";
    description.value = newGroup?.description ?? "";
  }
);

async function handleSubmit() {
  const updatedGroup = {
    ...props.group,
    name: name.value,
    description: description.value,
    updated_at: new Date().toISOString(),
  };
  emit("save", updatedGroup);
}
</script>
<style scoped></style>
