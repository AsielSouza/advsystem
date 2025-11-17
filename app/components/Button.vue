<template>
  <button
    :type="type"
    :disabled="disabled"
    :class="buttonClasses"
    @click="$emit('click', $event)"
  >
    <slot />
  </button>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  type: {
    type: String,
    default: 'button',
    validator: (value) => ['button', 'submit', 'reset'].includes(value)
  },
  variant: {
    type: String,
    default: 'primary',
    validator: (value) => ['primary', 'secondary', 'success', 'danger', 'warning', 'outline'].includes(value)
  },
  size: {
    type: String,
    default: 'md',
    validator: (value) => ['sm', 'md', 'lg'].includes(value)
  },
  disabled: {
    type: Boolean,
    default: false
  },
  fullWidth: {
    type: Boolean,
    default: false
  }
})

defineEmits(['click'])

const variantClasses = {
  primary: 'bg-primary-600 hover:bg-primary-700 text-white focus:ring-primary-500',
  secondary: 'bg-gray-500 hover:bg-gray-600 text-white focus:ring-gray-500',
  success: 'bg-success-500 hover:bg-success-600 text-white focus:ring-success-500',
  danger: 'bg-danger-500 hover:bg-danger-600 text-white focus:ring-danger-500',
  warning: 'bg-warning-500 hover:bg-warning-600 text-white focus:ring-warning-500',
  outline: 'border-2 border-primary-300 text-primary-700 hover:bg-primary-50 focus:ring-primary-500'
}

const sizeClasses = {
  sm: 'px-4 py-2 text-sm',
  md: 'px-6 py-3 text-base',
  lg: 'px-8 py-4 text-lg'
}

const buttonClasses = computed(() => [
  'rounded-lg',
  'font-medium',
  'transition-colors',
  'focus:outline-none',
  'focus:ring-2',
  'focus:ring-offset-2',
  variantClasses[props.variant],
  sizeClasses[props.size],
  props.fullWidth ? 'w-full' : '',
  props.disabled ? 'opacity-50 cursor-not-allowed' : 'cursor-pointer'
])
</script>

