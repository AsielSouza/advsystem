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
          v-model="formDataFisica.nome_completo"
          label="Nome Completo"
          placeholder="Digite o nome completo"
          :required="true"
        />

        <!-- CPF -->
        <Input
          v-model="formDataFisica.cpf"
          label="CPF"
          placeholder="000.000.000-00"
          :required="true"
          hint="Formato: XXX.XXX.XXX-XX ou apenas números"
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
            :disabled="isSaving"
            @click="handleSave"
          >
            {{ isSaving ? 'Salvando...' : 'Salvar' }}
          </Button>
        </div>
      </div>

      <!-- Conteúdo Pessoa Jurídica -->
      <div v-if="activeTab === 'juridica'" class="space-y-4">
        <p class="text-gray-600 text-sm">
          Formulário de cadastro para Pessoa Jurídica será implementado aqui.
        </p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import Input from './Input.vue'
import InputData from './InputData.vue'
import Dropdown from './Dropdown.vue'
import Button from './Button.vue'

const router = useRouter()
const supabase = useSupabaseClient()
const toast = useToast()

const activeTab = ref('fisica')
const isSaving = ref(false)

// Dados do formulário Pessoa Física
const formDataFisica = ref({
  nome_completo: '',
  cpf: '',
  rg: '',
  rg_orgao_emissor: '',
  data_nascimento: '',
  estado_civil: '',
  profissao: ''
})

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

// Função para limpar o formulário
const clearForm = () => {
  formDataFisica.value = {
    nome_completo: '',
    cpf: '',
    rg: '',
    rg_orgao_emissor: '',
    data_nascimento: '',
    estado_civil: '',
    profissao: ''
  }
}

// Função para salvar no Supabase
const handleSave = async () => {
  // Validação básica
  if (!formDataFisica.value.nome_completo || !formDataFisica.value.cpf) {
    toast.showError('Por favor, preencha pelo menos o nome completo e CPF.', 5000)
    return
  }

  isSaving.value = true

  try {
    // Prepara os dados para inserção (remove campos vazios opcionais)
    const dataToInsert = {
      nome_completo: formDataFisica.value.nome_completo.trim(),
      cpf: formDataFisica.value.cpf.trim(),
      rg: formDataFisica.value.rg.trim() || null,
      rg_orgao_emissor: formDataFisica.value.rg_orgao_emissor.trim() || null,
      data_nascimento: formDataFisica.value.data_nascimento || null,
      estado_civil: formDataFisica.value.estado_civil || null,
      profissao: formDataFisica.value.profissao.trim() || null
    }

    // Insere no Supabase
    const { data, error } = await supabase
      .from('clientes_pessoa_fisica')
      .insert([dataToInsert])
      .select()

    if (error) {
      console.error('Erro ao salvar:', error)
      toast.showError(error.message || 'Erro ao salvar o cadastro. Tente novamente.', 5000)
      isSaving.value = false
      return
    }

    // Sucesso
    toast.success('Cliente cadastrado com sucesso!', 3000)
    clearForm()
    isSaving.value = false
  } catch (error) {
    console.error('Erro inesperado:', error)
    toast.showError('Erro inesperado ao salvar. Tente novamente.', 5000)
    isSaving.value = false
  }
}

// Função para cancelar e redirecionar
const handleCancel = () => {
  router.push('/')
}
</script>

