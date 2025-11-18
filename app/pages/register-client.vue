<template>
  <div class="min-h-screen bg-gray-50 py-8 px-6">
    <div class="max-w-4xl mx-auto">
      <!-- Cabeçalho da página -->
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-gray-900 mb-2">
          Cadastro de Clientes
        </h1>
        <p class="text-gray-600">
          Preencha os dados do cliente conforme o tipo de pessoa
        </p>
      </div>

      <!-- Card de cadastro com abas -->
      <RegisterCard />
    </div>

    <!-- Toast de Notificação -->
    <Toast
      v-if="toast.showToast.value"
      :message="toast.toastMessage.value"
      :type="toast.toastType.value"
      :duration="toast.toastDuration.value"
      @close="toast.close"
    />
  </div>
</template>

<script setup>
import RegisterCard from '../components/RegisterCard.vue'
import Toast from '../components/Toast.vue'

// Define o layout padrão para esta página
definePageMeta({
  layout: 'default'
})

// Composable para toast (será usado pelo RegisterCard)
const toast = useToast()
</script>

