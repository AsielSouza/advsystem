<template>
  <div class="w-full space-y-4">
    <div class="bg-gray-50 rounded-xl border border-gray-200 p-6">
      <p class="text-sm text-gray-600 text-center">
        Tabela de divisão entre parceiros será implementada aqui
      </p>
    </div>
  </div>
</template>

<script setup>
const props = defineProps({
  modelValue: {
    type: Array,
    default: () => []
  },
  error: {
    type: String,
    default: ''
  }
})

const emit = defineEmits(['update:modelValue', 'change'])
</script>
