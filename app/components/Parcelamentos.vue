<template>
  <div class="w-full">
    <label class="block text-sm font-semibold text-gray-800 mb-3 tracking-tight">
      Parcelas
    </label>
    
    <div v-if="parcelas.length === 0" class="p-4 bg-gray-50 border border-gray-200 rounded-xl text-center">
      <p class="text-sm text-gray-500">
        Nenhuma parcela configurada
      </p>
    </div>

    <div v-else class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
      <div
        v-for="(parcela, index) in parcelas"
        :key="parcela.id || index"
        class="p-4 bg-white border border-gray-200 rounded-xl shadow-sm hover:shadow-md transition-shadow"
      >
        <div class="flex items-center justify-between mb-3">
          <h4 class="text-sm font-semibold text-gray-900">
            Parcela {{ parcela.numero_parcela }}
          </h4>
          <span
            v-if="parcela.pago"
            class="px-2 py-1 text-xs font-medium rounded-full bg-green-100 text-green-800"
          >
            Pago
          </span>
        </div>

        <div class="space-y-3">
          <!-- Valor da Parcela -->
          <div>
            <label
              :for="`valor-parcela-${index}`"
              class="block text-xs font-medium text-gray-700 mb-1.5"
            >
              Valor
            </label>
            <div class="relative">
              <span class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-600 text-sm font-medium z-10">
                R$
              </span>
              <input
                :id="`valor-parcela-${index}`"
                v-model="parcela.valorFormatted"
                type="text"
                placeholder="0,00"
                :disabled="parcela.pago"
                :class="[
                  'w-full pl-10 pr-3 py-2 text-sm border rounded-lg text-gray-900 placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-offset-0 transition-all duration-200 ease-in-out',
                  parcela.pago
                    ? 'bg-gray-50 cursor-not-allowed opacity-60 border-gray-200'
                    : errors[`parcela_${index}_valor`]
                    ? 'border-danger-400 focus:ring-danger-500 focus:border-danger-500 bg-danger-50/30'
                    : 'border-gray-200 focus:ring-primary-500 focus:border-primary-500 bg-white hover:border-gray-300'
                ]"
                @input="handleValorInput(index, $event)"
                @blur="handleValorBlur(index)"
                @focus="handleValorFocus(index, $event)"
              />
            </div>
            <p
              v-if="errors[`parcela_${index}_valor`]"
              class="mt-1 text-xs text-danger-600 font-medium"
            >
              {{ errors[`parcela_${index}_valor`] }}
            </p>
          </div>

          <!-- Data de Vencimento -->
          <div>
            <label
              :for="`data-vencimento-${index}`"
              class="block text-xs font-medium text-gray-700 mb-1.5"
            >
              Data de Vencimento
            </label>
            <input
              :id="`data-vencimento-${index}`"
              v-model="parcela.data_vencimento"
              type="date"
              :disabled="parcela.pago"
              :min="minDate"
              :class="[
                'w-full px-3 py-2 text-sm border rounded-lg text-gray-900 focus:outline-none focus:ring-2 focus:ring-offset-0 transition-all duration-200 ease-in-out',
                parcela.pago
                  ? 'bg-gray-50 cursor-not-allowed opacity-60 border-gray-200'
                  : errors[`parcela_${index}_data`]
                  ? 'border-danger-400 focus:ring-danger-500 focus:border-danger-500 bg-danger-50/30'
                  : 'border-gray-200 focus:ring-primary-500 focus:border-primary-500 bg-white hover:border-gray-300'
              ]"
              @input="handleDataChange(index)"
              @blur="handleDataBlur(index)"
            />
            <p
              v-if="errors[`parcela_${index}_data`]"
              class="mt-1 text-xs text-danger-600 font-medium"
            >
              {{ errors[`parcela_${index}_data`] }}
            </p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'

