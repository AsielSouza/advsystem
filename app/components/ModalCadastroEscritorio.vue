<template>
  <Modal
    :model-value="modelValue"
    @update:model-value="handleModalClose"
    @close="handleModalClose"
    :title="isEditMode ? 'Editar Escritório' : 'Cadastrar Escritório'"
    size="lg"
  >
    <form @submit.prevent="handleSubmit" class="space-y-6">
      <!-- Nome -->
      <Input
        v-model="formData.nome"
        label="Nome"
        placeholder="Digite o nome do escritório"
        type="text"
        :error="errors.nome"
        required
      />

      <!-- Nome Fantasia -->
      <Input
        v-model="formData.nome_fantasia"
        label="Nome Fantasia"
        placeholder="Digite o nome fantasia (opcional)"
        type="text"
        :error="errors.nome_fantasia"
      />

      <!-- CNPJ -->
      <Input
        v-model="formData.cnpj"
        label="CNPJ"
        placeholder="Digite o CNPJ (opcional)"
        type="text"
        :error="errors.cnpj"
        @update:model-value="handleCnpjUpdate"
        hint="Formato: XX.XXX.XXX/XXXX-XX"
      />

      <!-- Tipo de Escritório -->
      <Dropdown
        v-model="formData.tipo_escritorio"
        label="Tipo de Escritório"
        :options="tipoEscritorioOptions"
        placeholder="Selecione o tipo de escritório"
        :error="errors.tipo_escritorio"
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

      <!-- Cidade e Estado -->
      <div class="grid grid-cols-2 gap-4">
        <div class="col-span-1">
          <Input
            v-model="formData.cidade"
            label="Cidade"
            placeholder="Digite a cidade"
            type="text"
            :error="errors.cidade"
          />
        </div>
        <div class="col-span-1">
          <Dropdown
            v-model="formData.estado"
            label="Estado"
            :options="ufOptions"
            placeholder="UF"
            :error="errors.estado"
          />
        </div>
      </div>

      <!-- Status Ativo -->
      <div>
        <label class="flex items-center gap-3 cursor-pointer">
          <Toggle
            v-model="formData.ativo"
          />
          <span class="text-sm font-semibold text-gray-800">
            Escritório Ativo
          </span>
        </label>
      </div>

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
          placeholder="Digite observações sobre o escritório (opcional)"
          :class="[
            'w-full px-5 py-3.5 border rounded-xl text-gray-900 placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-offset-0 transition-all duration-200 ease-in-out shadow-sm hover:shadow-md focus:shadow-lg resize-none',
            errors.observacoes
              ? 'border-danger-400 focus:ring-danger-500 focus:border-danger-500 bg-danger-50/30'
              : 'border-gray-200 focus:ring-primary-500 focus:border-primary-500 bg-white hover:border-gray-300'
          ]"
        ></textarea>
        <p v-if="errors.observacoes" class="mt-1.5 text-sm text-danger-500">
          {{ errors.observacoes }}
        </p>
      </div>

      <!-- Mensagem de erro geral -->
      <div v-if="errorGeral" class="p-4 bg-danger-50 border border-danger-200 rounded-xl">
        <p class="text-sm text-danger-600">{{ errorGeral }}</p>
      </div>

      <!-- Botões de ação -->
      <div class="flex items-center justify-end gap-3 pt-4 border-t border-gray-200">
        <Button
          type="button"
          variant="outline"
          @click="handleCancel"
          :disabled="isSubmitting"
        >
          Cancelar
        </Button>
        <Button
          type="submit"
          :disabled="isSubmitting || !isFormValid"
          :loading="isSubmitting"
        >
          {{ isEditMode ? 'Salvar Alterações' : 'Cadastrar Escritório' }}
        </Button>
      </div>
    </form>
  </Modal>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import Modal from './Modal.vue'
import Input from './Input.vue'
import Dropdown from './Dropdown.vue'
import Toggle from './Toggle.vue'
import Button from './Button.vue'

