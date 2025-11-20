<template>
  <div class="bg-white rounded-xl shadow-lg border border-gray-200 overflow-hidden">
    <!-- Abas -->
    <div class="border-b border-gray-200">
      <div class="flex">
        <button
          @click="activeTab = 'fisica'"
          :class="[
            'flex-1 px-6 py-4 text-sm font-medium transition-colors border-b-2',
            activeTab === 'fisica'
              ? 'border-primary-600 text-primary-600 bg-primary-50'
              : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
          ]"
        >
          Pessoa Física
        </button>
        <button
          @click="activeTab = 'juridica'"
          :class="[
            'flex-1 px-6 py-4 text-sm font-medium transition-colors border-b-2',
            activeTab === 'juridica'
              ? 'border-primary-600 text-primary-600 bg-primary-50'
              : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
          ]"
        >
          Pessoa Jurídica
        </button>
      </div>
    </div>

    <!-- Conteúdo das abas -->
    <div class="p-6">
      <!-- Conteúdo Pessoa Física -->
      <div v-if="activeTab === 'fisica'" class="space-y-6">
        <!-- Nome Completo -->
        <Input
          :model-value="formDataFisica.nome_completo"
          label="Nome Completo"
          placeholder="Digite o nome completo"
          :required="true"
          :error="errors.nome_completo"
          @update:model-value="handleNomeCompletoUpdate"
        />

        <!-- CPF -->
        <Input
          :model-value="formDataFisica.cpf"
          label="CPF"
          placeholder="000.000.000-00"
          :required="true"
          :error="errors.cpf"
          @update:model-value="handleCpfUpdate"
        />

        <!-- RG e Órgão Emissor -->
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <Input
            v-model="formDataFisica.rg"
            label="RG"
            placeholder="Digite o RG"
          />
          <Input
            v-model="formDataFisica.rg_orgao_emissor"
            label="Órgão Emissor"
            placeholder="Ex: SSP, IFP, etc."
          />
        </div>

        <!-- Data de Nascimento -->
        <InputData
          v-model="formDataFisica.data_nascimento"
          label="Data de Nascimento"
          :max-date="maxDate"
        />

        <!-- Estado Civil -->
        <Dropdown
          v-model="formDataFisica.estado_civil"
          label="Estado Civil"
          :options="estadoCivilOptions"
          placeholder="Selecione o estado civil"
        />

        <!-- Profissão -->
        <Input
          v-model="formDataFisica.profissao"
          label="Profissão"
          placeholder="Digite a profissão"
        />

        <!-- Telefone -->
        <Input
          :model-value="formDataFisica.telefone"
          label="Telefone"
          placeholder="(00) 9 0000-0000"
          type="tel"
          :error="errors.telefone"
          @update:model-value="handleTelefoneUpdate"
        />

        <!-- Botões de ação -->
        <div class="flex justify-between items-center gap-4 pt-4 border-t border-gray-200">
          <Button
            variant="outline"
            @click="handleCancel"
          >
            Cancelar
          </Button>
          <Button
            variant="primary"
            :disabled="isSaving || isLoading"
            @click="handleSave"
          >
            {{ isSaving ? (isEditMode ? 'Editando...' : 'Salvando...') : (isEditMode ? 'Editar' : 'Salvar') }}
          </Button>
        </div>
      </div>

      <!-- Conteúdo Pessoa Jurídica -->
      <div v-if="activeTab === 'juridica'" class="space-y-6">
        <!-- Razão Social -->
        <Input
          :model-value="formDataJuridica.razao_social"
          label="Razão Social"
          placeholder="Digite a razão social"
          :required="true"
          :error="errors.razao_social"
          @update:model-value="handleRazaoSocialUpdate"
        />

        <!-- Nome Fantasia -->
        <Input
          :model-value="formDataJuridica.nome_fantasia"
          label="Nome Fantasia"
          placeholder="Digite o nome fantasia"
          :required="true"
          :error="errors.nome_fantasia"
          @update:model-value="handleNomeFantasiaUpdate"
        />

        <!-- CNPJ -->
        <Input
          :model-value="formDataJuridica.cnpj"
          label="CNPJ"
          placeholder="00.000.000/0000-00"
          :required="true"
          :error="errors.cnpj"
          @update:model-value="handleCnpjUpdate"
        />

        <!-- Inscrição Estadual e Inscrição Municipal -->
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <Input
            v-model="formDataJuridica.inscricao_estadual"
            label="Inscrição Estadual"
            placeholder="Digite a inscrição estadual"
            :error="errors.inscricao_estadual"
          />
          <Input
            v-model="formDataJuridica.inscricao_municipal"
            label="Inscrição Municipal"
            placeholder="Digite a inscrição municipal"
            :error="errors.inscricao_municipal"
          />
        </div>

        <!-- Representante Legal -->
        <Input
          :model-value="formDataJuridica.representante_legal_nome"
          label="Representante Legal"
          placeholder="Digite o nome do representante legal"
          :required="true"
          :error="errors.representante_legal_nome"
          @update:model-value="handleRepresentanteLegalUpdate"
        />

        <!-- CPF Representante Legal -->
        <Input
          :model-value="formDataJuridica.representante_legal_documento"
          label="CPF Representante Legal"
          placeholder="000.000.000-00"
          :required="true"
          :error="errors.representante_legal_documento"
          @update:model-value="handleCpfRepresentanteUpdate"
        />

        <!-- Telefone -->
        <Input
          :model-value="formDataJuridica.telefone"
          label="Telefone"
          placeholder="(00) 9 0000-0000"
          type="tel"
          :error="errors.telefone_juridica"
          @update:model-value="handleTelefoneJuridicaUpdate"
        />

        <!-- Botões de ação -->
        <div class="flex justify-between items-center gap-4 pt-4 border-t border-gray-200">
          <Button
            variant="outline"
            @click="handleCancel"
          >
            Cancelar
          </Button>
          <Button
            variant="primary"
            :disabled="isSaving || isLoading"
            @click="handleSave"
          >
            {{ isSaving ? (isEditMode ? 'Editando...' : 'Salvando...') : (isEditMode ? 'Editar' : 'Salvar') }}
          </Button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import Input from './Input.vue'
