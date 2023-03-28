<template>
  <MenuItem v-slot="{ active }">
    <Component
      :is="href ? 'a' : 'button'"
      :href="href"
      :disabled="disabled"
      :class="[
        'tw-block tw-px-4 tw-py-2 tw-text-sm tw-w-full tw-text-left',
        active && !disabled
          ? 'tw-bg-gray-100 tw-text-gray-900'
          : 'tw-text-gray-700',
        disabled && 'tw-opacity-30 tw-cursor-not-allowed',
      ]"
    >
      <slot />
    </Component>
  </MenuItem>
</template>
<script setup lang="ts">
import { MenuItem } from "@headlessui/vue";

withDefaults(
  defineProps<{
    href?: string;
    disabled?: boolean;
  }>(),
  {
    href: undefined,
    disabled: false,
  }
);
</script>
<style scoped></style>
