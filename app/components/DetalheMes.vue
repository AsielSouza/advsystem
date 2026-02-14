<template>
  <div class="bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden">
    <div class="px-4 py-3 border-b border-gray-200 bg-gray-50">
      <h2 class="text-lg font-semibold text-gray-900">Detalhamento por mês</h2>
      <p class="text-sm text-gray-500">
        Valores pagos no período (data de pagamento). Clique no mês para ver o detalhamento por processo.
      </p>
    </div>

    <div class="overflow-x-auto">
      <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
          <tr>
            <th
              scope="col"
              class="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider w-[180px]"
            >
              Mês
            </th>
            <th
              scope="col"
              class="px-4 py-3 text-right text-xs font-semibold text-gray-700 uppercase tracking-wider"
            >
              Valor Total
            </th>
            <th
              scope="col"
              class="px-4 py-3 text-right text-xs font-semibold text-gray-700 uppercase tracking-wider bg-blue-50"
            >
              Sócios
            </th>
            <th
              scope="col"
              class="px-4 py-3 text-right text-xs font-semibold text-gray-700 uppercase tracking-wider bg-emerald-50"
            >
              Advogados parceiros
            </th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
          <template v-for="linha in linhasVisiveis" :key="linha.mesKey">
            <!-- Linha principal do mês -->
            <tr
              class="hover:bg-gray-50 cursor-pointer transition-colors"
              :class="{ 'bg-primary-50/30': mesExpandido === linha.mesKey }"
              @click="toggleExpandir(linha.mesKey)"
            >
              <td class="px-4 py-3 whitespace-nowrap text-sm font-medium text-gray-900">
                <span class="inline-flex items-center gap-1.5">
                  {{ linha.mesLabel }}
                  <svg
                    :class="[
                      'h-4 w-4 text-gray-500 transition-transform',
                      mesExpandido === linha.mesKey ? 'rotate-180' : ''
                    ]"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                  </svg>
                </span>
              </td>
              <td class="px-4 py-3 whitespace-nowrap text-sm text-right text-gray-900">
                {{ formatCurrency(linha.total) }}
              </td>
              <td class="px-4 py-3 whitespace-nowrap text-sm text-right font-medium text-blue-800 bg-blue-50/30">
                {{ formatCurrency(linha.socios) }}
              </td>
              <td class="px-4 py-3 whitespace-nowrap text-sm text-right font-medium text-emerald-800 bg-emerald-50/30">
                {{ formatCurrency(linha.parceiros) }}
              </td>
            </tr>

            <!-- Linhas de detalhe (expandidas) -->
            <tr v-if="mesExpandido === linha.mesKey">
              <td colspan="4" class="px-0 py-0 align-top">
                <div class="bg-gray-50 border-t border-gray-200">
                  <table class="min-w-full divide-y divide-gray-200">
                    <thead class="bg-gray-100">
                      <tr>
                        <th class="px-6 py-2 text-left text-xs font-medium text-gray-600 uppercase">Nº do processo</th>
                        <th class="px-6 py-2 text-left text-xs font-medium text-gray-600 uppercase">Advogados envolvidos</th>
                        <th class="px-6 py-2 text-right text-xs font-medium text-gray-600 uppercase">Valores disponíveis</th>
                      </tr>
                    </thead>
                    <tbody class="bg-white divide-y divide-gray-100">
                      <tr
                        v-for="(item, idx) in detalhesDoMes(linha.mesKey)"
                        :key="idx"
                        class="hover:bg-gray-50"
                      >
                        <td class="px-6 py-2 text-sm text-gray-900 align-top">
                          {{ item.numero_processo }}
                        </td>
                        <td class="px-6 py-2 text-sm text-gray-700 align-top">
                          <div class="space-y-1">
                            <div
                              v-for="adv in item.advogadosComValor"
                              :key="adv.nome"
                              class="font-medium text-gray-800"
                            >
                              {{ adv.nome }}
                            </div>
                            <span v-if="!item.advogadosComValor?.length" class="text-gray-400">—</span>
                          </div>
                        </td>
                        <td class="px-6 py-2 text-sm text-right align-top">
                          <div class="space-y-1">
                            <div
                              v-for="adv in item.advogadosComValor"
                              :key="adv.nome"
                              class="font-semibold text-gray-900"
                            >
                              {{ formatCurrency(adv.valor) }}
                            </div>
                            <span v-if="!item.advogadosComValor?.length" class="text-gray-400">—</span>
                          </div>
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </td>
            </tr>
          </template>
          <tr v-if="linhasVisiveis.length === 0">
            <td colspan="4" class="px-4 py-8 text-center text-gray-500">
              Nenhum pagamento no período selecionado.
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'

const props = defineProps({
  resumoPorMes: {
    type: Array,
    default: () => []
  },
  detalhePorMesHonorario: {
    type: Object,
    default: () => ({})
  }
})

const mesExpandido = ref(null)

function toggleExpandir(mesKey) {
  mesExpandido.value = mesExpandido.value === mesKey ? null : mesKey
}

const linhasVisiveis = computed(() => props.resumoPorMes || [])

function detalhesDoMes(mesKey) {
  return (props.detalhePorMesHonorario || {})[mesKey] || []
}

function formatCurrency(value) {
  if (value == null || (typeof value !== 'number' && isNaN(parseFloat(value)))) return 'R$ 0,00'
  const num = typeof value === 'string' ? parseFloat(value) : value
  return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(num)
}
</script>
