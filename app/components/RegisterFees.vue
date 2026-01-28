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
        
        <!-- Passo 1: Dados do Processo -->
        <ProcessoCadFees
          v-if="currentStep === 1"
          v-model="formData.processo"
          @change="handleProcessoChange"
        />
        
        <!-- Passo 2: Financeiro -->
        <FinanceiroCadFees
          v-if="currentStep === 2"
          v-model="formData.financeiro"
          @change="handleFinanceiroChange"
        />
        
        <!-- Passo 3: Honorários -->
        <HonorariosCadFees
          v-if="currentStep === 3"
          v-model="formData.honorarios"
          @change="handleHonorariosChange"
        />
        
        <!-- Placeholder para os outros passos -->
        <div v-if="currentStep > 3" class="text-center py-12 text-gray-500">
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
import ProcessoCadFees from './ProcessoCadFees.vue'
import FinanceiroCadFees from './FinanceiroCadFees.vue'
import HonorariosCadFees from './HonorariosCadFees.vue'
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
  // Dados do Processo (preenchidos no passo 1)
  processo: {
    numero_processo: '',
    valor_causa: '',
    historico: ''
  },
  // Campos adicionais do processo (podem ser usados em outros passos)
  parte: '',
  parte_outro_descricao: '',
  descricao: '',
  // Financeiro (preenchido no passo 2)
  financeiro: {
    data_contratacao: '',
    valor_honorario: '',
    forma_pagamento: '',
    data_pagamento: '',
    parcelas: []
  },
  // Campos adicionais financeiros (podem ser usados em outros passos)
  valor_total: '',
  numero_parcelas: null,
  // Honorários (preenchido no passo 3)
  honorarios: {
    dividir_entre_socios: false,
    advogado_responsavel_id: '',
    divisao_socios: [],
    dividir_entre_parceiros: false,
    divisao_parceiros: []
  }
})

// Validações para permitir avançar
const canAdvance = computed(() => {
  if (currentStep.value === 0) {
    // Passo Cliente: precisa ter cliente selecionado
    return !!formData.cliente && !!formData.cliente.id
  }
  if (currentStep.value === 1) {
    // Passo Dados do Processo: número do processo é obrigatório
    return !!formData.processo.numero_processo && formData.processo.numero_processo.trim() !== ''
  }
  if (currentStep.value === 2) {
    // Passo Financeiro: data da contratação e valor do honorário são obrigatórios
    return !!formData.financeiro.data_contratacao && 
           !!formData.financeiro.valor_honorario && 
           formData.financeiro.valor_honorario.trim() !== ''
  }
  if (currentStep.value === 3) {
    // Passo Honorários: se não dividir entre sócios, precisa ter advogado responsável
    if (!formData.honorarios.dividir_entre_socios) {
      return !!formData.honorarios.advogado_responsavel_id && 
             formData.honorarios.advogado_responsavel_id.trim() !== ''
    }
    // Se dividir entre sócios, precisa ter pelo menos um sócio e total de 100%
    if (formData.honorarios.dividir_entre_socios) {
      const divisaoSocios = formData.honorarios.divisao_socios || []
      if (divisaoSocios.length === 0) return false
      
      const total = divisaoSocios.reduce((sum, socio) => {
        return sum + (parseFloat(socio.percentual) || 0)
      }, 0)
      
      return Math.abs(total - 100) < 0.01 // Permite pequena diferença de arredondamento
    }
    return true
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

// Handler para mudança dos dados do processo
const handleProcessoChange = (processo) => {
  formData.processo = processo
}

// Handler para mudança dos dados financeiros
const handleFinanceiroChange = (financeiro) => {
  // Evita atualização desnecessária se os dados são os mesmos
  if (JSON.stringify(formData.financeiro) !== JSON.stringify(financeiro)) {
    Object.assign(formData.financeiro, financeiro)
  }
}

// Handler para mudança dos dados de honorários
const handleHonorariosChange = (honorarios) => {
  // Evita atualização desnecessária se os dados são os mesmos
  if (JSON.stringify(formData.honorarios) !== JSON.stringify(honorarios)) {
    Object.assign(formData.honorarios, honorarios)
  }
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
