<template>
  <Modal
    :model-value="modelValue"
    @update:model-value="handleModalClose"
    @close="handleModalClose"
    title="Registrar Pagamento"
    size="md"
  >
    <form @submit.prevent="handleSubmit" class="space-y-6">
      <!-- Informações da Parcela -->
      <div class="bg-gray-50 rounded-lg p-4 border border-gray-200">
        <div class="grid grid-cols-2 gap-4 text-sm">
          <div>
            <p class="text-gray-500 mb-1">Número da Parcela</p>
            <p class="font-semibold text-gray-900">{{ parcela.numero_da_parcela }}</p>
          </div>
          <div>
            <p class="text-gray-500 mb-1">Valor da Parcela</p>
            <p class="font-semibold text-gray-900">{{ formatCurrencyDisplay(parcela.valor_parcela) }}</p>
          </div>
          <div>
            <p class="text-gray-500 mb-1">Valor Já Pago</p>
            <p class="font-semibold text-gray-900">{{ formatCurrencyDisplay(parcela.valor_pago_parcela || 0) }}</p>
          </div>
          <div>
            <p class="text-gray-500 mb-1">Saldo Devedor</p>
            <p class="font-semibold text-danger-600">{{ formatCurrencyDisplay(saldoDevedor) }}</p>
          </div>
        </div>
      </div>

      <!-- Campo de Valor Pago -->
      <div class="w-full">
        <label
          for="valor-pago"
          class="block text-sm font-semibold text-gray-800 mb-2.5 tracking-tight"
        >
          Valor Pago
          <span class="text-danger-500 ml-0.5">*</span>
        </label>
        <div class="relative">
          <span class="absolute left-5 top-1/2 -translate-y-1/2 text-gray-600 font-medium z-10">
            R$
          </span>
          <input
            id="valor-pago"
            v-model="valorPagoFormatted"
            type="text"
            placeholder="0,00"
            required
            :class="[
              'w-full pl-12 pr-5 py-3.5 border rounded-xl text-gray-900 placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-offset-0 transition-all duration-200 ease-in-out shadow-sm hover:shadow-md focus:shadow-lg',
              errors.valorPago
                ? 'border-danger-400 focus:ring-danger-500 focus:border-danger-500 bg-danger-50/30'
                : 'border-gray-200 focus:ring-primary-500 focus:border-primary-500 bg-white hover:border-gray-300'
            ]"
            @input="handleValorPagoInput"
            @blur="handleValorPagoBlur"
            @focus="handleValorPagoFocus"
          />
        </div>
        <p
          v-if="errors.valorPago"
          class="mt-2 text-sm text-danger-600 font-medium flex items-center gap-1.5"
        >
          <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
          </svg>
          {{ errors.valorPago }}
        </p>
      </div>

      <!-- Calendário de Data de Pagamento -->
      <CalendarPay
        v-model="formData.dataPagamento"
        label="Data do Pagamento"
        :error="errors.dataPagamento"
        required
        :max-date="maxDate"
      />

      <!-- Mensagem de Erro Geral -->
      <div v-if="errorGeral" class="p-4 bg-danger-50 border border-danger-200 rounded-lg">
        <p class="text-sm text-danger-600 font-medium">{{ errorGeral }}</p>
      </div>
    </form>

    <template #footer>
      <div class="flex items-center justify-end gap-3">
        <Button
          variant="outline"
          size="sm"
          @click="handleCancel"
        >
          Cancelar
        </Button>
        <Button
          variant="primary"
          size="sm"
          type="submit"
          :disabled="isSubmitting || !isFormValid"
          @click="handleSubmit"
        >
          <span v-if="isSubmitting">Registrando...</span>
          <span v-else>Registrar Pagamento</span>
        </Button>
      </div>
    </template>
  </Modal>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import Modal from './Modal.vue'
import Button from './Button.vue'
import CalendarPay from './CalendarPay.vue'

