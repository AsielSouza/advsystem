<template>
  <div class="w-full space-y-4">
    <!-- Botão para adicionar advogado -->
    <div class="flex justify-end">
      <Button
        v-if="!mostrarDropdownAdicionar && opcoesAdvogadosDisponiveis.length > 0"
        variant="primary"
        size="sm"
        @click="mostrarDropdownAdicionar = true"
      >
        + Adicionar advogado
      </Button>
      
      <!-- Dropdown para adicionar advogado -->
      <div v-else-if="mostrarDropdownAdicionar" class="w-full space-y-2">
        <Dropdown
          id="adicionar-advogado"
          v-model="advogadoSelecionado"
          label="Selecione o advogado"
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
        v-if="!mostrarDropdownAdicionar && opcoesAdvogadosDisponiveis.length === 0 && socios.length > 0"
        class="text-sm text-gray-500 text-right"
      >
        Todos os advogados sócios já foram adicionados
      </p>
    </div>

    <!-- Tabela de Divisão -->
    <div v-if="socios.length > 0" class="bg-white rounded-xl border border-gray-200 overflow-hidden">
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
              v-for="(socio, index) in socios"
              :key="socio.id"
              class="hover:bg-gray-50 transition-colors"
            >
              <td class="px-6 py-4 whitespace-nowrap">
                <span class="text-sm font-medium text-gray-900">{{ socio.nome }}</span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="flex items-center gap-2">
                  <Input
                    :id="`percentual-${socio.id}`"
                    v-model="socio.percentual"
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
const socios = ref([])
const mostrarDropdownAdicionar = ref(false)
const advogadoSelecionado = ref('')
const todosAdvogados = ref([])
const isUpdatingFromProps = ref(false)

// Busca advogados sócios ativos
const fetchAdvogadosSocios = async () => {
  try {
    const { data, error } = await supabase
      .from('advogados')
      .select('id, nome, oab_numero, oab_uf')
      .eq('tipo_vinculo', 'socio')
      .eq('ativo', true)
      .order('nome', { ascending: true })

    if (error) {
      console.error('Erro ao buscar advogados sócios:', error)
      todosAdvogados.value = []
      return
    }

    todosAdvogados.value = data || []
  } catch (error) {
    console.error('Erro inesperado ao buscar advogados sócios:', error)
    todosAdvogados.value = []
  }
}

// Opções de advogados disponíveis (não adicionados ainda)
const opcoesAdvogadosDisponiveis = computed(() => {
  const idsAdicionados = socios.value.map(s => s.id_advogado)
  return todosAdvogados.value
    .filter(adv => !idsAdicionados.includes(adv.id))
    .map(adv => ({
      value: adv.id.toString(),
      label: `${adv.nome}${adv.oab_numero ? ` - OAB ${adv.oab_numero}/${adv.oab_uf || ''}` : ''}`
    }))
})

// Total de percentuais
const totalPercentual = computed(() => {
  return socios.value.reduce((total, socio) => {
    const percentual = parseFloat(socio.percentual) || 0
    return total + percentual
  }, 0)
})

// Distribui percentuais igualmente entre todos os sócios
const distribuirPercentuais = () => {
  if (socios.value.length === 0) return
  
  const quantidade = socios.value.length
  
  if (quantidade === 1) {
    socios.value[0].percentual = '100.00'
    emitChange()
    return
  }
  
  // Calcula o percentual base (100 / quantidade)
  const percentualBase = 100 / quantidade
  // Arredonda para 2 casas decimais (para baixo)
  const percentualArredondado = Math.floor(percentualBase * 100) / 100
  
  // Calcula quanto falta para 100% após distribuir igualmente
  const totalDistribuido = percentualArredondado * (quantidade - 1)
  const resto = 100 - totalDistribuido
  
  // O primeiro sócio recebe o resto para bater exatamente 100%
  socios.value.forEach((socio, index) => {
    if (index === 0) {
      socio.percentual = resto.toFixed(2)
    } else {
      socio.percentual = percentualArredondado.toFixed(2)
    }
  })
  
  emitChange()
}

