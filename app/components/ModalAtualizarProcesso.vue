<template>
  <Modal
    :model-value="modelValue"
    @update:model-value="handleModalClose"
    @close="handleModalClose"
    :title="itemEditando ? 'Editar Atualização' : 'Atualizar Processo'"
    size="lg"
  >
    <form @submit.prevent="handleSubmit" class="space-y-6">
      <!-- Campo de Texto para Histórico -->
      <div>
        <label
          for="historico"
          class="block text-sm font-semibold text-gray-800 mb-2.5 tracking-tight"
        >
          Descrição da Atualização
          <span class="text-danger-500 ml-0.5">*</span>
        </label>
        <textarea
          id="historico"
          v-model="formData.historico"
          rows="6"
          :placeholder="itemEditando ? 'Edite a descrição da atualização...' : 'Descreva a atualização do processo...'"
          :class="[
            'w-full px-4 py-3 border rounded-lg text-sm text-gray-900 placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-offset-0 transition-all duration-200 ease-in-out shadow-sm hover:shadow-md focus:shadow-lg resize-none',
            errors.historico
              ? 'border-danger-400 focus:ring-danger-500 focus:border-danger-500 bg-danger-50/30'
              : 'border-gray-200 focus:ring-primary-500 focus:border-primary-500 bg-white hover:border-gray-300'
          ]"
          @blur="handleBlur"
        ></textarea>
        <p v-if="errors.historico" class="mt-1 text-xs text-danger-600 font-medium">
          {{ errors.historico }}
        </p>
        <p v-else class="mt-1 text-xs text-gray-500">
          Descreva detalhadamente a atualização ou andamento do processo
        </p>
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
          <span v-if="isSubmitting">Salvando...</span>
          <span v-else>Salvar Atualização</span>
        </Button>
      </div>
    </template>
  </Modal>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import Modal from './Modal.vue'
import Button from './Button.vue'

