<template>
  <Modal
    :model-value="modelValue"
    @update:model-value="handleModalClose"
    @close="handleModalClose"
    :title="isEditMode ? 'Editar Advogado' : 'Cadastrar Advogado'"
    size="lg"
  >
    <form @submit.prevent="handleSubmit" class="space-y-6">
      <!-- Nome -->
      <Input
        v-model="formData.nome"
        label="Nome"
        placeholder="Digite o nome completo"
        type="text"
        :error="errors.nome"
        required
      />

      <!-- OAB Número e UF -->
      <div class="grid grid-cols-3 gap-4">
        <div class="col-span-2">
          <Input
            v-model="formData.oab_numero"
            label="Número OAB"
            placeholder="Digite o número da OAB"
            type="text"
            :error="errors.oab_numero"
            required
          />
        </div>
        <div class="col-span-1">
          <Dropdown
            v-model="formData.oab_uf"
            label="UF"
            :options="ufOptions"
            placeholder="UF"
            :error="errors.oab_uf"
            required
          />
        </div>
      </div>

      <!-- Tipo de Vínculo -->
      <Dropdown
        v-model="formData.tipo_vinculo"
        label="Tipo de Vínculo"
        :options="tipoVinculoOptions"
        placeholder="Selecione o tipo de vínculo"
        :error="errors.tipo_vinculo"
        required
      />

      <!-- Email -->
      <Input
        v-model="formData.email"
        label="E-mail"
        placeholder="Digite o e-mail"
        type="email"
        :error="errors.email"
      />

      <!-- Telefone -->
      <Input
        v-model="formData.telefone"
        label="Telefone"
        placeholder="Digite o telefone"
        type="tel"
        :error="errors.telefone"
      />

      <!-- Percentual Padrão -->
      <Input
        v-model="formData.percentual_padrao"
        label="Percentual Padrão (%)"
        placeholder="Digite o percentual padrão"
        type="number"
        :error="errors.percentual_padrao"
        hint="Valor opcional entre 0 e 100"
      />

      <!-- Observações -->
      <div>
        <label
          for="observacoes"
          class="block text-sm font-semibold text-gray-800 mb-2.5 tracking-tight"
        >
          Observações
        </label>
        <textarea
          id="observacoes"
          v-model="formData.observacoes"
          rows="4"
          placeholder="Digite observações sobre o advogado (opcional)"
          :class="[
            'w-full px-5 py-3.5 border rounded-xl text-gray-900 placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-offset-0 transition-all duration-200 ease-in-out shadow-sm hover:shadow-md focus:shadow-lg resize-none',
            errors.observacoes
              ? 'border-danger-400 focus:ring-danger-500 focus:border-danger-500 bg-danger-50/30'
              : 'border-gray-200 focus:ring-primary-500 focus:border-primary-500 bg-white hover:border-gray-300'
          ]"
        ></textarea>
        <p
          v-if="errors.observacoes"
          class="mt-2 text-sm text-danger-600 font-medium flex items-center gap-1.5"
        >
          <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
          </svg>
          {{ errors.observacoes }}
        </p>
      </div>

      <!-- Toggles -->
      <div class="grid grid-cols-1 gap-4">
        <Toggle
          v-model="formData.ativo"
          label="Ativo"
          description="O advogado está ativo no sistema"
        />
      </div>

      <!-- Mensagem de Erro Geral -->
      <div v-if="errorGeral" class="p-4 bg-danger-50 border border-danger-200 rounded-lg">
        <p class="text-sm text-danger-600 font-medium">{{ errorGeral }}</p>
      </div>
    </form>

    <template #footer>
      <div class="flex items-center justify-end gap-3">
        <Button
          variant="outline"
          size="sm"
          @click="handleCancel"
        >
          Cancelar
        </Button>
        <Button
          variant="primary"
          size="sm"
          type="submit"
          :disabled="isSubmitting || !isFormValid"
          @click="handleSubmit"
        >
          <span v-if="isSubmitting">{{ isEditMode ? 'Atualizando...' : 'Salvando...' }}</span>
          <span v-else>{{ isEditMode ? 'Atualizar' : 'Salvar' }}</span>
        </Button>
      </div>
    </template>
  </Modal>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import Modal from './Modal.vue'
import Button from './Button.vue'
import Input from './Input.vue'
import Dropdown from './Dropdown.vue'
import Toggle from './Toggle.vue'

const props = defineProps({
  modelValue: {
    type: Boolean,
    default: false
  },
  advogado: {
    type: Object,
    default: null
  }
})

// Verifica se está em modo de edição
const isEditMode = computed(() => {
  return !!props.advogado && !!props.advogado.id
})

const emit = defineEmits(['update:modelValue', 'salvo'])

const supabase = useSupabaseClient()
const toast = useToast()