const props = defineProps({
  modelValue: {
    type: Boolean,
    default: false
  },
  parcela: {
    type: Object,
    required: true
  },
  honorario: {
    type: Object,
    required: true
  },
  todasParcelas: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['update:modelValue', 'salvo'])

const supabase = useSupabaseClient()

const formData = ref({
  valorPago: '',
  dataPagamento: ''
})

const valorPagoFormatted = ref('')

const errors = ref({
  valorPago: '',
  dataPagamento: ''
})

const errorGeral = ref('')
const isSubmitting = ref(false)

// Calcular saldo devedor da parcela
const saldoDevedor = computed(() => {
  const valorParcela = parseFloat(props.parcela.valor_parcela) || 0
  const valorPago = parseFloat(props.parcela.valor_pago_parcela) || 0
  return valorParcela - valorPago
})

// Data máxima (hoje)
const maxDate = computed(() => {
  const hoje = new Date()
  return hoje.toISOString().split('T')[0]
})

// Funções para formatação de moeda brasileira
const formatCurrency = (value) => {
  if (!value && value !== 0) return ''
  
  // Converte para número se for string
  const numValue = typeof value === 'string' ? parseFloat(value.replace(/[^\d,.-]/g, '').replace(',', '.')) : value
  
  if (isNaN(numValue)) return ''
  
  // Formata como moeda brasileira (sem R$)
  return new Intl.NumberFormat('pt-BR', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  }).format(numValue)
}

// Função para exibir valores formatados com R$ no template
const formatCurrencyDisplay = (value) => {
  if (!value && value !== 0) return 'R$ 0,00'
  const numValue = typeof value === 'string' ? parseFloat(value.replace(/[^\d,.-]/g, '').replace(',', '.')) : value
  if (isNaN(numValue)) return 'R$ 0,00'
  return new Intl.NumberFormat('pt-BR', {
    style: 'currency',
    currency: 'BRL'
  }).format(numValue)
}

const unformatCurrency = (value) => {
  if (!value) return ''
  
  // Remove tudo exceto números, vírgula e ponto
  const cleaned = value.toString().replace(/[^\d,.-]/g, '')
  
  // Substitui vírgula por ponto para conversão
  const normalized = cleaned.replace(',', '.')
  
  // Remove pontos que não sejam decimais (separadores de milhar)
  const parts = normalized.split('.')
  if (parts.length > 2) {
    // Se há múltiplos pontos, mantém apenas o último como decimal
    const integerPart = parts.slice(0, -1).join('')
    const decimalPart = parts[parts.length - 1]
    return `${integerPart}.${decimalPart}`
  }
  
  return normalized
}

// Converter string de moeda para número
const parseCurrency = (value) => {
  const unformatted = unformatCurrency(value)
  return parseFloat(unformatted) || 0
}

// Handlers para o campo Valor Pago
const handleValorPagoInput = (event) => {
  let inputValue = event.target.value
  
  // Remove apenas caracteres não permitidos (mantém números, vírgula e ponto)
  inputValue = inputValue.replace(/[^\d,.-]/g, '')
  
  // Se está vazio, limpa tudo
  if (inputValue === '' || inputValue === '.' || inputValue === ',') {
    formData.value.valorPago = ''
    valorPagoFormatted.value = ''
    if (errors.value.valorPago) {
      errors.value.valorPago = ''
    }
    return
  }
  
  // Atualiza o valor formatado (sem formatar ainda, apenas limpa caracteres inválidos)
  valorPagoFormatted.value = inputValue
  
  // Converte para número para atualizar formData (mas não formata ainda)
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
    // Atualiza o valor numérico no formData
    formData.value.valorPago = numValue.toString()
  } else {
    // Se não é válido ainda, mantém vazio no formData
    formData.value.valorPago = ''
  }
  
  // Limpa erro se houver
  if (errors.value.valorPago) {
    errors.value.valorPago = ''
  }
}

const handleValorPagoBlur = () => {
  // Formata o valor ao sair do campo
  if (valorPagoFormatted.value) {
    const unformatted = unformatCurrency(valorPagoFormatted.value)
    const numValue = parseFloat(unformatted)
    
    if (!isNaN(numValue) && numValue >= 0) {
      // Atualiza formData com o valor numérico
      formData.value.valorPago = numValue.toString()
      // Formata para exibição
      valorPagoFormatted.value = formatCurrency(numValue)
    } else {
      // Se não é válido, limpa
      formData.value.valorPago = ''
      valorPagoFormatted.value = ''
    }
  } else {
    formData.value.valorPago = ''
  }
  
  validateValor()
}

