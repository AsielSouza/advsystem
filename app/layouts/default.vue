<template>
  <div class="h-full w-full bg-gray-50 flex flex-col overflow-hidden">
    <Header />
    <main class="flex-1 w-full overflow-y-auto overflow-x-hidden">
      <slot />
    </main>
  </div>
</template>

<script setup>
import Header from '../components/Header.vue'
</script>

