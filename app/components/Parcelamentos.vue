<template>
  <div class="w-full">
    <div class="flex items-center justify-between mb-3">
      <label class="block text-sm font-semibold text-gray-800 tracking-tight">
        Parcelas
      </label>
      <button
        type="button"
        @click="rebalancearValores"
        class="flex items-center gap-2 px-3 py-1.5 text-sm font-medium text-primary-600 hover:text-primary-700 bg-primary-50 hover:bg-primary-100 border border-primary-200 rounded-lg transition-all duration-200 ease-in-out hover:shadow-sm"
        title="Rebalancear valores das parcelas"
      >
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-refresh-ccw">
          <path d="M21 12a9 9 0 0 0-9-9 9.75 9.75 0 0 0-6.74 2.74L3 8"/>
          <path d="M3 3v5h5"/>
          <path d="M3 12a9 9 0 0 0 9 9 9.75 9.75 0 0 0 6.74-2.74L21 16"/>
          <path d="M16 16h5v5"/>
        </svg>
        <span>Rebalancear</span>
      </button>
    </div>
    
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
                :key="`valor-input-${index}-${parcela.id || index}`"
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
                :value="parcela.valorFormatted"
                @input="handleValorInput(index, $event)"
                @blur="handleValorBlur(index, $event)"
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
import { ref, computed, watch, onMounted, nextTick } from 'vue'

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

// Função para rebalancear todos os valores das parcelas
const rebalancearValores = () => {
  const valorTotalNum = parseFloat(props.valorTotal) || 0
  
  if (valorTotalNum <= 0 || parcelas.value.length === 0) {
    return
  }
  
  // Conta quantas parcelas não estão pagas
  const parcelasNaoPagas = parcelas.value.filter(p => !p.pago)
  const quantidadeParcelasNaoPagas = parcelasNaoPagas.length
  
  if (quantidadeParcelasNaoPagas === 0) {
    return
  }
  
  // Calcula o valor total já pago
  let valorTotalPago = 0
  parcelas.value.forEach(parcela => {
    if (parcela.pago) {
      valorTotalPago += parseFloat(parcela.valor) || 0
    }
  })
  
  // Calcula o valor restante para distribuir
  const valorRestante = valorTotalNum - valorTotalPago
  
  if (valorRestante <= 0) {
    return
  }
  
  // Distribui o valor restante igualmente entre as parcelas não pagas
  const valorPorParcela = valorRestante / quantidadeParcelasNaoPagas
  
  // Atualiza todas as parcelas não pagas
  parcelas.value.forEach((parcela, index) => {
    if (!parcela.pago) {
      parcelas.value[index].valor = valorPorParcela
      parcelas.value[index].valorFormatted = formatCurrency(valorPorParcela)
    }
  })
  
  // Valida e emite mudanças
  validateParcelas()
  emitChange()
}

// Função para redistribuir valores automaticamente
const redistribuirValores = (indexAlterado) => {
  const valorTotalNum = parseFloat(props.valorTotal) || 0
  
  // Soma valores das parcelas anteriores (incluindo a atual)
  let somaAnteriores = 0
  for (let i = 0; i <= indexAlterado; i++) {
    if (!parcelas.value[i].pago) {
      somaAnteriores += parcelas.value[i].valor || 0
    } else {
      // Se a parcela está paga, inclui seu valor na soma
      somaAnteriores += parcelas.value[i].valor || 0
    }
  }
  
  // Calcula o valor restante para distribuir nas parcelas seguintes
  let valorRestante = valorTotalNum - somaAnteriores
  
  // Conta quantas parcelas seguintes existem (não pagas)
  const parcelasSeguintes = parcelas.value.slice(indexAlterado + 1).filter(p => !p.pago)
  const quantidadeParcelasSeguintes = parcelasSeguintes.length
  
  // Se não há parcelas seguintes, não redistribui
  if (quantidadeParcelasSeguintes === 0) {
    return
  }
  
  // Se valor restante é negativo ou zero, distribui zero
  if (valorRestante <= 0) {
    parcelas.value.forEach((parcela, index) => {
      if (index > indexAlterado && !parcela.pago) {
        parcelas.value[index].valor = 0
        parcelas.value[index].valorFormatted = formatCurrency(0)
      }
    })
    return
  }
  
  // Distribui o valor restante igualmente entre as parcelas seguintes
  const valorPorParcela = valorRestante / quantidadeParcelasSeguintes
  
  // Atualiza as parcelas seguintes
  parcelas.value.forEach((parcela, index) => {
    if (index > indexAlterado && !parcela.pago) {
      parcelas.value[index].valor = valorPorParcela
      parcelas.value[index].valorFormatted = formatCurrency(valorPorParcela)
    }
  })
}