const props = defineProps({
  modelValue: {
    type: Boolean,
    default: false
  },
  honorario: {
    type: Object,
    required: true
  },
  itemEditando: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['update:modelValue', 'salvo'])

const supabase = useSupabaseClient()

const formData = ref({
  historico: ''
})

const errors = ref({
  historico: ''
})

const errorGeral = ref('')
const isSubmitting = ref(false)

// Validação do campo histórico
const validateHistorico = () => {
  if (!formData.value.historico || formData.value.historico.trim().length === 0) {
    errors.value.historico = 'A descrição da atualização é obrigatória'
    return false
  }
  
  if (formData.value.historico.trim().length < 1) {
    errors.value.historico = 'A descrição deve ter pelo menos 1 caractere'
    return false
  }

  errors.value.historico = ''
  return true
}

// Validação geral do formulário
const isFormValid = computed(() => {
  return formData.value.historico.trim().length >= 1 && !errors.value.historico
})

// Limpar formulário
const resetForm = () => {
  formData.value = {
    historico: ''
  }
  errors.value = {
    historico: ''
  }
  errorGeral.value = ''
}

// Handler de blur - só valida se o modal estiver aberto
const handleBlur = () => {
  if (props.modelValue) {
    validateHistorico()
  }
}

// Carregar dados do item sendo editado
const carregarDadosEdicao = () => {
  if (props.itemEditando) {
    formData.value.historico = props.itemEditando.historico || ''
  } else {
    formData.value.historico = ''
  }
  // Limpar erros ao carregar dados
  errors.value.historico = ''
}

// Handler de cancelamento
const handleCancel = () => {
  resetForm()
  emit('update:modelValue', false)
}

// Handler quando modal fecha (por qualquer motivo - clicar fora, ESC, etc)
const handleModalClose = (value) => {
  // Sempre resetar ao fechar
  resetForm()
  emit('update:modelValue', value)
}

// Obter nome do usuário atual
const obterNomeUsuario = async () => {
  try {
    const { data: { user } } = await supabase.auth.getUser()
    
    if (!user) {
      return 'Usuário'
    }

    // Tenta buscar o display_name da tabela de perfis
    const { data: profile, error: profileError } = await supabase
      .from('profiles')
      .select('display_name')
      .eq('id', user.id)
      .single()

    if (!profileError && profile?.display_name) {
      return profile.display_name
    }

    // Se não encontrar na tabela profiles, tenta user_metadata
    if (user.user_metadata?.display_name) {
      return user.user_metadata.display_name
    }

    // Se não encontrar display_name, usa o email como fallback
    if (user.email) {
      return user.email.split('@')[0]
    }

    return 'Usuário'
  } catch (error) {
    console.error('Erro ao buscar nome do usuário:', error)
    return 'Usuário'
  }
}

// Handler de submit
const handleSubmit = async () => {
  if (!validateHistorico()) {
    return
  }

  if (!isFormValid.value) {
    return
  }

  isSubmitting.value = true
  errorGeral.value = ''

  try {
    // Obter nome do usuário
    const nomeUsuario = await obterNomeUsuario()

    // Se estiver editando, atualizar o registro existente
    if (props.itemEditando) {
      // Preparar dados para atualização
      const updateData = {
        historico: formData.value.historico.trim(),
        editado_por: nomeUsuario
      }

      // Manter criado_por se já existir, senão definir
      if (!props.itemEditando.criado_por) {
        updateData.criado_por = props.itemEditando.usuario_nome || nomeUsuario
      }

      // Atualizar o registro existente
      const { data, error } = await supabase
        .from('honorarios_historico')
        .update(updateData)
        .eq('id', props.itemEditando.id)
        .select()
        .single()

      if (error) {
        console.error('Erro ao atualizar histórico:', error)
        // Se o erro for por coluna não existir, tenta sem os campos extras
        if (error.message?.includes('column') || error.message?.includes('does not exist')) {
          const { data: dataRetry, error: errorRetry } = await supabase
            .from('honorarios_historico')
            .update({
              historico: formData.value.historico.trim() + '\n\n[Editado por ' + nomeUsuario + ']'
            })
            .eq('id', props.itemEditando.id)
            .select()
            .single()

          if (errorRetry) {
            errorGeral.value = 'Erro ao atualizar. Tente novamente.'
            isSubmitting.value = false
            return
          }

          // Sucesso sem campos extras
          resetForm()
          emit('update:modelValue', false)
          emit('salvo', dataRetry)
          return
        }

        errorGeral.value = 'Erro ao atualizar. Tente novamente.'
        isSubmitting.value = false
        return
      }

      // Sucesso - registro atualizado
      resetForm()
      emit('update:modelValue', false)
      emit('salvo', data)
      return
    }

    // Criar nova atualização (não é edição)
    const { data, error } = await supabase
      .from('honorarios_historico')
      .insert({
        honorario_id: props.honorario.id,
        numero_processo: props.honorario.numero_processo || 'N/A',
        historico: formData.value.historico.trim(),
        criado_por: nomeUsuario,
        usuario_nome: nomeUsuario
      })
      .select()
      .single()

    if (error) {
      console.error('Erro ao salvar histórico:', error)
      // Se o erro for por coluna não existir, tenta sem os campos extras
      if (error.message?.includes('column') || error.message?.includes('does not exist')) {
        const { data: dataRetry, error: errorRetry } = await supabase
          .from('honorarios_historico')
          .insert({
            honorario_id: props.honorario.id,
            numero_processo: props.honorario.numero_processo || 'N/A',
            historico: formData.value.historico.trim()
          })
          .select()
          .single()

        if (errorRetry) {
          errorGeral.value = 'Erro ao salvar atualização. Tente novamente.'
          isSubmitting.value = false
          return
        }

        // Sucesso sem campos extras
        resetForm()
        emit('update:modelValue', false)
        emit('salvo', dataRetry)
        return
      }

      errorGeral.value = 'Erro ao salvar atualização. Tente novamente.'
      isSubmitting.value = false
      return
    }

    // Sucesso
    resetForm()
    emit('update:modelValue', false)
    emit('salvo', data)
  } catch (error) {
    console.error('Erro inesperado ao salvar histórico:', error)
    errorGeral.value = 'Erro inesperado ao salvar atualização. Tente novamente.'
  } finally {
    isSubmitting.value = false
  }
}

// Carregar dados quando modal abrir ou itemEditando mudar
watch(() => props.modelValue, (newValue) => {
  if (newValue) {
    // Modal abrindo - carregar dados e limpar erros
    carregarDadosEdicao()
    errors.value.historico = ''
    errorGeral.value = ''
  } else {
    // Modal fechando - resetar tudo
    resetForm()
  }
})

watch(() => props.itemEditando, () => {
  if (props.modelValue) {
    // Se o modal estiver aberto e o itemEditando mudar, recarregar dados
    carregarDadosEdicao()
  }
}, { immediate: true })
</script>

