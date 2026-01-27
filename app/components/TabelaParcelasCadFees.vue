<template>
  <div class="w-full space-y-4">
    <!-- Campo de Quantidade de Parcelas -->
    <Input
      id="quantidade-parcelas"
      v-model="quantidadeParcelas"
      type="number"
      label="Quantidade de parcelas"
      placeholder="Digite a quantidade"
      :error="errors.quantidade_parcelas"
    />

    <!-- Tabela de Parcelas -->
    <div v-if="parcelas.length > 0" class="bg-white rounded-xl border border-gray-200 overflow-hidden">
      <div class="overflow-x-auto">
        <table class="w-full">
          <thead class="bg-gray-50 border-b border-gray-200">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                Nº parcela
              </th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                Data do pagamento
              </th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                Valor a ser pago
              </th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr
              v-for="parcela in parcelas"
              :key="parcela.numero"
              class="hover:bg-gray-50 transition-colors"
            >
              <td class="px-6 py-4 whitespace-nowrap">
                <span class="text-sm font-medium text-gray-900">{{ parcela.numero }}</span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span class="text-sm text-gray-900">{{ formatDate(parcela.dataPagamento) }}</span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span class="text-sm text-gray-900">{{ formatCurrency(parcela.valor) }}</span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import Input from './Input.vue'

const props = defineProps({
  valorTotal: {
    type: [String, Number],
    default: 0
  },
  dataContratacao: {
    type: String,
    default: ''
  },
  modelValue: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['update:modelValue', 'change'])

// Estado local
const quantidadeParcelas = ref(props.modelValue?.length || 0)

// Erros
const errors = ref({
  quantidade_parcelas: ''
})

// Calcula as parcelas baseado no valor total e quantidade
const parcelas = computed(() => {
  if (!quantidadeParcelas.value || quantidadeParcelas.value <= 0) {
    return []
  }

  if (!props.valorTotal || parseFloat(props.valorTotal) <= 0) {
    return []
  }

  const valorTotalNum = parseFloat(props.valorTotal)
  const quantidade = parseInt(quantidadeParcelas.value)
  
  if (isNaN(valorTotalNum) || isNaN(quantidade) || quantidade <= 0) {
    return []
  }

  // Calcula o valor de cada parcela
  const valorParcela = valorTotalNum / quantidade
  
  // Array para armazenar as parcelas
  const parcelasArray = []
  
  // Data base para cálculo (data de contratação ou hoje)
  let dataBase = new Date()
  if (props.dataContratacao) {
    const dataContratacaoParsed = new Date(props.dataContratacao)
    if (!isNaN(dataContratacaoParsed.getTime())) {
      dataBase = dataContratacaoParsed
    }
  }

  // Gera as parcelas
  for (let i = 1; i <= quantidade; i++) {
    // Calcula a data de pagamento
    // Primeira parcela: data de contratação + 30 dias
    // Parcelas seguintes: mensais (30 dias cada)
    const dataPagamento = new Date(dataBase)
    dataPagamento.setDate(dataPagamento.getDate() + (30 * i))
    
    // Busca dados existentes da parcela se houver
    const parcelaExistente = props.modelValue?.find(p => p.numero === i)
    
    parcelasArray.push({
      numero: i,
      dataPagamento: dataPagamento.toISOString().split('T')[0],
      valor: valorParcela
    })
  }

  return parcelasArray
})

// Watch para quantidade de parcelas - atualiza as parcelas automaticamente
watch(quantidadeParcelas, (newValue) => {
  if (newValue && newValue > 0) {
    emitParcelas()
  } else {
    emit('update:modelValue', [])
    emit('change', [])
  }
})

// Watch para valor total - recalcula as parcelas quando o valor mudar
watch(() => props.valorTotal, () => {
  if (quantidadeParcelas.value > 0) {
    emitParcelas()
  }
})

// Watch para data de contratação - recalcula as datas quando mudar
watch(() => props.dataContratacao, () => {
  if (quantidadeParcelas.value > 0) {
    emitParcelas()
  }
})

// Função para emitir as parcelas
const emitParcelas = () => {
  emit('update:modelValue', parcelas.value)
  emit('change', parcelas.value)
}

// Watch para atualizar quantidade quando modelValue mudar externamente
watch(() => props.modelValue, (newValue) => {
  if (newValue && Array.isArray(newValue) && newValue.length > 0) {
    quantidadeParcelas.value = newValue.length
  } else if (!newValue || newValue.length === 0) {
    quantidadeParcelas.value = 0
  }
}, { immediate: true, deep: true })

// Formatação
const formatCurrency = (value) => {
  if (!value && value !== 0) return 'R$ 0,00'
  const numValue = typeof value === 'string' ? parseFloat(value) : value
  if (isNaN(numValue)) return 'R$ 0,00'
  return new Intl.NumberFormat('pt-BR', {
    style: 'currency',
    currency: 'BRL'
  }).format(numValue)
}

const formatDate = (date) => {
  if (!date) return '-'
  const d = new Date(date)
  if (isNaN(d.getTime())) return '-'
  return d.toLocaleDateString('pt-BR')
}
</script>