const handleValorPagoFocus = (event) => {
  // Remove formatação ao focar para facilitar edição
  // Converte o valor formatado de volta para número simples
  if (formData.value.valorPago) {
    const numValue = parseFloat(formData.value.valorPago)
    if (!isNaN(numValue)) {
      // Mostra o valor sem formatação para facilitar edição
      // Mas mantém com vírgula como separador decimal
      valorPagoFormatted.value = numValue.toString().replace('.', ',')
    }
  }
  // Seleciona todo o texto
  setTimeout(() => {
    event.target.select()
  }, 0)
}

// Validação do valor
const validateValor = () => {
  const valor = parseFloat(formData.value.valorPago) || 0
  const valorTotal = parseFloat(props.honorario.valor_total) || 0
  
  if (!formData.value.valorPago || formData.value.valorPago === '' || valor <= 0) {
    errors.value.valorPago = 'O valor deve ser maior que zero'
    return false
  }
  
  // Verificar se não excede o valor total da causa
  // Considera o valor já pago em todas as parcelas, exceto o que será adicionado nesta
  const valorPagoAtualParcela = parseFloat(props.parcela.valor_pago_parcela) || 0
  const totalPago = props.todasParcelas.reduce((sum, p) => {
    if (p.id === props.parcela.id) {
      // Não inclui o valor já pago desta parcela, pois será substituído
      return sum
    }
    return sum + (parseFloat(p.valor_pago_parcela) || 0)
  }, 0)
  
  // O novo total seria: total já pago (sem esta parcela) + valor do pagamento
  const novoTotalPago = totalPago + valor
  
  if (novoTotalPago > valorTotal) {
    errors.value.valorPago = `O valor excede o valor total da causa (${formatCurrencyDisplay(valorTotal)}). Máximo permitido: ${formatCurrencyDisplay(valorTotal - totalPago)}`
    return false
  }
  
  errors.value.valorPago = ''
  return true
}

// Validação da data
const validateData = () => {
  if (!formData.value.dataPagamento) {
    errors.value.dataPagamento = 'A data do pagamento é obrigatória'
    return false
  }
  
  errors.value.dataPagamento = ''
  return true
}

// Validação geral
const isFormValid = computed(() => {
  const valor = parseFloat(formData.value.valorPago) || 0
  return valor > 0 && formData.value.dataPagamento && !errors.value.valorPago && !errors.value.dataPagamento
})

// Limpar formulário
const resetForm = () => {
  formData.value = {
    valorPago: '',
    dataPagamento: ''
  }
  valorPagoFormatted.value = ''
  errors.value = {
    valorPago: '',
    dataPagamento: ''
  }
  errorGeral.value = ''
}

// Handler de cancelamento
const handleCancel = () => {
  resetForm()
  emit('update:modelValue', false)
}

// Handler quando modal fecha
const handleModalClose = (value) => {
  resetForm()
  emit('update:modelValue', value)
}

