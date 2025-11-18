<template>
  <div class="min-h-screen bg-gray-50">
    <Header />
    <main class="max-w-full mx-auto">
      <slot />
    </main>
  </div>
</template>

<script setup>
import Header from '../components/Header.vue'
</script>

