<template>
  <div class="min-h-screen bg-gray-50 py-8 px-6">
    <div class="max-w-7xl mx-auto">
      <!-- Cabeçalho da página -->
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-gray-900 mb-2">
          Módulo de Clientes
        </h1>
        <p class="text-gray-600">
          Gerencie seus clientes: visualize listas ou cadastre novos
        </p>
      </div>

      <!-- Grid de módulos -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 max-w-4xl">
        <!-- Lista de Clientes -->
        <CardModules
          title="Lista de Clientes"
          description="Visualize e gerencie todos os clientes cadastrados no sistema"
          module-id="lista-clientes"
          @click="handleModuleClick"
        >
          <template #icon>
            <svg class="w-6 h-6 lg:w-8 lg:h-8 text-primary-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01" />
            </svg>
          </template>
        </CardModules>

        <!-- Cadastrar novo cliente -->
        <CardModules
          title="Cadastrar novo cliente"
          description="Adicione um novo cliente ao sistema preenchendo os dados necessários"
          module-id="cadastrar-cliente"
          @click="handleModuleClick"
        >
          <template #icon>
            <div class="relative">
              <!-- Ícone de usuários múltiplos -->
              <svg class="w-6 h-6 lg:w-8 lg:h-8 text-primary-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
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
  if (moduleId === 'lista-clientes') {
    router.push('/clientes')
  } else if (moduleId === 'cadastrar-cliente') {
    router.push('/register-client')
  }
}
</script>

