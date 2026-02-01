<template>
  <div class="w-full">
    <label
      v-if="label"
      :for="inputId"
      class="block text-sm font-semibold text-gray-800 mb-2.5 tracking-tight"
    >
      {{ label }}
      <span v-if="required" class="text-danger-500 ml-0.5">*</span>
    </label>
    <div
      class="relative"
      :class="disabled ? 'cursor-not-allowed' : 'cursor-pointer'"
      @click="openCalendar"
    >
      <input
        ref="inputRef"
        :id="inputId"
        type="date"
        :value="modelValue"
        :placeholder="placeholder"
        :disabled="disabled"
        :required="required"
        :max="maxDate"
        :min="minDate"
        :class="inputClasses"
        @input="$emit('update:modelValue', $event.target.value)"
        @blur="$emit('blur', $event)"
        @focus="$emit('focus', $event)"
      />
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
import { computed, ref } from 'vue'

const props = defineProps({
  modelValue: {
    type: String,
    default: ''
  },
  label: {
    type: String,
    default: ''
  },
  placeholder: {
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
  maxDate: {
    type: String,
    default: ''
  },
  minDate: {
    type: String,
    default: ''
  }
})

defineEmits(['update:modelValue', 'blur', 'focus'])

const inputRef = ref(null)

/**
 * Abre o calendário nativo ao clicar em qualquer parte do campo.
 * Usa showPicker() quando disponível, fallback para focus + click.
 */
const openCalendar = () => {
  if (props.disabled) return
  const input = inputRef.value
  if (!input) return
  if (typeof input.showPicker === 'function') {
    input.showPicker()
  } else {
    input.focus()
    input.click()
  }
}

// Função para gerar hash simples e determinístico baseado em string
const hashString = (str) => {
  let hash = 0
  if (str.length === 0) return '0'
  for (let i = 0; i < str.length; i++) {
    const char = str.charCodeAt(i)
    hash = ((hash << 5) - hash) + char
    hash = hash & hash // Convert to 32bit integer
  }
  return Math.abs(hash).toString(36)
}

// Gera ID determinístico baseado em propriedades do componente
const inputId = computed(() => {
  if (props.id) return props.id
  
  const key = `input-date-${props.label || ''}-${props.placeholder || ''}`
  const hash = hashString(key)
  
  return `input-date-${hash}`
})

const inputClasses = computed(() => [
  'w-full',
  'px-5',
  'py-3.5',
  'border',
  'rounded-xl',
  'text-gray-900',
  'placeholder:text-gray-400',
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
</script>

