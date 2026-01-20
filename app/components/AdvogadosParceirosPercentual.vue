<template>
  <div class="w-full">
    <label class="block text-sm font-semibold text-gray-800 mb-2.5 tracking-tight">
      Advogados Parceiros
      <span class="text-danger-500 ml-0.5">*</span>
    </label>

    <!-- Lista de Advogados Parceiros -->
    <div v-if="advogadosParceiros.length === 0" class="p-6 bg-gray-50 border border-gray-200 rounded-xl text-center">
      <p class="text-sm text-gray-500">
        Nenhum advogado parceiro ou associado ativo encontrado.
      </p>
    </div>

    <div v-else class="space-y-3">
      <!-- Tabela de Advogados -->
      <div class="border border-gray-200 rounded-xl overflow-hidden">
        <div class="overflow-x-auto">
          <table class="w-full">
            <thead class="bg-gray-50 border-b border-gray-200">
              <tr>
                <th class="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                  Advogado
                </th>
                <th class="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                  OAB
                </th>
                <th class="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                  Tipo de Vínculo
                </th>
                <th class="px-4 py-3 text-right text-xs font-semibold text-gray-700 uppercase tracking-wider w-32">
                  Percentual (%)
                </th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <tr
                v-for="(advogado, index) in advogadosParceiros"
                :key="advogado.id"
                class="hover:bg-gray-50 transition-colors"
              >
                <td class="px-4 py-3">
                  <div class="text-sm font-medium text-gray-900">
                    {{ advogado.nome }}
                  </div>
                </td>
                <td class="px-4 py-3">
                  <div class="text-sm text-gray-600">
                    <span v-if="advogado.oab_numero">
                      {{ advogado.oab_numero }}/{{ advogado.oab_uf }}
                    </span>
                    <span v-else class="text-gray-400">-</span>
                  </div>
                </td>
                <td class="px-4 py-3">
                  <div class="text-sm text-gray-600">
                    {{ formatarTipoVinculo(advogado.tipo_vinculo) }}
                  </div>
                </td>
                <td class="px-4 py-3">
                  <div class="flex items-center justify-end gap-2">
                    <div class="relative w-24">
                      <input
                        :id="`percentual-${advogado.id}`"
                        v-model.number="advogado.percentual"
                        type="number"
                        step="0.01"
                        min="0"
                        max="100"
                        placeholder="0"
                        :class="[
                          'w-full px-3 py-2 pr-8 border rounded-lg text-sm text-gray-900 placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-offset-0 transition-all duration-200 ease-in-out shadow-sm hover:shadow-md focus:shadow-lg',
                          getPercentualError(advogado.id)
                            ? 'border-danger-400 focus:ring-danger-500 focus:border-danger-500 bg-danger-50/30'
                            : 'border-gray-200 focus:ring-primary-500 focus:border-primary-500 bg-white hover:border-gray-300'
                        ]"
                        @input="handlePercentualChange(advogado.id, $event)"
                        @blur="validatePercentual(advogado.id)"
                      />
                      <span class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500 text-sm pointer-events-none">%</span>
                    </div>
                  </div>
                  <p
                    v-if="getPercentualError(advogado.id)"
                    class="mt-1 text-xs text-danger-600 font-medium text-right"
                  >
                    {{ getPercentualError(advogado.id) }}
                  </p>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Mensagem de erro do total -->
      <p
        v-if="errorTotal"
        class="text-sm text-danger-600 font-medium flex items-center gap-1.5"
      >
        <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
          <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
        </svg>
        {{ errorTotal }}
      </p>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'

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

const emit = defineEmits(['update:modelValue', 'change', 'validation'])

const supabase = useSupabaseClient()

const advogadosParceiros = ref([])
const percentuaisErrors = ref({})
const errorTotal = ref('')
const isInitializing = ref(false)

// Total de percentuais
const totalPercentual = computed(() => {
  return advogadosParceiros.value.reduce((total, adv) => {
    const percentual = parseFloat(adv.percentual) || 0
    return total + percentual
  }, 0)
})

// Formatar tipo de vínculo para exibição
const formatarTipoVinculo = (tipo) => {
  const tipos = {
    'associado': 'Associado',
    'parceiro': 'Parceiro'
  }
  return tipos[tipo] || tipo
}

// Buscar advogados parceiros e associados ativos
const fetchAdvogadosParceiros = async () => {
  try {
    const { data, error } = await supabase
      .from('advogados')
      .select('id, nome, oab_numero, oab_uf, tipo_vinculo')
      .in('tipo_vinculo', ['associado', 'parceiro'])
      .eq('ativo', true)
      .order('nome', { ascending: true })

    if (error) {
      console.error('Erro ao buscar advogados parceiros:', error)
      return
    }

    // Se há valores iniciais (modelValue), usa eles
    if (props.modelValue && props.modelValue.length > 0) {
      // Mapeia os advogados com os percentuais existentes
      advogadosParceiros.value = (data || []).map(advogado => {
        const existing = props.modelValue.find(v => v.id === advogado.id)
        return {
          ...advogado,
          percentual: existing ? parseFloat(existing.percentual) || 0 : 0
        }
      })
    } else {
      // Inicializa com percentuais zerados
      advogadosParceiros.value = (data || []).map(advogado => ({
        ...advogado,
        percentual: 0
      }))
      
      // Distribui automaticamente se houver advogados
      if (advogadosParceiros.value.length > 0) {
        distributePercentuais()
      }
    }

    emitChange()
  } catch (error) {
    console.error('Erro inesperado ao buscar advogados parceiros:', error)
  }
}

