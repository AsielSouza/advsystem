<template>
  <button
    @click="handleLogout"
    :disabled="isLoading"
    class="p-2 text-gray-600 hover:text-danger-600 hover:bg-danger-50 rounded-lg transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-danger-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed"
    aria-label="Sair"
    title="Sair"
  >
    <svg
      v-if="!isLoading"
      xmlns="http://www.w3.org/2000/svg"
      class="h-6 w-6"
      fill="none"
      viewBox="0 0 24 24"
      stroke="currentColor"
      stroke-width="2"
    >
      <path
        stroke-linecap="round"
        stroke-linejoin="round"
        d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"
      />
    </svg>
    <svg
      v-else
      xmlns="http://www.w3.org/2000/svg"
      class="h-6 w-6 animate-spin"
      fill="none"
      viewBox="0 0 24 24"
    >
      <circle
        class="opacity-25"
        cx="12"
        cy="12"
        r="10"
        stroke="currentColor"
        stroke-width="4"
      ></circle>
      <path
        class="opacity-75"
        fill="currentColor"
        d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
      ></path>
    </svg>
  </button>
</template>

<script setup>
import { ref } from 'vue'

const auth = useAuth()
const toast = useToast()
const isLoading = ref(false)

const handleLogout = async () => {
  if (isLoading.value) return

  isLoading.value = true

  try {
    const result = await auth.logout()

    if (result.success) {
      toast.showSuccess('Logout realizado com sucesso!', 3000)
    } else if (result.error) {
      toast.showError(result.error, 5000)
    }
  } catch (error) {
    console.error('Erro ao fazer logout:', error)
    toast.showError('Erro ao fazer logout. Tente novamente.', 5000)
  } finally {
    isLoading.value = false
  }
}
</script>

