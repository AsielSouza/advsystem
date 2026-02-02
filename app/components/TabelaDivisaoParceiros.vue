<template>
  <div class="w-full space-y-4">
    <!-- Botão para adicionar advogado parceiro -->
    <div class="flex justify-end">
      <Button
        v-if="!mostrarDropdownAdicionar && opcoesAdvogadosDisponiveis.length > 0"
        variant="primary"
        size="sm"
        @click="mostrarDropdownAdicionar = true"
      >
        + Adicionar advogado parceiro
      </Button>
      
      <!-- Dropdown para adicionar advogado -->
      <div v-else-if="mostrarDropdownAdicionar" class="w-full space-y-2">
        <Dropdown
          id="adicionar-advogado-parceiro"
          v-model="advogadoSelecionado"
          label="Selecione o advogado parceiro"
          placeholder="Escolha um advogado"
          :options="opcoesAdvogadosDisponiveis"
          @update:modelValue="handleAdicionarAdvogado"
        />
        <div class="flex justify-end">
          <Button
            variant="outline"
            size="sm"
            @click="handleCancelarAdicionar"
          >
            Cancelar
          </Button>
        </div>
      </div>
      
      <p
        v-if="!mostrarDropdownAdicionar && opcoesAdvogadosDisponiveis.length === 0 && parceiros.length > 0"
        class="text-sm text-gray-500 text-right"
      >
        Todos os advogados parceiros já foram adicionados
      </p>
    </div>

    <!-- Tabela de Divisão -->
    <div v-if="parceiros.length > 0" class="bg-white rounded-xl border border-gray-200 overflow-hidden">
      <div class="overflow-x-auto">
        <table class="w-full">
          <thead class="bg-gray-50 border-b border-gray-200">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                Advogado
              </th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                Percentual (%)
              </th>
              <th class="px-6 py-3 text-right text-xs font-semibold text-gray-700 uppercase tracking-wider">
                Ações
              </th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr
              v-for="(parceiro, index) in parceiros"
              :key="parceiro.id"
              class="hover:bg-gray-50 transition-colors"
            >
              <td class="px-6 py-4 whitespace-nowrap">
                <span class="text-sm font-medium text-gray-900">{{ parceiro.nome }}</span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="flex items-center gap-2">
                  <Input
                    :id="`percentual-parceiro-${parceiro.id}`"
                    v-model="parceiro.percentual"
                    type="number"
                    placeholder="0,00"
                    class="w-32"
                    @blur="handlePercentualBlur(index)"
                  />
                  <span class="text-sm text-gray-500">%</span>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-right">
                <button
                  type="button"
                  class="text-danger-600 hover:text-danger-800 text-sm font-medium"
                  @click="handleRemoverAdvogado(index)"
                >
                  Remover
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      
      <!-- Total de percentuais -->
      <div class="px-6 py-4 bg-gray-50 border-t border-gray-200">
        <div class="flex items-center justify-between">
          <span class="text-sm font-semibold text-gray-700">Total:</span>
          <span
            :class="[
              'text-sm font-bold',
              totalPercentual === 100 ? 'text-green-600' : 'text-danger-600'
            ]"
          >
            {{ totalPercentual.toFixed(2) }}%
          </span>
        </div>
        <p
          v-if="totalPercentual !== 100"
          class="mt-1 text-xs text-danger-600"
        >
          O total deve ser exatamente 100%
        </p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted, nextTick } from 'vue'
import Button from './Button.vue'
import Dropdown from './Dropdown.vue'
import Input from './Input.vue'

const props = defineProps({
  modelValue: {
    type: Array,
    default: () => []
  },
  error: {
    type: String,
    default: ''
  }
})

const emit = defineEmits(['update:modelValue', 'change'])

const supabase = useSupabaseClient()

// Estados locais
const parceiros = ref([])
const mostrarDropdownAdicionar = ref(false)
const advogadoSelecionado = ref('')
const todosAdvogados = ref([])
const isUpdatingFromProps = ref(false)

