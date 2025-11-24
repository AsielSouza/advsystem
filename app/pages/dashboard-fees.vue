<template>
  <div class="h-full w-full bg-gray-50 py-4 sm:py-8 px-4 sm:px-6 overflow-y-auto">
    <div class="max-w-7xl mx-auto w-full">
      <!-- Cabeçalho da página -->
      <div class="mb-8">
        <div class="flex items-center justify-between mb-4">
          <ButtonBack @click="handleVoltar" />
          <button
            @click="irParaRascunho"
            class="px-4 py-2 bg-gray-600 hover:bg-gray-700 text-white text-sm font-medium rounded-lg transition-colors"
          >
            Rascunho
          </button>
        </div>
        <h1 class="text-3xl font-bold text-gray-900 mb-2">
          Dashboard de Honorários
        </h1>
        <p class="text-gray-600">
          Visualize e gerencie toda a movimentação dos honorários
        </p>
      </div>

      <!-- Loading -->
      <div v-if="isLoading" class="flex items-center justify-center py-12">
        <div class="text-center">
          <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600 mb-4"></div>
          <p class="text-gray-600">Carregando honorários...</p>
        </div>
      </div>

      <!-- Conteúdo -->
      <div v-else>
        <!-- Campo de Pesquisa -->
        <div class="mb-6">
          <CampoPesquisa
            v-model="termoPesquisa"
            placeholder="Pesquisar por nome do cliente ou número do processo..."
            @search="handleSearch"
          />
        </div>

        <!-- Lista de Honorários -->
        <ListaHonorarios
          :honorarios="honorariosFiltrados"
          @editar="handleEditar"
        />
      </div>

      <!-- Toast de Notificação -->
      <Toast
        v-if="toast.showToast.value"
        :message="toast.toastMessage.value"
        :type="toast.toastType.value"
        :duration="toast.toastDuration.value"
        @close="toast.close"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import ButtonBack from '../components/ButtonBack.vue'
import CampoPesquisa from '../components/CampoPesquisa.vue'
import ListaHonorarios from '../components/ListaHonorarios.vue'
import Toast from '../components/Toast.vue'

// Define o layout padrão para esta página
definePageMeta({
  layout: 'default'
})

const router = useRouter()
const supabase = useSupabaseClient()
const toast = useToast()

// Estados
const isLoading = ref(true)
const termoPesquisa = ref('')
const honorariosRaw = ref([])
const parcelas = ref([])
const clientesPF = ref([])
const clientesPJ = ref([])
const advogados = ref([])
const socios = ref([])

// Honorários formatados e filtrados
const honorariosFiltrados = computed(() => {
  let honorariosFormatados = formatarHonorarios(honorariosRaw.value)
  
  // Aplicar filtro de pesquisa
  if (termoPesquisa.value.trim()) {
    const termo = termoPesquisa.value.toLowerCase().trim()
    honorariosFormatados = honorariosFormatados.filter(honorario => {
      const nomeCliente = (honorario.cliente_nome || '').toLowerCase()
      const numeroProcesso = (honorario.numero_processo || '').toLowerCase()
      return nomeCliente.includes(termo) || numeroProcesso.includes(termo)
    })
  }
  
  return honorariosFormatados
})

