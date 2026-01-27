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
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import InputData from './InputData.vue'
import InputValor from './InputValor.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({
      data_contratacao: '',
      valor_honorario: '',
      forma_pagamento: '' // Removido dropdown; gerenciamento futuro
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

// Erros
const errors = ref({
  data_contratacao: '',
  valor_honorario: ''
})

// Watch para data da contratação
watch(dataContratacao, () => {
  emitFormData()
})

// Watch para valor do honorário
watch(valorHonorario, () => {
  emitFormData()
})

// Função para emitir dados do formulário
const emitFormData = () => {
  const formData = {
    data_contratacao: dataContratacao.value,
    valor_honorario: valorHonorario.value || '',
    forma_pagamento: '' // Removido dropdown; gerenciamento futuro
  }
  
  emit('update:modelValue', formData)
  emit('change', formData)
}

// Watch para atualizar campos quando modelValue mudar externamente
watch(() => props.modelValue, (newValue) => {
  if (newValue) {
    dataContratacao.value = newValue.data_contratacao || ''
    valorHonorario.value = newValue.valor_honorario || ''
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
