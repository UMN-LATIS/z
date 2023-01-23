<template>
  <div class="test">
    <h1>Test</h1>
    <p>Test</p>
    <button @click="handleClick">{{ count }}</button>
  </div>
</template>
<script setup lang="ts">
import { ref } from 'vue';
const count = ref(0);

function handleClick() {
  console.log('click, count: ', count.value);
  count.value++;
}
</script>
<style scoped>
.test {
  color: red;
}
</style>
