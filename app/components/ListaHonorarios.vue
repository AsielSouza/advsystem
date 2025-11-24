<template>
  <div class="w-full space-y-3">
    <!-- Mensagem quando não há honorários -->
    <div v-if="!honorarios || honorarios.length === 0" class="text-center py-12 bg-white rounded-xl border border-gray-200">
      <p class="text-gray-500 text-lg">Nenhum honorário encontrado</p>
    </div>

    <!-- Lista de Honorários -->
    <div
      v-for="honorario in honorarios"
      :key="honorario.id"
      class="bg-white rounded-xl border border-gray-200 overflow-hidden shadow-sm hover:shadow-md transition-shadow"
    >
      <!-- Cabeçalho do Honorário (Sempre visível) -->
      <button
        @click="toggleHonorario(honorario.id)"
        class="w-full px-6 py-4 flex items-center justify-between hover:bg-gray-50 transition-colors text-left"
      >
        <div class="flex-1">
          <div class="flex items-center gap-3 mb-1">
            <h3 class="text-lg font-semibold text-gray-900">
              Processo #{{ honorario.numero_processo || 'N/A' }}
            </h3>
            <span
              :class="[
                'px-2 py-1 rounded-full text-xs font-medium',
                getStatusClass(honorario.status)
              ]"
            >
              {{ formatStatus(honorario.status) }}
            </span>
          </div>
          <div class="flex items-center gap-4 text-sm text-gray-600">
            <!-- Advogado Responsável Único -->
            <span v-if="honorario.advogado_responsavel && !honorario.dividir_entre_socios">
              Advogado Responsável: {{ honorario.advogado_responsavel }}
            </span>
            <!-- Advogados Responsáveis (Sócios) -->
            <span v-else-if="honorario.advogados_socios && honorario.advogados_socios.length > 0">
              Advogados Responsáveis: {{ formatarAdvogadosSocios(honorario.advogados_socios) }}
            </span>
            <span v-else class="text-gray-400">
              Nenhum advogado responsável definido
            </span>
            <span v-if="honorario.valor_total" class="font-semibold text-gray-900">
              {{ formatCurrency(honorario.valor_total) }}
            </span>
          </div>
        </div>
        <!-- Ícone de expansão -->
        <div class="ml-4 flex-shrink-0">
          <svg
            :class="[
              'h-5 w-5 text-gray-400 transition-transform duration-200',
              expandedHonorarios.includes(honorario.id) ? 'transform rotate-180' : ''
            ]"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
          </svg>
        </div>
      </button>

      <!-- Conteúdo Expandido -->
      <Transition
        enter-active-class="transition ease-out duration-200"
        enter-from-class="opacity-0 max-h-0"
        enter-to-class="opacity-100 max-h-screen"
        leave-active-class="transition ease-in duration-150"
        leave-from-class="opacity-100 max-h-screen"
        leave-to-class="opacity-0 max-h-0"
      >
        <div
          v-if="expandedHonorarios.includes(honorario.id)"
          class="border-t border-gray-200 overflow-hidden"
        >
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

            <!-- Resumo de Parcelas -->
            <div v-if="honorario.parcelas && honorario.parcelas.length > 0" class="border-t border-gray-200 pt-4">
              <h4 class="text-sm font-semibold text-gray-900 mb-3">Resumo de Parcelas</h4>
              <div class="space-y-2">
                <div class="flex items-center justify-between text-sm">
                  <span class="text-gray-600">Total de parcelas:</span>
                  <span class="font-semibold text-gray-900">{{ honorario.parcelas.length }}</span>
                </div>
                <div class="flex items-center justify-between text-sm">
                  <span class="text-gray-600">Parcelas pagas:</span>
                  <span class="font-semibold text-success-600">
                    {{ getParcelasPagas(honorario.parcelas) }}
                  </span>
                </div>
                <div class="flex items-center justify-between text-sm">
                  <span class="text-gray-600">Parcelas pendentes:</span>
                  <span class="font-semibold text-warning-600">
                    {{ getParcelasPendentes(honorario.parcelas) }}
                  </span>
                </div>
              </div>
            </div>

            <!-- Botão de Ações -->
            <div class="flex items-center gap-3 pt-4 border-t border-gray-200">
              <Button
                variant="primary"
                size="sm"
                @click="editarHonorario(honorario.id)"
              >
                Editar Honorário
              </Button>
            </div>
          </div>
        </div>
      </Transition>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import Button from './Button.vue'

const props = defineProps({
  honorarios: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['editar'])

const expandedHonorarios = ref([])

const toggleHonorario = (honorarioId) => {
  const index = expandedHonorarios.value.indexOf(honorarioId)
  if (index > -1) {
    expandedHonorarios.value.splice(index, 1)
  } else {
    expandedHonorarios.value.push(honorarioId)
  }
}

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

const formatStatus = (status) => {
  const statusMap = {
    'pendente': 'Pendente',
    'pago': 'Pago',
    'cancelado': 'Cancelado',
    'paga': 'Paga'
  }
  return statusMap[status] || status || 'Não definido'
}

const formatFormaPagamento = (forma) => {
  const formasMap = {
    'avista': 'À Vista',
    'parcelado': 'Parcelado'
  }
  return formasMap[forma] || forma || 'Não informado'
}

const getStatusClass = (status) => {
  const statusClasses = {
    'pago': 'bg-green-100 text-green-800',
    'paga': 'bg-green-100 text-green-800',
    'pendente': 'bg-yellow-100 text-yellow-800',
    'cancelado': 'bg-red-100 text-red-800'
  }
  return statusClasses[status] || 'bg-gray-100 text-gray-800'
}

const getParcelasPagas = (parcelas) => {
  if (!parcelas || !Array.isArray(parcelas)) return 0
  return parcelas.filter(p => p.status === 'paga' || p.status === 'pago').length
}

const getParcelasPendentes = (parcelas) => {
  if (!parcelas || !Array.isArray(parcelas)) return 0
  return parcelas.filter(p => p.status === 'pendente').length
}

const formatarAdvogadosSocios = (advogadosSocios) => {
  if (!advogadosSocios || advogadosSocios.length === 0) return ''
  return advogadosSocios.map(socio => `${socio.nome} [${socio.percentual}%]`).join(', ')
}

const editarHonorario = (id) => {
  emit('editar', id)
}
</script>