import InputData from './InputData.vue'
import Dropdown from './Dropdown.vue'
import Button from './Button.vue'

const props = defineProps({
  clienteId: {
    type: String,
    default: null
  }
})

const router = useRouter()
const supabase = useSupabaseClient()
const toast = useToast()

const activeTab = ref('fisica')
const isSaving = ref(false)
const isLoading = ref(false)

// Estados de erro para cada campo
const errors = ref({
  // Pessoa Física
  nome_completo: '',
  cpf: '',
  telefone: '',
  // Pessoa Jurídica
  razao_social: '',
  nome_fantasia: '',
  cnpj: '',
  inscricao_estadual: '',
  inscricao_municipal: '',
  representante_legal_nome: '',
  representante_legal_documento: '',
  telefone_juridica: ''
})

// Função para limpar todos os erros
const clearErrors = () => {
  errors.value = {
    nome_completo: '',
    cpf: '',
    telefone: '',
    razao_social: '',
    nome_fantasia: '',
    cnpj: '',
    inscricao_estadual: '',
    inscricao_municipal: '',
    representante_legal_nome: '',
    representante_legal_documento: '',
    telefone_juridica: ''
  }
}

// Função para validar o formulário
const validateForm = () => {
  clearErrors()
  let isValid = true
  const errorMessages = []

  // Validação baseada na aba ativa
  if (activeTab.value === 'fisica') {
    // Validação Pessoa Física
    // Validação do Nome Completo (obrigatório)
    if (!formDataFisica.value.nome_completo || formDataFisica.value.nome_completo.trim().length === 0) {
      errors.value.nome_completo = 'Nome completo é obrigatório'
      errorMessages.push('Nome Completo')
      isValid = false
    } else if (formDataFisica.value.nome_completo.trim().length < 3) {
      errors.value.nome_completo = 'Nome completo deve ter pelo menos 3 caracteres'
      errorMessages.push('Nome Completo')
      isValid = false
    }

    // Validação do CPF (obrigatório)
    if (!formDataFisica.value.cpf || formDataFisica.value.cpf.trim().length === 0) {
      errors.value.cpf = 'CPF é obrigatório'
      errorMessages.push('CPF')
      isValid = false
    } else {
      const cpfFormatado = formatCpf(formDataFisica.value.cpf)
      if (!cpfFormatado) {
        errors.value.cpf = 'CPF inválido. Use o formato: XXX.XXX.XXX-XX'
        errorMessages.push('CPF')
        isValid = false
      }
    }

    // Validação do Telefone (opcional, mas se preenchido deve ser válido)
    if (formDataFisica.value.telefone && formDataFisica.value.telefone.trim().length > 0) {
      const telefoneFormatado = formatTelefone(formDataFisica.value.telefone)
      if (!telefoneFormatado) {
        errors.value.telefone = 'Telefone inválido. Use o formato: (XX) 9 XXXX-XXXX'
        errorMessages.push('Telefone')
        isValid = false
      }
    }
  } else {
    // Validação Pessoa Jurídica
    // Validação da Razão Social (obrigatório)
    if (!formDataJuridica.value.razao_social || formDataJuridica.value.razao_social.trim().length === 0) {
      errors.value.razao_social = 'Razão social é obrigatória'
      errorMessages.push('Razão Social')
      isValid = false
    } else if (formDataJuridica.value.razao_social.trim().length < 3) {
      errors.value.razao_social = 'Razão social deve ter pelo menos 3 caracteres'
      errorMessages.push('Razão Social')
      isValid = false
    }

    // Validação do Nome Fantasia (obrigatório)
    if (!formDataJuridica.value.nome_fantasia || formDataJuridica.value.nome_fantasia.trim().length === 0) {
      errors.value.nome_fantasia = 'Nome fantasia é obrigatório'
      errorMessages.push('Nome Fantasia')
      isValid = false
    } else if (formDataJuridica.value.nome_fantasia.trim().length < 3) {
      errors.value.nome_fantasia = 'Nome fantasia deve ter pelo menos 3 caracteres'
      errorMessages.push('Nome Fantasia')
      isValid = false
    }

    // Validação do CNPJ (obrigatório)
    if (!formDataJuridica.value.cnpj || formDataJuridica.value.cnpj.trim().length === 0) {
      errors.value.cnpj = 'CNPJ é obrigatório'
      errorMessages.push('CNPJ')
      isValid = false
    } else {
      const cnpjFormatado = formatCnpj(formDataJuridica.value.cnpj)
      if (!cnpjFormatado) {
        errors.value.cnpj = 'CNPJ inválido. Use o formato: XX.XXX.XXX/XXXX-XX'
        errorMessages.push('CNPJ')
        isValid = false
      }
    }

    // Validação do Representante Legal (obrigatório)
    if (!formDataJuridica.value.representante_legal_nome || formDataJuridica.value.representante_legal_nome.trim().length === 0) {
      errors.value.representante_legal_nome = 'Representante legal é obrigatório'
      errorMessages.push('Representante Legal')
      isValid = false
    } else if (formDataJuridica.value.representante_legal_nome.trim().length < 3) {
      errors.value.representante_legal_nome = 'Representante legal deve ter pelo menos 3 caracteres'
      errorMessages.push('Representante Legal')
      isValid = false
    }

    // Validação do CPF Representante Legal (obrigatório)
    if (!formDataJuridica.value.representante_legal_documento || formDataJuridica.value.representante_legal_documento.trim().length === 0) {
      errors.value.representante_legal_documento = 'CPF do representante legal é obrigatório'
      errorMessages.push('CPF Representante Legal')
      isValid = false
    } else {
      const cpfFormatado = formatCpf(formDataJuridica.value.representante_legal_documento)
      if (!cpfFormatado) {
        errors.value.representante_legal_documento = 'CPF inválido. Use o formato: XXX.XXX.XXX-XX'
        errorMessages.push('CPF Representante Legal')
        isValid = false
      }
    }

    // Validação do Telefone (opcional, mas se preenchido deve ser válido)
    if (formDataJuridica.value.telefone && formDataJuridica.value.telefone.trim().length > 0) {
      const telefoneFormatado = formatTelefone(formDataJuridica.value.telefone)
      if (!telefoneFormatado) {
        errors.value.telefone_juridica = 'Telefone inválido. Use o formato: (XX) 9 XXXX-XXXX'
        errorMessages.push('Telefone')
        isValid = false
      }
    }
  }

  // Se houver erros, mostra mensagem no Toast
  if (!isValid) {
    const errorList = []
    
    if (activeTab.value === 'fisica') {
      // Erros Pessoa Física
      if (errors.value.nome_completo) {
        errorList.push(`Nome Completo: ${errors.value.nome_completo}`)
      }
      if (errors.value.cpf) {
        errorList.push(`CPF: ${errors.value.cpf}`)
      }
      if (errors.value.telefone) {
        errorList.push(`Telefone: ${errors.value.telefone}`)
      }
    } else {
      // Erros Pessoa Jurídica
      if (errors.value.razao_social) {
        errorList.push(`Razão Social: ${errors.value.razao_social}`)
      }
      if (errors.value.nome_fantasia) {
        errorList.push(`Nome Fantasia: ${errors.value.nome_fantasia}`)
      }
      if (errors.value.cnpj) {
        errorList.push(`CNPJ: ${errors.value.cnpj}`)
      }
      if (errors.value.representante_legal_nome) {
        errorList.push(`Representante Legal: ${errors.value.representante_legal_nome}`)
      }
      if (errors.value.representante_legal_documento) {
        errorList.push(`CPF Representante Legal: ${errors.value.representante_legal_documento}`)
      }
      if (errors.value.telefone_juridica) {
        errorList.push(`Telefone: ${errors.value.telefone_juridica}`)
      }
    }
    
    const message = `Por favor, corrija os seguintes campos:\n${errorList.join('\n')}`
    toast.showError(message, 7000)
    
    // Aguarda um pouco antes de rolar para garantir que os erros sejam renderizados
    setTimeout(() => {
      const firstErrorField = document.querySelector('.border-danger-400')
      if (firstErrorField) {
        firstErrorField.scrollIntoView({ behavior: 'smooth', block: 'center' })
        // Adiciona um foco visual temporário
        firstErrorField.focus()
      }
    }, 100)
  }

  return isValid
}

