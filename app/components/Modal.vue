<template>
  <Transition
    enter-active-class="transition ease-out duration-200"
    enter-from-class="opacity-0"
    enter-to-class="opacity-100"
    leave-active-class="transition ease-in duration-150"
    leave-from-class="opacity-100"
    leave-to-class="opacity-0"
  >
    <div
      v-if="modelValue"
      class="fixed inset-0 z-50 overflow-y-auto"
      @click.self="handleClose"
    >
      <!-- Overlay -->
      <div class="fixed inset-0 bg-black bg-opacity-50 transition-opacity"></div>

      <!-- Modal -->
      <div class="flex min-h-full items-center justify-center p-4">
        <div
          :class="[
            'relative bg-white rounded-2xl shadow-2xl w-full overflow-hidden transform transition-all',
            sizeClasses[size]
          ]"
          @click.stop
        >
          <!-- Header do Modal -->
          <div v-if="title || showClose" class="flex items-center justify-between p-6 border-b border-gray-200">
            <h2 v-if="title" class="text-2xl font-bold text-gray-900">
              {{ title }}
            </h2>
            <div v-else></div>
            <button
              v-if="showClose"
              @click="handleClose"
              class="p-2 text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-lg transition-colors"
              aria-label="Fechar"
            >
              <svg
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
                  d="M6 18L18 6M6 6l12 12"
                />
              </svg>
            </button>
          </div>

          <!-- Conteúdo do Modal -->
          <div 
            :class="[
              'overflow-y-auto',
              contentPaddingClass
            ]"
          >
            <slot />
          </div>

          <!-- Footer do Modal (opcional) -->
          <div v-if="$slots.footer" class="p-6 border-t border-gray-200">
            <slot name="footer" />
          </div>
        </div>
      </div>
    </div>
  </Transition>
</template>

<script setup>
import { computed, watch, onMounted, onUnmounted } from 'vue'

const props = defineProps({
  modelValue: {
    type: Boolean,
    default: false
  },
  title: {
    type: String,
    default: ''
  },
  size: {
    type: String,
    default: 'md',
    validator: (value) => ['sm', 'md', 'lg', 'xl', '2xl', '3xl', 'full'].includes(value)
  },
  showClose: {
    type: Boolean,
    default: true
  },
  closeOnClickOutside: {
    type: Boolean,
    default: true
  },
  closeOnEscape: {
    type: Boolean,
    default: true
  },
  contentPadding: {
    type: Boolean,
    default: true
  },
  maxHeight: {
    type: String,
    default: '90vh'
  }
})

const emit = defineEmits(['update:modelValue', 'close'])

const sizeClasses = {
  sm: 'max-w-md',
  md: 'max-w-md',
  lg: 'max-w-lg',
  xl: 'max-w-xl',
  '2xl': 'max-w-2xl',
  '3xl': 'max-w-3xl',
  full: 'max-w-full mx-4'
}

const contentPaddingClass = computed(() => {
  const base = `max-h-[calc(${props.maxHeight}-180px)]`
  return props.contentPadding 
    ? `${base} p-6`
    : base
})

const handleClose = () => {
  if (props.closeOnClickOutside || !props.closeOnClickOutside) {
    emit('update:modelValue', false)
    emit('close')
  }
}

// Fechar ao pressionar ESC
const handleEscape = (event) => {
  if (props.closeOnEscape && event.key === 'Escape' && props.modelValue) {
    handleClose()
  }
}

watch(() => props.modelValue, (newValue) => {
  if (newValue) {
    // Bloquear scroll do body quando modal estiver aberto
    document.body.style.overflow = 'hidden'
  } else {
    // Restaurar scroll do body quando modal fechar
    document.body.style.overflow = ''
  }
})

onMounted(() => {
  if (props.closeOnEscape) {
    document.addEventListener('keydown', handleEscape)
  }
})

onUnmounted(() => {
  document.removeEventListener('keydown', handleEscape)
  // Garantir que o scroll seja restaurado
  document.body.style.overflow = ''
})
</script>

