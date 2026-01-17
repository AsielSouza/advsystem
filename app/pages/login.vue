 <template>
  <div class="h-full w-full bg-gradient-to-br from-primary-50 via-white to-primary-100/80 flex items-center justify-center p-4 sm:p-6 lg:p-8 relative overflow-hidden">
    <!-- Decorative elements -->
    <div class="absolute inset-0 overflow-hidden pointer-events-none">
      <div class="absolute -top-40 -right-40 w-80 h-80 bg-primary-200 rounded-full mix-blend-multiply filter blur-3xl opacity-20"></div>
      <div class="absolute -bottom-40 -left-40 w-80 h-80 bg-primary-300 rounded-full mix-blend-multiply filter blur-3xl opacity-20"></div>
    </div>
    
    <div class="w-full flex items-center justify-center relative z-10">
      <!-- Formulário de Login Centralizado -->
      <LoginCard
        :is-loading="auth.isLoading.value"
        @submit="handleLogin"
      />
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
import { watch, onMounted } from 'vue'
import LoginCard from '../components/LoginCard.vue'

// Define o layout específico para esta página
definePageMeta({
  layout: 'login'
})

// Composables (auto-importados pelo Nuxt)
const auth = useAuth()
const toast = useToast()
const user = useSupabaseUser()

// Verificar se usuário já está autenticado e redirecionar
const checkAuthAndRedirect = () => {
  if (user.value) {
    navigateTo('/')
  }
}

// Verificar ao montar o componente
onMounted(() => {
  checkAuthAndRedirect()
})

// Verificar quando o estado do usuário mudar
watch(user, (newUser) => {
  if (newUser) {
    navigateTo('/')
  }
}, { immediate: true })

// Handler de login
const handleLogin = async (formData: { email: string; password: string }) => {
  const result = await auth.login(formData.email, formData.password)
  
  if (!result.success && result.error) {
    toast.showError(result.error, 10000)
  }
}
</script>