const props = defineProps({
  modelValue: {
    type: Array,
    default: () => []
  },
  numeroParcelas: {
    type: Number,
    default: 0
  },
  valorTotal: {
    type: [String, Number],
    default: 0
  },
  honorarioId: {
    type: String,
    default: null
  },
  errors: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['update:modelValue', 'change', 'validation'])

const supabase = useSupabaseClient()

const parcelas = ref([])
const parcelasErrors = ref({})

// Data mínima (hoje)
const minDate = computed(() => {
  const today = new Date()
  const year = today.getFullYear()
  const month = String(today.getMonth() + 1).padStart(2, '0')
  const day = String(today.getDate()).padStart(2, '0')
  return `${year}-${month}-${day}`
})

// Funções para formatação de moeda
const formatCurrency = (value) => {
  if (!value && value !== 0) return ''
  
  const numValue = typeof value === 'string' ? parseFloat(value.replace(/[^\d,.-]/g, '').replace(',', '.')) : value
  
  if (isNaN(numValue)) return ''
  
  return new Intl.NumberFormat('pt-BR', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  }).format(numValue)
}

const unformatCurrency = (value) => {
  if (!value) return ''
  
  const cleaned = value.toString().replace(/[^\d,.-]/g, '')
  const normalized = cleaned.replace(',', '.')
  
  const parts = normalized.split('.')
  if (parts.length > 2) {
    const integerPart = parts.slice(0, -1).join('')
    const decimalPart = parts[parts.length - 1]
    return `${integerPart}.${decimalPart}`
  }
  
  return normalized
}

// Inicializa parcelas baseado no número de parcelas
const initializeParcelas = () => {
  if (props.numeroParcelas <= 0) {
    parcelas.value = []
    emitChange()
    return
  }

  // Se já existem parcelas e o número não mudou, mantém
  if (parcelas.value.length === props.numeroParcelas && props.modelValue.length > 0) {
    return
  }

  // Calcula valor por parcela
  const valorTotalNum = parseFloat(props.valorTotal) || 0
  const valorPorParcela = valorTotalNum / props.numeroParcelas

  // Cria array de parcelas
  const novasParcelas = []
  const hoje = new Date()

  for (let i = 1; i <= props.numeroParcelas; i++) {
    // Calcula data de vencimento (30 dias por parcela)
    const dataVencimento = new Date(hoje)
    dataVencimento.setMonth(dataVencimento.getMonth() + i)

    const ano = dataVencimento.getFullYear()
    const mes = String(dataVencimento.getMonth() + 1).padStart(2, '0')
    const dia = String(dataVencimento.getDate()).padStart(2, '0')
    const dataFormatada = `${ano}-${mes}-${dia}`

    // Verifica se já existe parcela com este número
    const parcelaExistente = props.modelValue.find(p => p.numero_parcela === i)

    novasParcelas.push({
      id: parcelaExistente?.id || null,
      numero_parcela: i,
      valor: parcelaExistente?.valor || valorPorParcela,
      valorFormatted: parcelaExistente?.valor ? formatCurrency(parcelaExistente.valor) : formatCurrency(valorPorParcela),
      data_vencimento: parcelaExistente?.data_vencimento || dataFormatada,
      pago: parcelaExistente?.pago || false,
      data_pagamento: parcelaExistente?.data_pagamento || null
    })
  }

  parcelas.value = novasParcelas
  emitChange()
}

// Handlers para valor
const handleValorInput = (index, event) => {
  let inputValue = event.target.value
  inputValue = inputValue.replace(/[^\d,.-]/g, '')

  if (inputValue === '' || inputValue === '.' || inputValue === ',') {
    parcelas.value[index].valor = 0
    parcelas.value[index].valorFormatted = ''
    delete parcelasErrors.value[`parcela_${index}_valor`]
    emitChange()
    return
  }

  parcelas.value[index].valorFormatted = inputValue

  let normalized = inputValue.replace(',', '.')
  const parts = normalized.split('.')
  if (parts.length > 2) {
    const integerPart = parts.slice(0, -1).join('')
    const decimalPart = parts[parts.length - 1]
    normalized = `${integerPart}.${decimalPart}`
  }

  const numValue = parseFloat(normalized)
  if (!isNaN(numValue) && numValue >= 0) {
    parcelas.value[index].valor = numValue
  } else {
    parcelas.value[index].valor = 0
  }

  delete parcelasErrors.value[`parcela_${index}_valor`]
  emitChange()
  validateParcelas()
}

