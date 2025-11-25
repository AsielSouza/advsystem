<template>
  <div class="w-full space-y-2">
    <!-- Barra de Percentual -->
    <div class="w-full h-6 bg-gray-200 rounded-full overflow-hidden flex">
      <div
        v-for="(socio, index) in sociosOrdenados"
        :key="`${socio.nome}-${index}`"
        :style="{ width: `${socio.percentual}%`, backgroundColor: getCor(index) }"
        :title="`${socio.nome}: ${socio.percentual}%`"
        class="h-full transition-all duration-300 hover:opacity-90 flex items-center justify-center"
      >
        <span
          v-if="socio.percentual >= 5"
          class="text-xs font-semibold text-white px-1 truncate"
        >
          {{ formatarPercentual(socio.percentual) }}%
        </span>
      </div>
    </div>

    <!-- Legenda com Nomes e Percentuais -->
    <div class="flex flex-wrap gap-3 text-xs">
      <div
        v-for="(socio, index) in sociosOrdenados"
        :key="`legenda-${socio.nome}-${index}`"
        class="flex items-center gap-2"
      >
        <div
          :style="{ backgroundColor: getCor(index) }"
          class="w-3 h-3 rounded-full flex-shrink-0"
        ></div>
        <span class="text-gray-700 font-medium">
          {{ socio.nome }}
        </span>
        <span class="text-gray-500">
          ({{ formatarPercentual(socio.percentual) }}%)
        </span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  socios: {
    type: Array,
    default: () => [],
    validator: (value) => {
      return Array.isArray(value) && value.every(s => 
        s && typeof s.nome === 'string' && (typeof s.percentual === 'number' || typeof s.percentual === 'string')
      )
    }
  }
})

// Cores para as barras (paleta de cores harmoniosa)
const cores = [
  '#3B82F6', // blue-500
  '#10B981', // emerald-500
  '#F59E0B', // amber-500
  '#EF4444', // red-500
  '#8B5CF6', // violet-500
  '#06B6D4', // cyan-500
  '#F97316', // orange-500
  '#EC4899', // pink-500
  '#14B8A6', // teal-500
  '#6366F1'  // indigo-500
]

// Ordena os sócios por percentual (maior para menor) para melhor visualização
const sociosOrdenados = computed(() => {
  if (!props.socios || props.socios.length === 0) return []
  
  return [...props.socios]
    .map(s => ({
      ...s,
      percentual: parseFloat(s.percentual) || 0
    }))
    .filter(s => s && s.percentual > 0)
    .sort((a, b) => b.percentual - a.percentual)
})

// Retorna a cor baseada no índice (com repetição se necessário)
const getCor = (index) => {
  return cores[index % cores.length]
}

// Formata o percentual para exibição (remove decimais desnecessários)
const formatarPercentual = (percentual) => {
  const num = parseFloat(percentual) || 0
  // Se for um número inteiro, mostra sem decimais, senão mostra 2 casas decimais
  return num % 1 === 0 ? num.toFixed(0) : num.toFixed(2)
}
</script>

