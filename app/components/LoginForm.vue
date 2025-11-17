<template>
  <form
    @submit.prevent="handleSubmit"
    class="space-y-6"
  >
    <Input
      v-model="formData.email"
      type="email"
      label="Email"
      placeholder="Digite seu email"
      :required="true"
      :error="errors.email"
      @blur="validateEmail"
    />

    <Input
      v-model="formData.password"
      type="password"
      label="Senha"
      placeholder="Digite sua senha"
      :required="true"
      :error="errors.password"
      @blur="validatePassword"
    />

    <div class="flex items-center justify-between">
      <label class="flex items-center">
        <input
          v-model="formData.rememberMe"
          type="checkbox"
          class="w-4 h-4 text-primary-600 border-gray-300 rounded focus:ring-primary-500"
        />
        <span class="ml-2 text-sm text-gray-700">Lembrar-me</span>
      </label>
      <a
        href="#"
        class="text-sm text-primary-600 hover:text-primary-800"
        @click.prevent="$emit('forgotPassword')"
      >
        Esqueceu a senha?
      </a>
    </div>

    <Button
      type="submit"
      variant="primary"
      :full-width="true"
      :disabled="isSubmitting"
    >
      {{ isSubmitting ? 'Entrando...' : 'Entrar' }}
    </Button>

    <div
      v-if="errorMessage"
      class="bg-red-50 border-l-4 border-red-500 p-4 rounded"
    >
      <p class="text-sm text-red-700">{{ errorMessage }}</p>
    </div>
  </form>
</template>

<script setup>
import { ref, reactive } from 'vue'

const props = defineProps({
  isLoading: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['submit', 'forgotPassword'])

const formData = reactive({
  email: '',
  password: '',
  rememberMe: false
})

const errors = reactive({
  email: '',
  password: ''
})

const isSubmitting = ref(false)
const errorMessage = ref('')

const validateEmail = () => {
  if (!formData.email) {
    errors.email = 'Email é obrigatório'
    return false
  }
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  if (!emailRegex.test(formData.email)) {
    errors.email = 'Email inválido'
    return false
  }
  errors.email = ''
  return true
}

const validatePassword = () => {
  if (!formData.password) {
    errors.password = 'Senha é obrigatória'
    return false
  }
  if (formData.password.length < 6) {
    errors.password = 'Senha deve ter no mínimo 6 caracteres'
    return false
  }
  errors.password = ''
  return true
}

const handleSubmit = async () => {
  // Limpar mensagens de erro anteriores
  errorMessage.value = ''

  // Validar campos
  const isEmailValid = validateEmail()
  const isPasswordValid = validatePassword()

  if (!isEmailValid || !isPasswordValid) {
    return
  }

  isSubmitting.value = true

  try {
    await emit('submit', {
      email: formData.email,
      password: formData.password,
      rememberMe: formData.rememberMe
    })
  } catch (error) {
    errorMessage.value = error.message || 'Erro ao fazer login. Tente novamente.'
  } finally {
    isSubmitting.value = false
  }
}
</script>

