<template>
  <div class="tw-flow-root">
    <div class="tw--my-2 tw--mx-6 tw-overflow-x-auto lg:tw--mx-8">
      <div
        class="tw-inline-block tw-min-w-full tw-py-2 tw-align-middle sm:tw-px-6 lg:tw-px-8"
      >
        <table class="tw-min-w-full tw-divide-y tw-divide-neutral-300">
          <thead>
            <slot name="thead" />
          </thead>
          <tbody class="tw-divide-y tw-divide-neutral-200">
            <slot name="tbody" />
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>
<script setup lang="ts"></script>
<style scoped></style>
