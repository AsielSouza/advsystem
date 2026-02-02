<template>
  <div class="h-full w-full bg-gray-50 py-4 sm:py-8 px-4 sm:px-6 overflow-y-auto">
    <div class="max-w-4xl mx-auto w-full relative">
      <!-- Overlay de loading ao salvar -->
      <div
        v-if="isSubmitting"
        class="absolute inset-0 bg-white/70 z-10 flex items-center justify-center rounded-xl"
      >
        <div class="text-center">
          <div class="inline-block animate-spin rounded-full h-10 w-10 border-b-2 border-primary-600 mb-4" />
          <p class="text-gray-700 font-medium">Salvando honorário...</p>
        </div>
      </div>

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
      <RegisterFees
        :honorario-id="honorarioId"
        :submitting="isSubmitting"
        @submit="handleSubmit"
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

<script setup>
import { ref, computed } from 'vue'
import RegisterFees from '../components/RegisterFees.vue'
import ButtonBack from '../components/ButtonBack.vue'
import Toast from '../components/Toast.vue'

const route = useRoute()
const router = useRouter()
const toast = useToast()
const { salvar } = useSalvarHonorario()

definePageMeta({
  layout: 'default'
})

const isSubmitting = ref(false)

const honorarioId = computed(() => route.query.id || null)
const isEditMode = computed(() => !!honorarioId.value)

const handleVoltar = () => {
  router.push('/honorarios')
}

const handleSubmit = async (formData) => {
  if (isSubmitting.value) return

  isSubmitting.value = true

  try {
    const result = await salvar(formData)

    if ('error' in result) {
      toast.showError(result.error)
      return
    }

    toast.success('Honorário cadastrado com sucesso!', 3000)
    router.push('/dashboard-fees')
  } catch (err) {
    console.error('Erro ao salvar honorário:', err)
    toast.showError('Erro inesperado ao salvar. Tente novamente.')
  } finally {
    isSubmitting.value = false
  }
}
</script>
