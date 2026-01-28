<template>
  <div class="w-full space-y-4">
    <!-- Data da Contratação -->
    <InputData
      id="data-contratacao"
      v-model="dataContratacao"
      label="Data da contratação"
      :error="errors.data_contratacao"
    />

    <!-- Valor do Honorário -->
    <InputValor
      id="valor-honorario"
      v-model="valorHonorario"
      label="Valor do honorário"
      placeholder="0,00"
      :error="errors.valor_honorario"
    />

    <!-- Forma de Pagamento -->
    <label class="block text-sm font-semibold text-gray-800 mb-2.5 tracking-tight">
      Forma de pagamento
    </label>
    <Dropdown
      id="forma-pagamento"
      v-model="formaPagamento"
      placeholder="Escolha a forma de pagamento"
      :options="opcoesFormaPagamento"
    />

    <!-- Data do Pagamento (apenas quando À vista) -->
    <InputData
      v-if="formaPagamento === 'a_vista'"
      id="data-pagamento"
      v-model="dataPagamento"
      label="Data do pagamento"
      :error="errors.data_pagamento"
    />

    <!-- Tabela de Parcelas (apenas quando Parcelado) -->
    <TabelaParcelasCadFees
      v-if="formaPagamento === 'parcelado'"
      :valor-total="valorHonorario"
      :data-contratacao="dataContratacao"
      v-model="parcelas"
    />
  </div>
</template>

<script setup>
import { ref, watch, nextTick } from 'vue'
import InputData from './InputData.vue'
import InputValor from './InputValor.vue'
import Dropdown from './Dropdown.vue'
import TabelaParcelasCadFees from './TabelaParcelasCadFees.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({
      data_contratacao: '',
      valor_honorario: '',
      forma_pagamento: '',
      data_pagamento: '',
      parcelas: []
    })
  },
  error: {
    type: String,
    default: ''
  }
})

const emit = defineEmits(['update:modelValue', 'change'])

// Estados locais
const dataContratacao = ref(props.modelValue?.data_contratacao || '')
const valorHonorario = ref(props.modelValue?.valor_honorario || '')
const formaPagamento = ref(props.modelValue?.forma_pagamento || '')
const dataPagamento = ref(props.modelValue?.data_pagamento || '')
const parcelas = ref(props.modelValue?.parcelas || [])

// Opções do dropdown de forma de pagamento
const opcoesFormaPagamento = [
  { value: 'a_vista', label: 'À vista' },
  { value: 'parcelado', label: 'Parcelado' }
]

// Erros
const errors = ref({
  data_contratacao: '',
  valor_honorario: '',
  data_pagamento: ''
})

// Flag para evitar loop infinito durante atualizações internas
const isUpdatingFromProps = ref(false)

// Watch para data da contratação
watch(dataContratacao, () => {
  if (!isUpdatingFromProps.value) {
    emitFormData()
  }
})

// Watch para valor do honorário
watch(valorHonorario, () => {
  if (!isUpdatingFromProps.value) {
    emitFormData()
  }
})

// Watch para forma de pagamento
watch(formaPagamento, () => {
  if (isUpdatingFromProps.value) return
  
  // Limpa parcelas quando mudar para "À vista"
  if (formaPagamento.value !== 'parcelado') {
    parcelas.value = []
  }
  // Limpa data de pagamento quando mudar para "Parcelado"
  if (formaPagamento.value !== 'a_vista') {
    dataPagamento.value = ''
  }
  emitFormData()
})

// Watch para data de pagamento
watch(dataPagamento, () => {
  if (!isUpdatingFromProps.value) {
    emitFormData()
  }
})

// Watch para parcelas
watch(parcelas, () => {
  if (!isUpdatingFromProps.value) {
    emitFormData()
  }
}, { deep: true })

// Função para emitir dados do formulário
const emitFormData = () => {
  const formData = {
    data_contratacao: dataContratacao.value,
    valor_honorario: valorHonorario.value || '',
    forma_pagamento: formaPagamento.value || '',
    data_pagamento: formaPagamento.value === 'a_vista' ? dataPagamento.value : '',
    parcelas: formaPagamento.value === 'parcelado' ? parcelas.value : []
  }
  
  emit('update:modelValue', formData)
  emit('change', formData)
}

// Watch para atualizar campos quando modelValue mudar externamente
watch(() => props.modelValue, (newValue) => {
  if (!newValue || isUpdatingFromProps.value) return
  
  // Verifica se há mudanças reais antes de atualizar
  const hasChanges = 
    dataContratacao.value !== (newValue.data_contratacao || '') ||
    valorHonorario.value !== (newValue.valor_honorario || '') ||
    formaPagamento.value !== (newValue.forma_pagamento || '') ||
    dataPagamento.value !== (newValue.data_pagamento || '') ||
    JSON.stringify(parcelas.value) !== JSON.stringify(newValue.parcelas || [])
  
  if (hasChanges) {
    isUpdatingFromProps.value = true
    dataContratacao.value = newValue.data_contratacao || ''
    valorHonorario.value = newValue.valor_honorario || ''
    formaPagamento.value = newValue.forma_pagamento || ''
    dataPagamento.value = newValue.data_pagamento || ''
    parcelas.value = newValue.parcelas || []
    // Usa nextTick para garantir que a flag seja resetada após todas as atualizações
    nextTick(() => {
      isUpdatingFromProps.value = false
    })
  }
}, { immediate: true, deep: true })

// Watch para atualizar erros quando prop error mudar
watch(() => props.error, (newError) => {
  if (newError) {
    // Se houver erro geral, pode ser tratado aqui
    // Por enquanto, os erros específicos vêm via props.modelValue ou são locais
  }
})
</script>
