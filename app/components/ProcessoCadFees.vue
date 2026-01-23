<template>
  <div class="w-full space-y-4">
    <!-- Nº do Processo -->
    <Input
      id="numero-processo"
      v-model="numeroProcesso"
      label="Nº do processo"
      placeholder="Digite o número do processo..."
      :error="errors.numero_processo"
    />

    <!-- Valor da Causa -->
    <InputValor
      id="valor-causa"
      v-model="valorCausa"
      label="Valor da causa"
      placeholder="0,00"
      :error="errors.valor_causa"
    />

    <!-- Histórico -->
    <InputTextarea
      id="historico"
      v-model="historico"
      label="Histórico"
      placeholder="Adicione observações sobre o processo..."
      :rows="6"
      :error="errors.historico"
    />
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import Input from './Input.vue'
import InputValor from './InputValor.vue'
import InputTextarea from './InputTextarea.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({
      numero_processo: '',
      valor_causa: '',
      historico: ''
    })
  },
  error: {
    type: String,
    default: ''
  }
})

const emit = defineEmits(['update:modelValue', 'change'])

// Estados locais
const numeroProcesso = ref(props.modelValue?.numero_processo || '')
const valorCausa = ref(props.modelValue?.valor_causa || '')
const historico = ref(props.modelValue?.historico || '')

// Erros
const errors = ref({
  numero_processo: '',
  valor_causa: '',
  historico: ''
})

// Watch para número do processo
watch(numeroProcesso, () => {
  emitFormData()
})

// Watch para valor da causa
watch(valorCausa, () => {
  emitFormData()
})

// Watch para histórico
watch(historico, () => {
  emitFormData()
})

// Função para emitir dados do formulário
const emitFormData = () => {
  const formData = {
    numero_processo: numeroProcesso.value,
    valor_causa: valorCausa.value || '',
    historico: historico.value
  }
  
  emit('update:modelValue', formData)
  emit('change', formData)
}

// Watch para atualizar campos quando modelValue mudar externamente
watch(() => props.modelValue, (newValue) => {
  if (newValue) {
    numeroProcesso.value = newValue.numero_processo || ''
    valorCausa.value = newValue.valor_causa || ''
    historico.value = newValue.historico || ''
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
