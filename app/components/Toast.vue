<template>
  <Transition
    enter-active-class="transition ease-out duration-300"
    enter-from-class="opacity-0 translate-y-2"
    enter-to-class="opacity-100 translate-y-0"
    leave-active-class="transition ease-in duration-200"
    leave-from-class="opacity-100 translate-y-0"
    leave-to-class="opacity-0 translate-y-2"
  >
    <div
      v-if="show"
      :class="toastClasses"
      class="fixed top-4 right-4 z-50 flex items-center space-x-3 px-6 py-4 rounded-lg shadow-lg max-w-md"
    >
      <div class="flex-shrink-0">
        <span v-if="type === 'error'" class="text-2xl">✕</span>
        <span v-else-if="type === 'success'" class="text-2xl">✓</span>
        <span v-else-if="type === 'warning'" class="text-2xl">⚠️</span>
        <span v-else class="text-2xl">ℹ️</span>
      </div>
      <div class="flex-1">
        <p class="text-sm font-medium">{{ message }}</p>
      </div>
      <button
        @click="close"
        class="flex-shrink-0 text-current opacity-70 hover:opacity-100 transition-opacity"
      >
        <span class="text-xl">×</span>
      </button>
    </div>
  </Transition>
</template>

<script setup lang="ts">
import { computed, ref, onMounted, onUnmounted } from 'vue'

const props = defineProps({
  message: {
    type: String,
    required: true
  },
  type: {
    type: String,
    default: 'error',
    validator: (value: string) => ['error', 'success', 'warning', 'info'].includes(value)
  },
  duration: {
    type: Number,
    default: 10000 // 10 segundos
  }
})

const emit = defineEmits(['close'])

const show = ref(true)
let timeoutId: ReturnType<typeof setTimeout> | null = null

const toastClasses = computed(() => {
  const baseClasses = 'text-white'
  
  switch (props.type) {
    case 'error':
      return `${baseClasses} bg-danger-500`
    case 'success':
      return `${baseClasses} bg-success-500`
    case 'warning':
      return `${baseClasses} bg-warning-500`
    case 'info':
      return `${baseClasses} bg-primary-600`
    default:
      return `${baseClasses} bg-danger-500`
  }
})

const close = () => {
  show.value = false
  if (timeoutId) {
    clearTimeout(timeoutId)
  }
  setTimeout(() => {
    emit('close')
  }, 200) // Aguarda a animação de saída
}

onMounted(() => {
  if (props.duration > 0) {
    timeoutId = setTimeout(() => {
      close()
    }, props.duration)
  }
})

onUnmounted(() => {
  if (timeoutId) {
    clearTimeout(timeoutId)
  }
})
</script>

