<template>
  <div class="bg-white rounded-xl shadow-lg border border-gray-200">
    <div class="p-6">
      <!-- Stepper de Progresso -->
      <RegisterFeesStepper :current-step="currentStep" />
      
      <!-- Conteúdo dos Passos será adicionado aqui -->
      <div class="mt-8 relative">
        <!-- Passo 0: Cliente -->
        <ClientCadFees
          v-if="currentStep === 0"
          v-model="formData.cliente"
          @change="handleClienteChange"
        />
        
        <!-- Placeholder para os outros passos -->
        <div v-else class="text-center py-12 text-gray-500">
          <p class="text-lg font-medium">Passo {{ currentStep + 1 }} de 4</p>
          <p class="text-sm mt-2">Conteúdo será implementado aqui</p>
        </div>
      </div>

      <!-- Botões de Navegação -->
      <div class="flex items-center justify-between mt-8 pt-6 border-t border-gray-200">
        <!-- Botão Voltar -->
        <Button
          v-if="currentStep > 0"
          type="button"
          variant="outline"
          @click="handlePreviousStep"
        >
          Voltar
        </Button>
        <div v-else></div>

        <!-- Botão Avançar ou Concluir -->
        <Button
          v-if="currentStep < 3"
          type="button"
          @click="handleNextStep"
          :disabled="!canAdvance"
        >
          Avançar
        </Button>
        <Button
          v-else
          type="button"
          @click="handleSubmit"
          :disabled="!canSubmit"
        >
          Concluir
        </Button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed } from 'vue'
import RegisterFeesStepper from './RegisterFeesStepper.vue'
import ClientCadFees from './ClientCadFees.vue'
import Button from './Button.vue'

const props = defineProps({
  honorarioId: {
    type: String,
    default: null
  }
})

const emit = defineEmits(['submit', 'cancel', 'error'])

const currentStep = ref(0)

// Dados do formulário (mantidos durante a navegação)
const formData = reactive({
  cliente: null,
  // Dados do Processo (serão preenchidos no passo 1)
  numero_processo: '',
  parte: '',
  parte_outro_descricao: '',
  data_contratacao: '',
  descricao: '',
  // Financeiro (será preenchido no passo 2)
  valor_total: '',
  forma_pagamento: '',
  numero_parcelas: null,
  // Honorários (será preenchido no passo 3)
  advogado_responsavel_id: ''
})

// Validações para permitir avançar
const canAdvance = computed(() => {
  if (currentStep.value === 0) {
    // Passo Cliente: precisa ter cliente selecionado
    return !!formData.cliente && !!formData.cliente.id
  }
  // Outros passos: por enquanto sempre permite (validação será feita quando implementar cada passo)
  return true
})

// Validações para permitir concluir
const canSubmit = computed(() => {
  // Por enquanto sempre permite (validação completa será feita quando implementar todos os passos)
  return true
})

// Handler para mudança do cliente
const handleClienteChange = (cliente) => {
  formData.cliente = cliente
}

// Handler para avançar para o próximo passo
const handleNextStep = () => {
  if (currentStep.value < 3 && canAdvance.value) {
    currentStep.value++
  }
}

// Handler para voltar ao passo anterior
const handlePreviousStep = () => {
  if (currentStep.value > 0) {
    currentStep.value--
  }
}

// Handler para submeter o formulário
const handleSubmit = () => {
  if (canSubmit.value) {
    // Emite evento de submit com todos os dados do formulário
    emit('submit', formData)
  }
}
</script>
