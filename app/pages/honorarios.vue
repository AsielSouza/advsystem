<template>
  <div class="h-full w-full bg-gray-50 py-4 sm:py-8 px-4 sm:px-6 overflow-y-auto">
    <div class="max-w-7xl mx-auto w-full">
      <!-- Cabeçalho da página -->
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-gray-900 mb-2">
          Módulo de Honorários
        </h1>
        <p class="text-gray-600">
          Gerencie os honorários do sistema
        </p>
      </div>

      <!-- Grid de módulos -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 max-w-4xl">
        <!-- Dashboard de Honorários -->
        <CardModules
          title="Dashboard de Honorários"
          description="Visualize e gerencie toda a movimentação dos honorários"
          module-id="dashboard-fees"
          @click="handleModuleClick"
        >
          <template #icon>
            <svg class="w-6 h-6 lg:w-8 lg:h-8 text-primary-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
            </svg>
          </template>
        </CardModules>

        <!-- Novo honorário -->
        <CardModules
          title="Novo honorário"
          description="Cadastre um novo honorário no sistema"
          module-id="novo-honorario"
          @click="handleModuleClick"
        >
          <template #icon>
            <div class="relative">
              <!-- Ícone de Balança da Justiça -->
              <svg class="w-6 h-6 lg:w-8 lg:h-8 text-primary-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 6l3 1m0 0l-3 9a5.002 5.002 0 006.001 0M6 7l3 9M6 7l6-2m6 2l3-1m-3 1l-3 9a5.002 5.002 0 006.001 0M18 7l3 9m-3-9l-6-2m0-2v2m0 16V5m0 16H9m3 0h3" />
              </svg>
              <!-- Símbolo de "+" em um círculo no canto inferior direito -->
              <div class="absolute -bottom-1 -right-1 w-4 h-4 lg:w-5 lg:h-5 bg-primary-600 rounded-full flex items-center justify-center shadow-sm">
                <svg class="w-2.5 h-2.5 lg:w-3 lg:h-3 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
                </svg>
              </div>
            </div>
          </template>
        </CardModules>
      </div>
    </div>
  </div>
</template>

<script setup>
import CardModules from '../components/CardModules.vue'

const router = useRouter()

// Define o layout padrão para esta página
definePageMeta({
  layout: 'default'
})

const handleModuleClick = (moduleId) => {
  if (moduleId === 'dashboard-fees') {
    router.push('/dashboard-fees')
  } else if (moduleId === 'novo-honorario') {
    router.push('/register-fees')
  }
}
</script>

