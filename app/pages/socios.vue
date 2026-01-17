<template>
  <div class="h-full w-full bg-gray-50 py-4 sm:py-8 px-4 sm:px-6 overflow-y-auto">
    <div class="max-w-7xl mx-auto w-full">
      <!-- Cabeçalho da página -->
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-gray-900 mb-2">
          Sócios
        </h1>
        <p class="text-gray-600">
          Gerencie e visualize escritórios, sócios e parcerias
        </p>
      </div>

      <!-- Tabela de Sócios -->
      <TabelaSocios
        ref="tabelaSociosRef"
        @edit="handleEdit"
        @delete="handleDelete"
        @cadastrar-socio="handleCadastrarSocio"
        @cadastrar-escritorio="handleCadastrarEscritorio"
        @edit-escritorio="handleEditEscritorio"
        @delete-escritorio="handleDeleteEscritorio"
      />
    </div>

    <!-- Modal de Cadastro/Edição de Advogado -->
    <ModalCadastroAdv
      v-model="showModalCadastroSocio"
      :advogado="socioEditando"
      @salvo="handleSocioSalvo"
    />

    <!-- Modal de Cadastro/Edição de Escritório -->
    <ModalCadastroEscritorio
      v-model="showModalCadastroEscritorio"
      :escritorio="escritorioEditando"
      @salvo="handleEscritorioSalvo"
    />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import TabelaSocios from '../components/TabelaSocios.vue'
import ModalCadastroAdv from '../components/ModalCadastroAdv.vue'
import ModalCadastroEscritorio from '../components/ModalCadastroEscritorio.vue'

const router = useRouter()
const supabase = useSupabaseClient()
const toast = useToast()
const tabelaSociosRef = ref(null)
const showModalCadastroSocio = ref(false)
const socioEditando = ref(null)
const showModalCadastroEscritorio = ref(false)
const escritorioEditando = ref(null)

// Define o layout padrão para esta página
definePageMeta({
  layout: 'default'
})

// Função para abrir modal de cadastro de sócio
const handleCadastrarSocio = () => {
  socioEditando.value = null // Limpar dados de edição
  showModalCadastroSocio.value = true
}

// Função chamada quando um sócio é salvo
const handleSocioSalvo = (socio) => {
  // Limpar dados de edição
  socioEditando.value = null
  // Recarrega a lista de advogados na tabela
  if (tabelaSociosRef.value) {
    tabelaSociosRef.value.fetchAdvogados()
  }
}

// Função para editar advogado/sócio
const handleEdit = (advogado) => {
  socioEditando.value = advogado // Definir sócio para edição
  showModalCadastroSocio.value = true // Abrir modal
}

// Função para excluir advogado/sócio
const handleDelete = async (advogado) => {
  // Confirmação antes de excluir
  if (!confirm(`Deseja realmente excluir o advogado "${advogado.nome}"?`)) {
    return
  }

  try {
    const { error } = await supabase
      .from('advogados')
      .delete()
      .eq('id', advogado.id)

    if (error) {
      console.error('Erro ao excluir advogado:', error)
      toast.showError(error.message || 'Erro ao excluir advogado. Tente novamente.', 5000)
      return
    }

    toast.success('Advogado excluído com sucesso!', 3000)
    
    // Recarrega a lista de advogados
    if (tabelaSociosRef.value) {
      tabelaSociosRef.value.fetchAdvogados()
    }
  } catch (error) {
    console.error('Erro inesperado ao excluir advogado:', error)
    toast.showError('Erro inesperado ao excluir advogado. Tente novamente.', 5000)
  }
}

// Função para abrir modal de cadastro de escritório
const handleCadastrarEscritorio = () => {
  escritorioEditando.value = null // Limpar dados de edição
  showModalCadastroEscritorio.value = true
}

// Função chamada quando um escritório é salvo
const handleEscritorioSalvo = (escritorio) => {
  // Limpar dados de edição
  escritorioEditando.value = null
  // Recarrega a lista de escritórios na tabela
  if (tabelaSociosRef.value) {
    tabelaSociosRef.value.fetchEscritorios()
  }
}

// Função para editar escritório
const handleEditEscritorio = (escritorio) => {
  escritorioEditando.value = escritorio // Definir escritório para edição
  showModalCadastroEscritorio.value = true // Abrir modal
}

// Função para excluir escritório
const handleDeleteEscritorio = async (escritorio) => {
  // Confirmação antes de excluir
  if (!confirm(`Deseja realmente excluir o escritório "${escritorio.nome}"?`)) {
    return
  }

  try {
    const { error } = await supabase
      .from('escritorios')
      .delete()
      .eq('id', escritorio.id)

    if (error) {
      console.error('Erro ao excluir escritório:', error)
      toast.showError(error.message || 'Erro ao excluir escritório. Tente novamente.', 5000)
      return
    }

    toast.success('Escritório excluído com sucesso!', 3000)
    
    // Recarrega a lista de escritórios
    if (tabelaSociosRef.value) {
      tabelaSociosRef.value.fetchEscritorios()
    }
  } catch (error) {
    console.error('Erro inesperado ao excluir escritório:', error)
    toast.showError('Erro inesperado ao excluir escritório. Tente novamente.', 5000)
  }
}
</script>