const props = defineProps({
  modelValue: {
    type: Boolean,
    required: true
  },
  escritorio: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['update:modelValue', 'salvo'])

const supabase = useSupabaseClient()
const toast = useToast()

// Computed para verificar se está em modo de edição
const isEditMode = computed(() => {
  return !!props.escritorio && !!props.escritorio.id
})

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

// Opções de tipo de escritório
const tipoEscritorioOptions = [
  { value: 'PROPRIO', label: 'Próprio' },
  { value: 'EXTERNO', label: 'Externo' }
]

const formData = ref({
  nome: '',
  nome_fantasia: '',
  cnpj: '',
  tipo_escritorio: 'PROPRIO',
  email: '',
  telefone: '',
  cidade: '',
  estado: '',
  ativo: true,
  observacoes: ''
})

const errors = ref({
  nome: '',
  nome_fantasia: '',
  cnpj: '',
  tipo_escritorio: '',
  email: '',
  telefone: '',
  cidade: '',
  estado: '',
  observacoes: ''
})

const errorGeral = ref('')
const isSubmitting = ref(false)

// Limpar formulário
const resetForm = () => {
  formData.value = {
    nome: '',
    nome_fantasia: '',
    cnpj: '',
    tipo_escritorio: 'PROPRIO',
    email: '',
    telefone: '',
    cidade: '',
    estado: '',
    ativo: true,
    observacoes: ''
  }
  clearErrors()
  errorGeral.value = ''
}

// Limpar erros
const clearErrors = () => {
  errors.value = {
    nome: '',
    nome_fantasia: '',
    cnpj: '',
    tipo_escritorio: '',
    email: '',
    telefone: '',
    cidade: '',
    estado: '',
    observacoes: ''
  }
}

// Função para formatar CNPJ enquanto o usuário digita
const formatCnpjInput = (value) => {
  if (!value) return ''
  
  // Remove todos os caracteres não numéricos
  const apenasNumeros = value.replace(/\D/g, '')
  
  // Limita a 14 dígitos
  const numerosLimitados = apenasNumeros.substring(0, 14)
  
  if (numerosLimitados.length === 0) return ''
  
  // Aplica formatação progressiva: XX.XXX.XXX/XXXX-XX
  if (numerosLimitados.length <= 2) {
    return numerosLimitados
  } else if (numerosLimitados.length <= 5) {
    return `${numerosLimitados.substring(0, 2)}.${numerosLimitados.substring(2)}`
  } else if (numerosLimitados.length <= 8) {
    return `${numerosLimitados.substring(0, 2)}.${numerosLimitados.substring(2, 5)}.${numerosLimitados.substring(5)}`
  } else if (numerosLimitados.length <= 12) {
    return `${numerosLimitados.substring(0, 2)}.${numerosLimitados.substring(2, 5)}.${numerosLimitados.substring(5, 8)}/${numerosLimitados.substring(8)}`
  } else {
    return `${numerosLimitados.substring(0, 2)}.${numerosLimitados.substring(2, 5)}.${numerosLimitados.substring(5, 8)}/${numerosLimitados.substring(8, 12)}-${numerosLimitados.substring(12)}`
  }
}

// Handler para formatação automática de CNPJ durante a digitação
const handleCnpjUpdate = (value) => {
  const valorFormatado = formatCnpjInput(value)
  formData.value.cnpj = valorFormatado
  if (errors.value.cnpj) {
    errors.value.cnpj = ''
  }
}

// Função para formatar CNPJ no formato exigido: XX.XXX.XXX/XXXX-XX ou apenas números
const formatCnpj = (value) => {
  if (!value) return null
  
  // Remove todos os caracteres não numéricos
  const apenasNumeros = value.replace(/\D/g, '')
  
  // Se não tiver exatamente 14 dígitos, retorna null (formato inválido)
  if (apenasNumeros.length !== 14) {
    return null
  }
  
  // Formata no padrão XX.XXX.XXX/XXXX-XX
  return `${apenasNumeros.substring(0, 2)}.${apenasNumeros.substring(2, 5)}.${apenasNumeros.substring(5, 8)}/${apenasNumeros.substring(8, 12)}-${apenasNumeros.substring(12)}`
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

  // Validar tipo de escritório (obrigatório)
  if (!formData.value.tipo_escritorio || formData.value.tipo_escritorio.trim().length === 0) {
    errors.value.tipo_escritorio = 'Tipo de escritório é obrigatório'
    isValid = false
  }

  // Validar CNPJ (opcional, mas se preenchido deve ser válido)
  if (formData.value.cnpj && formData.value.cnpj.trim().length > 0) {
    const cnpjFormatado = formatCnpj(formData.value.cnpj)
    if (!cnpjFormatado) {
      errors.value.cnpj = 'CNPJ inválido. Use o formato: XX.XXX.XXX/XXXX-XX'
      isValid = false
    }
  }

  // Validar email (opcional, mas se preenchido deve ser válido)
  if (formData.value.email && formData.value.email.trim().length > 0) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (!emailRegex.test(formData.value.email)) {
      errors.value.email = 'E-mail inválido'
      isValid = false
    }
  }

  return isValid
}

