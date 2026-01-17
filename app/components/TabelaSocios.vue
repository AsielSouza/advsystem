<template>
  <div class="bg-white rounded-xl shadow-lg border border-gray-200 overflow-hidden">
    <!-- Navegação das Abas -->
    <div class="border-b border-gray-200">
      <nav class="flex space-x-8 px-4 sm:px-6" aria-label="Tabs">
        <button
          @click="abaAtiva = 'escritorios'"
          :class="[
            'py-4 px-1 border-b-2 font-medium text-sm transition-colors',
            abaAtiva === 'escritorios'
              ? 'border-primary-500 text-primary-600'
              : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
          ]"
        >
          Escritórios
        </button>
        <button
          @click="abaAtiva = 'socios'"
          :class="[
            'py-4 px-1 border-b-2 font-medium text-sm transition-colors',
            abaAtiva === 'socios'
              ? 'border-primary-500 text-primary-600'
              : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
          ]"
        >
          Sócios
        </button>
      </nav>
    </div>

    <!-- Conteúdo das Abas -->
    <div>
      <!-- Aba de Escritórios -->
      <div v-if="abaAtiva === 'escritorios'">
        <!-- Cabeçalho da tabela -->
        <div class="px-4 sm:px-6 py-4 border-b border-gray-200 bg-gray-50">
          <div class="flex items-center justify-between mb-4">
            <h2 class="text-lg font-semibold text-gray-900">Escritórios</h2>
            <Button @click="handleCadastrarEscritorio" size="sm">
              Cadastrar Escritório
            </Button>
          </div>
          <!-- Campo de pesquisa -->
          <Search
            v-model="searchQueryEscritorios"
            placeholder="Pesquisar por nome, CNPJ, email ou cidade..."
            @update:model-value="handleSearchEscritorios"
          />
        </div>

        <!-- Loading state -->
        <div v-if="isLoadingEscritorios" class="p-12 text-center">
          <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
          <p class="mt-4 text-gray-600">Carregando escritórios...</p>
        </div>

        <!-- Empty state -->
        <div v-else-if="!isLoadingEscritorios && filteredEscritorios.length === 0" class="p-12 text-center">
          <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
          </svg>
          <p class="mt-4 text-gray-600">
            {{ searchQueryEscritorios ? 'Nenhum escritório encontrado com esse termo.' : 'Nenhum escritório cadastrado ainda.' }}
          </p>
        </div>

        <!-- Tabela de escritórios -->
        <div v-else class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Nome
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Nome Fantasia
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  CNPJ
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Tipo
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  E-mail
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Telefone
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Localização
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
              <tr v-for="escritorio in filteredEscritorios" :key="escritorio.id" class="hover:bg-gray-50 transition-colors">
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-sm font-medium text-gray-900">
                    {{ escritorio.nome }}
                  </div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-sm text-gray-600">
                    {{ escritorio.nome_fantasia || '-' }}
                  </div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-sm text-gray-600">
                    {{ formatarCNPJ(escritorio.cnpj) || '-' }}
                  </div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-sm text-gray-600">
                    {{ formatarTipoEscritorio(escritorio.tipo_escritorio) }}
                  </div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-sm text-gray-600">
                    {{ escritorio.email || '-' }}
                  </div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-sm text-gray-600">
                    {{ escritorio.telefone || '-' }}
                  </div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-sm text-gray-600">
                    {{ formatarLocalizacao(escritorio.cidade, escritorio.estado) }}
                  </div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span 
                    v-if="escritorio.ativo"
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
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                  <div class="flex items-center justify-end gap-2">
                    <ButtonEdit @click="handleEditEscritorio(escritorio)" />
                    <ButtonDelete @click="handleDeleteEscritorio(escritorio)" />
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Aba de Sócios -->
      <div v-if="abaAtiva === 'socios'">
        <!-- Cabeçalho da tabela -->
        <div class="px-4 sm:px-6 py-4 border-b border-gray-200 bg-gray-50">
          <div class="flex items-center justify-between mb-4">
            <h2 class="text-lg font-semibold text-gray-900">Quadro Societário</h2>
            <Button @click="handleCadastrarSocio" size="sm">
              Cadastrar Sócio
            </Button>
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
                  Tipo de Vínculo
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
                    {{ formatarTipoVinculo(advogado.tipo_vinculo) }}
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
                      v-if="advogado.tipo_vinculo === 'socio'"
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
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import Button from './Button.vue'
import ButtonEdit from './ButtonEdit.vue'
import ButtonDelete from './ButtonDelete.vue'
import Search from './Search.vue'

