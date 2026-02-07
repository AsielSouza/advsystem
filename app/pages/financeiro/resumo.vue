<template>
  <div class="h-full w-full bg-gray-50 py-4 sm:py-8 px-4 sm:px-6 overflow-y-auto">
    <div class="max-w-7xl mx-auto w-full">
      <!-- Cabeçalho -->
      <div class="mb-8">
        <div class="flex items-center justify-between mb-4">
          <ButtonBack @click="handleVoltar" />
        </div>
        <h1 class="text-3xl font-bold text-gray-900 mb-2">
          Visão geral por período
        </h1>
        <p class="text-gray-600">
          Totais por data de pagamento (entrada no caixa), com divisão Sócios e Advogados parceiros, por mês
        </p>
      </div>

      <!-- Filtro por período (data de pagamento) -->
      <div class="mb-8">
        <p class="text-sm font-semibold text-gray-800 mb-3">Período (data de pagamento)</p>
        <FiltroPeriodo v-model="periodo" />
      </div>

      <!-- Loading -->
      <div v-if="isLoading" class="flex justify-center py-12">
        <div class="text-center">
          <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600 mb-4"></div>
          <p class="text-gray-600">Carregando dados...</p>
        </div>
      </div>

      <template v-else>
        <!-- Cards resumo do período -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-8">
          <Card shadow="sm" :hover="false">
            <div class="flex items-center justify-between mb-2">
              <p class="text-sm font-medium text-gray-500">Total no período</p>
              <div class="h-10 w-10 rounded-full bg-primary-100 flex items-center justify-center">
                <svg class="h-5 w-5 text-primary-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </div>
            </div>
            <p class="text-2xl font-bold text-gray-900">{{ formatCurrency(totaisPeriodo.total) }}</p>
            <p class="text-xs text-gray-500 mt-1">Valores pagos no período (entrada no caixa)</p>
          </Card>

          <Card shadow="sm" :hover="false">
            <div class="flex items-center justify-between mb-2">
              <p class="text-sm font-medium text-gray-500">Sócios</p>
              <div class="h-10 w-10 rounded-full bg-blue-100 flex items-center justify-center">
                <svg class="h-5 w-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z" />
                </svg>
              </div>
            </div>
            <p class="text-2xl font-bold text-gray-900">{{ formatCurrency(totaisPeriodo.socios) }}</p>
            <p class="text-xs text-gray-500 mt-1">Parte dos honorários dos sócios</p>
          </Card>

          <Card shadow="sm" :hover="false">
            <div class="flex items-center justify-between mb-2">
              <p class="text-sm font-medium text-gray-500">Advogados parceiros</p>
              <div class="h-10 w-10 rounded-full bg-emerald-100 flex items-center justify-center">
                <svg class="h-5 w-5 text-emerald-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2 2v2m4 6h.01M5 20h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                </svg>
              </div>
            </div>
            <p class="text-2xl font-bold text-gray-900">{{ formatCurrency(totaisPeriodo.parceiros) }}</p>
            <p class="text-xs text-gray-500 mt-1">Parte dos honorários dos parceiros</p>
          </Card>
        </div>

        <!-- Tabela por mês -->
        <div class="bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden">
          <div class="px-4 py-3 border-b border-gray-200 bg-gray-50">
            <h2 class="text-lg font-semibold text-gray-900">Detalhamento por mês</h2>
            <p class="text-sm text-gray-500">Valores considerados pela data de pagamento — nome e valor por sócio e por advogado parceiro</p>
          </div>
          <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
              <thead class="bg-gray-50">
                <tr>
                  <th scope="col" class="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                    Mês
                  </th>
                  <th scope="col" class="px-4 py-3 text-right text-xs font-semibold text-gray-700 uppercase tracking-wider">
                    Total
                  </th>
                  <th scope="col" class="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                    Sócios (nome e valor)
                  </th>
                  <th scope="col" class="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                    Advogados parceiros (nome e valor)
                  </th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200">
                <tr
                  v-for="linha in resumoPorMes"
                  :key="linha.mesKey"
                  class="hover:bg-gray-50"
                >
                  <td class="px-4 py-3 whitespace-nowrap text-sm font-medium text-gray-900">
                    {{ linha.mesLabel }}
                  </td>
                  <td class="px-4 py-3 whitespace-nowrap text-sm text-right text-gray-900">
                    {{ formatCurrency(linha.total) }}
                  </td>
                  <td class="px-4 py-3 text-sm text-gray-700 align-top">
                    <div v-if="linha.sociosDetalhe.length" class="space-y-1">
                      <div
                        v-for="(item, idx) in linha.sociosDetalhe"
                        :key="'s-' + idx"
                        class="flex justify-between gap-4"
                      >
                        <span class="font-medium text-gray-800">{{ item.nome }}</span>
                        <span class="text-right whitespace-nowrap">{{ formatCurrency(item.valor) }}</span>
                      </div>
                    </div>
                    <span v-else class="text-gray-400">—</span>
                  </td>
                  <td class="px-4 py-3 text-sm text-gray-700 align-top">
                    <div v-if="linha.parceirosDetalhe.length" class="space-y-1">
                      <div
                        v-for="(item, idx) in linha.parceirosDetalhe"
                        :key="'p-' + idx"
                        class="flex justify-between gap-4"
                      >
                        <span class="font-medium text-gray-800">{{ item.nome }}</span>
                        <span class="text-right whitespace-nowrap">{{ formatCurrency(item.valor) }}</span>
                      </div>
                    </div>
                    <span v-else class="text-gray-400">—</span>
                  </td>
                </tr>
                <tr v-if="resumoPorMes.length === 0">
                  <td colspan="4" class="px-4 py-8 text-center text-gray-500">
                    Nenhum pagamento no período selecionado.
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </template>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import ButtonBack from '../../components/ButtonBack.vue'
import Card from '../../components/Card.vue'
import FiltroPeriodo from '../../components/FiltroPeriodo.vue'