// Dados do formulário Pessoa Física
const formDataFisica = ref({
  nome_completo: '',
  cpf: '',
  rg: '',
  rg_orgao_emissor: '',
  data_nascimento: '',
  estado_civil: '',
  profissao: '',
  telefone: ''
})

// Dados do formulário Pessoa Jurídica
const formDataJuridica = ref({
  razao_social: '',
  nome_fantasia: '',
  cnpj: '',
  inscricao_estadual: '',
  inscricao_municipal: '',
  representante_legal_nome: '',
  representante_legal_documento: '',
  telefone: ''
})

// Verifica se está em modo de edição
const isEditMode = computed(() => {
  return !!props.clienteId
})

// Verifica o tipo de cliente sendo editado (se houver)
const clienteType = ref('fisica') // 'fisica' ou 'juridica'

// Opções para Estado Civil
const estadoCivilOptions = [
  { value: 'Solteiro', label: 'Solteiro' },
  { value: 'Casado', label: 'Casado' },
  { value: 'Divorciado', label: 'Divorciado' },
  { value: 'Viúvo', label: 'Viúvo' },
  { value: 'União Estável', label: 'União Estável' }
]

// Data máxima para data de nascimento (hoje)
const maxDate = computed(() => {
  const today = new Date()
  return today.toISOString().split('T')[0]
})

