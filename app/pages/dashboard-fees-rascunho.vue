<template>
  <div class="h-full w-full bg-gray-50 py-4 sm:py-8 px-4 sm:px-6 overflow-y-auto">
    <div class="max-w-7xl mx-auto w-full">
      <!-- Cabeçalho da página -->
      <div class="mb-8">
        <div class="flex items-center justify-between mb-4">
          <ButtonBack @click="handleVoltar" />
          <button
            @click="irParaPrincipal"
            class="px-4 py-2 bg-primary-600 hover:bg-primary-700 text-white text-sm font-medium rounded-lg transition-colors"
          >
            Principal
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

      <!-- Lista de Honorários -->
      <div v-else-if="honorarios.length > 0" class="space-y-6">
        <div
          v-for="honorario in honorarios"
          :key="honorario.id"
          class="bg-white rounded-xl shadow-lg border border-gray-200 overflow-hidden"
        >
          <!-- Cabeçalho do Honorário -->
          <div class="bg-gradient-to-r from-primary-50 to-primary-100/50 px-6 py-4 border-b border-gray-200">
            <div class="flex items-center justify-between">
              <div class="flex-1">
                <h2 class="text-xl font-bold text-gray-900 mb-1">
                  Honorário #{{ honorario.numero_processo }}
                </h2>
                <div class="flex items-center gap-4 text-sm text-gray-600">
                  <span>ID: {{ honorario.id.substring(0, 8) }}...</span>
                  <span>•</span>
                  <span>Contratação: {{ formatDate(honorario.data_contratacao) }}</span>
                  <span>•</span>
                  <span
                    :class="[
                      'px-2 py-1 rounded-full text-xs font-medium',
                      honorario.status === 'pago' ? 'bg-green-100 text-green-800' :
                      honorario.status === 'pendente' ? 'bg-yellow-100 text-yellow-800' :
                      'bg-red-100 text-red-800'
                    ]"
                  >
                    {{ formatStatus(honorario.status) }}
                  </span>
                </div>
              </div>
              <button
                @click="editarHonorario(honorario.id)"
                class="px-4 py-2 bg-primary-600 hover:bg-primary-700 text-white text-sm font-medium rounded-lg transition-colors"
              >
                Editar
              </button>
            </div>
          </div>

          <!-- Informações Principais -->
          <div class="p-6 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 border-b border-gray-200">
            <div>
              <p class="text-xs font-medium text-gray-500 uppercase mb-1">Cliente</p>
              <p class="text-sm font-semibold text-gray-900">
                {{ getClienteNome(honorario) }}
              </p>
            </div>
            <div>
              <p class="text-xs font-medium text-gray-500 uppercase mb-1">Valor Total</p>
              <p class="text-sm font-semibold text-gray-900">
                {{ formatCurrency(honorario.valor_total) }}
              </p>
            </div>
            <div>
              <p class="text-xs font-medium text-gray-500 uppercase mb-1">Forma de Pagamento</p>
              <p class="text-sm font-semibold text-gray-900">
                {{ formatFormaPagamento(honorario.forma_pagamento) }}
              </p>
            </div>
            <div>
              <p class="text-xs font-medium text-gray-500 uppercase mb-1">Parte no Processo</p>
              <p class="text-sm font-semibold text-gray-900">
                {{ formatParte(honorario.parte) }}
              </p>
            </div>
          </div>

          <!-- Movimentações Financeiras (Parcelas) -->
          <div class="p-6 border-b border-gray-200">
            <div class="flex items-center justify-between mb-4">
              <h3 class="text-lg font-semibold text-gray-900">Movimentações Financeiras</h3>
              <span class="text-sm text-gray-500">
                {{ getParcelasCount(honorario.id) }} parcela(s)
              </span>
            </div>
            <div v-if="getParcelas(honorario.id).length > 0" class="overflow-x-auto">
              <table class="w-full text-sm">
                <thead>
                  <tr class="border-b border-gray-200">
                    <th class="text-left py-2 px-3 font-semibold text-gray-700">Parcela</th>
                    <th class="text-left py-2 px-3 font-semibold text-gray-700">Valor</th>
                    <th class="text-left py-2 px-3 font-semibold text-gray-700">Valor Pago</th>
                    <th class="text-left py-2 px-3 font-semibold text-gray-700">Saldo</th>
                    <th class="text-left py-2 px-3 font-semibold text-gray-700">Vencimento</th>
                    <th class="text-left py-2 px-3 font-semibold text-gray-700">Status</th>
                    <th class="text-left py-2 px-3 font-semibold text-gray-700">Ações</th>
                  </tr>
                </thead>
                <tbody>
                  <tr
                    v-for="parcela in getParcelas(honorario.id)"
                    :key="parcela.id"
                    class="border-b border-gray-100 hover:bg-gray-50"
                  >
                    <td class="py-3 px-3 text-gray-900 font-medium">
                      #{{ parcela.numero_da_parcela }}
                    </td>
                    <td class="py-3 px-3 text-gray-900">
                      {{ formatCurrency(parcela.valor_parcela) }}
                    </td>
                    <td class="py-3 px-3 text-gray-900">
                      {{ formatCurrency(parcela.valor_pago_parcela) }}
                    </td>
                    <td class="py-3 px-3">
                      <span
                        :class="[
                          'font-medium',
                          getSaldoDevedor(parcela) > 0 ? 'text-danger-600' : 'text-success-600'
                        ]"
                      >
                        {{ formatCurrency(getSaldoDevedor(parcela)) }}
                      </span>
                    </td>
                    <td class="py-3 px-3 text-gray-600">
                      {{ formatDate(parcela.data_vencimento) }}
                    </td>
                    <td class="py-3 px-3">
                      <span
                        :class="[
                          'px-2 py-1 rounded-full text-xs font-medium',
                          parcela.status === 'paga' ? 'bg-green-100 text-green-800' :
                          'bg-yellow-100 text-yellow-800'
                        ]"
                      >
                        {{ formatStatus(parcela.status) }}
                      </span>
                    </td>
                    <td class="py-3 px-3">
                      <button
                        @click="editarParcela(parcela.id)"
                        class="text-primary-600 hover:text-primary-700 text-sm font-medium"
                      >
                        Editar
                      </button>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
            <div v-else class="text-center py-4 text-gray-500 text-sm">
              Nenhuma movimentação financeira registrada
            </div>
          </div>

          <!-- Divisão entre Sócios -->
          <div v-if="honorario.dividir_entre_socios" class="p-6 border-b border-gray-200">
            <div class="flex items-center justify-between mb-4">
              <h3 class="text-lg font-semibold text-gray-900">Divisão entre Sócios</h3>
              <span class="text-sm text-gray-500">
                {{ getSociosCount(honorario.id) }} advogado(s)
              </span>
            </div>
            <div v-if="getSocios(honorario.id).length > 0" class="space-y-3">
              <div
                v-for="socio in getSocios(honorario.id)"
                :key="socio.id"
                class="flex items-center justify-between p-3 bg-gray-50 rounded-lg border border-gray-200"
              >
                <div class="flex-1">
                  <p class="text-sm font-semibold text-gray-900">{{ socio.nome_advogado }}</p>
                  <p class="text-xs text-gray-500 mt-0.5">Percentual: {{ socio.percentual_valor }}%</p>
                </div>
                <div class="text-right">
                  <p class="text-sm font-semibold text-gray-900">
                    {{ formatCurrency(calcularValorSocio(honorario.valor_total, socio.percentual_valor)) }}
                  </p>
                  <p class="text-xs text-gray-500">Valor do advogado</p>
                </div>
                <button
                  @click="editarSocio(socio.id)"
                  class="ml-4 text-primary-600 hover:text-primary-700 text-sm font-medium"
                >
                  Editar
                </button>
              </div>
              <div class="mt-4 p-3 bg-primary-50 rounded-lg border border-primary-200">
                <div class="flex items-center justify-between">
                  <span class="text-sm font-semibold text-gray-900">Total de Percentuais:</span>
                  <span
                    :class="[
                      'text-sm font-bold',
                      getTotalPercentuais(honorario.id) === 100 ? 'text-success-600' : 'text-danger-600'
                    ]"
                  >
                    {{ getTotalPercentuais(honorario.id).toFixed(2) }}%
                  </span>
                </div>
              </div>
            </div>
            <div v-else class="text-center py-4 text-gray-500 text-sm">
              Nenhum sócio cadastrado para este honorário
            </div>
          </div>

          <!-- Advogado Responsável (quando não divide) -->
          <div v-else class="p-6 border-b border-gray-200">
            <h3 class="text-lg font-semibold text-gray-900 mb-4">Advogado Responsável</h3>
            <div v-if="honorario.advogado_responsavel_id" class="flex items-center justify-between p-3 bg-gray-50 rounded-lg border border-gray-200">
              <div>
                <p class="text-sm font-semibold text-gray-900">
                  {{ getAdvogadoNome(honorario.advogado_responsavel_id) }}
                </p>
                <p class="text-xs text-gray-500 mt-0.5">Responsável único pelo honorário</p>
              </div>
              <button
                @click="editarAdvogadoResponsavel(honorario.id)"
                class="text-primary-600 hover:text-primary-700 text-sm font-medium"
              >
                Editar
              </button>
            </div>
            <div v-else class="text-center py-4 text-gray-500 text-sm">
              Nenhum advogado responsável definido
            </div>
          </div>

          <!-- Histórico -->
          <div class="p-6">
            <div class="flex items-center justify-between mb-4">
              <h3 class="text-lg font-semibold text-gray-900">Histórico</h3>
              <button
                @click="adicionarHistorico(honorario.id)"
                class="px-3 py-1.5 bg-primary-600 hover:bg-primary-700 text-white text-xs font-medium rounded-lg transition-colors"
              >
                + Adicionar
              </button>
            </div>
            <div v-if="getHistorico(honorario.id).length > 0" class="space-y-3">
              <div
                v-for="(historico, index) in getHistorico(honorario.id)"
                :key="historico.id"
                class="p-4 bg-gray-50 rounded-lg border border-gray-200"
              >
                <div class="flex items-start justify-between mb-2">
                  <span class="text-xs text-gray-500">
                    {{ formatDateTime(historico.created_at) }}
                  </span>
                  <button
                    @click="editarHistorico(historico.id)"
                    class="text-primary-600 hover:text-primary-700 text-xs font-medium"
                  >
                    Editar
                  </button>
                </div>
                <p class="text-sm text-gray-900 whitespace-pre-wrap">{{ historico.historico }}</p>
              </div>
            </div>
            <div v-else class="text-center py-4 text-gray-500 text-sm">
              Nenhum histórico registrado
            </div>
          </div>
        </div>
      </div>

      <!-- Mensagem quando não há honorários -->
      <div v-else class="text-center py-12">
        <p class="text-gray-500 text-lg mb-4">Nenhum honorário cadastrado</p>
        <button
          @click="novoHonorario"
          class="px-6 py-3 bg-primary-600 hover:bg-primary-700 text-white font-medium rounded-lg transition-colors"
        >
          Cadastrar Primeiro Honorário
        </button>
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
import { ref, onMounted, computed } from 'vue'
import ButtonBack from '../components/ButtonBack.vue'
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
const honorarios = ref([])
const parcelas = ref([])
const socios = ref([])
const historico = ref([])
const advogados = ref([])
const clientesPF = ref([])
const clientesPJ = ref([])

