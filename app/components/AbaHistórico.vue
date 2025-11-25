<template>
  <div class="w-full space-y-6">
    <!-- Cabeçalho com Botão -->
    <div class="flex items-center justify-between">
      <h3 class="text-lg font-semibold text-gray-900">Histórico de Atualizações</h3>
      <Button
        variant="primary"
        size="sm"
        @click="abrirModal"
      >
        <svg
          class="w-4 h-4 mr-2 inline-block"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M12 4v16m8-8H4"
          />
        </svg>
        Atualizar Histórico
      </Button>
    </div>

    <!-- Timeline de Atualizações -->
    <AtualizacaoHistorico 
      :historico="historico"
      @editar="handleEditarHistorico"
    />

    <!-- Modal de Atualização -->
    <ModalAtualizarProcesso
      v-model="modalAberto"
      :honorario="honorario"
      :item-editando="itemEditando"
      @salvo="handleHistoricoSalvo"
    />
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import Button from './Button.vue'
import AtualizacaoHistorico from './AtualizacaoHistorico.vue'
import ModalAtualizarProcesso from './ModalAtualizarProcesso.vue'

const props = defineProps({
  honorario: {
    type: Object,
    required: true
  }
})

const supabase = useSupabaseClient()

const historico = ref([])
const modalAberto = ref(false)
const isLoading = ref(false)
const itemEditando = ref(null)

// Buscar histórico do honorário
const fetchHistorico = async () => {
  if (!props.honorario?.id) return

  isLoading.value = true
  try {
    const { data, error } = await supabase
      .from('honorarios_historico')
      .select('*')
      .eq('honorario_id', props.honorario.id)
      .order('created_at', { ascending: false })

    if (error) {
      console.error('Erro ao buscar histórico:', error)
      return
    }

    historico.value = data || []
  } catch (error) {
    console.error('Erro inesperado ao buscar histórico:', error)
  } finally {
    isLoading.value = false
  }
}

// Abrir modal
const abrirModal = () => {
  itemEditando.value = null
  modalAberto.value = true
}

// Handler para editar histórico
const handleEditarHistorico = (item) => {
  itemEditando.value = item
  modalAberto.value = true
}

// Handler quando histórico é salvo
const handleHistoricoSalvo = () => {
  // Recarregar histórico após salvar
  itemEditando.value = null
  fetchHistorico()
}

// Buscar histórico ao montar componente
onMounted(() => {
  fetchHistorico()
})

// Buscar histórico quando honorário mudar
watch(() => props.honorario?.id, (newId) => {
  if (newId) {
    fetchHistorico()
  }
})
</script>