// Função para formatar CPF enquanto o usuário digita
const formatCpfInput = (value) => {
  if (!value) return ''
  
  // Remove todos os caracteres não numéricos
  const apenasNumeros = value.replace(/\D/g, '')
  
  // Limita a 11 dígitos
  const numerosLimitados = apenasNumeros.substring(0, 11)
  
  if (numerosLimitados.length === 0) return ''
  
  // Aplica formatação progressiva: XXX.XXX.XXX-XX
  if (numerosLimitados.length <= 3) {
    return numerosLimitados
  } else if (numerosLimitados.length <= 6) {
    return `${numerosLimitados.substring(0, 3)}.${numerosLimitados.substring(3)}`
  } else if (numerosLimitados.length <= 9) {
    return `${numerosLimitados.substring(0, 3)}.${numerosLimitados.substring(3, 6)}.${numerosLimitados.substring(6)}`
  } else {
    return `${numerosLimitados.substring(0, 3)}.${numerosLimitados.substring(3, 6)}.${numerosLimitados.substring(6, 9)}-${numerosLimitados.substring(9)}`
  }
}

// Handler para atualização do Nome Completo
const handleNomeCompletoUpdate = (value) => {
  formDataFisica.value.nome_completo = value
  // Limpa o erro do nome completo quando o usuário começa a digitar
  if (errors.value.nome_completo) {
    errors.value.nome_completo = ''
  }
}