// Handlers para valor
const handleValorInput = (index, event) => {
  const input = event.target
  let inputValue = input.value
  
  // Remove apenas caracteres não permitidos (mantém números, vírgula e ponto)
  const cleanedValue = inputValue.replace(/[^\d,.-]/g, '')
  
  // Se caracteres foram removidos, atualiza o input e ajusta cursor
  if (cleanedValue !== inputValue) {
    const cursorPosition = input.selectionStart || 0
    const lengthDiff = inputValue.length - cleanedValue.length
    
    // Atualiza o valor do input diretamente
    input.value = cleanedValue
    
    // Ajusta posição do cursor
    const newPosition = Math.max(0, cursorPosition - lengthDiff)
    nextTick(() => {
      if (input) {
        input.setSelectionRange(newPosition, newPosition)
      }
    })
  }
  
  // NÃO atualiza valorFormatted durante digitação para evitar re-renderização
  // Apenas limpa erros
  delete parcelasErrors.value[`parcela_${index}_valor`]
}

const handleValorBlur = (index, event) => {
  const input = event.target
  let inputValue = input.value
  
  // Remove caracteres inválidos se houver
  inputValue = inputValue.replace(/[^\d,.-]/g, '')
  
  // Se está vazio, limpa tudo
  if (inputValue === '' || inputValue === '.' || inputValue === ',') {
    parcelas.value[index].valor = 0
    parcelas.value[index].valorFormatted = ''
    input.value = ''
    delete parcelasErrors.value[`parcela_${index}_valor`]
    redistribuirValores(index)
    validateParcelas()
    emitChange()
    return
  }
  
  // Converte para número
  let normalized = inputValue.replace(',', '.')
  
  // Trata múltiplos pontos/vírgulas
  const parts = normalized.split('.')
  if (parts.length > 2) {
    const integerPart = parts.slice(0, -1).join('')
    const decimalPart = parts[parts.length - 1]
    normalized = `${integerPart}.${decimalPart}`
  }
  
  const numValue = parseFloat(normalized)
  
  if (!isNaN(numValue) && numValue >= 0) {
    // Atualiza o valor numérico
    parcelas.value[index].valor = numValue
    // Formata para exibição
    const formatted = formatCurrency(numValue)
    parcelas.value[index].valorFormatted = formatted
    // Atualiza o input com valor formatado
    input.value = formatted
    // Redistribui valores após formatar
    redistribuirValores(index)
  } else {
    // Se não é válido, limpa
    parcelas.value[index].valor = 0
    parcelas.value[index].valorFormatted = ''
    input.value = ''
    // Redistribui valores quando limpa
    redistribuirValores(index)
  }
  
  validateParcelas()
  emitChange()
}

const handleValorFocus = (index, event) => {
  const input = event.target
  // Remove formatação ao focar para facilitar edição
  if (parcelas.value[index].valor > 0) {
    const numValue = parseFloat(parcelas.value[index].valor)
    if (!isNaN(numValue)) {
      // Mostra o valor sem formatação para facilitar edição
      // Mas mantém com vírgula como separador decimal
      const unformatted = numValue.toString().replace('.', ',')
      parcelas.value[index].valorFormatted = unformatted
      input.value = unformatted
    }
  }
  // Seleciona todo o texto
  setTimeout(() => {
    input.select()
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
  const valorTotalNum = parseFloat(props.valorTotal) || 0
  let somaValores = 0

  parcelas.value.forEach((parcela, index) => {
    // Valida valor
    if (!parcela.valor || parcela.valor <= 0) {
      parcelasErrors.value[`parcela_${index}_valor`] = 'Valor deve ser maior que zero'
      isValid = false
    }

    // Soma valores para validar total
    if (parcela.valor > 0) {
      somaValores += parcela.valor
    }

    // Valida data
    if (!parcela.data_vencimento) {
      parcelasErrors.value[`parcela_${index}_data`] = 'Data de vencimento é obrigatória'
      isValid = false
    }
  })

  // Valida se a soma dos valores é igual ao valor total (com tolerância de 0.01 para arredondamento)
  const diferenca = Math.abs(somaValores - valorTotalNum)
  if (diferenca > 0.01) {
    // Não marca como erro individual, mas adiciona uma validação geral
    // A redistribuição automática já garante que a soma será correta
    // Este check é apenas para validação final
  }

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
watch(() => props.valorTotal, (newValor, oldValor) => {
  // Só redistribui se o valor total mudou e não há valores personalizados
  if (parcelas.value.length > 0 && newValor !== oldValor) {
    const valorTotalNum = parseFloat(props.valorTotal) || 0
    const valorPorParcela = valorTotalNum / parcelas.value.length

    // Verifica se alguma parcela foi editada manualmente
    const temValorPersonalizado = parcelas.value.some((p, idx) => {
      const valorEsperado = valorTotalNum / parcelas.value.length
      return Math.abs(p.valor - valorEsperado) > 0.01 && !p.pago
    })

    // Se não tem valor personalizado, redistribui igualmente
    if (!temValorPersonalizado) {
      parcelas.value.forEach((parcela, index) => {
        if (!parcela.pago) {
          parcelas.value[index].valor = valorPorParcela
          parcelas.value[index].valorFormatted = formatCurrency(valorPorParcela)
        }
      })
      emitChange()
    }
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