definePageMeta({
  layout: 'default'
})

const router = useRouter()
const supabase = useSupabaseClient()

const periodo = ref({
  dataInicial: getPrimeiroDiaMes(),
  dataFinal: getUltimoDiaMes()
})

const isLoading = ref(false)
const parcelasFiltradas = ref([])
const honorariosMap = ref({})

function getPrimeiroDiaMes() {
  const d = new Date()
  d.setDate(1)
  return d.toISOString().slice(0, 10)
}

function getUltimoDiaMes() {
  const d = new Date()
  d.setMonth(d.getMonth() + 1, 0)
  return d.toISOString().slice(0, 10)
}

async function carregarDados() {
  const dataInicial = periodo.value?.dataInicial
  const dataFinal = periodo.value?.dataFinal
  if (!dataInicial || !dataFinal) return

  isLoading.value = true
  try {
    const { data: parcelas, error: errParcelas } = await supabase
      .from('honorarios_parcelas')
      .select('id, honorario_id, valor_pago_parcela, data_pagamento')
      .not('data_pagamento', 'is', null)
      .gte('data_pagamento', dataInicial)
      .lte('data_pagamento', dataFinal)

    if (errParcelas) {
      console.error('Erro ao buscar parcelas:', errParcelas)
      parcelasFiltradas.value = []
      return
    }

    const lista = parcelas || []
    parcelasFiltradas.value = lista

    const honorarioIds = [...new Set(lista.map((p) => p.honorario_id).filter(Boolean))]
    if (honorarioIds.length === 0) {
      honorariosMap.value = {}
      return
    }

    const { data: honorarios, error: errHonorarios } = await supabase
      .from('honorarios')
      .select('id, percentual_socios, percentual_parceiros, advogado_responsavel_id')
      .in('id', honorarioIds)

    if (errHonorarios) {
      console.error('Erro ao buscar honorários:', errHonorarios)
      honorariosMap.value = {}
      return
    }

    const { data: sociosRows } = await supabase
      .from('honorarios_socios')
      .select('honorario_id, nome_advogado, percentual_valor')
      .in('honorario_id', honorarioIds)

    const { data: parceirosRows } = await supabase
      .from('honorarios_parceiros')
      .select('honorario_id, nome_advogado, percentual_valor')
      .in('honorario_id', honorarioIds)

    const advogadoIds = [...new Set((honorarios || []).map((h) => h.advogado_responsavel_id).filter(Boolean))]
    let advogadosMap = {}
    if (advogadoIds.length > 0) {
      const { data: advogados } = await supabase
        .from('advogados')
        .select('id, nome')
        .in('id', advogadoIds)
      advogadosMap = (advogados || []).reduce((acc, a) => ({ ...acc, [a.id]: a.nome || '' }), {})
    }

    const sociosPorHonorario = {}
    for (const s of sociosRows || []) {
      if (!sociosPorHonorario[s.honorario_id]) sociosPorHonorario[s.honorario_id] = []
      sociosPorHonorario[s.honorario_id].push({
        nome: s.nome_advogado || 'Sócio',
        percentual_valor: parseFloat(s.percentual_valor) || 0
      })
    }
    const parceirosPorHonorario = {}
    for (const p of parceirosRows || []) {
      if (!parceirosPorHonorario[p.honorario_id]) parceirosPorHonorario[p.honorario_id] = []
      parceirosPorHonorario[p.honorario_id].push({
        nome: p.nome_advogado || 'Parceiro',
        percentual_valor: parseFloat(p.percentual_valor) || 0
      })
    }

    const map = {}
    for (const h of honorarios || []) {
      const socios = sociosPorHonorario[h.id] || []
      const parceiros = parceirosPorHonorario[h.id] || []
      const advogadoNome = h.advogado_responsavel_id ? (advogadosMap[h.advogado_responsavel_id] || 'Advogado responsável') : null
      map[h.id] = {
        percentual_socios: parseFloat(h.percentual_socios) ?? 100,
        percentual_parceiros: parseFloat(h.percentual_parceiros) ?? 0,
        socios,
        parceiros,
        advogado_responsavel_nome: advogadoNome
      }
    }
    honorariosMap.value = map
  } finally {
    isLoading.value = false
  }
}

