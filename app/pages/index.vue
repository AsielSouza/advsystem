<template>
  <div class="min-h-screen bg-gray-50 py-8 px-6">
    <div class="max-w-7xl mx-auto">
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
      <div class="grid grid-cols-1 lg:grid-cols-4 gap-6">
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
    title: 'Módulo 2',
    description: 'Descrição do segundo módulo do sistema. Funcionalidades e recursos disponíveis.'
  },
  {
    id: 'modulo-3',
    title: 'Módulo 3',
    description: 'Descrição do terceiro módulo do sistema. Funcionalidades e recursos disponíveis.'
  },
  {
    id: 'modulo-4',
    title: 'Módulo 4',
    description: 'Descrição do quarto módulo do sistema. Funcionalidades e recursos disponíveis.'
  }
]

const handleModuleClick = (moduleId) => {
  if (moduleId === 'modulo-1') {
    router.push('/modulo-clientes')
  } else {
    // Lógica será implementada posteriormente para outros módulos
    console.log('Módulo clicado:', moduleId)
  }
}
</script>
