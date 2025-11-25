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
                getStatusClass(honorario)
              ]"
            >
              {{ formatStatus(honorario) }}
            </span>
          </div>
          <div class="flex flex-col gap-2 text-sm text-gray-600">
            <!-- Advogado Responsável Único -->
            <div v-if="honorario.advogado_responsavel && !honorario.dividir_entre_socios" class="flex items-center gap-4">
              <span>
                Advogado Responsável: {{ honorario.advogado_responsavel }}
              </span>
              <span v-if="honorario.valor_total" class="font-semibold text-gray-900">
                {{ formatCurrency(honorario.valor_total) }}
              </span>
            </div>
            <!-- Advogados Responsáveis (Sócios) com Barra de Percentual -->
            <div v-else-if="honorario.advogados_socios && honorario.advogados_socios.length > 0" class="space-y-2">
              <div class="flex items-center gap-4">
                <span class="text-xs font-medium text-gray-500 uppercase">Advogados Responsáveis:</span>
                <span v-if="honorario.valor_total" class="font-semibold text-gray-900">
                  {{ formatCurrency(honorario.valor_total) }}
                </span>
              </div>
              <BarraPercentual :socios="honorario.advogados_socios" />
            </div>
            <div v-else class="flex items-center gap-4">
              <span class="text-gray-400">
                Nenhum advogado responsável definido
              </span>
              <span v-if="honorario.valor_total" class="font-semibold text-gray-900">
                {{ formatCurrency(honorario.valor_total) }}
              </span>
            </div>
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
        <InfoProcesso
          v-if="expandedHonorarios.includes(honorario.id)"
          :honorario="honorario"
        />
      </Transition>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import BarraPercentual from './BarraPercentual.vue'
import InfoProcesso from './InfoProcesso.vue'
import { useHonorarioStatus } from '~/composables/useHonorarioStatus'

const props = defineProps({
  honorarios: {
    type: Array,
    default: () => []
  }
})

const expandedHonorarios = ref([])
const { formatStatus, getStatusClass } = useHonorarioStatus()

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
</script>

<style scoped>
@keyframes piscar-vermelho {
  0%, 100% {
    background-color: rgb(254 226 226);
    color: rgb(153 27 27);
    opacity: 1;
  }
  50% {
    background-color: rgb(239 68 68);
    color: rgb(255 255 255);
    opacity: 0.9;
  }
}

.status-atraso-piscante {
  animation: piscar-vermelho 1.5s ease-in-out infinite;
}
</style>