// Lista de UFs do Brasil
const ufOptions = [
  { value: 'AC', label: 'AC' },
  { value: 'AL', label: 'AL' },
  { value: 'AP', label: 'AP' },
  { value: 'AM', label: 'AM' },
  { value: 'BA', label: 'BA' },
  { value: 'CE', label: 'CE' },
  { value: 'DF', label: 'DF' },
  { value: 'ES', label: 'ES' },
  { value: 'GO', label: 'GO' },
  { value: 'MA', label: 'MA' },
  { value: 'MT', label: 'MT' },
  { value: 'MS', label: 'MS' },
  { value: 'MG', label: 'MG' },
  { value: 'PA', label: 'PA' },
  { value: 'PB', label: 'PB' },
  { value: 'PR', label: 'PR' },
  { value: 'PE', label: 'PE' },
  { value: 'PI', label: 'PI' },
  { value: 'RJ', label: 'RJ' },
  { value: 'RN', label: 'RN' },
  { value: 'RS', label: 'RS' },
  { value: 'RO', label: 'RO' },
  { value: 'RR', label: 'RR' },
  { value: 'SC', label: 'SC' },
  { value: 'SP', label: 'SP' },
  { value: 'SE', label: 'SE' },
  { value: 'TO', label: 'TO' }
]

// Opções de tipo de vínculo
const tipoVinculoOptions = [
  { value: 'socio', label: 'Sócio' },
  { value: 'associado', label: 'Associado' },
  { value: 'parceiro', label: 'Parceiro' }
]

const formData = ref({
  nome: '',
  oab_numero: '',
  oab_uf: '',
  tipo_vinculo: 'socio',
  email: '',
  telefone: '',
  percentual_padrao: '',
  observacoes: '',
  ativo: true
})

const errors = ref({
  nome: '',
  oab_numero: '',
  oab_uf: '',
  tipo_vinculo: '',
  email: '',
  telefone: '',
  percentual_padrao: '',
  observacoes: ''
})

const errorGeral = ref('')
const isSubmitting = ref(false)

// Limpar formulário
const resetForm = () => {
  formData.value = {
    nome: '',
    oab_numero: '',
    oab_uf: '',
    tipo_vinculo: 'socio',
    email: '',
    telefone: '',
    percentual_padrao: '',
    observacoes: '',
    ativo: true
  }
  clearErrors()
  errorGeral.value = ''
}

// Limpar erros
const clearErrors = () => {
  errors.value = {
    nome: '',
    oab_numero: '',
    oab_uf: '',
    tipo_vinculo: '',
    email: '',
    telefone: '',
    percentual_padrao: '',
    observacoes: ''
  }
}

// Validação do formulário
const validate = () => {
  clearErrors()
  errorGeral.value = ''
  let isValid = true

  // Validar nome (obrigatório)
  if (!formData.value.nome || formData.value.nome.trim().length === 0) {
    errors.value.nome = 'Nome é obrigatório'
    isValid = false
  } else if (formData.value.nome.trim().length < 3) {
    errors.value.nome = 'Nome deve ter pelo menos 3 caracteres'
    isValid = false
  }

  // Validar OAB número (obrigatório)
  if (!formData.value.oab_numero || formData.value.oab_numero.trim().length === 0) {
    errors.value.oab_numero = 'Número OAB é obrigatório'
    isValid = false
  }

  // Validar OAB UF (obrigatório)
  if (!formData.value.oab_uf || formData.value.oab_uf.trim().length === 0) {
    errors.value.oab_uf = 'UF é obrigatória'
    isValid = false
  }

  // Validar tipo de vínculo (obrigatório)
  if (!formData.value.tipo_vinculo || formData.value.tipo_vinculo.trim().length === 0) {
    errors.value.tipo_vinculo = 'Tipo de vínculo é obrigatório'
    isValid = false
  }

  // Validar email (opcional, mas se preenchido deve ser válido)
  if (formData.value.email && formData.value.email.trim().length > 0) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (!emailRegex.test(formData.value.email)) {
      errors.value.email = 'E-mail inválido'
      isValid = false
    }
  }

  // Validar percentual (opcional, mas se preenchido deve ser entre 0 e 100)
  if (formData.value.percentual_padrao && formData.value.percentual_padrao.trim().length > 0) {
    const percentual = parseFloat(formData.value.percentual_padrao)
    if (isNaN(percentual)) {
      errors.value.percentual_padrao = 'Percentual deve ser um número válido'
      isValid = false
    } else if (percentual < 0 || percentual > 100) {
      errors.value.percentual_padrao = 'Percentual deve estar entre 0 e 100'
      isValid = false
    }
  }

  return isValid
}

// Computed para verificar se o formulário é válido
const isFormValid = computed(() => {
  return formData.value.nome.trim().length > 0 &&
         formData.value.oab_numero.trim().length > 0 &&
         formData.value.oab_uf.trim().length > 0 &&
         formData.value.tipo_vinculo.trim().length > 0
})

