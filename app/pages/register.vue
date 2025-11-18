<template>
  <div class="min-h-screen bg-gradient-to-br from-primary-50 via-white to-primary-100/80 flex items-center justify-center p-6 lg:p-8 relative overflow-hidden">
    <!-- Decorative elements -->
    <div class="absolute inset-0 overflow-hidden pointer-events-none">
      <div class="absolute -top-40 -right-40 w-80 h-80 bg-primary-200 rounded-full mix-blend-multiply filter blur-3xl opacity-20"></div>
      <div class="absolute -bottom-40 -left-40 w-80 h-80 bg-primary-300 rounded-full mix-blend-multiply filter blur-3xl opacity-20"></div>
    </div>
    
    <div class="w-full max-w-md relative z-10">
      <div class="bg-white rounded-3xl shadow-2xl border border-gray-100 p-10 lg:p-12 backdrop-blur-sm">
        <div class="mb-10">
          <h2 class="text-4xl font-bold text-gray-900 mb-3 tracking-tight">
            Criar Conta
          </h2>
          <p class="text-gray-600 text-base font-medium">
            Preencha os dados para se registrar
          </p>
        </div>

        <form @submit.prevent="handleRegister" class="space-y-7">
          <Input
            v-model="displayName"
            type="text"
            label="Nome de usuário"
            placeholder="Digite seu nome de usuário"
            :required="true"
            :error="errors.displayName"
            @blur="validateDisplayName"
          />

          <Input
            v-model="email"
            type="email"
            label="Email"
            placeholder="Digite seu email"
            :required="true"
            :error="errors.email"
            @blur="validateEmail"
          />

          <Input
            v-model="password"
            type="password"
            label="Senha"
            placeholder="Digite sua senha"
            :required="true"
            :error="errors.password"
            @blur="validatePassword"
          />

          <Input
            v-model="confirmPassword"
            type="password"
            label="Confirmar Senha"
            placeholder="Confirme sua senha"
            :required="true"
            :error="errors.confirmPassword"
            @blur="validateConfirmPassword"
          />

          <Button
            type="submit"
            variant="primary"
            :full-width="true"
            :disabled="auth.isLoading.value"
          >
            {{ auth.isLoading.value ? 'Cadastrando...' : 'Cadastrar' }}
          </Button>
        </form>

        <div class="mt-6 text-center">
          <p class="text-sm text-gray-600">
            Já tem uma conta?
            <NuxtLink to="/login" class="text-primary-600 hover:text-primary-700 font-semibold">
              Faça login
            </NuxtLink>
          </p>
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
import { ref, reactive } from 'vue'
import Input from '../components/Input.vue'
import Button from '../components/Button.vue'

// Define o layout específico para esta página
definePageMeta({
  layout: 'login'
})

// Composables (auto-importados pelo Nuxt)
const auth = useAuth()
const toast = useToast()
const router = useRouter()

// Estados do formulário
const displayName = ref('')
const email = ref('')
const password = ref('')
const confirmPassword = ref('')

// Erros de validação
const errors = reactive({
  displayName: '',
  email: '',
  password: '',
  confirmPassword: ''
})

// Validações
const validateDisplayName = () => {
  if (!displayName.value.trim()) {
    errors.displayName = 'Nome de usuário é obrigatório'
    return false
  }
  if (displayName.value.trim().length < 3) {
    errors.displayName = 'Nome de usuário deve ter no mínimo 3 caracteres'
    return false
  }
  errors.displayName = ''
  return true
}

const validateEmail = () => {
  if (!email.value) {
    errors.email = 'Email é obrigatório'
    return false
  }
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  if (!emailRegex.test(email.value)) {
    errors.email = 'Email inválido'
    return false
  }
  errors.email = ''
  return true
}

const validatePassword = () => {
  if (!password.value) {
    errors.password = 'Senha é obrigatória'
    return false
  }
  if (password.value.length < 6) {
    errors.password = 'Senha deve ter no mínimo 6 caracteres'
    return false
  }
  errors.password = ''
  
  // Valida confirmPassword se já foi preenchido
  if (confirmPassword.value) {
    validateConfirmPassword()
  }
  
  return true
}

const validateConfirmPassword = () => {
  if (!confirmPassword.value) {
    errors.confirmPassword = 'Confirmação de senha é obrigatória'
    return false
  }
  if (password.value !== confirmPassword.value) {
    errors.confirmPassword = 'As senhas não coincidem'
    return false
  }
  errors.confirmPassword = ''
  return true
}

// Handler de registro
const handleRegister = async () => {
  // Limpar erros anteriores
  Object.keys(errors).forEach(key => {
    errors[key] = ''
  })

  // Validar todos os campos
  const isDisplayNameValid = validateDisplayName()
  const isEmailValid = validateEmail()
  const isPasswordValid = validatePassword()
  const isConfirmPasswordValid = validateConfirmPassword()

  if (!isDisplayNameValid || !isEmailValid || !isPasswordValid || !isConfirmPasswordValid) {
    return
  }

  // Realizar registro
  const result = await auth.register(email.value, password.value, displayName.value.trim())

  if (result.success) {
    toast.showSuccess('Conta criada com sucesso! Redirecionando...', 3000)
    setTimeout(() => {
      router.push('/login')
    }, 2000)
  } else if (result.error) {
    toast.showError(result.error, 10000)
  }
}
</script>