// Funções de formatação
const formatCurrency = (value) => {
  if (!value && value !== 0) return 'R$ 0,00'
  const numValue = typeof value === 'string' ? parseFloat(value) : value
  if (isNaN(numValue)) return 'R$ 0,00'
  return new Intl.NumberFormat('pt-BR', {
    style: 'currency',
    currency: 'BRL'
  }).format(numValue)
}

const formatDate = (date) => {
  if (!date) return '-'
  const d = new Date(date)
  return d.toLocaleDateString('pt-BR')
}

const formatDateTime = (dateTime) => {
  if (!dateTime) return '-'
  const d = new Date(dateTime)
  return d.toLocaleString('pt-BR')
}

const formatStatus = (status) => {
  const statusMap = {
    'pendente': 'Pendente',
    'pago': 'Pago',
    'cancelado': 'Cancelado',
    'paga': 'Paga'
  }
  return statusMap[status] || status
}

const formatFormaPagamento = (forma) => {
  const formasMap = {
    'avista': 'À Vista',
    'parcelado': 'Parcelado'
  }
  return formasMap[forma] || forma
}

const formatParte = (parte) => {
  const partesMap = {
    'autor': 'Autor',
    'reu': 'Réu',
    'terceiro_interessado': 'Terceiro Interessado',
    'outro': 'Outro'
  }
  return partesMap[parte] || parte
}