const handleValorBlur = (index) => {
  if (parcelas.value[index].valorFormatted) {
    const unformatted = unformatCurrency(parcelas.value[index].valorFormatted)
    const numValue = parseFloat(unformatted)

    if (!isNaN(numValue) && numValue >= 0) {
      parcelas.value[index].valor = numValue
      parcelas.value[index].valorFormatted = formatCurrency(numValue)
    } else {
      parcelas.value[index].valor = 0
      parcelas.value[index].valorFormatted = ''
    }
  } else {
    parcelas.value[index].valor = 0
  }
  validateParcelas()
  emitChange()
}

const handleValorFocus = (index, event) => {
  if (parcelas.value[index].valor > 0) {
    const numValue = parseFloat(parcelas.value[index].valor)
    if (!isNaN(numValue)) {
      parcelas.value[index].valorFormatted = numValue.toString().replace('.', ',')
    }
  }
  setTimeout(() => {
    event.target.select()
  }, 0)
}

// Handlers para data
const handleDataChange = (index) => {
  delete parcelasErrors.value[`parcela_${index}_data`]
  emitChange()
  validateParcelas()
}

const handleDataBlur = (index) => {
  validateParcelas()
}

// Validação
const validateParcelas = () => {
  parcelasErrors.value = {}
  let isValid = true

  parcelas.value.forEach((parcela, index) => {
    // Valida valor
    if (!parcela.valor || parcela.valor <= 0) {
      parcelasErrors.value[`parcela_${index}_valor`] = 'Valor deve ser maior que zero'
      isValid = false
    }

    // Valida data
    if (!parcela.data_vencimento) {
      parcelasErrors.value[`parcela_${index}_data`] = 'Data de vencimento é obrigatória'
      isValid = false
    }
  })

  // Emite validação
  emit('validation', {
    isValid,
    errors: parcelasErrors.value
  })
}

// Emite mudanças
const emitChange = () => {
  const data = parcelas.value.map(parcela => ({
    id: parcela.id,
    numero_parcela: parcela.numero_parcela,
    valor: parseFloat(parcela.valor) || 0,
    data_vencimento: parcela.data_vencimento,
    pago: parcela.pago || false,
    data_pagamento: parcela.data_pagamento || null
  }))

  emit('update:modelValue', data)
  emit('change', data)
}

// Watch para mudanças no número de parcelas
watch(() => props.numeroParcelas, () => {
  initializeParcelas()
}, { immediate: true })

// Watch para mudanças no valor total
watch(() => props.valorTotal, () => {
  if (parcelas.value.length > 0) {
    // Redistribui valores se necessário
    const valorTotalNum = parseFloat(props.valorTotal) || 0
    const valorPorParcela = valorTotalNum / parcelas.value.length

    parcelas.value.forEach(parcela => {
      if (!parcela.pago) {
        parcela.valor = valorPorParcela
        parcela.valorFormatted = formatCurrency(valorPorParcela)
      }
    })
    emitChange()
  }
})

// Watch para modelValue (carregamento de dados existentes)
watch(() => props.modelValue, (newValue) => {
  if (newValue && newValue.length > 0 && props.numeroParcelas > 0) {
    // Atualiza parcelas com valores existentes
    parcelas.value = newValue.map(parcela => ({
      ...parcela,
      valorFormatted: formatCurrency(parcela.valor || 0)
    }))
  }
}, { deep: true })

onMounted(() => {
  initializeParcelas()
  validateParcelas()
})

// Expõe métodos públicos
defineExpose({
  validate: validateParcelas,
  getData: () => parcelas.value.map(p => ({
    id: p.id,
    numero_parcela: p.numero_parcela,
    valor: parseFloat(p.valor) || 0,
    data_vencimento: p.data_vencimento,
    pago: p.pago || false,
    data_pagamento: p.data_pagamento || null
  }))
})
</script>

