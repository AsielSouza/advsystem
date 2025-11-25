<template>
  <div class="border-t border-gray-200 overflow-hidden">
    <div class="p-6 space-y-6">
      <!-- Informações Principais -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        <div>
          <p class="text-xs font-medium text-gray-500 uppercase mb-1">Cliente</p>
          <p class="text-sm font-semibold text-gray-900">
            {{ honorario.cliente_nome || 'Não informado' }}
          </p>
        </div>
        <div>
          <p class="text-xs font-medium text-gray-500 uppercase mb-1">Valor Total</p>
          <p class="text-sm font-semibold text-gray-900">
            {{ formatCurrency(honorario.valor_total) }}
          </p>
        </div>
        <div>
          <p class="text-xs font-medium text-gray-500 uppercase mb-1">Forma de Pagamento</p>
          <p class="text-sm font-semibold text-gray-900">
            {{ formatFormaPagamento(honorario.forma_pagamento) }}
          </p>
        </div>
        <div>
          <p class="text-xs font-medium text-gray-500 uppercase mb-1">Data de Contratação</p>
          <p class="text-sm font-semibold text-gray-900">
            {{ formatDate(honorario.data_contratacao) }}
          </p>
        </div>
      </div>

      <!-- Abas de Navegação -->
      <AbasProcesso :honorario="honorario" />
    </div>
  </div>
</template>

<script setup>
import AbasProcesso from './AbasProcesso.vue'

const props = defineProps({
  honorario: {
    type: Object,
    required: true
  }
})

// Funções de formatação
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

const formatFormaPagamento = (forma) => {
  const formasMap = {
    'avista': 'À Vista',
    'parcelado': 'Parcelado'
  }
  return formasMap[forma] || forma || 'Não informado'
}
</script>