// Funções auxiliares
const getClienteNome = (honorario) => {
  if (honorario.cliente_pessoa_fisica_id) {
    const cliente = clientesPF.value.find(c => c.id === honorario.cliente_pessoa_fisica_id)
    return cliente?.nome_completo || 'Cliente não encontrado'
  } else if (honorario.cliente_pessoa_juridica_id) {
    const cliente = clientesPJ.value.find(c => c.id === honorario.cliente_pessoa_juridica_id)
    return cliente?.razao_social || 'Cliente não encontrado'
  }
  return 'Não informado'
}

const getParcelas = (honorarioId) => {
  return parcelas.value.filter(p => p.honorario_id === honorarioId)
    .sort((a, b) => a.numero_da_parcela - b.numero_da_parcela)
}

const getParcelasCount = (honorarioId) => {
  return getParcelas(honorarioId).length
}

const getSaldoDevedor = (parcela) => {
  return parseFloat(parcela.valor_parcela) - parseFloat(parcela.valor_pago_parcela || 0)
}

const getSocios = (honorarioId) => {
  return socios.value.filter(s => s.honorario_id === honorarioId)
}

const getSociosCount = (honorarioId) => {
  return getSocios(honorarioId).length
}

const calcularValorSocio = (valorTotal, percentual) => {
  return (parseFloat(valorTotal) * parseFloat(percentual)) / 100
}