// Busca advogados parceiros e associados ativos
const fetchAdvogadosParceiros = async () => {
  try {
    const { data, error } = await supabase
      .from('advogados')
      .select('id, nome, oab_numero, oab_uf')
      .in('tipo_vinculo', ['associado', 'parceiro'])
      .eq('ativo', true)
      .order('nome', { ascending: true })

    if (error) {
      console.error('Erro ao buscar advogados parceiros:', error)
      todosAdvogados.value = []
      return
    }

    todosAdvogados.value = data || []
  } catch (error) {
    console.error('Erro inesperado ao buscar advogados parceiros:', error)
    todosAdvogados.value = []
  }
}

// Opções de advogados disponíveis (não adicionados ainda)
const opcoesAdvogadosDisponiveis = computed(() => {
  const idsAdicionados = parceiros.value.map(p => p.id_advogado)
  return todosAdvogados.value
    .filter(adv => !idsAdicionados.includes(adv.id))
    .map(adv => ({
      value: adv.id.toString(),
      label: `${adv.nome}${adv.oab_numero ? ` - OAB ${adv.oab_numero}/${adv.oab_uf || ''}` : ''}`
    }))
})

// Total de percentuais
const totalPercentual = computed(() => {
  return parceiros.value.reduce((total, parceiro) => {
    const percentual = parseFloat(parceiro.percentual) || 0
    return total + percentual
  }, 0)
})

// Distribui percentuais igualmente entre todos os parceiros
const distribuirPercentuais = () => {
  if (parceiros.value.length === 0) return
  
  const quantidade = parceiros.value.length
  
  if (quantidade === 1) {
    parceiros.value[0].percentual = '100.00'
    emitChange()
    return
  }
  
  const percentualBase = 100 / quantidade
  const percentualArredondado = Math.floor(percentualBase * 100) / 100
  const totalDistribuido = percentualArredondado * (quantidade - 1)
  const resto = 100 - totalDistribuido
  
  parceiros.value.forEach((parceiro, index) => {
    if (index === 0) {
      parceiro.percentual = resto.toFixed(2)
    } else {
      parceiro.percentual = percentualArredondado.toFixed(2)
    }
  })
  
  emitChange()
}

// Balanceia percentuais quando um é alterado
const balancearPercentuais = (indiceAlterado, novoValor) => {
  if (parceiros.value.length <= 1) {
    parceiros.value[0].percentual = Math.min(100, Math.max(0, novoValor)).toFixed(2)
    emitChange()
    return
  }
  
  const valorAlterado = parseFloat(novoValor) || 0
  const valorLimitado = Math.min(100, Math.max(0, valorAlterado))
  
  const totalOutros = parceiros.value.reduce((total, parceiro, index) => {
    if (index === indiceAlterado) return total
    return total + (parseFloat(parceiro.percentual) || 0)
  }, 0)
  
  const totalComNovoValor = valorLimitado + totalOutros
  
  if (totalComNovoValor > 100) {
    const fator = (100 - valorLimitado) / totalOutros
    parceiros.value.forEach((parceiro, index) => {
      if (index !== indiceAlterado) {
        const novoPercentual = (parseFloat(parceiro.percentual) || 0) * fator
        parceiro.percentual = Math.max(0, novoPercentual).toFixed(2)
      }
    })
  } else {
    const faltaPara100 = 100 - valorLimitado - totalOutros
    
    if (faltaPara100 !== 0 && Math.abs(faltaPara100) > 0.01) {
      const outrosParceiros = parceiros.value.filter((_, index) => index !== indiceAlterado)
      const percentualPorParceiro = faltaPara100 / outrosParceiros.length
      
      outrosParceiros.forEach((parceiro) => {
        const indiceOriginal = parceiros.value.findIndex(p => p.id_advogado === parceiro.id_advogado)
        if (indiceOriginal !== -1) {
          const novoPercentual = (parseFloat(parceiro.percentual) || 0) + percentualPorParceiro
          parceiros.value[indiceOriginal].percentual = Math.max(0, novoPercentual).toFixed(2)
        }
      })
    }
  }
  
  parceiros.value[indiceAlterado].percentual = valorLimitado.toFixed(2)
  
  const totalFinal = parceiros.value.reduce((total, parceiro) => {
    return total + (parseFloat(parceiro.percentual) || 0)
  }, 0)
  
  if (Math.abs(totalFinal - 100) > 0.01) {
    const diferenca = 100 - totalFinal
    const primeiroPercentual = parseFloat(parceiros.value[0].percentual) + diferenca
    parceiros.value[0].percentual = Math.max(0, primeiroPercentual).toFixed(2)
  }
  
  emitChange()
}

