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
    <div class="relative">
      <span class="absolute left-5 top-1/2 -translate-y-1/2 text-gray-600 text-sm font-medium z-10">
        R$
      </span>
      <input
        :id="inputId"
        type="text"
        :value="displayValue"
        :placeholder="placeholder"
        :disabled="disabled"
        :required="required"
        :class="inputClasses"
        @input="handleInput"
        @blur="handleBlur"
        @focus="handleFocus"
        @wheel.prevent="handleWheel"
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
import { computed, ref, watch, nextTick } from 'vue'

const props = defineProps({
  modelValue: {
    type: [String, Number],
    default: ''
  },
  label: {
    type: String,
    default: ''
  },
  placeholder: {
    type: String,
    default: '0,00'
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
  }
})

const emit = defineEmits(['update:modelValue', 'blur', 'focus'])

// Valor para exibição (sem formatação durante digitação)
const displayValue = ref('')
// Flag para controlar se o campo está focado
const isFocused = ref(false)

// Função para formatar moeda brasileira (sem R$) - apenas no blur
const formatCurrency = (value) => {
  if (value === null || value === undefined || value === '') return ''
  
  const numValue = typeof value === 'string' 
    ? parseFloat(value.replace(',', '.')) 
    : value
  
  if (isNaN(numValue) || numValue < 0) return ''
  
  return new Intl.NumberFormat('pt-BR', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  }).format(numValue)
}

// Função para converter valor formatado (00.000,00) para editável (00000,00)
// Remove pontos de milhar, mantém vírgula decimal
const unformatForEditing = (value) => {
  if (!value) return ''
  
  // Remove R$ e espaços, mantém apenas números, pontos e vírgulas
  let cleaned = value.toString().replace(/[^\d,.-]/g, '')
  
  // Se tem vírgula: padrão brasileiro (pontos = separadores de milhar)
  if (cleaned.includes(',')) {
    // Remove todos os pontos (separadores de milhar), mantém vírgula
    return cleaned.replace(/\./g, '')
  }
  
  // Se não tem vírgula mas tem pontos (separadores de milhar)
  if (cleaned.includes('.')) {
    // Remove todos os pontos
    return cleaned.replace(/\./g, '')
  }
  
  return cleaned
}

// Função para converter string editável (1111,50) para número
const parseEditableValue = (value) => {
  if (!value) return null
  
  // Remove tudo exceto números e vírgula
  const cleaned = value.replace(/[^\d,]/g, '')
  
  if (!cleaned) return null
  
  // Converte vírgula para ponto e faz parse
  const normalized = cleaned.replace(',', '.')
  const numValue = parseFloat(normalized)
  
  return isNaN(numValue) ? null : numValue
}

// Handler para prevenir scroll do mouse no campo de valor
const handleWheel = (event) => {
  if (document.activeElement === event.target) {
    event.preventDefault()
  }
}

// Handler para input - valida e limita durante digitação (SEM formatação)
const handleInput = (event) => {
  let inputValue = event.target.value
  const cursorPosition = event.target.selectionStart || 0
  
  // Remove caracteres não permitidos (mantém apenas números e vírgula)
  let cleaned = inputValue.replace(/[^\d,]/g, '')
  
  // Valida e limita vírgula
  const commaIndex = cleaned.indexOf(',')
  if (commaIndex !== -1) {
    // Permite apenas uma vírgula
    const beforeComma = cleaned.substring(0, commaIndex)
    const afterComma = cleaned.substring(commaIndex + 1).replace(/,/g, '')
    
    // Limita a 2 casas decimais após vírgula
    const limitedDecimals = afterComma.substring(0, 2)
    cleaned = beforeComma + ',' + limitedDecimals
  }
  
  // Atualiza o input se houve mudança
  if (cleaned !== inputValue) {
    event.target.value = cleaned
    // Mantém cursor na posição correta
    const newPosition = Math.min(cursorPosition, cleaned.length)
    nextTick(() => {
      if (event.target) {
        event.target.setSelectionRange(newPosition, newPosition)
      }
    })
  }
  
  // Atualiza displayValue (sem formatação de milhar)
  displayValue.value = cleaned
  
  // Converte para número e emite
  const numValue = parseEditableValue(cleaned)
  if (numValue !== null && numValue >= 0) {
    emit('update:modelValue', numValue.toString())
  } else {
    emit('update:modelValue', '')
  }
}

// Handler para blur - formata o valor no padrão brasileiro
const handleBlur = (event) => {
  isFocused.value = false
  const input = event.target
  let inputValue = input.value
  
  // Remove caracteres inválidos
  inputValue = inputValue.replace(/[^\d,]/g, '')
  
  // Se está vazio ou apenas vírgula, limpa tudo
  if (inputValue === '' || inputValue === ',') {
    displayValue.value = ''
    emit('update:modelValue', '')
    emit('blur', event)
    return
  }
  
  // Converte para número
  const numValue = parseEditableValue(inputValue)
  
  if (numValue !== null && numValue >= 0) {
    // Formata para exibição no padrão brasileiro (00.000,00)
    const formatted = formatCurrency(numValue)
    displayValue.value = formatted
    input.value = formatted
    emit('update:modelValue', numValue.toString())
  } else {
    // Se não é válido, limpa
    displayValue.value = ''
    input.value = ''
    emit('update:modelValue', '')
  }
  
  emit('blur', event)
}

// Handler para focus - converte formato para editável
const handleFocus = (event) => {
  isFocused.value = true
  
  // Se há valor formatado (com pontos de milhar), remove formatação
  if (displayValue.value) {
    const unformatted = unformatForEditing(displayValue.value)
    displayValue.value = unformatted
    event.target.value = unformatted
  }
  
  emit('focus', event)
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
  
  const key = `valor-${props.label || ''}-${props.placeholder || ''}`
  const hash = hashString(key)
  
  return `input-valor-${hash}`
})

const inputClasses = computed(() => [
  'w-full',
  'pl-12',
  'pr-5',
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

// Watch para atualizar displayValue quando modelValue mudar externamente
// Só atualiza se o campo NÃO estiver focado (para não interferir na digitação)
watch(() => props.modelValue, (newValue) => {
  // Não atualiza se o campo estiver focado (usuário está digitando)
  if (isFocused.value) return
  
  if (newValue !== null && newValue !== undefined && newValue !== '') {
    let numValue
    
    // Se é string, pode estar formatada (00.000,00) ou ser numérica
    if (typeof newValue === 'string') {
      // Se contém pontos ou vírgulas, desformata primeiro
      if (newValue.includes('.') || newValue.includes(',')) {
        // Remove pontos (milhares) e converte vírgula para ponto
        const cleaned = newValue.replace(/[^\d,.-]/g, '').replace(/\./g, '').replace(',', '.')
        numValue = parseFloat(cleaned)
      } else {
        // String numérica simples
        numValue = parseFloat(newValue)
      }
    } else {
      // Número direto
      numValue = newValue
    }
    
    if (!isNaN(numValue) && numValue >= 0) {
      // Formata no padrão brasileiro (00.000,00) apenas se não estiver focado
      displayValue.value = formatCurrency(numValue)
    } else {
      displayValue.value = ''
    }
  } else {
    displayValue.value = ''
  }
}, { immediate: true })
</script>
