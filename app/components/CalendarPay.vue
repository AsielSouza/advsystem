<template>
  <div class="w-full">
    <label
      v-if="label"
      :for="calendarId"
      class="block text-sm font-semibold text-gray-800 mb-2.5 tracking-tight"
    >
      {{ label }}
      <span v-if="required" class="text-danger-500 ml-0.5">*</span>
    </label>
    <div class="relative">
      <input
        :id="calendarId"
        type="date"
        :value="modelValue"
        :min="minDate"
        :max="maxDate"
        :disabled="disabled"
        :required="required"
        :class="inputClasses"
        @input="handleInput"
        @blur="$emit('blur', $event)"
        @focus="$emit('focus', $event)"
      />
      <div class="absolute right-4 top-1/2 -translate-y-1/2 pointer-events-none">
        <svg
          class="w-5 h-5 text-gray-400"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"
          />
        </svg>
      </div>
    </div>
    <p v-if="error" class="mt-1 text-xs text-danger-600 font-medium">
      {{ error }}
    </p>
    <p v-else-if="hint" class="mt-1 text-xs text-gray-500">
      {{ hint }}
    </p>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  modelValue: {
    type: String,
    default: ''
  },
  label: {
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
  minDate: {
    type: String,
    default: ''
  },
  maxDate: {
    type: String,
    default: ''
  },
  id: {
    type: String,
    default: ''
  }
})

const emit = defineEmits(['update:modelValue', 'blur', 'focus'])

const calendarId = computed(() => props.id || `calendar-${Math.random().toString(36).substr(2, 9)}`)

const inputClasses = computed(() => [
  'w-full',
  'px-5',
  'py-3.5',
  'pr-12',
  'border',
  'rounded-xl',
  'text-gray-900',
  'focus:outline-none',
  'focus:ring-2',
  'focus:ring-offset-0',
  'transition-all',
  'duration-200',
  'ease-in-out',
  'shadow-sm',
  'hover:shadow-md',
  'focus:shadow-lg',
  props.error
    ? 'border-danger-400 focus:ring-danger-500 focus:border-danger-500 bg-danger-50/30'
    : 'border-gray-200 focus:ring-primary-500 focus:border-primary-500 bg-white hover:border-gray-300',
  props.disabled ? 'bg-gray-50 cursor-not-allowed opacity-50 border-gray-200' : ''
])

const handleInput = (event) => {
  emit('update:modelValue', event.target.value)
}
</script>

