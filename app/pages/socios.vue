<template>
  <div class="min-h-screen bg-gray-50 py-8 px-6">
    <div class="max-w-7xl mx-auto">
      <!-- Cabeçalho da página -->
      <div class="mb-8">
        <div class="flex items-center justify-between mb-4">
          <ButtonBack @click="handleVoltar" />
        </div>
        <div class="flex items-center justify-between">
          <div>
            <h1 class="text-3xl font-bold text-gray-900 mb-2">
              Quadro Societário
            </h1>
            <p class="text-gray-600">
              Gerencie e visualize todos os sócios cadastrados no sistema
            </p>
          </div>
          <Button @click="openModal">
            Novo sócio
          </Button>
        </div>
      </div>

      <!-- Tabela de Sócios -->
      <TabelaSocios
        ref="tabelaSociosRef"
        @edit="handleEdit"
        @delete="handleDelete"
      />

      <!-- Modal de Cadastro/Edição de Advogado -->
      <Modal
        v-model="isModalOpen"
        :title="isEditing ? 'Editar Sócio' : 'Novo Sócio'"
        size="3xl"
        @close="closeModal"
      >
        <form @submit.prevent="handleSubmit" class="space-y-6">
          <!-- Nome -->
          <Input
            v-model="formData.nome"
            label="Nome Completo"
            placeholder="Digite o nome completo"
            required
            :error="errors.nome"
          />

          <!-- OAB Número e UF -->
          <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div class="md:col-span-2">
              <Input
                v-model="formData.oab_numero"
                label="Número OAB"
                placeholder="Digite o número da OAB"
                required
                :error="errors.oab_numero"
              />
            </div>
            <div>
              <Dropdown
                v-model="formData.oab_uf"
                label="UF"
                placeholder="Selecione"
                :options="ufOptions"
                required
                :error="errors.oab_uf"
              />
            </div>
          </div>

          <!-- Email -->
          <Input
            v-model="formData.email"
            type="email"
            label="E-mail"
            placeholder="Digite o e-mail"
            :error="errors.email"
          />

          <!-- Telefone -->
          <Input
            v-model="formData.telefone"
            type="tel"
            label="Telefone"
            placeholder="Digite o telefone"
            :error="errors.telefone"
          />

          <!-- Percentual Padrão -->
          <Input
            v-model="formData.percentual_padrao"
            type="number"
            label="Percentual Padrão (%)"
            placeholder="Digite o percentual padrão"
            :error="errors.percentual_padrao"
            hint="Percentual padrão para cálculo de honorários"
          />

          <!-- Toggles -->
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <Toggle
              v-model="formData.ativo"
              label="Ativo"
              description="Advogado está ativo no sistema"
            />
            <Toggle
              v-model="formData.is_socio"
              label="É Sócio"
              description="Advogado faz parte do quadro societário"
            />
          </div>
        </form>

        <template #footer>
          <div class="flex items-center justify-end gap-4">
            <Button
              type="button"
              variant="outline"
              @click="closeModal"
            >
              Cancelar
            </Button>
            <Button
              type="button"
              :disabled="isSubmitting"
              @click="handleSubmit"
            >
              {{ isSubmitting ? 'Salvando...' : (isEditing ? 'Atualizar' : 'Cadastrar') }}
            </Button>
          </div>
        </template>
      </Modal>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, onUnmounted } from 'vue'
import TabelaSocios from '../components/TabelaSocios.vue'
import ButtonBack from '../components/ButtonBack.vue'
import Button from '../components/Button.vue'
import Input from '../components/Input.vue'
import Dropdown from '../components/Dropdown.vue'
import Toggle from '../components/Toggle.vue'
import Modal from '../components/Modal.vue'

const router = useRouter()
const supabase = useSupabaseClient()
const toast = useToast()
const tabelaSociosRef = ref(null)

// Define o layout padrão para esta página
definePageMeta({
  layout: 'default'
})

// Estados do modal
const isModalOpen = ref(false)
const isEditing = ref(false)
const isSubmitting = ref(false)
const editingId = ref(null)

// Opções de UF
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

// Dados do formulário
const formData = reactive({
  nome: '',
  oab_numero: '',
  oab_uf: '',
  email: '',
  telefone: '',
  ativo: true,
  is_socio: true,
  percentual_padrao: null
})

// Erros de validação
const errors = reactive({
  nome: '',
  oab_numero: '',
  oab_uf: '',
  email: '',
  telefone: '',
  percentual_padrao: ''
})

// Limpar formulário
const resetForm = () => {
  formData.nome = ''
  formData.oab_numero = ''
  formData.oab_uf = ''
  formData.email = ''
  formData.telefone = ''
  formData.ativo = true
  formData.is_socio = true
  formData.percentual_padrao = null
  
  // Limpar erros
  Object.keys(errors).forEach(key => {
    errors[key] = ''
  })
  
  isEditing.value = false
  editingId.value = null
}

// Abrir modal
const openModal = () => {
  resetForm()
  isModalOpen.value = true
}

// Fechar modal
const closeModal = () => {
  isModalOpen.value = false
  resetForm()
}