// Handler para formatação automática de CPF durante a digitação
const handleCpfUpdate = (value) => {
  const valorFormatado = formatCpfInput(value)
  formDataFisica.value.cpf = valorFormatado
  // Limpa o erro do CPF quando o usuário começa a digitar
  if (errors.value.cpf) {
    errors.value.cpf = ''
  }
}

// Função para formatar telefone enquanto o usuário digita
const formatTelefoneInput = (value) => {
  if (!value) return ''
  
  // Remove todos os caracteres não numéricos
  const apenasNumeros = value.replace(/\D/g, '')
  
  // Limita a 11 dígitos
  const numerosLimitados = apenasNumeros.substring(0, 11)
  
  if (numerosLimitados.length === 0) return ''
  
  // Aplica formatação progressiva
  if (numerosLimitados.length <= 2) {
    return `(${numerosLimitados}`
  } else if (numerosLimitados.length <= 3) {
    return `(${numerosLimitados.substring(0, 2)}) ${numerosLimitados.substring(2)}`
  } else if (numerosLimitados.length <= 7) {
    return `(${numerosLimitados.substring(0, 2)}) ${numerosLimitados.substring(2, 3)} ${numerosLimitados.substring(3)}`
  } else if (numerosLimitados.length <= 11) {
    return `(${numerosLimitados.substring(0, 2)}) ${numerosLimitados.substring(2, 3)} ${numerosLimitados.substring(3, 7)}-${numerosLimitados.substring(7)}`
  }
  
  return value
}

// Handler para formatação automática durante a digitação
const handleTelefoneUpdate = (value) => {
  const valorFormatado = formatTelefoneInput(value)
  formDataFisica.value.telefone = valorFormatado
  // Limpa o erro do telefone quando o usuário começa a digitar
  if (errors.value.telefone) {
    errors.value.telefone = ''
  }
}

// Handlers para Pessoa Jurídica
const handleRazaoSocialUpdate = (value) => {
  formDataJuridica.value.razao_social = value
  if (errors.value.razao_social) {
    errors.value.razao_social = ''
  }
}

const handleNomeFantasiaUpdate = (value) => {
  formDataJuridica.value.nome_fantasia = value
  if (errors.value.nome_fantasia) {
    errors.value.nome_fantasia = ''
  }
}

const handleRepresentanteLegalUpdate = (value) => {
  formDataJuridica.value.representante_legal_nome = value
  if (errors.value.representante_legal_nome) {
    errors.value.representante_legal_nome = ''
  }
}

const handleCpfRepresentanteUpdate = (value) => {
  const valorFormatado = formatCpfInput(value)
  formDataJuridica.value.representante_legal_documento = valorFormatado
  if (errors.value.representante_legal_documento) {
    errors.value.representante_legal_documento = ''
  }
}

const handleTelefoneJuridicaUpdate = (value) => {
  const valorFormatado = formatTelefoneInput(value)
  formDataJuridica.value.telefone = valorFormatado
  if (errors.value.telefone_juridica) {
    errors.value.telefone_juridica = ''
  }
}

// Função para formatar CPF no formato exigido pela constraint: XXX.XXX.XXX-XX ou apenas números
const formatCpf = (value) => {
  if (!value) return null
  
  // Remove todos os caracteres não numéricos
  const apenasNumeros = value.replace(/\D/g, '')
  
  // Se não tiver exatamente 11 dígitos, retorna null (formato inválido)
  if (apenasNumeros.length !== 11) {
    return null
  }
  
  // Formata no padrão XXX.XXX.XXX-XX
  return `${apenasNumeros.substring(0, 3)}.${apenasNumeros.substring(3, 6)}.${apenasNumeros.substring(6, 9)}-${apenasNumeros.substring(9)}`
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
  formDataJuridica.value.cnpj = valorFormatado
  if (errors.value.cnpj) {
    errors.value.cnpj = ''
  }
}

