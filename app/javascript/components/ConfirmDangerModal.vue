<template>
  <Modal :isOpen="isOpen" @close="$emit('close')">
    <div
      class="tw-text-center sm:tw-flex tw-items-start tw-gap-6 sm:tw-text-left"
    >
      <div
        class="tw-rounded-full tw-bg-red-100 tw-text-red-600 tw-inline-flex tw-p-2 tw-mb-4 sm:tw-p-3"
      >
        <ExclamationTriangleIcon />
      </div>
      <div>
        <h2 class="tw-text-xl tw-mb-4 tw-font-semibold">
          {{ title }}
        </h2>
        <p class="tw-text-neutral-500 tw-mb-4">
          <slot>
            Are you sure you want to delete this? This action cannot be undone.
          </slot>
        </p>
        <div
          class="tw-flex tw-flex-col tw-gap-2 sm:tw-flex-row-reverse sm:tw-justify-start tw-items-center"
        >
          <button
            class="tw-py-2 tw-px-4 tw-bg-red-600 tw-text-red-50 tw-rounded tw-border-red-800 hover:tw-shadow-sm hover:tw-shadow-red-200 tw-transition-shadow"
            @click="$emit('confirm')"
          >
            {{ buttonLabel || "Confirm" }}
          </button>
          <button
            class="tw-py-2 tw-px-4 tw-border-neutral-300 tw-border hover:tw-shadow-sm"
            @click="$emit('close')"
          >
            Cancel
          </button>
        </div>
      </div>
    </div>
  </Modal>
</template>
<script setup lang="ts">
import ExclamationTriangleIcon from "@/icons/ExclamationTriangleIcon.vue";
import Modal from "@/components/Modal.vue";
defineProps<{
  isOpen: boolean;
  title: string;
  buttonLabel?: string;
}>();

defineEmits<{
  (event: "confirm"): void;
  (event: "close"): void;
}>();
</script>
<style scoped></style>
