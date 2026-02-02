<template>
  <div class="w-full space-y-6">
    <!-- Legenda -->
    <div class="flex flex-wrap gap-4 p-4 bg-gray-50 rounded-xl border border-gray-200">
      <div class="flex items-center gap-2">
        <div class="w-3 h-3 rounded-full bg-primary-500" />
        <span class="text-sm text-gray-700">A receber — valor total do honorário que o advogado tem direito</span>
      </div>
      <div class="flex items-center gap-2">
        <div class="w-3 h-3 rounded-full bg-green-500" />
        <span class="text-sm text-gray-700">Disponível para resgate — valor já recebido (parcelas pagas)</span>
      </div>
      <div class="flex items-center gap-2">
        <div class="w-3 h-3 rounded-full bg-amber-400" />
        <span class="text-sm text-gray-700">Provisionado — aguardando pagamento das parcelas</span>
      </div>
    </div>

    <!-- Sócios / Advogado Responsável -->
    <div v-if="listaSocios.length > 0" class="space-y-4">
      <h4 class="text-sm font-semibold text-gray-800 uppercase tracking-wider flex items-center gap-2">
        <span class="w-8 h-8 rounded-lg bg-primary-100 flex items-center justify-center">
          <svg class="w-4 h-4 text-primary-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
          </svg>
        </span>
        Sócios / Advogado Responsável
      </h4>
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <div
          v-for="item in listaSocios"
          :key="item.id || item.nome"
          class="bg-white rounded-xl border border-gray-200 p-5 shadow-sm hover:shadow-md transition-shadow"
        >
          <div class="flex items-start justify-between mb-4">
            <div>
              <p class="font-semibold text-gray-900">{{ item.nome }}</p>
              <span class="inline-flex mt-1 px-2 py-0.5 text-xs font-medium rounded-full bg-primary-100 text-primary-800">
                Sócio
              </span>
            </div>
          </div>
          <div class="space-y-3">
            <div>
              <p class="text-xs font-medium text-gray-500 uppercase mb-0.5">A receber</p>
              <p class="text-lg font-bold text-primary-600">{{ formatCurrency(item.aReceber) }}</p>
            </div>
            <div>
              <p class="text-xs font-medium text-gray-500 uppercase mb-0.5">Disponível para resgate</p>
              <p class="text-lg font-bold text-green-600">{{ formatCurrency(item.disponivelResgate) }}</p>
            </div>
            <div>
              <p class="text-xs font-medium text-gray-500 uppercase mb-0.5">Provisionado</p>
              <p class="text-base font-semibold text-amber-600">{{ formatCurrency(item.provisionado) }}</p>
            </div>
          </div>
          <div class="mt-4 pt-4 border-t border-gray-100">
            <div class="h-2 rounded-full bg-gray-100 overflow-hidden">
              <div
                class="h-full rounded-full bg-green-500 transition-all"
                :style="{ width: percentualDisponivel(item) + '%' }"
              />
            </div>
            <p class="text-xs text-gray-500 mt-1">
              {{ percentualDisponivel(item).toFixed(1) }}% já disponível
            </p>
          </div>
        </div>
      </div>
    </div>

    <!-- Parceiros -->
    <div v-if="listaParceiros.length > 0" class="space-y-4">
      <h4 class="text-sm font-semibold text-gray-800 uppercase tracking-wider flex items-center gap-2">
        <span class="w-8 h-8 rounded-lg bg-emerald-100 flex items-center justify-center">
          <svg class="w-4 h-4 text-emerald-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2 2v2m4 6h.01M5 20h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z" />
          </svg>
        </span>
        Advogados Parceiros
      </h4>
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <div
          v-for="item in listaParceiros"
          :key="item.id || item.nome"
          class="bg-white rounded-xl border border-gray-200 p-5 shadow-sm hover:shadow-md transition-shadow"
        >
          <div class="flex items-start justify-between mb-4">
            <div>
              <p class="font-semibold text-gray-900">{{ item.nome }}</p>
              <span class="inline-flex mt-1 px-2 py-0.5 text-xs font-medium rounded-full bg-emerald-100 text-emerald-800">
                Parceiro
              </span>
            </div>
          </div>
          <div class="space-y-3">
            <div>
              <p class="text-xs font-medium text-gray-500 uppercase mb-0.5">A receber</p>
              <p class="text-lg font-bold text-primary-600">{{ formatCurrency(item.aReceber) }}</p>
            </div>
            <div>
              <p class="text-xs font-medium text-gray-500 uppercase mb-0.5">Disponível para resgate</p>
              <p class="text-lg font-bold text-green-600">{{ formatCurrency(item.disponivelResgate) }}</p>
            </div>
            <div>
              <p class="text-xs font-medium text-gray-500 uppercase mb-0.5">Provisionado</p>
              <p class="text-base font-semibold text-amber-600">{{ formatCurrency(item.provisionado) }}</p>
            </div>
          </div>
          <div class="mt-4 pt-4 border-t border-gray-100">
            <div class="h-2 rounded-full bg-gray-100 overflow-hidden">
              <div
                class="h-full rounded-full bg-green-500 transition-all"
                :style="{ width: percentualDisponivel(item) + '%' }"
              />
            </div>
            <p class="text-xs text-gray-500 mt-1">
              {{ percentualDisponivel(item).toFixed(1) }}% já disponível
            </p>
          </div>
        </div>
      </div>
    </div>

    <!-- Mensagem quando não há divisão -->
    <div
      v-if="listaSocios.length === 0 && listaParceiros.length === 0"
      class="p-12 text-center bg-gray-50 rounded-xl border border-gray-200"
    >
      <p class="text-gray-500">Nenhuma divisão de honorários configurada para este processo.</p>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'

