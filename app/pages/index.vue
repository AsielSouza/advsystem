<template>
  <div class="h-full w-full bg-gray-50 py-4 sm:py-8 px-4 sm:px-6 overflow-y-auto">
    <div class="max-w-7xl mx-auto w-full">
      <!-- Cabeçalho da página -->
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-gray-900 mb-2">
          Módulos do Sistema
        </h1>
        <p class="text-gray-600">
          Selecione um módulo para acessar suas funcionalidades
        </p>
      </div>

      <!-- Grid de módulos -->
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <CardModules
          v-for="(module, index) in modules"
          :key="module.id"
          :title="module.title"
          :description="module.description"
          :module-id="module.id"
          @click="handleModuleClick"
        >
          <template v-if="index === 0" #icon>
            <svg class="w-8 h-8 text-primary-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
            </svg>
          </template>
          <template v-else-if="index === 1" #icon>
            <svg class="w-6 h-6 lg:w-8 lg:h-8 text-primary-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 6l3 1m0 0l-3 9a5.002 5.002 0 006.001 0M6 7l3 9M6 7l6-2m6 2l3-1m-3 1l-3 9a5.002 5.002 0 006.001 0M18 7l3 9m-3-9l-6-2m0-2v2m0 16V5m0 16H9m3 0h3" />
            </svg>
          </template>
          <template v-else-if="index === 2" #icon>
            <svg class="w-6 h-6 lg:w-8 lg:h-8 text-primary-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </template>
        </CardModules>
      </div>
    </div>
  </div>
</template>

<script setup>
import CardModules from '../components/CardModules.vue'

const router = useRouter()

// Módulos fictícios
const modules = [
  {
    id: 'modulo-1',
    title: 'Cadastro',
    description: ''
  },
  {
    id: 'modulo-2',
    title: 'Honorários',
    description: ''
  },
  {
    id: 'modulo-3',
    title: 'Financeiro',
    description: ''
  }
]

const handleModuleClick = (moduleId) => {
  if (moduleId === 'modulo-1') {
    router.push('/modulo-clientes')
  } else if (moduleId === 'modulo-2') {
    router.push('/honorarios')
  } else if (moduleId === 'modulo-3') {
    router.push('/financeiro')
  }
}
</script>
