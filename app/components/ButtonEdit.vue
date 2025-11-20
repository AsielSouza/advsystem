<template>
  <button
    type="button"
    :disabled="disabled"
    :class="buttonClasses"
    @click="$emit('click', $event)"
    :title="title || 'Editar'"
  >
    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
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
    default: 'Editar'
  }
})

defineEmits(['click'])

const buttonClasses = computed(() => [
  'w-8 h-8',
  'flex items-center justify-center',
  'bg-primary-100 hover:bg-primary-200',
  'text-primary-600 hover:text-primary-700',
  'rounded-lg',
  'transition-colors',
  'duration-200',
  'focus:outline-none',
  'focus:ring-2',
  'focus:ring-primary-500',
  'focus:ring-offset-1',
  'disabled:opacity-50',
  'disabled:cursor-not-allowed',
  'disabled:hover:bg-primary-100',
  'cursor-pointer'
])
</script>

