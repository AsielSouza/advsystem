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
  primary: 'bg-gradient-to-r from-primary-600 to-primary-700 hover:from-primary-700 hover:to-primary-800 text-white focus:ring-primary-500 shadow-md hover:shadow-lg active:shadow-sm',
  secondary: 'bg-gradient-to-r from-gray-500 to-gray-600 hover:from-gray-600 hover:to-gray-700 text-white focus:ring-gray-500 shadow-md hover:shadow-lg active:shadow-sm',
  success: 'bg-gradient-to-r from-success-500 to-success-600 hover:from-success-600 hover:to-success-700 text-white focus:ring-success-500 shadow-md hover:shadow-lg active:shadow-sm',
  danger: 'bg-gradient-to-r from-danger-500 to-danger-600 hover:from-danger-600 hover:to-danger-700 text-white focus:ring-danger-500 shadow-md hover:shadow-lg active:shadow-sm',
  warning: 'bg-gradient-to-r from-warning-500 to-warning-600 hover:from-warning-600 hover:to-warning-700 text-white focus:ring-warning-500 shadow-md hover:shadow-lg active:shadow-sm',
  outline: 'border-2 border-gray-300 text-gray-700 hover:bg-gray-50 hover:border-gray-400 focus:ring-gray-500 bg-transparent hover:shadow-md active:shadow-sm'
}

const sizeClasses = {
  sm: 'px-5 py-2.5 text-sm',
  md: 'px-7 py-3.5 text-base font-semibold',
  lg: 'px-9 py-4.5 text-lg font-semibold'
}

const buttonClasses = computed(() => [
  'rounded-xl',
  'font-semibold',
  'transition-all',
  'duration-200',
  'ease-in-out',
  'focus:outline-none',
  'focus:ring-2',
  'focus:ring-offset-2',
  'transform',
  'hover:scale-[1.02]',
  'active:scale-[0.98]',
  'disabled:transform-none',
  variantClasses[props.variant],
  sizeClasses[props.size],
  props.fullWidth ? 'w-full' : '',
  props.disabled ? 'opacity-50 cursor-not-allowed shadow-none hover:shadow-none' : 'cursor-pointer'
])
</script>

