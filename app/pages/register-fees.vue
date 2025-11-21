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

      <!-- Formulário de Honorário -->
      <RegisterFeesForm
        :honorario-id="honorarioId"
        @submit="handleSubmit"
        @cancel="handleCancel"
        @error="handleError"
      />

      <!-- Toast de Notificação -->
      <Toast
        v-if="toast.showToast.value"
        :message="toast.toastMessage.value"
        :type="toast.toastType.value"
        :duration="toast.toastDuration.value"
        @close="toast.close"
      />
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import RegisterFeesForm from '../components/RegisterFeesForm.vue'
import ButtonBack from '../components/ButtonBack.vue'
import Toast from '../components/Toast.vue'

const route = useRoute()
const router = useRouter()

// Define o layout padrão para esta página
definePageMeta({
  layout: 'default'
})

// Composable para toast
const toast = useToast()

// Verifica se está em modo de edição (se tem ID na query)
const honorarioId = computed(() => {
  return route.query.id || null
})

const isEditMode = computed(() => {
  return !!honorarioId.value
})

// Handler para submit (sucesso)
const handleSubmit = (honorario) => {
  toast.success(`Honorário ${isEditMode.value ? 'atualizado' : 'cadastrado'} com sucesso!`, 3000)
  
  // Redireciona após um pequeno delay
  setTimeout(() => {
    router.push('/honorarios')
  }, 1500)
}

// Handler para erro
const handleError = (errorMessage) => {
  toast.showError(errorMessage || 'Erro ao processar o formulário. Verifique os dados e tente novamente.', 5000)
}

// Handler para cancelar
const handleCancel = () => {
  router.push('/honorarios')
}

// Função para voltar
const handleVoltar = () => {
  router.push('/honorarios')
}
</script>