const totaisPeriodo = computed(() => {
  const parcelas = parcelasFiltradas.value
  const map = honorariosMap.value
  let total = 0
  let socios = 0
  let parceiros = 0
  for (const p of parcelas) {
    const valor = parseFloat(p.valor_pago_parcela) || 0
    const h = map[p.honorario_id]
    const pSocios = h ? h.percentual_socios / 100 : 1
    const pParceiros = h ? h.percentual_parceiros / 100 : 0
    total += valor
    socios += valor * pSocios
    parceiros += valor * pParceiros
  }
  return { total, socios, parceiros }
})

const resumoPorMes = computed(() => {
  const parcelas = parcelasFiltradas.value
  const map = honorariosMap.value
  const porMes = {}
  for (const p of parcelas) {
    const dataPag = p.data_pagamento
    if (!dataPag) continue
    const mesKey = dataPag.slice(0, 7)
    if (!porMes[mesKey]) {
      porMes[mesKey] = { total: 0, socios: 0, parceiros: 0, porSocio: {}, porParceiro: {} }
    }
    const valor = parseFloat(p.valor_pago_parcela) || 0
    const h = map[p.honorario_id]
    const pSocios = h ? h.percentual_socios / 100 : 1
    const pParceiros = h ? h.percentual_parceiros / 100 : 0
    const valorSocios = valor * pSocios
    const valorParceiros = valor * pParceiros

    porMes[mesKey].total += valor
    porMes[mesKey].socios += valorSocios
    porMes[mesKey].parceiros += valorParceiros

    if (h?.socios?.length) {
      const sumPct = h.socios.reduce((s, x) => s + (x.percentual_valor || 0), 0) || 1
      for (const s of h.socios) {
        const nome = s.nome || 'Sócio'
        const v = valorSocios * ((s.percentual_valor || 0) / sumPct)
        porMes[mesKey].porSocio[nome] = (porMes[mesKey].porSocio[nome] || 0) + v
      }
    } else if (valorSocios > 0 && h?.advogado_responsavel_nome) {
      const nome = h.advogado_responsavel_nome
      porMes[mesKey].porSocio[nome] = (porMes[mesKey].porSocio[nome] || 0) + valorSocios
    }

    if (h?.parceiros?.length) {
      for (const pct of h.parceiros) {
        const nome = pct.nome || 'Parceiro'
        const v = valorParceiros * ((pct.percentual_valor || 0) / 100)
        porMes[mesKey].porParceiro[nome] = (porMes[mesKey].porParceiro[nome] || 0) + v
      }
    }
  }
  const meses = Object.keys(porMes).sort()
  return meses.map((mesKey) => {
    const [ano, mes] = mesKey.split('-')
    const mesLabel = new Date(Number(ano), Number(mes) - 1, 1).toLocaleDateString('pt-BR', {
      month: 'long',
      year: 'numeric'
    })
    const row = porMes[mesKey]
    const sociosDetalhe = Object.entries(row.porSocio || {})
      .filter(([, v]) => v > 0)
      .map(([nome, valor]) => ({ nome, valor }))
      .sort((a, b) => b.valor - a.valor)
    const parceirosDetalhe = Object.entries(row.porParceiro || {})
      .filter(([, v]) => v > 0)
      .map(([nome, valor]) => ({ nome, valor }))
      .sort((a, b) => b.valor - a.valor)
    return {
      mesKey,
      mesLabel: mesLabel.charAt(0).toUpperCase() + mesLabel.slice(1),
      total: row.total,
      socios: row.socios,
      parceiros: row.parceiros,
      sociosDetalhe,
      parceirosDetalhe
    }
  })
})

function formatCurrency(value) {
  if (value == null || (typeof value !== 'number' && isNaN(parseFloat(value)))) return 'R$ 0,00'
  const num = typeof value === 'string' ? parseFloat(value) : value
  return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(num)
}

function handleVoltar() {
  router.push('/financeiro')
}

watch(periodo, () => carregarDados(), { deep: true })

carregarDados()
</script>
