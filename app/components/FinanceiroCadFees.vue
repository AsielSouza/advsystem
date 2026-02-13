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
    <label for="forma-pagamento" class="block text-sm font-semibold text-gray-800 mb-2.5 tracking-tight">
      Forma de pagamento
      <span class="text-danger-500 ml-0.5">*</span>
    </label>
    <Dropdown
      id="forma-pagamento"
      v-model="formaPagamento"
      placeholder="Escolha a forma de pagamento"
      :options="opcoesFormaPagamento"
      :error="errors.forma_pagamento"
    />

    <!-- Possui entrada -->
    <Toggle
      id="possui-entrada"
      v-model="possuiEntrada"
      label="Possui entrada"
      :description="possuiEntrada ? 'Sim' : 'Não'"
    />
    <template v-if="possuiEntrada">
      <InputValor
        id="valor-entrada"
        v-model="valorEntrada"
        label="Valor de entrada"
        placeholder="0,00"
        :error="errors.valor_entrada"
      />
      <InputData
        id="data-entrada"
        v-model="dataEntrada"
        label="Data da entrada"
        :error="errors.data_entrada"
      />
    </template>

    <!-- Data do Pagamento (apenas quando À vista) -->
    <InputData
      v-if="formaPagamento === 'a_vista'"
      id="data-pagamento"
      v-model="dataPagamento"
      label="Data do pagamento"
      :error="errors.data_pagamento"
    />

    <!-- Tabela de Parcelas (apenas quando Parcelado) -->
    <div v-if="formaPagamento === 'parcelado'" class="space-y-1">
      <TabelaParcelasCadFees
        :valor-total="valorHonorario"
        :valor-entrada="possuiEntrada ? valorEntrada : '0'"
        :data-contratacao="dataContratacao"
        v-model="parcelas"
      />
      <p
        v-if="parcelas.length < 1"
        class="text-sm text-danger-600 font-medium flex items-center gap-1.5"
      >
        <svg class="w-4 h-4 shrink-0" fill="currentColor" viewBox="0 0 20 20">
          <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
        </svg>
        A quantidade de parcelas deve ser igual ou superior a 1.
      </p>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, nextTick, onMounted } from 'vue'
import InputData from './InputData.vue'
import InputValor from './InputValor.vue'
import Dropdown from './Dropdown.vue'
import Toggle from './Toggle.vue'
import TabelaParcelasCadFees from './TabelaParcelasCadFees.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({
      data_contratacao: '',
      valor_honorario: '',
      forma_pagamento: '',
      data_pagamento: '',
      possui_entrada: false,
      valor_entrada: '',
      data_entrada: '',
      parcelas: []
    })
  },
  error: {
    type: String,
    default: ''
  }
})

const emit = defineEmits(['update:modelValue', 'change'])

// Retorna a data de hoje no formato YYYY-MM-DD (para input type="date")
const getHoje = () => new Date().toISOString().slice(0, 10)

// Estados locais (Data da contratação e Data do pagamento default = hoje quando vazios)
const dataContratacao = ref(props.modelValue?.data_contratacao?.trim() || getHoje())
const valorHonorario = ref(props.modelValue?.valor_honorario || '')
const formaPagamento = ref(props.modelValue?.forma_pagamento || '')
const possuiEntrada = ref(props.modelValue?.possui_entrada ?? false)
const valorEntrada = ref(props.modelValue?.valor_entrada || '')
const dataEntrada = ref(props.modelValue?.data_entrada?.trim() || getHoje())
const dataPagamento = ref(props.modelValue?.data_pagamento?.trim() || '')
const parcelas = ref(props.modelValue?.parcelas || [])

// Opções do dropdown de forma de pagamento
const opcoesFormaPagamento = [
  { value: 'a_vista', label: 'À vista' },
  { value: 'parcelado', label: 'Parcelado' }
]

// Erros (data e valor podem vir de fora; forma_pagamento e parcelas validados aqui)
const errors = ref({
  data_contratacao: '',
  valor_honorario: '',
  forma_pagamento: '',
  data_pagamento: '',
  valor_entrada: '',
  data_entrada: '',
  parcelas: ''
})

// Atualiza erro de forma de pagamento quando o campo está vazio
watch(formaPagamento, () => {
  const v = (formaPagamento.value || '').trim()
  const valida = v === 'a_vista' || v === 'avista' || v === 'parcelado'
  errors.value.forma_pagamento = valida ? '' : 'Escolha a forma de pagamento.'
}, { immediate: true })

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
  if (formaPagamento.value === 'a_vista') {
    // Ao escolher À vista, preenche Data do pagamento com hoje se estiver vazia
    if (!dataPagamento.value?.trim()) {
      dataPagamento.value = getHoje()
    }
  } else {
    dataPagamento.value = ''
  }
  emitFormData()
})

// Watch para possui entrada
watch(possuiEntrada, () => {
  if (!isUpdatingFromProps.value) {
    if (!possuiEntrada.value) {
      valorEntrada.value = ''
      dataEntrada.value = ''
    } else if (!dataEntrada.value?.trim()) {
      dataEntrada.value = getHoje()
    }
    emitFormData()
  }
})

// Watch para valor e data de entrada
watch([valorEntrada, dataEntrada], () => {
  if (!isUpdatingFromProps.value) {
    emitFormData()
  }
}, { deep: true })

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
    possui_entrada: possuiEntrada.value,
    valor_entrada: possuiEntrada.value ? (valorEntrada.value || '0') : '',
    data_entrada: possuiEntrada.value ? (dataEntrada.value || '') : '',
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
    possuiEntrada.value !== (newValue.possui_entrada ?? false) ||
    valorEntrada.value !== (newValue.valor_entrada || '') ||
    dataEntrada.value !== (newValue.data_entrada || '') ||
    JSON.stringify(parcelas.value) !== JSON.stringify(newValue.parcelas || [])
  
  if (hasChanges) {
    isUpdatingFromProps.value = true
    dataContratacao.value = newValue.data_contratacao?.trim() || getHoje()
    valorHonorario.value = newValue.valor_honorario || ''
    formaPagamento.value = newValue.forma_pagamento || ''
    possuiEntrada.value = newValue.possui_entrada ?? false
    valorEntrada.value = newValue.valor_entrada || ''
    dataEntrada.value = newValue.data_entrada?.trim() || (newValue.possui_entrada ? getHoje() : '')
    dataPagamento.value = newValue.data_pagamento?.trim() || (newValue.forma_pagamento === 'a_vista' ? getHoje() : '')
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

// Emite valores iniciais (ex.: data contratação = hoje) para o pai após a primeira sincronização
onMounted(() => {
  nextTick(() => {
    emitFormData()
  })
})
</script>
