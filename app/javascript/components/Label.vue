<template>
  <label class="tw-font-semibold">
    <slot />
    <span v-if="required" class="tw-text-red-800 tw-text-sm">*</span>
  </label>
</template>
<script setup lang="ts">
withDefaults(
  defineProps<{
    required?: boolean;
  }>(),
  {
    required: false,
  }
);
</script>
<style scoped></style>
