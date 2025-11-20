<template>
  <button
    type="button"
    :disabled="disabled"
    :class="buttonClasses"
    @click="handleClick"
    :title="title || 'Voltar'"
  >
    <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
    </svg>
    <span>{{ label || 'Voltar' }}</span>
  </button>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  label: {
    type: String,
    default: 'Voltar'
  },
  disabled: {
    type: Boolean,
    default: false
  },
  title: {
    type: String,
    default: 'Voltar'
  },
  variant: {
    type: String,
    default: 'outline',
    validator: (value) => ['primary', 'secondary', 'outline'].includes(value)
  }
})

const emit = defineEmits(['click'])

const variantClasses = {
  primary: 'bg-primary-600 hover:bg-primary-700 text-white border-primary-600',
  secondary: 'bg-gray-600 hover:bg-gray-700 text-white border-gray-600',
  outline: 'border-2 border-gray-300 text-gray-700 hover:bg-gray-50 hover:border-gray-400 bg-transparent'
}

const buttonClasses = computed(() => [
  'inline-flex',
  'items-center',
  'justify-center',
  'px-4',
  'py-2.5',
  'rounded-lg',
  'font-medium',
  'text-sm',
  'transition-all',
  'duration-200',
  'ease-in-out',
  'focus:outline-none',
  'focus:ring-2',
  'focus:ring-offset-2',
  'focus:ring-primary-500',
  variantClasses[props.variant],
  props.disabled ? 'opacity-50 cursor-not-allowed' : 'cursor-pointer hover:shadow-md active:shadow-sm'
])

const handleClick = () => {
  if (!props.disabled) {
    emit('click')
  }
}
</script>

