<template>
  <Teleport to="body">
    <Transition
      enterActiveClass="tw-ease-out tw-duration-300"
      enterFromClass="tw-opacity-0"
      enterToClass="tw-opacity-100"
      leaveActiveClass="tw-ease-in tw-duration-200"
      leaveFromClass="tw-opacity-100"
      leaveToClass="tw-opacity-0"
    >
      <div
        v-show="isOpen"
        class="tw-fixed tw-inset-0 tw-w-full tw-h-full tw-bg-[rgba(0,0,0,0.5)] tw-flex tw-items-end tw-p-4 sm:tw-items-center tw-justify-center tw-z-[200]"
        @mousedown="$emit('close')"
      >
        <div
          class="tw-bg-white tw-w-full tw-max-w-screen-sm tw-max-h-[80vh] tw-p-8 tw-relative tw-rounded tw-overflow-y-auto tw-z-[210]"
          @mousedown.stop
        >
          <button
            class="tw-absolute tw-right-4 tw-top-4 tw-rounded-md tw-bg-white tw-p-2 tw-text-neutral-400 hover:tw-text-neutral-900 tw-transition-colors"
            @click="$emit('close')"
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              stroke-width="1.5"
              stroke="currentColor"
              class="tw-w-6 tw-h-6"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                d="M6 18L18 6M6 6l12 12"
              />
            </svg>
            <span class="sr-only">Close</span>
          </button>
          <slot></slot>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup lang="ts">
import { onMounted } from "vue";

const props = defineProps<{
  isOpen: boolean;
}>();

const emit = defineEmits<{
  (event: "close"): void;
}>();

onMounted(() => {
  document.addEventListener("keydown", (e) => {
    if (props.isOpen && e.keyCode == 27) {
      emit("close");
    }
  });
});
</script>

<style scoped></style>