// Função para formatar honorários com dados relacionados
const formatarHonorarios = (honorarios) => {
  return honorarios.map(honorario => {
    // Buscar nome do cliente
    let clienteNome = 'Não informado'
    if (honorario.cliente_pessoa_fisica_id) {
      const cliente = clientesPF.value.find(c => c.id === honorario.cliente_pessoa_fisica_id)
      clienteNome = cliente?.nome_completo || 'Cliente não encontrado'
    } else if (honorario.cliente_pessoa_juridica_id) {
      const cliente = clientesPJ.value.find(c => c.id === honorario.cliente_pessoa_juridica_id)
      clienteNome = cliente?.razao_social || 'Cliente não encontrado'
    }

    // Buscar parcelas do honorário
    const parcelasHonorario = parcelas.value.filter(p => p.honorario_id === honorario.id)
      .sort((a, b) => a.numero_da_parcela - b.numero_da_parcela)

    // Buscar informações de advogados
    let advogadoResponsavel = null
    let advogadosSocios = []

    if (honorario.dividir_entre_socios) {
      // Buscar sócios do honorário
      const sociosHonorario = socios.value.filter(s => s.honorario_id === honorario.id)
      advogadosSocios = sociosHonorario.map(socio => {
        return {
          nome: socio.nome_advogado,
          percentual: socio.percentual_valor
        }
      })
    } else if (honorario.advogado_responsavel_id) {
      // Buscar advogado responsável único
      const advogado = advogados.value.find(a => a.id === honorario.advogado_responsavel_id)
      advogadoResponsavel = advogado?.nome || 'Advogado não encontrado'
    }

    return {
      ...honorario,
      cliente_nome: clienteNome,
      parcelas: parcelasHonorario,
      advogado_responsavel: advogadoResponsavel,
      advogados_socios: advogadosSocios
    }
  })
}

// Funções de busca
const fetchHonorarios = async () => {
  try {
    const { data, error } = await supabase
      .from('honorarios')
      .select('*')
      .order('created_at', { ascending: false })

    if (error) {
      console.error('Erro ao buscar honorários:', error)
      toast.showError('Erro ao carregar honorários.', 5000)
      return
    }

    honorariosRaw.value = data || []
  } catch (error) {
    console.error('Erro inesperado ao buscar honorários:', error)
    toast.showError('Erro inesperado ao carregar honorários.', 5000)
  }
}

const fetchParcelas = async () => {
  try {
    const { data, error } = await supabase
      .from('honorarios_parcelas')
      .select('*')
      .order('numero_da_parcela', { ascending: true })

    if (error) {
      console.error('Erro ao buscar parcelas:', error)
      return
    }

    parcelas.value = data || []
  } catch (error) {
    console.error('Erro inesperado ao buscar parcelas:', error)
  }
}

const fetchClientes = async () => {
  try {
    // Busca clientes pessoa física
    const { data: dataFisica, error: errorFisica } = await supabase
      .from('clientes_pessoa_fisica')
      .select('id, nome_completo')

    // Busca clientes pessoa jurídica
    const { data: dataJuridica, error: errorJuridica } = await supabase
      .from('clientes_pessoa_juridica')
      .select('id, razao_social')

    if (errorFisica) {
      console.error('Erro ao buscar clientes pessoa física:', errorFisica)
    }

    if (errorJuridica) {
      console.error('Erro ao buscar clientes pessoa jurídica:', errorJuridica)
    }

    clientesPF.value = dataFisica || []
    clientesPJ.value = dataJuridica || []
  } catch (error) {
    console.error('Erro inesperado ao buscar clientes:', error)
  }
}

const fetchAdvogados = async () => {
  try {
    const { data, error } = await supabase
      .from('advogados')
      .select('id, nome')

    if (error) {
      console.error('Erro ao buscar advogados:', error)
      return
    }

    advogados.value = data || []
  } catch (error) {
    console.error('Erro inesperado ao buscar advogados:', error)
  }
}

const fetchSocios = async () => {
  try {
    const { data, error } = await supabase
      .from('honorarios_socios')
      .select('*')

    if (error) {
      console.error('Erro ao buscar sócios:', error)
      return
    }

    socios.value = data || []
  } catch (error) {
    console.error('Erro inesperado ao buscar sócios:', error)
  }
}

// Handlers
const handleVoltar = () => {
  router.push('/honorarios')
}

const irParaRascunho = () => {
  router.push('/dashboard-fees-rascunho')
}

const handleSearch = (termo) => {
  // A busca é reativa através do computed honorariosFiltrados
  // Não precisa fazer nada aqui, apenas manter para compatibilidade
}

const handleEditar = (id) => {
  router.push(`/register-fees?id=${id}`)
}

// Carrega dados ao montar
onMounted(async () => {
  isLoading.value = true
  try {
    await Promise.all([
      fetchHonorarios(),
      fetchParcelas(),
      fetchClientes(),
      fetchAdvogados(),
      fetchSocios()
    ])
  } finally {
    isLoading.value = false
  }
})
</script>