const props = defineProps({
  honorario: {
    type: Object,
    required: true
  }
})

const supabase = useSupabaseClient()
const parceiros = ref([])

// Total já pago (soma do valor_pago_parcela de todas as parcelas)
const totalPago = computed(() => {
  const p = props.honorario?.parcelas || []
  return p.reduce((sum, parcela) => sum + (parseFloat(parcela.valor_pago_parcela) || 0), 0)
})

const valorTotal = computed(() => parseFloat(props.honorario?.valor_total) || 0)
const percentualSocios = computed(() => parseFloat(props.honorario?.percentual_socios) ?? 100)
const percentualParceiros = computed(() => parseFloat(props.honorario?.percentual_parceiros) ?? 0)
const dividirEntreParceiros = computed(() => props.honorario?.dividir_entre_parceiros === true)

// Buscar parceiros do honorário
const fetchParceiros = async () => {
  if (!props.honorario?.id || !dividirEntreParceiros.value) return

  try {
    const { data, error } = await supabase
      .from('honorarios_parceiros')
      .select('*')
      .eq('honorario_id', props.honorario.id)

    if (error) {
      console.error('Erro ao buscar parceiros:', error)
      parceiros.value = []
      return
    }

    parceiros.value = data || []
  } catch (err) {
    console.error('Erro inesperado ao buscar parceiros:', err)
    parceiros.value = []
  }
}

// Lista de sócios com valores calculados
const listaSocios = computed(() => {
  const honorario = props.honorario

  if (honorario?.dividir_entre_socios && honorario?.advogados_socios?.length) {
    const pSocios = percentualSocios.value / 100
    const valorGrupoSocios = valorTotal.value * pSocios
    const valorGrupoSociosPago = totalPago.value * pSocios

    return honorario.advogados_socios.map((s) => {
      const pct = (parseFloat(s.percentual) || 0) / 100
      const aReceber = valorGrupoSocios * pct
      const disponivelResgate = valorGrupoSociosPago * pct
      const provisionado = Math.max(0, aReceber - disponivelResgate)

      return {
        id: s.id_advogado || s.nome,
        nome: s.nome,
        aReceber,
        disponivelResgate,
        provisionado
      }
    })
  }

  if (honorario?.advogado_responsavel && !honorario?.dividir_entre_socios) {
    const aReceber = valorTotal.value
    const disponivelResgate = totalPago.value
    const provisionado = Math.max(0, aReceber - disponivelResgate)

    return [{
      id: 'responsavel',
      nome: honorario.advogado_responsavel,
      aReceber,
      disponivelResgate,
      provisionado
    }]
  }

  return []
})

// Lista de parceiros com valores calculados
const listaParceiros = computed(() => {
  if (!dividirEntreParceiros.value || parceiros.value.length === 0) return []

  const pParceiros = percentualParceiros.value / 100
  const valorGrupoParceiros = valorTotal.value * pParceiros
  const valorGrupoParceirosPago = totalPago.value * pParceiros

  return parceiros.value.map((p) => {
    const pct = (parseFloat(p.percentual_valor) || 0) / 100
    const aReceber = valorGrupoParceiros * pct
    const disponivelResgate = valorGrupoParceirosPago * pct
    const provisionado = Math.max(0, aReceber - disponivelResgate)

    return {
      id: p.id_advogado,
      nome: p.nome_advogado,
      aReceber,
      disponivelResgate,
      provisionado
    }
  })
})

const percentualDisponivel = (item) => {
  if (!item.aReceber || item.aReceber <= 0) return 0
  return Math.min(100, (item.disponivelResgate / item.aReceber) * 100)
}

const formatCurrency = (value) => {
  if (!value && value !== 0) return 'R$ 0,00'
  const num = typeof value === 'string' ? parseFloat(value) : value
  if (isNaN(num)) return 'R$ 0,00'
  return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(num)
}

onMounted(() => {
  fetchParceiros()
})

watch(() => props.honorario?.id, () => {
  fetchParceiros()
})
</script>
