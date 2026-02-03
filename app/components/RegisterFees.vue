<template>
  <div class="bg-white rounded-xl shadow-lg border border-gray-200">
    <div class="p-6">
      <!-- Stepper de Progresso -->
      <RegisterFeesStepper :current-step="currentStep" />

      <!-- Percentual do honorário total para cada grupo (quando no passo Honorários e dividir entre parceiros ativo) -->
      <PercentualGruposHonorario
        v-if="currentStep === 3 && formData.honorarios.dividir_entre_parceiros"
        :model-value="{
          percentual_socios: formData.honorarios.percentual_socios,
          percentual_parceiros: formData.honorarios.percentual_parceiros
        }"
        class="mt-4"
        @update:model-value="handlePercentualGruposUpdate"
      />
      
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
          :disabled="!canSubmit || submitting"
        >
          {{ submitting ? 'Salvando...' : 'Concluir' }}
        </Button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, watch } from 'vue'
import RegisterFeesStepper from './RegisterFeesStepper.vue'
import PercentualGruposHonorario from './PercentualGruposHonorario.vue'
import ClientCadFees from './ClientCadFees.vue'
import ProcessoCadFees from './ProcessoCadFees.vue'
import FinanceiroCadFees from './FinanceiroCadFees.vue'
import HonorariosCadFees from './HonorariosCadFees.vue'
import Button from './Button.vue'

const props = defineProps({
  honorarioId: {
    type: String,
    default: null
  },
  initialData: {
    type: Object,
    default: null
  },
  submitting: {
    type: Boolean,
    default: false
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
    percentual_socios: 50,
    percentual_parceiros: 50,
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
    const honorarios = formData.honorarios

    // Se dividir entre parceiros: percentuais devem somar 100% e validar ambos os grupos
    if (honorarios.dividir_entre_parceiros) {
      const pSocios = parseFloat(honorarios.percentual_socios) || 0
      const pParceiros = parseFloat(honorarios.percentual_parceiros) || 0
      if (Math.abs(pSocios + pParceiros - 100) > 0.01) return false

      const divisaoParceiros = honorarios.divisao_parceiros || []
      if (divisaoParceiros.length === 0) return false
      const totalParceiros = divisaoParceiros.reduce((sum, p) => sum + (parseFloat(p.percentual) || 0), 0)
      if (Math.abs(totalParceiros - 100) > 0.01) return false

      if (!honorarios.dividir_entre_socios) {
        return !!honorarios.advogado_responsavel_id?.trim()
      }
      const divisaoSocios = honorarios.divisao_socios || []
      if (divisaoSocios.length === 0) return false
      const totalSocios = divisaoSocios.reduce((sum, s) => sum + (parseFloat(s.percentual) || 0), 0)
      return Math.abs(totalSocios - 100) < 0.01
    }

    // Se não dividir entre parceiros: lógica original
    if (!honorarios.dividir_entre_socios) {
      return !!honorarios.advogado_responsavel_id && honorarios.advogado_responsavel_id.trim() !== ''
    }
    const divisaoSocios = honorarios.divisao_socios || []
    if (divisaoSocios.length === 0) return false
    const total = divisaoSocios.reduce((sum, socio) => sum + (parseFloat(socio.percentual) || 0), 0)
    return Math.abs(total - 100) < 0.01
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

// Handler para atualização dos percentuais Sócios/Parceiros (do header)
const handlePercentualGruposUpdate = (value) => {
  formData.honorarios.percentual_socios = value.percentual_socios
  formData.honorarios.percentual_parceiros = value.percentual_parceiros
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

// Preencher formulário quando initialData for passado (modo edição)
watch(() => props.initialData, (data) => {
  if (!data) return

  formData.cliente = data.cliente
    ? { ...data.cliente }
    : null

  formData.processo = {
    numero_processo: data.processo?.numero_processo ?? '',
    valor_causa: data.processo?.valor_causa ?? '',
    historico: data.processo?.historico ?? ''
  }

  formData.financeiro = {
    data_contratacao: data.financeiro?.data_contratacao ?? '',
    valor_honorario: data.financeiro?.valor_honorario ?? '',
    forma_pagamento: data.financeiro?.forma_pagamento ?? '',
    data_pagamento: data.financeiro?.data_pagamento ?? '',
    parcelas: Array.isArray(data.financeiro?.parcelas)
      ? data.financeiro.parcelas.map((p) => ({ ...p }))
      : []
  }

  formData.honorarios = {
    dividir_entre_socios: data.honorarios?.dividir_entre_socios ?? false,
    advogado_responsavel_id: data.honorarios?.advogado_responsavel_id ?? '',
    divisao_socios: Array.isArray(data.honorarios?.divisao_socios)
      ? data.honorarios.divisao_socios.map((s) => ({ ...s }))
      : [],
    dividir_entre_parceiros: data.honorarios?.dividir_entre_parceiros ?? false,
    percentual_socios: data.honorarios?.percentual_socios ?? 50,
    percentual_parceiros: data.honorarios?.percentual_parceiros ?? 50,
    divisao_parceiros: Array.isArray(data.honorarios?.divisao_parceiros)
      ? data.honorarios.divisao_parceiros.map((p) => ({ ...p }))
      : []
  }
}, { immediate: true, deep: true })
</script>
