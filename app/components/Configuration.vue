<template>
  <div class="relative">
    <!-- Botão do ícone de engrenagem -->
    <button
      @click="toggleConfig"
      class="p-2 text-gray-600 hover:text-primary-600 hover:bg-gray-100 rounded-lg transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2"
      aria-label="Configurações"
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
          d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"
        />
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"
        />
      </svg>
    </button>

    <!-- Modal de Configuração -->
    <Transition
      enter-active-class="transition ease-out duration-200"
      enter-from-class="opacity-0"
      enter-to-class="opacity-100"
      leave-active-class="transition ease-in duration-150"
      leave-from-class="opacity-100"
      leave-to-class="opacity-0"
    >
      <div
        v-if="isOpen"
        class="fixed inset-0 z-50 overflow-y-auto"
        @click.self="closeConfig"
      >
        <!-- Overlay -->
        <div class="fixed inset-0 bg-black bg-opacity-50 transition-opacity"></div>

        <!-- Modal -->
        <div class="flex min-h-full items-center justify-center p-4">
          <div
            class="relative bg-white rounded-2xl shadow-2xl max-w-2xl w-full max-h-[90vh] overflow-hidden transform transition-all"
            @click.stop
          >
            <!-- Header do Modal -->
            <div class="flex items-center justify-between p-6 border-b border-gray-200">
              <h2 class="text-2xl font-bold text-gray-900">
                Configurações
              </h2>
              <button
                @click="closeConfig"
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
            <div class="p-6 overflow-y-auto max-h-[calc(90vh-120px)]">
              <!-- Conteúdo será adicionado aqui -->
              <p class="text-gray-500 text-center py-8">
                Conteúdo de configuração será adicionado aqui
              </p>
            </div>
          </div>
        </div>
      </div>
    </Transition>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'

const isOpen = ref(false)

const toggleConfig = () => {
  isOpen.value = !isOpen.value
}

const closeConfig = () => {
  isOpen.value = false
}

// Fechar ao pressionar ESC
const handleEscape = (event) => {
  if (event.key === 'Escape' && isOpen.value) {
    closeConfig()
  }
}

onMounted(() => {
  document.addEventListener('keydown', handleEscape)
})

onUnmounted(() => {
  document.removeEventListener('keydown', handleEscape)
})
</script>