// Computed para verificar se o formulário é válido
const isFormValid = computed(() => {
  return formData.value.nome.trim().length > 0 &&
         formData.value.tipo_escritorio.trim().length > 0
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
      tipo_escritorio: formData.value.tipo_escritorio,
      ativo: formData.value.ativo,
      updated_at: new Date().toISOString()
    }

    // Adicionar campos opcionais
    if (formData.value.nome_fantasia && formData.value.nome_fantasia.trim().length > 0) {
      dados.nome_fantasia = formData.value.nome_fantasia.trim()
    } else {
      dados.nome_fantasia = null
    }
    
    if (formData.value.cnpj && formData.value.cnpj.trim().length > 0) {
      const cnpjFormatado = formatCnpj(formData.value.cnpj)
      if (cnpjFormatado) {
        dados.cnpj = cnpjFormatado
      }
    } else {
      dados.cnpj = null
    }
    
    if (formData.value.email && formData.value.email.trim().length > 0) {
      dados.email = formData.value.email.trim()
    } else {
      dados.email = null
    }
    
    if (formData.value.telefone && formData.value.telefone.trim().length > 0) {
      dados.telefone = formData.value.telefone.trim()
    } else {
      dados.telefone = null
    }
    
    if (formData.value.cidade && formData.value.cidade.trim().length > 0) {
      dados.cidade = formData.value.cidade.trim()
    } else {
      dados.cidade = null
    }
    
    if (formData.value.estado && formData.value.estado.trim().length > 0) {
      dados.estado = formData.value.estado.trim().toUpperCase()
    } else {
      dados.estado = null
    }

    if (formData.value.observacoes && formData.value.observacoes.trim().length > 0) {
      dados.observacoes = formData.value.observacoes.trim()
    } else {
      dados.observacoes = null
    }

    let data, error

    if (isEditMode.value) {
      // Modo de edição - atualizar registro existente
      const { data: updateData, error: updateError } = await supabase
        .from('escritorios')
        .update(dados)
        .eq('id', props.escritorio.id)
        .select()
        .single()

      data = updateData
      error = updateError

      if (error) {
        console.error('Erro ao atualizar escritório:', error)
        errorGeral.value = error.message || 'Erro ao atualizar escritório. Tente novamente.'
        return
      }

      toast.success('Escritório atualizado com sucesso!', 3000)
    } else {
      // Modo de cadastro - inserir novo registro
      const { data: insertData, error: insertError } = await supabase
        .from('escritorios')
        .insert(dados)
        .select()
        .single()

      data = insertData
      error = insertError

      if (error) {
        console.error('Erro ao cadastrar escritório:', error)
        
        // Tratar erro de constraint única (CNPJ já existe)
        if (error.code === '23505' || error.message.includes('unique')) {
          errorGeral.value = 'Já existe um escritório cadastrado com este CNPJ'
        } else {
          errorGeral.value = error.message || 'Erro ao cadastrar escritório. Tente novamente.'
        }
        return
      }

      toast.success('Escritório cadastrado com sucesso!', 3000)
    }

    resetForm()
    emit('salvo', data)
    handleModalClose()
  } catch (error) {
    console.error('Erro inesperado:', error)
    errorGeral.value = `Erro inesperado ao ${isEditMode.value ? 'atualizar' : 'cadastrar'} escritório. Tente novamente.`
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

// Carregar dados do escritório quando modal abrir em modo de edição
const loadEscritorioData = () => {
  if (isEditMode.value && props.escritorio) {
    formData.value = {
      nome: props.escritorio.nome || '',
      nome_fantasia: props.escritorio.nome_fantasia || '',
      cnpj: props.escritorio.cnpj || '',
      tipo_escritorio: props.escritorio.tipo_escritorio || 'PROPRIO',
      email: props.escritorio.email || '',
      telefone: props.escritorio.telefone || '',
      cidade: props.escritorio.cidade || '',
      estado: props.escritorio.estado || '',
      ativo: props.escritorio.ativo !== undefined ? props.escritorio.ativo : true,
      observacoes: props.escritorio.observacoes || ''
    }
  } else {
    resetForm()
  }
}

// Observar mudanças no prop escritorio e no modelValue
watch(() => props.modelValue, (newValue) => {
  if (newValue) {
    // Quando modal abrir, carregar dados
    loadEscritorioData()
  } else {
    // Quando modal fechar, limpar formulário
    resetForm()
  }
})

watch(() => props.escritorio, () => {
  if (props.modelValue) {
    loadEscritorioData()
  }
}, { deep: true })
</script>
