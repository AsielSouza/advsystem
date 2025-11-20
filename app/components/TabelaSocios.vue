<template>
  <div class="bg-white rounded-xl shadow-lg border border-gray-200 overflow-hidden">
    <!-- Cabeçalho da tabela -->
    <div class="px-6 py-4 border-b border-gray-200 bg-gray-50">
      <div class="flex items-center justify-between mb-4">
        <h2 class="text-lg font-semibold text-gray-900">Quadro Societário</h2>
      </div>
      <!-- Campo de pesquisa -->
      <Search
        v-model="searchQuery"
        placeholder="Pesquisar por nome, OAB ou email..."
        @update:model-value="handleSearch"
      />
    </div>

    <!-- Loading state -->
    <div v-if="isLoading" class="p-12 text-center">
      <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
      <p class="mt-4 text-gray-600">Carregando sócios...</p>
    </div>

    <!-- Empty state -->
    <div v-else-if="!isLoading && filteredAdvogados.length === 0" class="p-12 text-center">
      <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
      </svg>
      <p class="mt-4 text-gray-600">
        {{ searchQuery ? 'Nenhum sócio encontrado com esse termo.' : 'Nenhum sócio cadastrado ainda.' }}
      </p>
    </div>

    <!-- Tabela de sócios -->
    <div v-else class="overflow-x-auto">
      <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Nome
            </th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              OAB
            </th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              E-mail
            </th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Telefone
            </th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Percentual
            </th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Status
            </th>
            <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
              Ações
            </th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
          <tr v-for="advogado in filteredAdvogados" :key="advogado.id" class="hover:bg-gray-50 transition-colors">
            <td class="px-6 py-4 whitespace-nowrap">
              <div class="text-sm font-medium text-gray-900">
                {{ advogado.nome }}
              </div>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <div class="text-sm text-gray-600">
                {{ advogado.oab_numero }}/{{ advogado.oab_uf }}
              </div>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <div class="text-sm text-gray-600">
                {{ advogado.email || '-' }}
              </div>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <div class="text-sm text-gray-600">
                {{ advogado.telefone || '-' }}
              </div>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <div class="text-sm text-gray-600">
                {{ advogado.percentual_padrao ? `${advogado.percentual_padrao}%` : '-' }}
              </div>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <div class="flex items-center gap-2">
                <span 
                  v-if="advogado.ativo"
                  class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800"
                >
                  Ativo
                </span>
                <span 
                  v-else
                  class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800"
                >
                  Inativo
                </span>
                <span 
                  v-if="advogado.is_socio"
                  class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800"
                >
                  Sócio
                </span>
              </div>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
              <div class="flex items-center justify-end gap-2">
                <ButtonEdit @click="handleEdit(advogado)" />
                <ButtonDelete @click="handleDelete(advogado)" />
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

const advogados = ref([])
const isLoading = ref(true)
const searchQuery = ref('')

// Busca os advogados do banco de dados
const fetchAdvogados = async () => {
  isLoading.value = true
  
  try {
    const { data, error } = await supabase
      .from('advogados')
      .select('*')
      .order('nome', { ascending: true })

    if (error) {
      console.error('Erro ao buscar advogados:', error)
      advogados.value = []
      return
    }

    advogados.value = data || []
  } catch (error) {
    console.error('Erro inesperado ao buscar advogados:', error)
    advogados.value = []
  } finally {
    isLoading.value = false
  }
}

// Filtra os advogados baseado na pesquisa
const filteredAdvogados = computed(() => {
  if (!searchQuery.value || searchQuery.value.trim() === '') {
    return advogados.value
  }

  const query = searchQuery.value.toLowerCase().trim()
  
  return advogados.value.filter(advogado => {
    const nome = (advogado.nome || '').toLowerCase()
    const oab = `${advogado.oab_numero || ''}/${advogado.oab_uf || ''}`.toLowerCase()
    const email = (advogado.email || '').toLowerCase()
    const telefone = (advogado.telefone || '').toLowerCase()
    
    return nome.includes(query) || 
           oab.includes(query) || 
           email.includes(query) ||
           telefone.includes(query)
  })
})

// Handler para pesquisa
const handleSearch = (value) => {
  searchQuery.value = value
}

// Função para editar advogado
const handleEdit = (advogado) => {
  emit('edit', advogado)
}

// Função para excluir advogado
const handleDelete = (advogado) => {
  emit('delete', advogado)
}

const emit = defineEmits(['edit', 'delete'])

// Expõe o método fetchAdvogados para uso externo (ref)
defineExpose({
  fetchAdvogados
})

// Busca os advogados quando o componente é montado
onMounted(() => {
  fetchAdvogados()
})
</script>