// Função para formatar CNPJ no formato exigido pela constraint: XX.XXX.XXX/XXXX-XX ou apenas números
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

// Função para formatar telefone no formato exigido pela constraint: (XX) 9 XXXX-XXXX
const formatTelefone = (value) => {
  if (!value) return null
  
  // Remove todos os caracteres não numéricos
  const apenasNumeros = value.replace(/\D/g, '')
  
  // Se não tiver exatamente 11 dígitos, retorna null (formato inválido)
  if (apenasNumeros.length !== 11) {
    return null
  }
  
  // Formata no padrão (XX) 9 XXXX-XXXX
  const ddd = apenasNumeros.substring(0, 2)
  const numero = apenasNumeros.substring(2)
  // Número deve começar com 9 (celular)
  if (numero[0] !== '9') {
    return null
  }
  
  return `(${ddd}) ${numero[0]} ${numero.substring(1, 5)}-${numero.substring(5)}`
}

// Função para limpar o formulário
const clearForm = () => {
  formDataFisica.value = {
    nome_completo: '',
    cpf: '',
    rg: '',
    rg_orgao_emissor: '',
    data_nascimento: '',
    estado_civil: '',
    profissao: '',
    telefone: ''
  }
  formDataJuridica.value = {
    razao_social: '',
    nome_fantasia: '',
    cnpj: '',
    inscricao_estadual: '',
    inscricao_municipal: '',
    representante_legal_nome: '',
    representante_legal_documento: '',
    telefone: ''
  }
  // Limpa também os erros ao limpar o formulário
  clearErrors()
}

// Função para carregar dados do cliente para edição
const loadClienteData = async () => {
  if (!props.clienteId) return

  isLoading.value = true

  try {
    // Tenta carregar como Pessoa Física primeiro
    let { data, error } = await supabase
      .from('clientes_pessoa_fisica')
      .select('*')
      .eq('id', props.clienteId)
      .single()

    if (!error && data) {
      // É Pessoa Física
      clienteType.value = 'fisica'
      activeTab.value = 'fisica'
      formDataFisica.value = {
        nome_completo: data.nome_completo || '',
        cpf: data.cpf || '',
        rg: data.rg || '',
        rg_orgao_emissor: data.rg_orgao_emissor || '',
        data_nascimento: data.data_nascimento || '',
        estado_civil: data.estado_civil || '',
        profissao: data.profissao || '',
        telefone: data.telefone || ''
      }
      isLoading.value = false
      return
    }

    // Se não encontrou como Pessoa Física, tenta como Pessoa Jurídica
    const resultJuridica = await supabase
      .from('clientes_pessoa_juridica')
      .select('*')
      .eq('id', props.clienteId)
      .single()

    if (resultJuridica.error) {
      console.error('Erro ao carregar cliente:', resultJuridica.error)
      toast.showError(resultJuridica.error.message || 'Erro ao carregar dados do cliente.', 5000)
      isLoading.value = false
      router.push('/modulo-clientes')
      return
    }

    if (resultJuridica.data) {
      // É Pessoa Jurídica
      clienteType.value = 'juridica'
      activeTab.value = 'juridica'
      formDataJuridica.value = {
        razao_social: resultJuridica.data.razao_social || '',
        nome_fantasia: resultJuridica.data.nome_fantasia || '',
        cnpj: resultJuridica.data.cnpj || '',
        inscricao_estadual: resultJuridica.data.inscricao_estadual || '',
        inscricao_municipal: resultJuridica.data.inscricao_municipal || '',
        representante_legal_nome: resultJuridica.data.representante_legal_nome || '',
        representante_legal_documento: resultJuridica.data.representante_legal_documento || '',
        telefone: resultJuridica.data.telefone || ''
      }
    }
  } catch (error) {
    console.error('Erro inesperado ao carregar cliente:', error)
    toast.showError('Erro inesperado ao carregar dados do cliente.', 5000)
    router.push('/modulo-clientes')
  } finally {
    isLoading.value = false
  }
}