// Handler para cancelar adicionar advogado
const handleCancelarAdicionar = () => {
  advogadoSelecionado.value = ''
  mostrarDropdownAdicionar.value = false
}

// Handler para adicionar advogado
const handleAdicionarAdvogado = (advogadoId) => {
  if (!advogadoId) return
  
  const advogado = todosAdvogados.value.find(a => a.id.toString() === advogadoId.toString())
  if (!advogado) return
  
  if (parceiros.value.some(p => p.id_advogado === advogado.id)) {
    return
  }
  
  parceiros.value.push({
    id: `temp-${Date.now()}-${Math.random()}`,
    id_advogado: advogado.id,
    nome: advogado.nome,
    percentual: '0.00'
  })
  
  distribuirPercentuais()
  
  advogadoSelecionado.value = ''
  mostrarDropdownAdicionar.value = false
}

// Handler para remover advogado
const handleRemoverAdvogado = (indice) => {
  parceiros.value.splice(indice, 1)
  
  if (parceiros.value.length > 0) {
    distribuirPercentuais()
  } else {
    emitChange()
  }
}

// Handler para blur do percentual (balanceamento e validação)
const handlePercentualBlur = (indice) => {
  const novoValor = parseFloat(parceiros.value[indice].percentual) || 0
  
  balancearPercentuais(indice, novoValor)
  
  const totalAtual = totalPercentual.value
  
  if (Math.abs(totalAtual - 100) > 0.01) {
    if (totalAtual > 100) {
      const fator = 100 / totalAtual
      parceiros.value.forEach(parceiro => {
        parceiro.percentual = (parseFloat(parceiro.percentual) * fator).toFixed(2)
      })
    } else {
      const diferenca = 100 - totalAtual
      const primeiroPercentual = parseFloat(parceiros.value[0].percentual) + diferenca
      parceiros.value[0].percentual = Math.max(0, primeiroPercentual).toFixed(2)
    }
  }
  
  emitChange()
}

// Função para emitir mudanças
const emitChange = () => {
  const dadosFormatados = parceiros.value.map(parceiro => ({
    id_advogado: parceiro.id_advogado,
    nome: parceiro.nome,
    percentual: parseFloat(parceiro.percentual) || 0
  }))
  
  emit('update:modelValue', dadosFormatados)
  emit('change', dadosFormatados)
}

// Watch para atualizar quando modelValue mudar externamente
watch(() => props.modelValue, (newValue) => {
  if (!newValue || !Array.isArray(newValue) || isUpdatingFromProps.value) return
  
  const hasChanges = JSON.stringify(parceiros.value.map(p => ({
    id_advogado: p.id_advogado,
    percentual: p.percentual
  }))) !== JSON.stringify(newValue.map(p => ({
    id_advogado: p.id_advogado,
    percentual: p.percentual?.toString() || '0'
  })))
  
  if (hasChanges) {
    isUpdatingFromProps.value = true
    
    parceiros.value = newValue.map(item => {
      const advogado = todosAdvogados.value.find(a => a.id.toString() === item.id_advogado?.toString())
      return {
        id: `temp-${item.id_advogado}-${Date.now()}`,
        id_advogado: item.id_advogado,
        nome: item.nome || advogado?.nome || '',
        percentual: (item.percentual || 0).toFixed(2)
      }
    })
    
    nextTick(() => {
      isUpdatingFromProps.value = false
    })
  }
}, { immediate: true, deep: true })

// Carrega advogados ao montar
onMounted(async () => {
  await fetchAdvogadosParceiros()
  
  if (props.modelValue && props.modelValue.length > 0) {
    parceiros.value = props.modelValue.map(item => {
      const advogado = todosAdvogados.value.find(a => a.id.toString() === item.id_advogado?.toString())
      return {
        id: `temp-${item.id_advogado}-${Date.now()}`,
        id_advogado: item.id_advogado,
        nome: item.nome || advogado?.nome || '',
        percentual: (item.percentual || 0).toFixed(2)
      }
    })
  }
})
</script>
