<template>
  <div class="h-full w-full bg-gray-50 py-4 sm:py-8 px-4 sm:px-6 overflow-y-auto">
    <div class="max-w-4xl mx-auto w-full">
      <!-- Cabeçalho da página -->
      <div class="mb-8">
        <div class="flex items-center justify-between mb-4">
          <ButtonBack @click="handleVoltar" />
        </div>
        <h1 class="text-3xl font-bold text-gray-900 mb-2">
          {{ isEditMode ? 'Editar Honorário' : 'Novo Honorário' }}
        </h1>
        <p class="text-gray-600">
          {{ isEditMode ? 'Edite os dados do honorário' : 'Cadastre um novo honorário no sistema' }}
        </p>
      </div>

      <!-- Componente de Registro de Honorário -->
      <RegisterFees :honorario-id="honorarioId" />
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import RegisterFees from '../components/RegisterFees.vue'
import ButtonBack from '../components/ButtonBack.vue'

const route = useRoute()
const router = useRouter()

// Define o layout padrão para esta página
definePageMeta({
  layout: 'default'
})

// Verifica se está em modo de edição (se tem ID na query)
const honorarioId = computed(() => {
  return route.query.id || null
})

const isEditMode = computed(() => {
  return !!honorarioId.value
})

// Função para voltar
const handleVoltar = () => {
  router.push('/honorarios')
}
</script>
