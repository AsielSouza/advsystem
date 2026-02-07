<template>
  <div class="h-full w-full bg-gray-50 py-4 sm:py-8 px-4 sm:px-6 overflow-y-auto">
    <div class="max-w-7xl mx-auto w-full">
      <!-- Cabeçalho da página -->
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-gray-900 mb-2">
          Financeiro
        </h1>
        <p class="text-gray-600">
          Visão geral do caixa e resumos por período
        </p>
      </div>

      <!-- Grid de módulos -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 max-w-4xl">
        <CardModules
          title="Visão geral por período"
          description="Totais por data de pagamento, com divisão Sócios e Advogados parceiros, por mês"
          module-id="resumo-periodo"
          @click="handleModuleClick"
        >
          <template #icon>
            <svg class="w-6 h-6 lg:w-8 lg:h-8 text-primary-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
            </svg>
          </template>
        </CardModules>
      </div>
    </div>
  </div>
</template>

<script setup>
import CardModules from '../../components/CardModules.vue'

definePageMeta({
  layout: 'default'
})

const router = useRouter()

const handleModuleClick = (moduleId) => {
  if (moduleId === 'resumo-periodo') {
    router.push('/financeiro/resumo')
  }
}
</script>
