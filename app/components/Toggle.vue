<template>
  <div class="w-full">
    <label
      v-if="label"
      :for="toggleId"
      class="block text-sm font-semibold text-gray-800 mb-2.5 tracking-tight"
    >
      {{ label }}
      <span v-if="required" class="text-danger-500 ml-0.5">*</span>
    </label>
    <div class="flex items-center gap-3">
      <button
        :id="toggleId"
        type="button"
        role="switch"
        :aria-checked="modelValue"
        :aria-label="label || 'Toggle'"
        :disabled="disabled"
        :class="toggleClasses"
        @click="handleToggle"
      >
        <span
          :class="thumbClasses"
          class="pointer-events-none inline-block h-5 w-5 rounded-full bg-white shadow-lg transform ring-0 transition-all duration-200 ease-in-out"
        />
      </button>
      <p
        v-if="description"
        class="text-sm text-gray-600 font-normal"
      >
        {{ description }}
      </p>
    </div>
    <p
      v-if="error"
      class="mt-2 text-sm text-danger-600 font-medium flex items-center gap-1.5"
    >
      <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
        <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
      </svg>
      {{ error }}
    </p>
    <p
      v-if="hint && !error"
      class="mt-2 text-sm text-gray-500 font-normal"
    >
      {{ hint }}
    </p>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  modelValue: {
    type: Boolean,
    default: false
  },
  label: {
    type: String,
    default: ''
  },
  description: {
    type: String,
    default: ''
  },
  error: {
    type: String,
    default: ''
  },
  hint: {
    type: String,
    default: ''
  },
  disabled: {
    type: Boolean,
    default: false
  },
  required: {
    type: Boolean,
    default: false
  },
  id: {
    type: String,
    default: ''
  },
  size: {
    type: String,
    default: 'md',
    validator: (value) => ['sm', 'md', 'lg'].includes(value)
  }
})

const emit = defineEmits(['update:modelValue', 'change'])

const toggleId = computed(() => props.id || `toggle-${Math.random().toString(36).substr(2, 9)}`)

const handleToggle = () => {
  if (!props.disabled) {
    const newValue = !props.modelValue
    emit('update:modelValue', newValue)
    emit('change', newValue)
  }
}

const sizeClasses = {
  sm: 'h-5 w-9',
  md: 'h-6 w-11',
  lg: 'h-7 w-13'
}

const thumbSizeClasses = {
  sm: 'h-4 w-4',
  md: 'h-5 w-5',
  lg: 'h-6 w-6'
}

const toggleClasses = computed(() => [
  'relative',
  'inline-flex',
  'flex-shrink-0',
  'cursor-pointer',
  'rounded-full',
  'border-2',
  'border-transparent',
  'transition-colors',
  'duration-200',
  'ease-in-out',
  'focus:outline-none',
  'focus:ring-2',
  'focus:ring-offset-2',
  'focus:ring-primary-500',
  sizeClasses[props.size],
  props.modelValue
    ? 'bg-primary-600 hover:bg-primary-700'
    : 'bg-gray-200 hover:bg-gray-300',
  props.disabled
    ? 'opacity-50 cursor-not-allowed hover:bg-gray-200 hover:bg-primary-600'
    : '',
  props.error
    ? 'ring-2 ring-danger-500 ring-offset-0'
    : ''
])

const thumbClasses = computed(() => [
  thumbSizeClasses[props.size],
  props.modelValue
    ? props.size === 'sm'
      ? 'translate-x-4'
      : props.size === 'md'
      ? 'translate-x-5'
      : 'translate-x-6'
    : 'translate-x-0'
])
</script>