const getTotalPercentuais = (honorarioId) => {
  const sociosHonorario = getSocios(honorarioId)
  return sociosHonorario.reduce((total, socio) => total + parseFloat(socio.percentual_valor || 0), 0)
}

const getAdvogadoNome = (advogadoId) => {
  const advogado = advogados.value.find(a => a.id === advogadoId)
  return advogado?.nome || 'Advogado não encontrado'
}

const getHistorico = (honorarioId) => {
  return historico.value.filter(h => h.honorario_id === honorarioId)
    .sort((a, b) => new Date(b.created_at) - new Date(a.created_at))
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

    honorarios.value = data || []
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

const fetchHistorico = async () => {
  try {
    const { data, error } = await supabase
      .from('honorarios_historico')
      .select('*')
      .order('created_at', { ascending: false })

    if (error) {
      console.error('Erro ao buscar histórico:', error)
      return
    }

    historico.value = data || []
  } catch (error) {
    console.error('Erro inesperado ao buscar histórico:', error)
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

// Funções de ação (placeholders - serão implementadas)
const editarHonorario = (id) => {
  router.push(`/register-fees?id=${id}`)
}

const editarParcela = (id) => {
  // TODO: Implementar modal ou página para editar parcela
  toast.info('Funcionalidade de edição de parcela será implementada em breve.', 3000)
}

const editarSocio = (id) => {
  // TODO: Implementar modal ou página para editar sócio
  toast.info('Funcionalidade de edição de sócio será implementada em breve.', 3000)
}

const editarAdvogadoResponsavel = (honorarioId) => {
  router.push(`/register-fees?id=${honorarioId}`)
}

const editarHistorico = (id) => {
  // TODO: Implementar modal ou página para editar histórico
  toast.info('Funcionalidade de edição de histórico será implementada em breve.', 3000)
}

const adicionarHistorico = (honorarioId) => {
  // TODO: Implementar modal para adicionar histórico
  toast.info('Funcionalidade de adicionar histórico será implementada em breve.', 3000)
}

const novoHonorario = () => {
  router.push('/register-fees')
}

const handleVoltar = () => {
  router.push('/honorarios')
}

const irParaPrincipal = () => {
  router.push('/dashboard-fees')
}

// Carrega dados ao montar
onMounted(async () => {
  isLoading.value = true
  try {
    await Promise.all([
      fetchHonorarios(),
      fetchParcelas(),
      fetchSocios(),
      fetchHistorico(),
      fetchAdvogados(),
      fetchClientes()
    ])
  } finally {
    isLoading.value = false
  }
})
</script>

