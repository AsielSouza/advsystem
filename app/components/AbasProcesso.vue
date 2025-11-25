<template>
  <div class="w-full">
    <!-- Navegação das Abas -->
    <div class="border-b border-gray-200">
      <nav class="flex space-x-8" aria-label="Tabs">
        <button
          @click="abaAtiva = 'historico'"
          :class="[
            'py-4 px-1 border-b-2 font-medium text-sm transition-colors',
            abaAtiva === 'historico'
              ? 'border-primary-500 text-primary-600'
              : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
          ]"
        >
          Histórico
        </button>
        <button
          @click="abaAtiva = 'financeiro'"
          :class="[
            'py-4 px-1 border-b-2 font-medium text-sm transition-colors',
            abaAtiva === 'financeiro'
              ? 'border-primary-500 text-primary-600'
              : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
          ]"
        >
          Financeiro
        </button>
      </nav>
    </div>

    <!-- Conteúdo das Abas -->
    <div class="mt-6">
      <AbaHistórico v-if="abaAtiva === 'historico'" :honorario="honorario" />
      <AbaFinanceiro v-if="abaAtiva === 'financeiro'" :honorario="honorario" />
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import AbaHistórico from './AbaHistórico.vue'
import AbaFinanceiro from './AbaFinanceiro.vue'

const props = defineProps({
  honorario: {
    type: Object,
    required: true
  }
})

const abaAtiva = ref('historico')
</script>

