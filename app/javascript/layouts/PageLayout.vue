<template>
  <div>
    <div class="tw-mt-16 tw-mb-4 tw-text-center">
      <slot name="header">
        <h1>Page Header</h1>
      </slot>
    </div>
    <div class="tw-p-4">
      <slot />
    </div>
  </div>
</template>
<script setup lang="ts"></script>
<style scoped></style>
