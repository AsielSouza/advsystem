<template>
  <div class="w-full space-y-6">
    <!-- Quadrantes de Resumo Financeiro -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
      <!-- Pendente -->
      <Card shadow="sm" :hover="false">
        <div class="flex items-center justify-between mb-2">
          <p class="text-sm font-medium text-gray-500">Pendente</p>
          <div class="h-10 w-10 rounded-full bg-yellow-100 flex items-center justify-center">
            <svg class="h-5 w-5 text-yellow-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
        </div>
        <p class="text-2xl font-bold text-gray-900">{{ formatCurrency(totalPendente) }}</p>
        <p class="text-xs text-gray-500 mt-1">Parcelas não pagas e não em atraso</p>
      </Card>

      <!-- Paga -->
      <Card shadow="sm" :hover="false">
        <div class="flex items-center justify-between mb-2">
          <p class="text-sm font-medium text-gray-500">Paga</p>
          <div class="h-10 w-10 rounded-full bg-green-100 flex items-center justify-center">
            <svg class="h-5 w-5 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
            </svg>
          </div>
        </div>
        <p class="text-2xl font-bold text-gray-900">{{ formatCurrency(totalPaga) }}</p>
        <p class="text-xs text-gray-500 mt-1">Valores já pagos</p>
      </Card>

      <!-- Em Atraso -->
      <Card shadow="sm" :hover="false">
        <div class="flex items-center justify-between mb-2">
          <p class="text-sm font-medium text-gray-500">Em Atraso</p>
          <div class="h-10 w-10 rounded-full bg-red-100 flex items-center justify-center">
            <svg class="h-5 w-5 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
            </svg>
          </div>
        </div>
        <p class="text-2xl font-bold text-gray-900">{{ formatCurrency(totalAtraso) }}</p>
        <p class="text-xs text-gray-500 mt-1">Valores em atraso</p>
      </Card>

      <!-- Saldo Devedor -->
      <Card shadow="sm" :hover="false">
        <div class="flex items-center justify-between mb-2">
          <p class="text-sm font-medium text-gray-500">Saldo Devedor</p>
          <div class="h-10 w-10 rounded-full bg-orange-100 flex items-center justify-center">
            <svg class="h-5 w-5 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z" />
            </svg>
          </div>
        </div>
        <p class="text-2xl font-bold text-gray-900">{{ formatCurrency(saldoDevedor) }}</p>
        <p class="text-xs text-gray-500 mt-1">Em Atraso + Pendentes</p>
      </Card>
    </div>

    <!-- Tabela de Parcelas -->
    <TabelaParcelas
      :parcelas="parcelas"
      @pagar="abrirModalPagamento"
    />

    <!-- Modal de Pagamento -->
    <ModalPagamento
      v-model="modalPagamentoAberto"
      :parcela="parcelaSelecionada"
      :honorario="honorario"
      :todas-parcelas="parcelas"
      @salvo="handlePagamentoSalvo"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import Card from './Card.vue'
import TabelaParcelas from './TabelaParcelas.vue'
import ModalPagamento from './ModalPagamento.vue'

const props = defineProps({
  honorario: {
    type: Object,
    required: true
  }
})

const supabase = useSupabaseClient()

const parcelas = ref([])
const modalPagamentoAberto = ref(false)
const parcelaSelecionada = ref(null)
const isLoading = ref(false)

// Buscar parcelas do honorário
const fetchParcelas = async () => {
  if (!props.honorario?.id) return

  isLoading.value = true
  try {
    const { data, error } = await supabase
      .from('honorarios_parcelas')
      .select('*')
      .eq('honorario_id', props.honorario.id)
      .order('data_vencimento', { ascending: true })

    if (error) {
      console.error('Erro ao buscar parcelas:', error)
      return
    }

    parcelas.value = data || []
  } catch (error) {
    console.error('Erro inesperado ao buscar parcelas:', error)
  } finally {
    isLoading.value = false
  }
}



// Calcular totais
const totalPendente = computed(() => {
  const hojeDate = new Date()
  hojeDate.setHours(0, 0, 0, 0)
  
  return parcelas.value
    .filter(p => {
      const status = p.status || 'pendente'
      const dataVencimento = new Date(p.data_vencimento)
      dataVencimento.setHours(0, 0, 0, 0)
      const valorParcela = parseFloat(p.valor_parcela) || 0
      const valorPago = parseFloat(p.valor_pago_parcela) || 0
      const saldo = valorParcela - valorPago
      
      return status === 'pendente' && dataVencimento >= hojeDate && saldo > 0
    })
    .reduce((sum, p) => {
      const valorParcela = parseFloat(p.valor_parcela) || 0
      const valorPago = parseFloat(p.valor_pago_parcela) || 0
      return sum + (valorParcela - valorPago)
    }, 0)
})

const totalPaga = computed(() => {
  // Soma todos os valores pagos (valor_pago_parcela) de todas as parcelas do honorário
  return parcelas.value.reduce((sum, p) => {
    return sum + (parseFloat(p.valor_pago_parcela) || 0)
  }, 0)
})

const totalAtraso = computed(() => {
  const hojeDate = new Date()
  hojeDate.setHours(0, 0, 0, 0)
  
  return parcelas.value
    .filter(p => {
      const status = p.status || 'pendente'
      const dataVencimento = new Date(p.data_vencimento)
      dataVencimento.setHours(0, 0, 0, 0)
      const valorParcela = parseFloat(p.valor_parcela) || 0
      const valorPago = parseFloat(p.valor_pago_parcela) || 0
      const saldo = valorParcela - valorPago
      
      return status === 'pendente' && dataVencimento < hojeDate && saldo > 0
    })
    .reduce((sum, p) => {
      const valorParcela = parseFloat(p.valor_parcela) || 0
      const valorPago = parseFloat(p.valor_pago_parcela) || 0
      return sum + (valorParcela - valorPago)
    }, 0)
})

const saldoDevedor = computed(() => {
  return totalAtraso.value + totalPendente.value
})

// Formatação
const formatCurrency = (value) => {
  if (!value && value !== 0) return 'R$ 0,00'
  const numValue = typeof value === 'string' ? parseFloat(value) : value
  if (isNaN(numValue)) return 'R$ 0,00'
  return new Intl.NumberFormat('pt-BR', {
    style: 'currency',
    currency: 'BRL'
  }).format(numValue)
}


// Abrir modal de pagamento
const abrirModalPagamento = (parcela) => {
  parcelaSelecionada.value = parcela
  modalPagamentoAberto.value = true
}

const emit = defineEmits(['pagamento-salvo'])

// Handler quando pagamento é salvo
const handlePagamentoSalvo = () => {
  fetchParcelas()
  emit('pagamento-salvo')
}

// Buscar parcelas ao montar
onMounted(() => {
  fetchParcelas()
})

// Buscar parcelas quando honorário mudar
watch(() => props.honorario?.id, (newId) => {
  if (newId) {
    fetchParcelas()
  }
})
</script>
