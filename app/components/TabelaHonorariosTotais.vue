<template>
  <div class="space-y-4">
    <h4
      class="text-sm font-semibold text-gray-800 uppercase tracking-wider flex items-center gap-2"
      :class="tituloClasse"
    >
      <span
        class="w-8 h-8 rounded-lg flex items-center justify-center"
        :class="iconeContainerClasse"
      >
        <!-- Sócios -->
        <svg
          v-if="variante === 'socio'"
          class="w-4 h-4 text-primary-600"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"
          />
        </svg>
        <!-- Parceiros -->
        <svg
          v-else
          class="w-4 h-4 text-emerald-600"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2 2v2m4 6h.01M5 20h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z"
          />
        </svg>
      </span>
      {{ tituloSecao }}
    </h4>

    <div class="bg-white rounded-xl border border-gray-200 overflow-hidden shadow-sm">
      <div class="overflow-x-auto">
        <table class="w-full">
          <thead class="bg-gray-50 border-b border-gray-200">
            <tr>
              <th
                class="px-6 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider"
              >
                Advogado
              </th>
              <th
                class="px-6 py-3 text-right text-xs font-semibold text-gray-700 uppercase tracking-wider"
              >
                A receber
              </th>
              <th
                class="px-6 py-3 text-right text-xs font-semibold text-gray-700 uppercase tracking-wider"
              >
                Disponível para Resgate
              </th>
              <th
                class="px-6 py-3 text-right text-xs font-semibold text-gray-700 uppercase tracking-wider"
              >
                Provisionado
              </th>
              <th
                class="px-6 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider w-48"
              >
                % disponível
              </th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr
              v-for="item in items"
              :key="item.id || item.nome"
              class="hover:bg-gray-50 transition-colors"
            >
              <td class="px-6 py-4 whitespace-nowrap">
                <span class="text-sm font-medium text-gray-900">{{ item.nome }}</span>
                <span
                  class="ml-2 inline-flex px-2 py-0.5 text-xs font-medium rounded-full"
                  :class="badgeClasse"
                >
                  {{ labelBadge }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-semibold text-primary-600">
                {{ formatCurrency(item.aReceber) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-semibold text-green-600">
                {{ formatCurrency(item.disponivelResgate) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-semibold text-amber-600">
                {{ formatCurrency(item.provisionado) }}
              </td>
              <td class="px-6 py-4">
                <BarraPercentualDisponivel
                  :percentual="percentualDisponivel(item)"
                  :mostrar-texto="false"
                />
                <span class="text-xs text-gray-500 mt-0.5 block">
                  {{ percentualDisponivel(item).toFixed(1) }}% já disponível
                </span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import BarraPercentualDisponivel from './BarraPercentualDisponivel.vue'

const props = defineProps({
  /** Título da seção (ex: "Sócios / Advogado Responsável" ou "Advogados Parceiros") */
  tituloSecao: {
    type: String,
    required: true
  },
  /** Lista de itens com nome e valores de honorário */
  items: {
    type: Array,
    default: () => [],
    validator: (value) =>
      Array.isArray(value) &&
      value.every(
        (i) =>
          i &&
          typeof i.nome === 'string' &&
          typeof i.aReceber === 'number' &&
          typeof i.disponivelResgate === 'number' &&
          typeof i.provisionado === 'number'
      )
  },
  /** Variante visual: 'socio' ou 'parceiro' (define ícone e badge) */
  variante: {
    type: String,
    default: 'socio',
    validator: (v) => v === 'socio' || v === 'parceiro'
  }
})

const labelBadge = computed(() => (props.variante === 'socio' ? 'Sócio' : 'Parceiro'))

const badgeClasse = computed(() =>
  props.variante === 'socio'
    ? 'bg-primary-100 text-primary-800'
    : 'bg-emerald-100 text-emerald-800'
)

const iconeContainerClasse = computed(() =>
  props.variante === 'socio' ? 'bg-primary-100' : 'bg-emerald-100'
)

function percentualDisponivel(item) {
  if (!item.aReceber || item.aReceber <= 0) return 0
  return Math.min(100, (item.disponivelResgate / item.aReceber) * 100)
}

function formatCurrency(value) {
  if (value !== 0 && !value) return 'R$ 0,00'
  const num = typeof value === 'string' ? parseFloat(value) : value
  if (Number.isNaN(num)) return 'R$ 0,00'
  return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(num)
}
</script>
