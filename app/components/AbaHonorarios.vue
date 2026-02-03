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

    <!-- Divisão explícita: Sócios / Advogado Responsável -->
    <section
      v-if="listaSocios.length > 0"
      class="rounded-xl border-2 border-primary-200 bg-primary-50/30 p-6 space-y-4"
    >
      <TabelaHonorariosTotais
        titulo-secao="Sócios / Advogado Responsável"
        :items="listaSocios"
        variante="socio"
      />
    </section>

    <!-- Divisão explícita: Advogados Parceiros -->
    <section
      v-if="listaParceiros.length > 0"
      class="rounded-xl border-2 border-emerald-200 bg-emerald-50/30 p-6 space-y-4"
    >
      <TabelaHonorariosTotais
        titulo-secao="Advogados Parceiros"
        :items="listaParceiros"
        variante="parceiro"
      />
    </section>

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
import TabelaHonorariosTotais from './TabelaHonorariosTotais.vue'

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

onMounted(() => {
  fetchParceiros()
})

watch(() => props.honorario?.id, () => {
  fetchParceiros()
})
</script>
