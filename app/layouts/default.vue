<template>
  <div class="min-h-screen bg-gray-50 flex flex-col">
    <Header />
    <main class="flex-1 w-full overflow-auto">
      <slot />
    </main>
  </div>
</template>

<script setup>
import Header from '../components/Header.vue'
</script>

