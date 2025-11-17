<template>
  <div class="min-h-screen bg-gradient-to-br from-primary-50 to-primary-100 flex items-center justify-center p-4">
    <div class="max-w-6xl w-full grid grid-cols-1 lg:grid-cols-2 gap-8 lg:gap-12">
      <!-- Coluna Esquerda - Descrição do Sistema -->
      <div class="flex flex-col justify-center space-y-6">
        <div class="space-y-4">
          <h1 class="text-4xl lg:text-5xl font-bold text-primary-800">
            Sistema de Gestão Financeira
          </h1>
          <h2 class="text-2xl lg:text-3xl font-semibold text-primary-700">
            Escritório de Advocacia
          </h2>
        </div>
        <div class="space-y-4 text-gray-700 text-lg leading-relaxed">
          <p>
            Gerencie de forma eficiente e organizada todas as finanças do seu escritório de advocacia.
          </p>
          <p>
            Com este sistema, você terá controle total sobre receitas, despesas, processos e clientes, 
            permitindo uma visão clara e estratégica da saúde financeira do seu negócio.
          </p>
          <ul class="list-disc list-inside space-y-2 text-primary-700">
            <li>Controle de receitas e despesas</li>
            <li>Gestão de processos e honorários</li>
            <li>Relatórios financeiros detalhados</li>
            <li>Análise de performance e indicadores</li>
          </ul>
        </div>
      </div>

      <!-- Coluna Direita - Formulário de Login -->
      <div class="flex items-center justify-center">
        <div class="w-full max-w-md bg-white rounded-2xl shadow-xl p-8 lg:p-10">
          <div class="mb-8">
            <h2 class="text-3xl font-bold text-primary-800 mb-2">
              Bem-vindo
            </h2>
            <p class="text-gray-600">
              Faça login para acessar o sistema
            </p>
          </div>

          <form @submit.prevent="handleLogin" class="space-y-6">
            <Input
              v-model="email"
              type="email"
              label="Email"
              placeholder="Digite seu email"
              :required="true"
            />

            <Input
              v-model="password"
              type="password"
              label="Senha"
              placeholder="Digite sua senha"
              :required="true"
            />

            <Button
              type="submit"
              variant="primary"
              :full-width="true"
              :disabled="auth.isLoading.value"
            >
              {{ auth.isLoading.value ? 'Entrando...' : 'Entrar' }}
            </Button>
          </form>
        </div>
      </div>
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

<script setup lang="ts">
import { ref } from 'vue'

// Composables (auto-importados pelo Nuxt)
const auth = useAuth()
const toast = useToast()

// Estados do formulário
const email = ref('')
const password = ref('')

// Handler de login
const handleLogin = async () => {
  const result = await auth.login(email.value, password.value)
  
  if (!result.success && result.error) {
    toast.showError(result.error, 10000)
  }
}
</script>
