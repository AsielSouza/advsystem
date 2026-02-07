<template>
  <div class="w-full">
    <ol class="items-center w-full flex justify-center space-x-4 sm:space-x-8">
      <li
        v-for="(step, index) in steps"
        :key="step.id"
        role="button"
        tabindex="0"
        :aria-current="currentStep === index ? 'step' : undefined"
        :aria-label="`Ir para passo: ${step.title}`"
        :class="[
          'flex items-center space-x-0 sm:space-x-3 transition-all duration-200 cursor-pointer rounded-lg p-1 -m-1 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2',
          step.completed || currentStep > index
            ? 'text-green-600'
            : currentStep === index
            ? 'text-primary-600'
            : 'text-gray-500'
        ]"
        @click="goToStep(index)"
        @keydown.enter.prevent="goToStep(index)"
        @keydown.space.prevent="goToStep(index)"
      >
        <!-- Ícone do Passo -->
        <span 
          :class="[
            'flex items-center justify-center w-10 h-10 rounded-full lg:h-12 lg:w-12 shrink-0 transition-all duration-200',
            step.completed || currentStep > index
              ? 'bg-green-100'
              : currentStep === index
              ? 'bg-primary-100 ring-4 ring-primary-200'
              : 'bg-gray-100'
          ]"
        >
          <!-- Ícone do Passo - Cliente -->
          <svg 
            v-if="step.id === 'cliente'"
            xmlns="http://www.w3.org/2000/svg" 
            width="24" 
            height="24" 
            fill="none" 
            viewBox="0 0 24 24" 
            stroke="currentColor"
            class="w-5 h-5 lg:w-6 lg:h-6"
            :class="
              step.completed || currentStep > index
                ? 'text-green-600'
                : currentStep === index
                ? 'text-primary-600'
                : 'text-gray-400'
            "
          >
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
          </svg>
          
          <!-- Ícone do Passo - Processo -->
          <svg 
            v-else-if="step.id === 'processo'"
            xmlns="http://www.w3.org/2000/svg" 
            width="24" 
            height="24" 
            fill="none" 
            viewBox="0 0 24 24" 
            stroke="currentColor"
            class="w-5 h-5 lg:w-6 lg:h-6"
            :class="
              step.completed || currentStep > index
                ? 'text-green-600'
                : currentStep === index
                ? 'text-primary-600'
                : 'text-gray-400'
            "
          >
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
          </svg>
          
          <!-- Ícone do Passo - Financeiro -->
          <svg 
            v-else-if="step.id === 'financeiro'"
            xmlns="http://www.w3.org/2000/svg" 
            width="24" 
            height="24" 
            fill="none" 
            viewBox="0 0 24 24" 
            stroke="currentColor"
            class="w-5 h-5 lg:w-6 lg:h-6"
            :class="
              step.completed || currentStep > index
                ? 'text-green-600'
                : currentStep === index
                ? 'text-primary-600'
                : 'text-gray-400'
            "
          >
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M6 14h2m3 0h5M3 7v10a1 1 0 001 1h16a1 1 0 001-1V7a1 1 0 00-1-1H4a1 1 0 00-1 1z"/>
          </svg>
          
          <!-- Ícone do Passo - Honorários -->
          <svg 
            v-else-if="step.id === 'honorarios'"
            xmlns="http://www.w3.org/2000/svg" 
            width="24" 
            height="24" 
            fill="none" 
            viewBox="0 0 24 24" 
            stroke="currentColor"
            class="w-5 h-5 lg:w-6 lg:h-6"
            :class="
              step.completed || currentStep > index
                ? 'text-green-600'
                : currentStep === index
                ? 'text-primary-600'
                : 'text-gray-400'
            "
          >
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 6l3 1m0 0l-3 9a5.002 5.002 0 006.001 0M6 7l3 9M6 7l6-2m6 2l3-1m-3 1l-3 9a5.002 5.002 0 006.001 0M18 7l3 9m-3-9l-6-2m0-2v2m0 16V5m0 16H9m3 0h3"/>
          </svg>
        </span>
        
        <!-- Título do Passo (oculto no mobile) -->
        <span class="hidden sm:block">
          <h3 
            :class="[
              'font-medium leading-tight',
              step.completed || currentStep > index || currentStep === index
                ? 'text-gray-900'
                : 'text-gray-500'
            ]"
          >
            {{ step.title }}
          </h3>
        </span>
      </li>
    </ol>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  currentStep: {
    type: Number,
    default: 0,
    validator: (value) => value >= 0 && value <= 3
  }
})

const emit = defineEmits(['go-to-step'])

const goToStep = (index) => {
  emit('go-to-step', index)
}

const steps = computed(() => [
  {
    id: 'cliente',
    title: 'Cliente',
    completed: props.currentStep > 0
  },
  {
    id: 'processo',
    title: 'Dados do Processo',
    completed: props.currentStep > 1
  },
  {
    id: 'financeiro',
    title: 'Financeiro',
    completed: props.currentStep > 2
  },
  {
    id: 'honorarios',
    title: 'Honorários',
    completed: props.currentStep > 3
  }
])
</script>
