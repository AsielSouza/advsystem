<template>
  <div class="flex items-center justify-center">
    <div 
      :class="[
        'w-full max-w-md bg-white rounded-3xl shadow-2xl border border-gray-100 p-10 lg:p-12 backdrop-blur-sm transition-all duration-700 ease-out',
        isVisible ? 'translate-y-0 opacity-100' : 'translate-y-12 opacity-0'
      ]"
    >
      <div class="mb-10">
        <h2 class="text-4xl font-bold text-gray-900 mb-3 tracking-tight">
          Bem-vindo
        </h2>
        <p class="text-gray-600 text-base font-medium">
          Faça login para acessar o sistema
        </p>
      </div>

      <form @submit.prevent="handleSubmit" class="space-y-7">
        <Input
          v-model="email"
          type="email"
          label="Email"
          placeholder="Digite seu email"
          :required="true"
        />

        <InputPassword
          v-model="password"
          label="Senha"
          placeholder="Digite sua senha"
          :required="true"
        />

        <Button
          type="submit"
          variant="primary"
          :full-width="true"
          :disabled="isLoading"
        >
          {{ isLoading ? 'Entrando...' : 'Entrar' }}
        </Button>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import Input from './Input.vue'
import InputPassword from './InputPassword.vue'
import Button from './Button.vue'

const props = defineProps({
  isLoading: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['submit'])

const email = ref('')
const password = ref('')
const isVisible = ref(false)

onMounted(() => {
  // Pequeno delay para garantir que o DOM está pronto
  setTimeout(() => {
    isVisible.value = true
  }, 50)
})

const handleSubmit = () => {
  emit('submit', {
    email: email.value,
    password: password.value
  })
}
</script>