// Handler de submit
const handleSubmit = async () => {
  if (!validateValor() || !validateData()) {
    return
  }

  if (!isFormValid.value) {
    return
  }

  isSubmitting.value = true
  errorGeral.value = ''

  try {
    // O valor digitado no campo é o que deve ser registrado
    const valorPago = parseFloat(formData.value.valorPago) || 0
    const valorParcela = parseFloat(props.parcela.valor_parcela) || 0
    const valorPagoAtual = parseFloat(props.parcela.valor_pago_parcela) || 0
    const saldoDevedorParcela = valorParcela - valorPagoAtual
    const novoValorPagoTotal = valorPagoAtual + valorPago

    // Se o valor pago é menor que o saldo devedor da parcela
    if (valorPago < saldoDevedorParcela) {
      // Pagamento parcial: registra o valor pago, mas parcela continua pendente
      const { error } = await supabase
        .from('honorarios_parcelas')
        .update({
          valor_pago_parcela: novoValorPagoTotal,
          // Não atualiza data_pagamento pois a parcela ainda não está totalmente paga
          data_pagamento: null
        })
        .eq('id', props.parcela.id)

      if (error) {
        console.error('Erro ao registrar pagamento parcial:', error)
        errorGeral.value = 'Erro ao registrar pagamento. Tente novamente.'
        isSubmitting.value = false
        return
      }
    } else {
      // Se o valor pago é maior ou igual ao saldo devedor da parcela
      // Paga a parcela atual completamente
      const valorExcedente = valorPago - saldoDevedorParcela
      
      // Atualizar parcela atual (marca como totalmente paga)
      const { error: errorAtual } = await supabase
        .from('honorarios_parcelas')
        .update({
          valor_pago_parcela: valorParcela, // Valor total da parcela
          data_pagamento: formData.value.dataPagamento
        })
        .eq('id', props.parcela.id)

      if (errorAtual) {
        console.error('Erro ao atualizar parcela atual:', errorAtual)
        errorGeral.value = 'Erro ao registrar pagamento. Tente novamente.'
        isSubmitting.value = false
        return
      }

      // Se há excedente, aplicar nas próximas parcelas
      if (valorExcedente > 0) {
        const valorTotal = parseFloat(props.honorario.valor_total) || 0
        
        // Calcular total já pago (incluindo o pagamento completo da parcela atual)
        const totalPagoAtual = props.todasParcelas.reduce((sum, p) => {
          if (p.id === props.parcela.id) {
            return sum + valorParcela // Já contabiliza o pagamento completo da parcela atual
          }
          return sum + (parseFloat(p.valor_pago_parcela) || 0)
        }, 0)
        
        const limiteTotal = valorTotal - totalPagoAtual

        // Limitar o excedente ao que não excede o valor total
        let valorRestante = valorExcedente
        if (valorRestante > limiteTotal && limiteTotal > 0) {
          valorRestante = limiteTotal
        } else if (limiteTotal <= 0) {
          valorRestante = 0
        }

        if (valorRestante > 0) {
          const proximasParcelas = props.todasParcelas
            .filter(p => p.numero_da_parcela > props.parcela.numero_da_parcela && p.status === 'pendente')
            .sort((a, b) => a.numero_da_parcela - b.numero_da_parcela)

          for (const proximaParcela of proximasParcelas) {
            if (valorRestante <= 0) break

            const valorPagoProxima = parseFloat(proximaParcela.valor_pago_parcela) || 0
            const valorParcelaProxima = parseFloat(proximaParcela.valor_parcela) || 0
            const saldoProxima = valorParcelaProxima - valorPagoProxima
            const valorAplicar = Math.min(valorRestante, saldoProxima)
            const novoValorPagoProxima = valorPagoProxima + valorAplicar

            const { error: errorProxima } = await supabase
              .from('honorarios_parcelas')
              .update({
                valor_pago_parcela: novoValorPagoProxima
              })
              .eq('id', proximaParcela.id)

            if (errorProxima) {
              console.error('Erro ao atualizar próxima parcela:', errorProxima)
            } else {
              valorRestante -= valorAplicar
            }
          }
        }
      }
    }

    // Sucesso
    resetForm()
    emit('update:modelValue', false)
    emit('salvo')
  } catch (error) {
    console.error('Erro inesperado ao registrar pagamento:', error)
    errorGeral.value = 'Erro inesperado ao registrar pagamento. Tente novamente.'
  } finally {
    isSubmitting.value = false
  }
}

// Carregar valor default quando modal abrir
watch(() => props.modelValue, (newValue) => {
  if (newValue) {
    // Valor default = saldo devedor da parcela
    const valorParcela = parseFloat(props.parcela.valor_parcela) || 0
    const valorPagoAtual = parseFloat(props.parcela.valor_pago_parcela) || 0
    const saldoDevedor = valorParcela - valorPagoAtual
    formData.value.valorPago = saldoDevedor.toString()
    // Mostra o valor sem formatação inicialmente para permitir digitação livre
    valorPagoFormatted.value = saldoDevedor > 0 ? saldoDevedor.toString().replace('.', ',') : ''
    formData.value.dataPagamento = maxDate.value
    errors.value = {
      valorPago: '',
      dataPagamento: ''
    }
    errorGeral.value = ''
  } else {
    resetForm()
  }
})
</script>