// Função para salvar/editar no Supabase
const handleSave = async () => {
  // Valida o formulário antes de salvar
  if (!validateForm()) {
    return
  }

  isSaving.value = true

  try {
    let dataToSave
    let tableName

    if (activeTab.value === 'fisica') {
      // Salvar Pessoa Física
      tableName = 'clientes_pessoa_fisica'
      
      // Formata o CPF antes de salvar (já validado)
      const cpfFormatado = formatCpf(formDataFisica.value.cpf)
      
      // Formata o telefone antes de salvar (já validado se preenchido)
      const telefoneFormatado = formatTelefone(formDataFisica.value.telefone)
      
      // Prepara os dados (remove campos vazios opcionais)
      dataToSave = {
        nome_completo: formDataFisica.value.nome_completo.trim(),
        cpf: cpfFormatado,
        rg: formDataFisica.value.rg.trim() || null,
        rg_orgao_emissor: formDataFisica.value.rg_orgao_emissor.trim() || null,
        data_nascimento: formDataFisica.value.data_nascimento || null,
        estado_civil: formDataFisica.value.estado_civil || null,
        profissao: formDataFisica.value.profissao.trim() || null,
        telefone: telefoneFormatado
      }
    } else {
      // Salvar Pessoa Jurídica
      tableName = 'clientes_pessoa_juridica'
      
      // Formata o CNPJ antes de salvar (já validado)
      const cnpjFormatado = formatCnpj(formDataJuridica.value.cnpj)
      
      // Formata o CPF do representante legal antes de salvar (já validado)
      const cpfRepresentanteFormatado = formatCpf(formDataJuridica.value.representante_legal_documento)
      
      // Formata o telefone antes de salvar (já validado se preenchido)
      const telefoneFormatado = formatTelefone(formDataJuridica.value.telefone)
      
      // Prepara os dados (remove campos vazios opcionais)
      dataToSave = {
        razao_social: formDataJuridica.value.razao_social.trim(),
        nome_fantasia: formDataJuridica.value.nome_fantasia.trim(),
        cnpj: cnpjFormatado,
        inscricao_estadual: formDataJuridica.value.inscricao_estadual.trim() || null,
        inscricao_municipal: formDataJuridica.value.inscricao_municipal.trim() || null,
        representante_legal_nome: formDataJuridica.value.representante_legal_nome.trim(),
        representante_legal_documento: cpfRepresentanteFormatado,
        telefone: telefoneFormatado
      }
    }

    let result
    if (isEditMode.value) {
      // Atualiza o cliente existente
      result = await supabase
        .from(tableName)
        .update(dataToSave)
        .eq('id', props.clienteId)
        .select()
    } else {
      // Insere novo cliente
      result = await supabase
        .from(tableName)
        .insert([dataToSave])
        .select()
    }

    const { data, error } = result

    if (error) {
      console.error('Erro ao salvar:', error)
      toast.showError(error.message || `Erro ao ${isEditMode.value ? 'editar' : 'salvar'} o cadastro. Tente novamente.`, 5000)
      isSaving.value = false
      return
    }

    // Sucesso
    toast.success(`Cliente ${isEditMode.value ? 'editado' : 'cadastrado'} com sucesso!`, 3000)
    
    if (!isEditMode.value) {
      clearForm()
    }
    
    isSaving.value = false
    
    // Redireciona para o módulo de clientes após salvar/editar
    setTimeout(() => {
      router.push('/modulo-clientes')
    }, 1000)
  } catch (error) {
    console.error('Erro inesperado:', error)
    toast.showError('Erro inesperado ao salvar. Tente novamente.', 5000)
    isSaving.value = false
  }
}

// Função para cancelar e redirecionar
const handleCancel = () => {
  // Se estiver em modo de edição, volta para a lista de clientes
  // Caso contrário, volta para o módulo de clientes
  if (isEditMode.value) {
    router.push('/clientes')
  } else {
    router.push('/modulo-clientes')
  }
}

// Carrega os dados do cliente quando estiver em modo de edição
watch(() => props.clienteId, (newId) => {
  if (newId) {
    loadClienteData()
  }
}, { immediate: true })

// Carrega os dados quando o componente é montado
onMounted(() => {
  if (props.clienteId) {
    loadClienteData()
  }
})
</script>

