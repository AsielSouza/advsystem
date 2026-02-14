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
                Data de vencimento
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
                <InputData
                  :model-value="parcela.dataPagamento"
                  :id="`parcela-data-${parcela.numero}`"
                  class="max-w-[180px]"
                  @update:model-value="(v) => atualizarDataParcela(parcela.numero, v)"
                />
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
import { ref, watch, nextTick } from 'vue'
import Input from './Input.vue'
import InputData from './InputData.vue'

const props = defineProps({
  valorTotal: {
    type: [String, Number],
    default: 0
  },
  valorEntrada: {
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

// Flag para evitar loop infinito durante atualizações internas
const isUpdatingFromProps = ref(false)

// Estado local: parcelas em ref para preservar edições manuais
const quantidadeParcelas = ref(props.modelValue?.length || 0)
const parcelas = ref([])

// Erros
const errors = ref({
  quantidade_parcelas: ''
})

// Parse valor no formato BR (1.000,50)
const parseValorBR = (v) => {
  if (v == null) return 0
  const s = String(v).replace(/\./g, '').replace(',', '.')
  const n = parseFloat(s)
  return isNaN(n) ? 0 : n
}

/**
 * Recalcula as parcelas a partir da quantidade, valor total, valor entrada e data de contratação.
 * Usa a regra: dataBase + 30 dias por parcela.
 * Ao mudar quantidade, valor total ou data de contratação: recalcula tudo.
 */
function recalcularParcelas() {
  const q = parseInt(quantidadeParcelas.value) || 0
  if (q <= 0) {
    parcelas.value = []
    emit('update:modelValue', [])
    emit('change', [])
    return
  }

  const valorTotalNum = parseValorBR(props.valorTotal)
  const valorEntradaNum = parseValorBR(props.valorEntrada)
  const valorParcelado = Math.max(0, valorTotalNum - valorEntradaNum)
  const valorParcela = valorParcelado / q

  let dataBase = new Date()
  if (props.dataContratacao) {
    const d = new Date(props.dataContratacao)
    if (!isNaN(d.getTime())) dataBase = d
  }

  const arr = []
  for (let i = 1; i <= q; i++) {
    const d = new Date(dataBase)
    d.setDate(d.getDate() + 30 * i)
    arr.push({
      numero: i,
      dataPagamento: d.toISOString().split('T')[0],
      valor: valorParcela
    })
  }
  parcelas.value = arr
  emitParcelas()
}

/**
 * Atualiza a data de vencimento de uma parcela específica (edição manual).
 */
function atualizarDataParcela(numero, novaData) {
  const p = parcelas.value.find((x) => x.numero === numero)
  if (p) {
    p.dataPagamento = novaData || p.dataPagamento
    emitParcelas()
  }
}

function emitParcelas() {
  emit('update:modelValue', parcelas.value)
  emit('change', parcelas.value)
}

// Watch quantidade - recalcula parcelas
watch(quantidadeParcelas, (newValue) => {
  if (isUpdatingFromProps.value) return

  if (newValue && newValue > 0) {
    recalcularParcelas()
  } else {
    parcelas.value = []
    emit('update:modelValue', [])
    emit('change', [])
  }
})

// Watch valor total, valor entrada, data contratação - recalcula tudo
watch(
  () => [props.valorTotal, props.valorEntrada, props.dataContratacao],
  () => {
    if (isUpdatingFromProps.value) return
    if (quantidadeParcelas.value > 0) {
      recalcularParcelas()
    }
  }
)

// Sync do modelValue (ex.: carregamento para edição)
watch(
  () => props.modelValue,
  (newValue) => {
    if (isUpdatingFromProps.value) return

    const arr = newValue && Array.isArray(newValue) ? newValue : []
    const newLength = arr.length

    if (newLength > 0) {
      if (quantidadeParcelas.value !== newLength) {
        isUpdatingFromProps.value = true
        quantidadeParcelas.value = newLength
        nextTick(() => {
          isUpdatingFromProps.value = false
        })
      }
      parcelas.value = arr.map((p) => ({ ...p }))
      // Não emite ao sincronizar do pai (ex.: carregamento para edição)
    } else {
      parcelas.value = []
    }
  },
  { immediate: true, deep: true }
)

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
</script>