// Validação
const validate = () => {
  let isValid = true
  
  // Limpar erros anteriores
  Object.keys(errors).forEach(key => {
    errors[key] = ''
  })
  
  // Validar nome
  if (!formData.nome || formData.nome.trim() === '') {
    errors.nome = 'Nome é obrigatório'
    isValid = false
  }
  
  // Validar OAB número
  if (!formData.oab_numero || formData.oab_numero.trim() === '') {
    errors.oab_numero = 'Número da OAB é obrigatório'
    isValid = false
  }
  
  // Validar OAB UF
  if (!formData.oab_uf) {
    errors.oab_uf = 'UF da OAB é obrigatória'
    isValid = false
  }
  
  // Validar email se preenchido
  if (formData.email && formData.email.trim() !== '') {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (!emailRegex.test(formData.email)) {
      errors.email = 'E-mail inválido'
      isValid = false
    }
  }
  
  // Validar percentual se preenchido
  if (formData.percentual_padrao !== null && formData.percentual_padrao !== '' && formData.percentual_padrao !== undefined) {
    const percentualStr = String(formData.percentual_padrao).trim()
    if (percentualStr !== '') {
      const percentual = parseFloat(percentualStr)
      if (isNaN(percentual) || percentual < 0 || percentual > 100) {
        errors.percentual_padrao = 'Percentual deve ser entre 0 e 100'
        isValid = false
      }
    }
  }
  
  return isValid
}

// Submeter formulário
const handleSubmit = async () => {
  if (!validate()) {
    return
  }
  
  isSubmitting.value = true
  
  try {
    const percentualValue = formData.percentual_padrao !== null && formData.percentual_padrao !== '' && formData.percentual_padrao !== undefined
      ? parseFloat(String(formData.percentual_padrao).trim())
      : null
    
    const dataToSave = {
      nome: formData.nome.trim(),
      oab_numero: formData.oab_numero.trim(),
      oab_uf: formData.oab_uf,
      email: formData.email.trim() || null,
      telefone: formData.telefone.trim() || null,
      ativo: formData.ativo,
      is_socio: formData.is_socio,
      percentual_padrao: percentualValue && !isNaN(percentualValue) ? percentualValue : null,
      updated_at: new Date().toISOString()
    }
    
    let error = null
    
    if (isEditing.value && editingId.value) {
      // Atualizar
      const { error: updateError } = await supabase
        .from('advogados')
        .update(dataToSave)
        .eq('id', editingId.value)
      
      error = updateError
      
      if (!error) {
        toast.success('Sócio atualizado com sucesso!', 3000)
      }
    } else {
      // Criar novo
      const { error: insertError } = await supabase
        .from('advogados')
        .insert(dataToSave)
      
      error = insertError
      
      if (!error) {
        toast.success('Sócio cadastrado com sucesso!', 3000)
      }
    }
    
    if (error) {
      console.error('Erro ao salvar sócio:', error)
      
      // Verificar se é erro de duplicação de OAB
      if (error.code === '23505') {
        toast.showError('Já existe um advogado cadastrado com este número OAB nesta UF.', 5000)
      } else {
        toast.showError(error.message || 'Erro ao salvar sócio. Tente novamente.', 5000)
      }
      return
    }
    
    // Recarregar tabela e fechar modal
    if (tabelaSociosRef.value) {
      tabelaSociosRef.value.fetchAdvogados()
    }
    closeModal()
    
  } catch (error) {
    console.error('Erro inesperado ao salvar sócio:', error)
    toast.showError('Erro inesperado ao salvar sócio. Tente novamente.', 5000)
  } finally {
    isSubmitting.value = false
  }
}

// Função para voltar
const handleVoltar = () => {
  router.push('/')
}

// Função para editar sócio
const handleEdit = (advogado) => {
  isEditing.value = true
  editingId.value = advogado.id
  formData.nome = advogado.nome || ''
  formData.oab_numero = advogado.oab_numero || ''
  formData.oab_uf = advogado.oab_uf || ''
  formData.email = advogado.email || ''
  formData.telefone = advogado.telefone || ''
  formData.ativo = advogado.ativo !== undefined ? advogado.ativo : true
  formData.is_socio = advogado.is_socio !== undefined ? advogado.is_socio : true
  formData.percentual_padrao = advogado.percentual_padrao || null
  isModalOpen.value = true
}

// Função para excluir sócio
const handleDelete = async (advogado) => {
  const nomeAdvogado = advogado.nome || 'sócio'
  
  if (!confirm(`Deseja realmente excluir o sócio "${nomeAdvogado}"?`)) {
    return
  }
  
  try {
    const { error } = await supabase
      .from('advogados')
      .delete()
      .eq('id', advogado.id)
    
    if (error) {
      console.error('Erro ao excluir sócio:', error)
      toast.showError(error.message || 'Erro ao excluir sócio. Tente novamente.', 5000)
      return
    }
    
    toast.success('Sócio excluído com sucesso!', 3000)
    
    // Recarrega a lista de sócios
    if (tabelaSociosRef.value) {
      tabelaSociosRef.value.fetchAdvogados()
    }
  } catch (error) {
    console.error('Erro inesperado ao excluir sócio:', error)
    toast.showError('Erro inesperado ao excluir sócio. Tente novamente.', 5000)
  }
}

</script>

