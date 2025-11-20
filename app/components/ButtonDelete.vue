<template>
  <button
    type="button"
    :disabled="disabled"
    :class="buttonClasses"
    @click="$emit('click', $event)"
    :title="title || 'Excluir'"
  >
    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
    </svg>
  </button>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  disabled: {
    type: Boolean,
    default: false
  },
  title: {
    type: String,
    default: 'Excluir'
  }
})

defineEmits(['click'])

const buttonClasses = computed(() => [
  'w-8 h-8',
  'flex items-center justify-center',
  'bg-danger-100 hover:bg-danger-200',
  'text-danger-600 hover:text-danger-700',
  'rounded-lg',
  'transition-colors',
  'duration-200',
  'focus:outline-none',
  'focus:ring-2',
  'focus:ring-danger-500',
  'focus:ring-offset-1',
  'disabled:opacity-50',
  'disabled:cursor-not-allowed',
  'disabled:hover:bg-danger-100',
  'cursor-pointer'
])
</script>

