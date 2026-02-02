<template>
  <div class="bg-white rounded-xl border border-gray-200 overflow-hidden">
    <div class="px-6 py-4 border-b border-gray-200">
      <h3 class="text-lg font-semibold text-gray-900">Parcelas</h3>
    </div>

    <div v-if="parcelas.length === 0" class="p-12 text-center">
      <p class="text-gray-500 text-sm">Nenhuma parcela encontrada</p>
    </div>

    <div v-else class="overflow-x-auto">
      <table class="w-full">
        <thead class="bg-gray-50 border-b border-gray-200">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
              Nº
            </th>
            <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
              Saldo Devedor
            </th>
            <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
              Data de Vencimento
            </th>
            <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
              Status
            </th>
            <th class="px-6 py-3 text-right text-xs font-semibold text-gray-700 uppercase tracking-wider">
              Ações
            </th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
          <tr
            v-for="parcela in parcelasOrdenadas"
            :key="parcela.id"
            class="hover:bg-gray-50 transition-colors"
          >
            <td class="px-6 py-4 whitespace-nowrap">
              <span class="text-sm font-medium text-gray-900">{{ parcela.numero_da_parcela }}</span>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <span class="text-sm text-gray-900">{{ formatCurrency(getValorParcela(parcela)) }}</span>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <span class="text-sm text-gray-900">{{ formatDate(parcela.data_vencimento) }}</span>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <span
                :class="[
                  'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium',
                  getStatusClass(parcela)
                ]"
              >
                {{ getStatusLabel(parcela) }}
              </span>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
              <Button
                v-if="getValorParcela(parcela) > 0"
                variant="primary"
                size="sm"
                :disabled="!podePagarParcela(parcela)"
                :title="!podePagarParcela(parcela) ? 'Pague a parcela anterior primeiro' : undefined"
                @click="$emit('pagar', parcela)"
              >
                Pagar
              </Button>
              <span v-else class="text-gray-400 text-sm">Paga</span>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import Button from './Button.vue'

const props = defineProps({
  parcelas: {
    type: Array,
    default: () => []
  }
})

defineEmits(['pagar'])

// Parcelas ordenadas por número (sequência 1, 2, 3...)
const parcelasOrdenadas = computed(() => {
  return [...props.parcelas].sort((a, b) => a.numero_da_parcela - b.numero_da_parcela)
})

// Verifica se uma parcela está totalmente paga (valor recebido >= valor devido)
const parcelaTotalmentePaga = (parcela) => {
  const valorParcela = parseFloat(parcela.valor_parcela) || 0
  const valorPago = parseFloat(parcela.valor_pago_parcela) || 0
  return valorPago >= valorParcela
}

// Verifica se o botão de pagamento da parcela deve estar habilitado.
// Regras: parcela 01 sempre habilitada quando pendente; demais apenas quando
// a parcela imediatamente anterior estiver totalmente paga.
const podePagarParcela = (parcela) => {
  const valorParcela = parseFloat(parcela.valor_parcela) || 0
  const valorPago = parseFloat(parcela.valor_pago_parcela) || 0
  const saldoDevedor = valorParcela - valorPago

  if (saldoDevedor <= 0) return false

  const numero = parcela.numero_da_parcela

  if (numero === 1) return true

  const parcelaAnterior = props.parcelas.find((p) => p.numero_da_parcela === numero - 1)
  if (!parcelaAnterior) return true

  return parcelaTotalmentePaga(parcelaAnterior)
}

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
  return d.toLocaleDateString('pt-BR')
}

const getStatusClass = (parcela) => {
  const status = parcela.status || 'pendente'
  const dataVencimento = new Date(parcela.data_vencimento)
  dataVencimento.setHours(0, 0, 0, 0)
  const hojeDate = new Date()
  hojeDate.setHours(0, 0, 0, 0)
  const valorParcela = parseFloat(parcela.valor_parcela) || 0
  const valorPago = parseFloat(parcela.valor_pago_parcela) || 0
  const saldo = valorParcela - valorPago

  if (status === 'paga') {
    return 'bg-green-100 text-green-800'
  } else if (dataVencimento < hojeDate && saldo > 0) {
    return 'bg-red-100 text-red-800'
  } else {
    return 'bg-yellow-100 text-yellow-800'
  }
}

const getStatusLabel = (parcela) => {
  const status = parcela.status || 'pendente'
  const dataVencimento = new Date(parcela.data_vencimento)
  dataVencimento.setHours(0, 0, 0, 0)
  const hojeDate = new Date()
  hojeDate.setHours(0, 0, 0, 0)
  const valorParcela = parseFloat(parcela.valor_parcela) || 0
  const valorPago = parseFloat(parcela.valor_pago_parcela) || 0
  const saldo = valorParcela - valorPago

  if (status === 'paga') {
    return 'Paga'
  } else if (dataVencimento < hojeDate && saldo > 0) {
    return 'Em Atraso'
  } else {
    return 'Pendente'
  }
}

// Calcular o valor da parcela (saldo devedor)
const getValorParcela = (parcela) => {
  const valorParcela = parseFloat(parcela.valor_parcela) || 0
  const valorPago = parseFloat(parcela.valor_pago_parcela) || 0
  return valorParcela - valorPago
}
</script>

