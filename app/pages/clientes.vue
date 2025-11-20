<template>
  <div class="min-h-screen bg-gray-50 py-8 px-6">
    <div class="max-w-7xl mx-auto">
      <!-- Cabeçalho da página -->
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-gray-900 mb-2">
          Clientes
        </h1>
        <p class="text-gray-600">
          Gerencie e visualize todos os clientes cadastrados no sistema
        </p>
      </div>

      <!-- Tabela de Clientes -->
      <TabelaClientes
        ref="tabelaClientesRef"
        @edit="handleEdit"
        @delete="handleDelete"
      />
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import TabelaClientes from '../components/TabelaClientes.vue'

const router = useRouter()
const supabase = useSupabaseClient()
const toast = useToast()
const tabelaClientesRef = ref(null)

// Define o layout padrão para esta página
definePageMeta({
  layout: 'default'
})

// Função para editar cliente
const handleEdit = (cliente) => {
  router.push(`/register-client?id=${cliente.id}`)
}

// Função para excluir cliente
const handleDelete = async (cliente) => {
  // Determina o nome para exibição na confirmação
  const nomeCliente = cliente.nome_completo || cliente.razao_social || cliente.nome || 'cliente'
  
  // Confirmação antes de excluir
  if (!confirm(`Deseja realmente excluir o cliente "${nomeCliente}"?`)) {
    return
  }

  try {
    // Determina a tabela baseado no tipo do cliente
    const tableName = cliente.tipo_cliente === 'juridica' 
      ? 'clientes_pessoa_juridica' 
      : 'clientes_pessoa_fisica'

    const { error } = await supabase
      .from(tableName)
      .delete()
      .eq('id', cliente.id)

    if (error) {
      console.error('Erro ao excluir cliente:', error)
      toast.showError(error.message || 'Erro ao excluir cliente. Tente novamente.', 5000)
      return
    }

    toast.success('Cliente excluído com sucesso!', 3000)
    
    // Recarrega a lista de clientes
    if (tabelaClientesRef.value) {
      tabelaClientesRef.value.fetchClientes()
    }
  } catch (error) {
    console.error('Erro inesperado ao excluir cliente:', error)
    toast.showError('Erro inesperado ao excluir cliente. Tente novamente.', 5000)
  }
}
</script>

