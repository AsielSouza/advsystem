<template>
  <div class="bg-white rounded-xl shadow-lg border border-gray-200 overflow-hidden">
    <!-- Cabeçalho da tabela -->
    <div class="px-4 sm:px-6 py-4 border-b border-gray-200 bg-gray-50">
      <div class="flex items-center justify-between mb-4">
        <h2 class="text-lg font-semibold text-gray-900">Lista de Clientes</h2>
      </div>
      <!-- Campo de pesquisa -->
      <Search
        v-model="searchQuery"
        placeholder="Pesquisar por nome, razão social ou nome fantasia..."
        @update:model-value="handleSearch"
      />
    </div>

    <!-- Loading state -->
    <div v-if="isLoading" class="p-12 text-center">
      <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
      <p class="mt-4 text-gray-600">Carregando clientes...</p>
    </div>

    <!-- Empty state -->
    <div v-else-if="!isLoading && filteredClientes.length === 0" class="p-12 text-center">
      <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
      </svg>
      <p class="mt-4 text-gray-600">
        {{ searchQuery ? 'Nenhum cliente encontrado com esse termo.' : 'Nenhum cliente cadastrado ainda.' }}
      </p>
    </div>

    <!-- Tabela de clientes -->
    <div v-else class="overflow-x-auto">
      <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Tipo
            </th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Nome / Razão Social
            </th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Telefone
            </th>
            <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
              Ações
            </th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
          <tr v-for="cliente in filteredClientes" :key="cliente.id" class="hover:bg-gray-50 transition-colors">
            <td class="px-6 py-4 whitespace-nowrap">
              <span 
                :class="[
                  'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium',
                  cliente.tipo === 'PF' 
                    ? 'bg-blue-100 text-blue-800' 
                    : 'bg-green-100 text-green-800'
                ]"
              >
                {{ cliente.tipo }}
              </span>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <div class="text-sm font-medium text-gray-900">
                {{ cliente.nome || cliente.razao_social || cliente.nome_completo }}
              </div>
              <div v-if="cliente.tipo === 'PJ' && cliente.nome_fantasia" class="text-xs text-gray-500">
                {{ cliente.nome_fantasia }}
              </div>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <div class="text-sm text-gray-600">
                {{ cliente.telefone || '-' }}
              </div>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
              <div class="flex items-center justify-end gap-2">
                <ButtonEdit @click="handleEdit(cliente)" />
                <ButtonDelete @click="handleDelete(cliente)" />
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import ButtonEdit from './ButtonEdit.vue'
import ButtonDelete from './ButtonDelete.vue'
import Search from './Search.vue'

const supabase = useSupabaseClient()

const clientes = ref([])
const clientesFisica = ref([])
const clientesJuridica = ref([])
const isLoading = ref(true)
const searchQuery = ref('')

// Busca os clientes do banco de dados (pessoa física e jurídica)
const fetchClientes = async () => {
  isLoading.value = true
  
  try {
    // Busca clientes pessoa física
    const { data: dataFisica, error: errorFisica } = await supabase
      .from('clientes_pessoa_fisica')
      .select('id, nome_completo, telefone')
      .order('nome_completo', { ascending: true })

    // Busca clientes pessoa jurídica
    const { data: dataJuridica, error: errorJuridica } = await supabase
      .from('clientes_pessoa_juridica')
      .select('id, razao_social, nome_fantasia, telefone')
      .order('razao_social', { ascending: true })

    if (errorFisica) {
      console.error('Erro ao buscar clientes pessoa física:', errorFisica)
    }

    if (errorJuridica) {
      console.error('Erro ao buscar clientes pessoa jurídica:', errorJuridica)
    }

    // Mapeia os dados adicionando tipo e nome unificado
    clientesFisica.value = (dataFisica || []).map(cliente => ({
      ...cliente,
      tipo: 'PF',
      nome: cliente.nome_completo,
      tipo_cliente: 'fisica'
    }))

    clientesJuridica.value = (dataJuridica || []).map(cliente => ({
      ...cliente,
      tipo: 'PJ',
      nome: cliente.razao_social,
      tipo_cliente: 'juridica'
    }))

    // Combina os dois arrays e ordena
    const todosClientes = [...clientesFisica.value, ...clientesJuridica.value]
    clientes.value = todosClientes.sort((a, b) => {
      const nomeA = a.nome || a.razao_social || ''
      const nomeB = b.nome || b.razao_social || ''
      return nomeA.localeCompare(nomeB, 'pt-BR', { sensitivity: 'base' })
    })
  } catch (error) {
    console.error('Erro inesperado ao buscar clientes:', error)
    clientes.value = []
  } finally {
    isLoading.value = false
  }
}

// Filtra os clientes baseado na pesquisa
const filteredClientes = computed(() => {
  if (!searchQuery.value || searchQuery.value.trim() === '') {
    return clientes.value
  }

  const query = searchQuery.value.toLowerCase().trim()
  
  return clientes.value.filter(cliente => {
    const nome = (cliente.nome || cliente.nome_completo || cliente.razao_social || '').toLowerCase()
    const nomeFantasia = (cliente.nome_fantasia || '').toLowerCase()
    const telefone = (cliente.telefone || '').toLowerCase()
    
    return nome.includes(query) || 
           nomeFantasia.includes(query) || 
           telefone.includes(query)
  })
})

// Handler para pesquisa
const handleSearch = (value) => {
  searchQuery.value = value
}

// Função para editar cliente
const handleEdit = (cliente) => {
  emit('edit', cliente)
}

// Função para excluir cliente
const handleDelete = (cliente) => {
  emit('delete', cliente)
}

const emit = defineEmits(['edit', 'delete'])

// Expõe o método fetchClientes para uso externo (ref)
defineExpose({
  fetchClientes
})

// Busca os clientes quando o componente é montado
onMounted(() => {
  fetchClientes()
})
</script>