// Distribui percentuais igualmente entre todos os advogados
const distributePercentuais = () => {
  if (advogadosParceiros.value.length === 0) return

  isInitializing.value = true
  
  // Se há apenas um advogado, ele recebe 100%
  if (advogadosParceiros.value.length === 1) {
    advogadosParceiros.value[0].percentual = 100
  } else {
    const percentualPorAdvogado = 100 / advogadosParceiros.value.length
    
    advogadosParceiros.value.forEach(advogado => {
      advogado.percentual = parseFloat(percentualPorAdvogado.toFixed(2))
    })
  }

  isInitializing.value = false
  emitChange()
}

// Handler quando um percentual é alterado
const handlePercentualChange = (advogadoId, event) => {
  let value = parseFloat(event.target.value) || 0
  
  // Limita o valor máximo a 100
  if (value > 100) {
    value = 100
    event.target.value = 100
  }
  
  // Encontra o advogado que foi alterado
  const advogadoAlterado = advogadosParceiros.value.find(a => a.id === advogadoId)
  if (!advogadoAlterado) return

  // Atualiza o valor do advogado alterado
  advogadoAlterado.percentual = value

  // Se há apenas um advogado, ele recebe 100%
  if (advogadosParceiros.value.length === 1) {
    advogadoAlterado.percentual = 100
    clearErrors()
    validateAll()
    emitChange()
    return
  }

  // Calcula o total dos outros advogados (sem o que foi alterado)
  const outrosAdvogados = advogadosParceiros.value.filter(a => a.id !== advogadoId)
  const totalOutros = outrosAdvogados.reduce((sum, adv) => {
    return sum + (parseFloat(adv.percentual) || 0)
  }, 0)

  // Calcula quanto falta para 100%
  const restante = 100 - value

  // Se há outros advogados, distribui o restante proporcionalmente
  if (outrosAdvogados.length > 0) {
    if (restante < 0) {
      // Se o valor digitado é maior que 100%, ajusta os outros para 0
      outrosAdvogados.forEach(adv => {
        adv.percentual = 0
      })
    } else if (restante === 0) {
      // Se já completou 100%, zera os outros
      outrosAdvogados.forEach(adv => {
        adv.percentual = 0
      })
    } else if (totalOutros === 0) {
      // Se os outros estão zerados, divide igualmente
      const percentualPorOutro = restante / outrosAdvogados.length
      outrosAdvogados.forEach(adv => {
        adv.percentual = parseFloat(percentualPorOutro.toFixed(2))
      })
    } else {
      // Distribui proporcionalmente baseado nos valores atuais
      outrosAdvogados.forEach(adv => {
        const proporcao = (parseFloat(adv.percentual) || 0) / totalOutros
        adv.percentual = parseFloat((restante * proporcao).toFixed(2))
      })
    }
  }

  // Limpa erros e valida
  clearErrors()
  validateAll()
  emitChange()
}

// Valida um percentual específico
const validatePercentual = (advogadoId) => {
  const advogado = advogadosParceiros.value.find(a => a.id === advogadoId)
  if (!advogado) return

  const percentual = parseFloat(advogado.percentual) || 0

  if (percentual < 0) {
    percentuaisErrors.value[advogadoId] = 'Percentual não pode ser negativo'
  } else if (percentual > 100) {
    percentuaisErrors.value[advogadoId] = 'Percentual não pode ser maior que 100%'
  } else {
    delete percentuaisErrors.value[advogadoId]
  }

  validateTotal()
}

// Valida todos os percentuais
const validateAll = () => {
  advogadosParceiros.value.forEach(advogado => {
    validatePercentual(advogado.id)
  })
  validateTotal()
}

// Valida se o total é 100%
const validateTotal = () => {
  const total = totalPercentual.value
  const diff = Math.abs(total - 100)

  if (diff > 0.01) {
    errorTotal.value = `A soma dos percentuais deve ser exatamente 100% (atual: ${total.toFixed(2)}%)`
  } else {
    errorTotal.value = ''
  }

  // Emite evento de validação
  const isValid = diff <= 0.01 && Object.keys(percentuaisErrors.value).length === 0
  emit('validation', {
    isValid,
    total: totalPercentual.value,
    errors: { ...percentuaisErrors.value, total: errorTotal.value }
  })
}

// Limpa todos os erros
const clearErrors = () => {
  percentuaisErrors.value = {}
  errorTotal.value = ''
}

// Retorna o erro de um percentual específico
const getPercentualError = (advogadoId) => {
  return percentuaisErrors.value[advogadoId] || ''
}

// Emite mudanças para o componente pai
const emitChange = () => {
  if (isInitializing.value) return

  const data = advogadosParceiros.value.map(advogado => ({
    id: advogado.id,
    percentual: parseFloat(advogado.percentual) || 0
  }))

  emit('update:modelValue', data)
  emit('change', data)
}

// Watch para detectar mudanças externas no modelValue
watch(() => props.modelValue, (newValue) => {
  if (!newValue || newValue.length === 0) {
    // Se não há valores, redistribui
    if (advogadosParceiros.value.length > 0) {
      distributePercentuais()
    }
    return
  }

  // Atualiza os percentuais com os valores recebidos
  advogadosParceiros.value.forEach(advogado => {
    const existing = newValue.find(v => v.id === advogado.id)
    if (existing) {
      advogado.percentual = parseFloat(existing.percentual) || 0
    }
  })

  validateAll()
}, { deep: true })

// Buscar advogados ao montar
onMounted(async () => {
  await fetchAdvogadosParceiros()
  validateAll()
})

// Expõe métodos públicos
defineExpose({
  validate: validateAll,
  clearErrors,
  getData: () => advogadosParceiros.value.map(a => ({ id: a.id, percentual: parseFloat(a.percentual) || 0 }))
})
</script>
