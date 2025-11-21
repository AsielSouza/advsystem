<template>
  <button
    @click="handleClick"
    class="w-full h-32 lg:h-auto lg:aspect-[2/1] bg-white rounded-xl shadow-md hover:shadow-xl border border-gray-200 p-4 lg:p-6 transition-all duration-300 hover:scale-105 hover:border-primary-300 group flex flex-row lg:flex-col items-center justify-start lg:justify-center text-left lg:text-center"
  >
    <!-- Ícone do módulo -->
    <div class="mb-0 lg:mb-4 mr-4 lg:mr-0 flex-shrink-0">
      <div class="w-12 h-12 lg:w-16 lg:h-16 bg-primary-100 rounded-lg flex items-center justify-center group-hover:bg-primary-200 transition-colors">
        <slot name="icon">
          <svg class="w-6 h-6 lg:w-8 lg:h-8 text-primary-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
          </svg>
        </slot>
      </div>
    </div>

    <!-- Conteúdo do módulo -->
    <div class="flex-1 flex flex-col justify-center min-w-0">
      <h3 class="text-base lg:text-lg font-semibold text-gray-900 group-hover:text-primary-600 transition-colors mb-1 lg:mb-2">
        {{ title }}
      </h3>
      <p v-if="description" class="text-xs lg:text-sm text-gray-600 line-clamp-2 lg:line-clamp-3">
        {{ description }}
      </p>
    </div>

    <!-- Seta de navegação -->
    <div class="mt-0 lg:mt-4 ml-2 lg:ml-0 flex-shrink-0">
      <svg class="w-4 h-4 lg:w-5 lg:h-5 text-gray-400 group-hover:text-primary-600 group-hover:translate-x-1 lg:group-hover:translate-x-0 lg:group-hover:translate-y-1 transition-all" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
      </svg>
    </div>
  </button>
</template>

<script setup>
const props = defineProps({
  title: {
    type: String,
    required: true
  },
  description: {
    type: String,
    required: true
  },
  moduleId: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['click'])

const handleClick = () => {
  emit('click', props.moduleId)
}
</script>

