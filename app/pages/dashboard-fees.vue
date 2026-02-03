<template>
  <div class="h-full w-full bg-gray-50 py-4 sm:py-8 px-4 sm:px-6 overflow-y-auto">
    <div class="max-w-7xl mx-auto w-full">
      <!-- Cabeçalho da página -->
      <div class="mb-8">
        <div class="flex items-center justify-between mb-4">
          <ButtonBack @click="handleVoltar" />
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
          @excluir="handleExcluir"
          @pagamento-salvo="handlePagamentoSalvo"
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
import { ref, computed, onMounted, watch } from 'vue'
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
const user = useSupabaseUser()

// Verificar autenticação e redirecionar se necessário
const checkAuthentication = async () => {
  const { data: { user: currentUser } } = await supabase.auth.getUser()
  
  if (!currentUser) {
    console.warn('⚠️ Usuário não autenticado. Redirecionando para login...')
    toast.showError('Você precisa estar autenticado para acessar esta página.', 3000)
    await router.push('/login')
    return false
  }
  
  return true
}

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
  if (!honorarios || honorarios.length === 0) {
    console.log('formatarHonorarios: Nenhum honorário para formatar')
    return []
  }
  
  console.log('formatarHonorarios: Formatando', honorarios.length, 'honorários')
  
  return honorarios.map(honorario => {
    try {
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
    } catch (error) {
      console.error('Erro ao formatar honorário:', honorario.id, error)
      // Retorna o honorário mesmo com erro para não perder dados
      return {
        ...honorario,
        cliente_nome: 'Erro ao carregar',
        parcelas: [],
        advogado_responsavel: null,
        advogados_socios: []
      }
    }
  })
}

// Funções de busca
const fetchHonorarios = async () => {
  try {
    console.log('Iniciando busca de honorários...')
    
    // Verificar autenticação
    const { data: { user } } = await supabase.auth.getUser()
    console.log('Usuário autenticado:', user ? 'Sim' : 'Não')
    if (user) {
      console.log('ID do usuário:', user.id)
      console.log('Email do usuário:', user.email)
    }
    
    const { data, error } = await supabase
      .from('honorarios')
      .select('*')
      .order('created_at', { ascending: false })

    if (error) {
      console.error('Erro ao buscar honorários:', error)
      console.error('Detalhes do erro:', {
        code: error.code,
        message: error.message,
        details: error.details,
        hint: error.hint
      })
      toast.showError(`Erro ao carregar honorários: ${error.message}`, 5000)
      honorariosRaw.value = []
      return
    }

    console.log('Resposta da query:', { data, error })
    console.log('Quantidade de honorários retornados:', data?.length || 0)
    honorariosRaw.value = data || []
    console.log('Honorários buscados do banco:', honorariosRaw.value.length)
    
    // Se não houver honorários, informar ao usuário
    if (honorariosRaw.value.length === 0) {
      console.warn('⚠️ Nenhum honorário encontrado no banco de dados.')
      console.warn('Verifique:')
      console.warn('1. Se há honorários cadastrados no sistema')
      console.warn('2. Se há políticas RLS (Row Level Security) bloqueando a leitura')
      console.warn('3. Se o usuário tem permissão para acessar a tabela honorarios')
    }
  } catch (error) {
    console.error('Erro inesperado ao buscar honorários:', error)
    toast.showError('Erro inesperado ao carregar honorários.', 5000)
    honorariosRaw.value = []
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

const handleSearch = (termo) => {
  // A busca é reativa através do computed honorariosFiltrados
  // Não precisa fazer nada aqui, apenas manter para compatibilidade
}

const handleEditar = (id) => {
  router.push(`/register-fees?id=${id}`)
}

/** Chamado quando um pagamento é registrado na aba Financeiro; atualiza parcelas para refletir na tabela de honorários. */
const handlePagamentoSalvo = async () => {
  await fetchParcelas()
}

const handleExcluir = async (honorario) => {
  const processo = honorario.numero_processo || 'N/A'
  if (!confirm(`Deseja realmente excluir o honorário do processo #${processo}? Esta ação não pode ser desfeita.`)) {
    return
  }

  try {
    const { error } = await supabase
      .from('honorarios')
      .delete()
      .eq('id', honorario.id)

    if (error) {
      console.error('Erro ao excluir honorário:', error)
      toast.showError(error.message || 'Erro ao excluir honorário. Tente novamente.', 5000)
      return
    }

    toast.success('Honorário excluído com sucesso!', 3000)

    await Promise.all([
      fetchHonorarios(),
      fetchParcelas(),
      fetchSocios()
    ])
  } catch (err) {
    console.error('Erro inesperado ao excluir honorário:', err)
    toast.showError('Erro inesperado ao excluir. Tente novamente.', 5000)
  }
}

// Carrega dados ao montar
onMounted(async () => {
  // Verificar autenticação primeiro
  const isAuthenticated = await checkAuthentication()
  if (!isAuthenticated) {
    return // Redirecionamento já foi feito
  }
  
  isLoading.value = true
  try {
    await Promise.all([
      fetchHonorarios(),
      fetchParcelas(),
      fetchClientes(),
      fetchAdvogados(),
      fetchSocios()
    ])
  } catch (error) {
    console.error('Erro ao carregar dados:', error)
    toast.showError('Erro ao carregar dados do dashboard.', 5000)
  } finally {
    isLoading.value = false
  }
  
  // Debug: verificar se os dados foram carregados
  console.log('Honorários carregados:', honorariosRaw.value.length)
  console.log('Honorários formatados:', honorariosFiltrados.value.length)
})

// Observar mudanças no estado de autenticação
watch(user, async (newUser) => {
  if (!newUser) {
    // Se o usuário fizer logout, redirecionar para login
    await router.push('/login')
  }
}, { immediate: false })
</script>