// Handler para submit
const handleSubmit = async () => {
  if (!validate()) {
    return
  }

  isSubmitting.value = true
  errorGeral.value = ''

  try {
    // Preparar dados para inserção/atualização
    const dados = {
      nome: formData.value.nome.trim(),
      oab_numero: formData.value.oab_numero.trim(),
      oab_uf: formData.value.oab_uf.trim().toUpperCase(),
      tipo_vinculo: formData.value.tipo_vinculo,
      ativo: formData.value.ativo,
      updated_at: new Date().toISOString()
    }

    // Adicionar campos opcionais
    if (formData.value.email && formData.value.email.trim().length > 0) {
      dados.email = formData.value.email.trim()
    } else {
      dados.email = null // Permite limpar o email
    }
    
    if (formData.value.telefone && formData.value.telefone.trim().length > 0) {
      dados.telefone = formData.value.telefone.trim()
    } else {
      dados.telefone = null // Permite limpar o telefone
    }
    
    if (formData.value.percentual_padrao && formData.value.percentual_padrao.trim().length > 0) {
      const percentual = parseFloat(formData.value.percentual_padrao)
      if (!isNaN(percentual)) {
        dados.percentual_padrao = percentual
      }
    } else {
      dados.percentual_padrao = null // Permite limpar o percentual
    }

    if (formData.value.observacoes && formData.value.observacoes.trim().length > 0) {
      dados.observacoes = formData.value.observacoes.trim()
    } else {
      dados.observacoes = null // Permite limpar as observações
    }

    let data, error

    if (isEditMode.value) {
      // Modo de edição - atualizar registro existente
      const { data: updateData, error: updateError } = await supabase
        .from('advogados')
        .update(dados)
        .eq('id', props.advogado.id)
        .select()
        .single()

      data = updateData
      error = updateError

      if (error) {
        console.error('Erro ao atualizar advogado:', error)
        
        // Tratar erro de constraint única (OAB já existe em outro registro)
        if (error.code === '23505' || error.message.includes('unique')) {
          errorGeral.value = 'Já existe um advogado cadastrado com este número OAB e UF'
        } else {
          errorGeral.value = error.message || 'Erro ao atualizar advogado. Tente novamente.'
        }
        return
      }

      toast.success('Advogado atualizado com sucesso!', 3000)
    } else {
      // Modo de cadastro - inserir novo registro
      const { data: insertData, error: insertError } = await supabase
        .from('advogados')
        .insert(dados)
        .select()
        .single()

      data = insertData
      error = insertError

      if (error) {
        console.error('Erro ao cadastrar advogado:', error)
        
        // Tratar erro de constraint única (OAB já existe)
        if (error.code === '23505' || error.message.includes('unique')) {
          errorGeral.value = 'Já existe um advogado cadastrado com este número OAB e UF'
        } else {
          errorGeral.value = error.message || 'Erro ao cadastrar advogado. Tente novamente.'
        }
        return
      }

      toast.success('Advogado cadastrado com sucesso!', 3000)
    }

    resetForm()
    emit('salvo', data)
    handleModalClose()
  } catch (error) {
    console.error('Erro inesperado:', error)
    errorGeral.value = `Erro inesperado ao ${isEditMode.value ? 'atualizar' : 'cadastrar'} advogado. Tente novamente.`
  } finally {
    isSubmitting.value = false
  }
}

// Handler para cancelar
const handleCancel = () => {
  resetForm()
  handleModalClose()
}

// Handler para fechar modal
const handleModalClose = () => {
  emit('update:modelValue', false)
}

// Carregar dados do advogado quando modal abrir em modo de edição
const loadAdvogadoData = () => {
  if (isEditMode.value && props.advogado) {
    formData.value = {
      nome: props.advogado.nome || '',
      oab_numero: props.advogado.oab_numero || '',
      oab_uf: props.advogado.oab_uf || '',
      tipo_vinculo: props.advogado.tipo_vinculo || 'socio',
      email: props.advogado.email || '',
      telefone: props.advogado.telefone || '',
      percentual_padrao: props.advogado.percentual_padrao ? String(props.advogado.percentual_padrao) : '',
      observacoes: props.advogado.observacoes || '',
      ativo: props.advogado.ativo !== undefined ? props.advogado.ativo : true
    }
  } else {
    resetForm()
  }
}

// Observar mudanças no prop advogado e no modelValue
watch(() => props.modelValue, (newValue) => {
  if (newValue) {
    // Quando modal abrir, carregar dados
    loadAdvogadoData()
  } else {
    // Quando modal fechar, limpar formulário
    resetForm()
  }
})

watch(() => props.advogado, () => {
  if (props.modelValue) {
    loadAdvogadoData()
  }
}, { deep: true })
</script>
