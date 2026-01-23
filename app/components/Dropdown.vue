<template>
  <div class="w-full">
    <label
      v-if="label"
      :for="selectId"
      class="block text-sm font-semibold text-gray-800 mb-2.5 tracking-tight"
    >
      {{ label }}
      <span v-if="required" class="text-danger-500 ml-0.5">*</span>
    </label>
    <div class="relative">
      <select
        :id="selectId"
        :value="modelValue"
        :disabled="disabled"
        :required="required"
        :class="selectClasses"
        @change="$emit('update:modelValue', $event.target.value)"
        @blur="$emit('blur', $event)"
        @focus="$emit('focus', $event)"
      >
        <option value="" disabled>{{ placeholder || 'Selecione uma opção' }}</option>
        <option
          v-for="option in computedOptions"
          :key="option.value"
          :value="option.value"
        >
          {{ option.label }}
        </option>
      </select>
      <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-5">
        <svg class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
        </svg>
      </div>
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
import { computed, ref, onMounted, watch } from 'vue'

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
    default: ''
  },
  options: {
    type: Array,
    default: () => [],
    validator: (value) => {
      if (value.length === 0) return true
      return value.every(opt => opt.value !== undefined && opt.label !== undefined)
    }
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
  loadFormasPagamento: {
    type: Boolean,
    default: false
  }
})

defineEmits(['update:modelValue', 'blur', 'focus'])

const supabase = useSupabaseClient()
const internalOptions = ref([])
const isLoading = ref(false)

// Busca formas de pagamento do banco de dados
const fetchFormasPagamento = async () => {
  if (!props.loadFormasPagamento) return

  isLoading.value = true

  try {
    // Busca todas as formas de pagamento
    const { data, error: fetchError } = await supabase
      .from('formas_pagamento')
      .select('*')

    if (fetchError) {
      console.error('Erro ao buscar formas de pagamento:', fetchError)
      internalOptions.value = []
      return
    }

    if (!data || data.length === 0) {
      internalOptions.value = []
      return
    }

    // Detecta dinamicamente as chaves disponíveis
    const primeiroRegistro = data[0]
    if (!primeiroRegistro) {
      internalOptions.value = []
      return
    }

    const chaves = Object.keys(primeiroRegistro)
    const idKey = chaves.find(k => k.includes('id') && !k.includes('created_at') && !k.includes('updated_at')) || chaves[0] || 'id'
    const nomeKey = chaves.find(k => k.includes('nome')) || chaves[1] || 'nome'

    // Mapeia os dados para o formato esperado
    const opcoesMapeadas = data.map((forma) => {
      const idValue = forma[idKey] || forma['forma.id'] || forma.id || ''
      const nomeValue = forma[nomeKey] || forma['forma.nome'] || forma.nome || ''
      return {
        value: idValue.toString(),
        label: nomeValue
      }
    }).filter(item => item.value && item.label)

    // Ordena por label (nome) alfabeticamente
    opcoesMapeadas.sort((a, b) => {
      return a.label.localeCompare(b.label, 'pt-BR', { sensitivity: 'base' })
    })

    internalOptions.value = opcoesMapeadas
  } catch (err) {
    console.error('Erro inesperado ao buscar formas de pagamento:', err)
    internalOptions.value = []
  } finally {
    isLoading.value = false
  }
}

// Computed para retornar as opções corretas
const computedOptions = computed(() => {
  if (props.loadFormasPagamento) {
    return internalOptions.value
  }
  return props.options
})

// Busca formas de pagamento ao montar se necessário
onMounted(() => {
  if (props.loadFormasPagamento) {
    fetchFormasPagamento()
  }
})

// Watch para recarregar se a prop mudar
watch(() => props.loadFormasPagamento, (newValue) => {
  if (newValue) {
    fetchFormasPagamento()
  }
})

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
const selectId = computed(() => {
  if (props.id) return props.id
  
  const key = `select-${props.label || ''}-${props.placeholder || ''}`
  const hash = hashString(key)
  
  return `select-${hash}`
})

const selectClasses = computed(() => [
  'w-full',
  'px-5',
  'py-3.5',
  'pr-12',
  'border',
  'rounded-xl',
  'text-gray-900',
  'bg-white',
  'appearance-none',
  'focus:outline-none',
  'focus:ring-2',
  'focus:ring-offset-0',
  'transition-all',
  'duration-200',
  'ease-in-out',
  'shadow-sm',
  'hover:shadow-md',
  'focus:shadow-lg',
  'cursor-pointer',
  props.error
    ? 'border-danger-400 focus:ring-danger-500 focus:border-danger-500 bg-danger-50/30'
    : 'border-gray-200 focus:ring-primary-500 focus:border-primary-500 hover:border-gray-300',
  props.disabled ? 'bg-gray-50 cursor-not-allowed opacity-50 border-gray-200' : ''
])
</script>

