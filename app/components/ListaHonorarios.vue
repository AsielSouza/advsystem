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
      class="bg-white rounded-xl border border-gray-200 shadow-sm hover:shadow-md transition-shadow"
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
        <!-- Dropdown de ações e ícone de expansão -->
        <div class="ml-4 flex-shrink-0 flex items-center gap-2">
          <div class="relative">
            <button
              type="button"
              class="p-2 rounded-lg text-gray-500 hover:text-gray-700 hover:bg-gray-100 transition-colors"
              title="Ações"
              @click.stop="toggleDropdown(honorario.id)"
            >
              <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                <path d="M12 8c1.1 0 2-.9 2-2s-.9-2-2-2-2 .9-2 2 .9 2 2 2zm0 2c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2zm0 6c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2z" />
              </svg>
            </button>
            <div
              v-if="dropdownAbertoId === honorario.id"
              class="absolute right-0 top-full mt-1 py-1 w-40 bg-white rounded-lg border border-gray-200 shadow-lg z-[100] flex flex-col gap-0.5"
              @click.stop
            >
              <div
                class="flex items-center gap-2 px-3 py-2 hover:bg-gray-50 cursor-pointer"
                @click.stop="handleEditar(honorario)"
              >
                <ButtonEdit title="Editar honorário" @click.stop="handleEditar(honorario)" />
                <span class="text-sm text-gray-700">Editar</span>
              </div>
              <div
                class="flex items-center gap-2 px-3 py-2 hover:bg-gray-50 cursor-pointer"
                @click.stop="handleExcluir(honorario)"
              >
                <ButtonDelete title="Excluir honorário" @click.stop="handleExcluir(honorario)" />
                <span class="text-sm text-gray-700">Excluir</span>
              </div>
            </div>
          </div>
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

      <!-- Conteúdo Expandido (overflow apenas aqui para não cortar o dropdown do cabeçalho) -->
      <div class="overflow-hidden rounded-b-xl">
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
            @pagamento-salvo="emit('pagamento-salvo')"
          />
        </Transition>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import BarraPercentual from './BarraPercentual.vue'
import InfoProcesso from './InfoProcesso.vue'
import ButtonEdit from './ButtonEdit.vue'
import ButtonDelete from './ButtonDelete.vue'
import { useHonorarioStatus } from '~/composables/useHonorarioStatus'

const props = defineProps({
  honorarios: {
    type: Array,
    default: () => []
  }
})

const expandedHonorarios = ref([])
const dropdownAbertoId = ref(null)
const { formatStatus, getStatusClass } = useHonorarioStatus()

const toggleDropdown = (honorarioId) => {
  dropdownAbertoId.value = dropdownAbertoId.value === honorarioId ? null : honorarioId
}

const fecharDropdown = () => {
  dropdownAbertoId.value = null
}

const emit = defineEmits(['editar', 'excluir', 'pagamento-salvo'])

const handleEditar = (honorario) => {
  fecharDropdown()
  emit('editar', honorario.id)
}

const handleExcluir = (honorario) => {
  fecharDropdown()
  emit('excluir', honorario)
}

const handleClickOutside = () => {
  fecharDropdown()
}

onMounted(() => {
  document.addEventListener('click', handleClickOutside)
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
})

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