// Balanceia percentuais quando um é alterado
const balancearPercentuais = (indiceAlterado, novoValor) => {
  if (socios.value.length <= 1) {
    socios.value[0].percentual = Math.min(100, Math.max(0, novoValor)).toFixed(2)
    emitChange()
    return
  }
  
  const valorAlterado = parseFloat(novoValor) || 0
  // Limita o valor entre 0 e 100
  const valorLimitado = Math.min(100, Math.max(0, valorAlterado))
  
  // Calcula o total atual dos outros sócios (sem o valor que está sendo alterado)
  const totalOutros = socios.value.reduce((total, socio, index) => {
    if (index === indiceAlterado) return total
    return total + (parseFloat(socio.percentual) || 0)
  }, 0)
  
  // Se o novo valor + total dos outros ultrapassar 100%, ajusta proporcionalmente
  const totalComNovoValor = valorLimitado + totalOutros
  
  if (totalComNovoValor > 100) {
    // Ajusta proporcionalmente todos os outros sócios
    const fator = (100 - valorLimitado) / totalOutros
    socios.value.forEach((socio, index) => {
      if (index !== indiceAlterado) {
        const novoPercentual = (parseFloat(socio.percentual) || 0) * fator
        socio.percentual = Math.max(0, novoPercentual).toFixed(2)
      }
    })
  } else {
    // Distribui o que falta para 100% entre os outros sócios
    const faltaPara100 = 100 - valorLimitado - totalOutros
    
    if (faltaPara100 !== 0 && Math.abs(faltaPara100) > 0.01) {
      const outrosSocios = socios.value.filter((_, index) => index !== indiceAlterado)
      const percentualPorSocio = faltaPara100 / outrosSocios.length
      
      outrosSocios.forEach((socio) => {
        const indiceOriginal = socios.value.findIndex(s => s.id_advogado === socio.id_advogado)
        if (indiceOriginal !== -1) {
          const novoPercentual = (parseFloat(socio.percentual) || 0) + percentualPorSocio
          socios.value[indiceOriginal].percentual = Math.max(0, novoPercentual).toFixed(2)
        }
      })
    }
  }
  
  // Atualiza o valor alterado
  socios.value[indiceAlterado].percentual = valorLimitado.toFixed(2)
  
  // Garante que o total seja exatamente 100% (ajuste final)
  const totalFinal = socios.value.reduce((total, socio) => {
    return total + (parseFloat(socio.percentual) || 0)
  }, 0)
  
  if (Math.abs(totalFinal - 100) > 0.01) {
    // Ajusta o primeiro sócio para bater 100%
    const diferenca = 100 - totalFinal
    const primeiroPercentual = parseFloat(socios.value[0].percentual) + diferenca
    socios.value[0].percentual = Math.max(0, primeiroPercentual).toFixed(2)
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
  
  // Verifica se já não foi adicionado
  if (socios.value.some(s => s.id_advogado === advogado.id)) {
    return
  }
  
  // Adiciona o sócio com percentual inicial 0
  socios.value.push({
    id: `temp-${Date.now()}-${Math.random()}`,
    id_advogado: advogado.id,
    nome: advogado.nome,
    percentual: '0.00'
  })
  
  // Distribui percentuais automaticamente
  distribuirPercentuais()
  
  // Limpa e esconde o dropdown
  advogadoSelecionado.value = ''
  mostrarDropdownAdicionar.value = false
}

// Handler para remover advogado
const handleRemoverAdvogado = (indice) => {
  socios.value.splice(indice, 1)
  
  // Redistribui percentuais se ainda houver sócios
  if (socios.value.length > 0) {
    distribuirPercentuais()
  } else {
    emitChange()
  }
}

// Handler para blur do percentual (balanceamento e validação)
const handlePercentualBlur = (indice) => {
  const novoValor = parseFloat(socios.value[indice].percentual) || 0
  
  // Balanceia os percentuais quando o usuário sai do campo
  balancearPercentuais(indice, novoValor)
  
  // Garante que o total seja exatamente 100% (ajuste final)
  const totalAtual = totalPercentual.value
  
  if (Math.abs(totalAtual - 100) > 0.01) {
    if (totalAtual > 100) {
      // Ajusta proporcionalmente se ultrapassar
      const fator = 100 / totalAtual
      socios.value.forEach(socio => {
        socio.percentual = (parseFloat(socio.percentual) * fator).toFixed(2)
      })
    } else {
      // Ajusta o primeiro sócio para bater 100%
      const diferenca = 100 - totalAtual
      const primeiroPercentual = parseFloat(socios.value[0].percentual) + diferenca
      socios.value[0].percentual = Math.max(0, primeiroPercentual).toFixed(2)
    }
  }
  
  emitChange()
}

// Função para emitir mudanças
const emitChange = () => {
  const dadosFormatados = socios.value.map(socio => ({
    id_advogado: socio.id_advogado,
    nome: socio.nome,
    percentual: parseFloat(socio.percentual) || 0
  }))
  
  emit('update:modelValue', dadosFormatados)
  emit('change', dadosFormatados)
}

// Watch para atualizar quando modelValue mudar externamente
watch(() => props.modelValue, (newValue) => {
  if (!newValue || !Array.isArray(newValue) || isUpdatingFromProps.value) return
  
  const hasChanges = JSON.stringify(socios.value.map(s => ({
    id_advogado: s.id_advogado,
    percentual: s.percentual
  }))) !== JSON.stringify(newValue.map(s => ({
    id_advogado: s.id_advogado,
    percentual: s.percentual?.toString() || '0'
  })))
  
  if (hasChanges) {
    isUpdatingFromProps.value = true
    
    // Mapeia os dados recebidos para o formato interno
    socios.value = newValue.map(item => {
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
  await fetchAdvogadosSocios()
  
  // Se há valores iniciais, carrega eles
  if (props.modelValue && props.modelValue.length > 0) {
    socios.value = props.modelValue.map(item => {
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