const supabase = useSupabaseClient()

// Define os emits no topo, antes de qualquer uso
const emit = defineEmits(['edit', 'delete', 'cadastrar-escritorio', 'cadastrar-socio', 'edit-escritorio', 'delete-escritorio'])

const abaAtiva = ref('socios')
const advogados = ref([])
const isLoading = ref(true)
const searchQuery = ref('')
const escritorios = ref([])
const isLoadingEscritorios = ref(true)
const searchQueryEscritorios = ref('')

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

// Função para formatar o tipo de vínculo
const formatarTipoVinculo = (tipoVinculo) => {
  if (!tipoVinculo) return '-'
  
  const tipos = {
    'socio': 'Sócio',
    'associado': 'Associado',
    'parceiro': 'Parceiro'
  }
  
  return tipos[tipoVinculo] || tipoVinculo
}

// Funções para cadastro em cada aba
const handleCadastrarEscritorio = () => {
  emit('cadastrar-escritorio')
}

const handleCadastrarSocio = () => {
  emit('cadastrar-socio')
}

// Busca os escritórios do banco de dados
const fetchEscritorios = async () => {
  isLoadingEscritorios.value = true
  
  try {
    const { data, error } = await supabase
      .from('escritorios')
      .select('*')
      .order('nome', { ascending: true })

    if (error) {
      console.error('Erro ao buscar escritórios:', error)
      escritorios.value = []
      return
    }

    escritorios.value = data || []
  } catch (error) {
    console.error('Erro inesperado ao buscar escritórios:', error)
    escritorios.value = []
  } finally {
    isLoadingEscritorios.value = false
  }
}

// Filtra os escritórios baseado na pesquisa
const filteredEscritorios = computed(() => {
  if (!searchQueryEscritorios.value || searchQueryEscritorios.value.trim() === '') {
    return escritorios.value
  }

  const query = searchQueryEscritorios.value.toLowerCase().trim()
  
  return escritorios.value.filter(escritorio => {
    const nome = (escritorio.nome || '').toLowerCase()
    const nomeFantasia = (escritorio.nome_fantasia || '').toLowerCase()
    const cnpj = (escritorio.cnpj || '').replace(/\D/g, '').toLowerCase()
    const email = (escritorio.email || '').toLowerCase()
    const telefone = (escritorio.telefone || '').toLowerCase()
    const cidade = (escritorio.cidade || '').toLowerCase()
    const estado = (escritorio.estado || '').toLowerCase()
    
    return nome.includes(query) || 
           nomeFantasia.includes(query) ||
           cnpj.includes(query) ||
           email.includes(query) ||
           telefone.includes(query) ||
           cidade.includes(query) ||
           estado.includes(query)
  })
})

// Handler para pesquisa de escritórios
const handleSearchEscritorios = (value) => {
  searchQueryEscritorios.value = value
}

// Função para editar escritório
const handleEditEscritorio = (escritorio) => {
  emit('edit-escritorio', escritorio)
}

// Função para excluir escritório
const handleDeleteEscritorio = (escritorio) => {
  emit('delete-escritorio', escritorio)
}

// Função para formatar CNPJ
const formatarCNPJ = (cnpj) => {
  if (!cnpj) return null
  const cnpjLimpo = cnpj.replace(/\D/g, '')
  if (cnpjLimpo.length !== 14) return cnpj
  return cnpjLimpo.replace(/^(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})$/, '$1.$2.$3/$4-$5')
}

// Função para formatar tipo de escritório
const formatarTipoEscritorio = (tipo) => {
  if (!tipo) return '-'
  return tipo === 'PROPRIO' ? 'Próprio' : 'Externo'
}

// Função para formatar localização
const formatarLocalizacao = (cidade, estado) => {
  if (cidade && estado) {
    return `${cidade}, ${estado}`
  }
  if (cidade) return cidade
  if (estado) return estado
  return '-'
}

// Expõe os métodos para uso externo (ref)
// Deve estar após todas as funções serem definidas
defineExpose({
  fetchAdvogados,
  fetchEscritorios
})

// Busca os advogados quando o componente é montado
onMounted(() => {
  fetchAdvogados()
  fetchEscritorios()
})
</script>
