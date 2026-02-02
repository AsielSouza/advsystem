<template>
  <div class="w-full space-y-4">
    <!-- Toggle: Dividir entre sócios -->
    <Toggle
      id="dividir-entre-socios"
      v-model="dividirEntreSocios"
      label="Dividir entre sócios"
      description="Ative para dividir o valor do honorário entre os sócios"
      @change="handleToggleChange"
    />

    <!-- Dropdown de Advogado (quando toggle está DESATIVADO) -->
    <Dropdown
      v-if="!dividirEntreSocios"
      id="advogado-responsavel"
      v-model="advogadoResponsavel"
      label="Advogado responsável"
      placeholder="Selecione o advogado responsável"
      :options="opcoesAdvogados"
      :error="errors.advogado_responsavel"
    />

    <!-- Tabela de Divisão entre Sócios (quando toggle está ATIVADO) -->
    <div v-if="dividirEntreSocios" class="space-y-2">
      <p class="text-sm font-semibold text-gray-800">
        Divisão entre sócios
        <span v-if="dividirEntreParceiros" class="text-gray-500 font-normal">
          ({{ percentualSocios }}% do valor total)
        </span>
      </p>
      <TabelaDivisaoSocios
        v-model="divisaoSocios"
      />
    </div>

    <!-- Toggle: Dividir entre parceiros -->
    <Toggle
      id="dividir-entre-parceiros"
      v-model="dividirEntreParceiros"
      label="Dividir entre parceiros"
      description="Ative para dividir o valor do honorário entre os parceiros"
      @change="handleToggleParceirosChange"
    />

    <!-- Tabela de Divisão entre Parceiros (quando toggle está ATIVADO) -->
    <div v-if="dividirEntreParceiros" class="space-y-2">
      <p class="text-sm font-semibold text-gray-800">
        Divisão entre advogados parceiros
        <span class="text-gray-500 font-normal">
          ({{ percentualParceiros }}% do valor total)
        </span>
      </p>
      <TabelaDivisaoParceiros
        v-model="divisaoParceiros"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, watch, onMounted, nextTick } from 'vue'
import Toggle from './Toggle.vue'
import Dropdown from './Dropdown.vue'
import TabelaDivisaoSocios from './TabelaDivisaoSocios.vue'
import TabelaDivisaoParceiros from './TabelaDivisaoParceiros.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({
      dividir_entre_socios: false,
      advogado_responsavel_id: '',
      divisao_socios: [],
      dividir_entre_parceiros: false,
      percentual_socios: 50,
      percentual_parceiros: 50,
      divisao_parceiros: []
    })
  },
  error: {
    type: String,
    default: ''
  }
})

const emit = defineEmits(['update:modelValue', 'change'])

const supabase = useSupabaseClient()

// Estados locais
const dividirEntreSocios = ref(props.modelValue?.dividir_entre_socios || false)
const advogadoResponsavel = ref(props.modelValue?.advogado_responsavel_id || '')
const divisaoSocios = ref(props.modelValue?.divisao_socios || [])
const dividirEntreParceiros = ref(props.modelValue?.dividir_entre_parceiros || false)
const percentualSocios = ref(String(props.modelValue?.percentual_socios ?? 50))
const percentualParceiros = ref(String(props.modelValue?.percentual_parceiros ?? 50))
const divisaoParceiros = ref(props.modelValue?.divisao_parceiros || [])
const opcoesAdvogados = ref([])
const isLoadingAdvogados = ref(false)

// Erros
const errors = ref({
  advogado_responsavel: ''
})

// Flag para evitar loop infinito durante atualizações internas
const isUpdatingFromProps = ref(false)

// Busca advogados sócios ativos (tipo de vínculo = Sócio) para o dropdown Advogado responsável
const fetchAdvogados = async () => {
  isLoadingAdvogados.value = true
  
  try {
    const { data, error } = await supabase
      .from('advogados')
      .select('id, nome, oab_numero, oab_uf')
      .eq('tipo_vinculo', 'socio')
      .eq('ativo', true)
      .order('nome', { ascending: true })

    if (error) {
      console.error('Erro ao buscar advogados:', error)
      opcoesAdvogados.value = []
      return
    }

    // Mapeia os advogados para o formato do Dropdown
    opcoesAdvogados.value = (data || []).map(advogado => ({
      value: advogado.id.toString(),
      label: `${advogado.nome}${advogado.oab_numero ? ` - OAB ${advogado.oab_numero}/${advogado.oab_uf || ''}` : ''}`
    }))
  } catch (error) {
    console.error('Erro inesperado ao buscar advogados:', error)
    opcoesAdvogados.value = []
  } finally {
    isLoadingAdvogados.value = false
  }
}

// Handler para mudança do toggle de sócios
const handleToggleChange = (value) => {
  if (isUpdatingFromProps.value) return
  
  // Limpa advogado responsável quando ativa divisão
  if (value) {
    advogadoResponsavel.value = ''
  }
  // Limpa divisão quando desativa toggle
  else {
    // Aqui podemos limpar dados de divisão quando implementar
  }
  
  emitFormData()
}

// Handler para mudança do toggle de parceiros
const handleToggleParceirosChange = (value) => {
  if (isUpdatingFromProps.value) return
  
  if (value) {
    // Inicializa percentuais 50/50 quando ativa
    const total = parseFloat(percentualSocios.value) + parseFloat(percentualParceiros.value)
    if (Math.abs(total - 100) > 0.01) {
      percentualSocios.value = '50.00'
      percentualParceiros.value = '50.00'
    }
  } else {
    divisaoParceiros.value = []
  }
  
  emitFormData()
}

// Watch para advogado responsável
watch(advogadoResponsavel, () => {
  if (!isUpdatingFromProps.value) {
    emitFormData()
  }
})

// Watch para dividir entre sócios
watch(dividirEntreSocios, () => {
  if (!isUpdatingFromProps.value) {
    emitFormData()
  }
})

// Watch para divisão de sócios
watch(divisaoSocios, () => {
  if (!isUpdatingFromProps.value) {
    emitFormData()
  }
}, { deep: true })

// Watch para dividir entre parceiros
watch(dividirEntreParceiros, () => {
  if (!isUpdatingFromProps.value) {
    emitFormData()
  }
})

// Watch para divisão de parceiros
watch(divisaoParceiros, () => {
  if (!isUpdatingFromProps.value) {
    emitFormData()
  }
}, { deep: true })

// Função para emitir dados do formulário
const emitFormData = () => {
  const formData = {
    dividir_entre_socios: dividirEntreSocios.value,
    advogado_responsavel_id: dividirEntreSocios.value ? '' : advogadoResponsavel.value,
    divisao_socios: dividirEntreSocios.value ? divisaoSocios.value : [],
    dividir_entre_parceiros: dividirEntreParceiros.value,
    percentual_socios: dividirEntreParceiros.value ? parseFloat(percentualSocios.value) || 50 : 100,
    percentual_parceiros: dividirEntreParceiros.value ? parseFloat(percentualParceiros.value) || 50 : 0,
    divisao_parceiros: dividirEntreParceiros.value ? divisaoParceiros.value : []
  }
  
  emit('update:modelValue', formData)
  emit('change', formData)
}

// Watch para percentuais dos grupos
watch([percentualSocios, percentualParceiros], () => {
  if (!isUpdatingFromProps.value) {
    emitFormData()
  }
})

// Watch para atualizar campos quando modelValue mudar externamente
watch(() => props.modelValue, (newValue) => {
  if (!newValue || isUpdatingFromProps.value) return
  
  // Verifica se há mudanças reais antes de atualizar
  const hasChanges = 
    dividirEntreSocios.value !== (newValue.dividir_entre_socios || false) ||
    advogadoResponsavel.value !== (newValue.advogado_responsavel_id || '') ||
    JSON.stringify(divisaoSocios.value) !== JSON.stringify(newValue.divisao_socios || []) ||
    dividirEntreParceiros.value !== (newValue.dividir_entre_parceiros || false) ||
    percentualSocios.value !== String(newValue.percentual_socios ?? 50) ||
    percentualParceiros.value !== String(newValue.percentual_parceiros ?? 50) ||
    JSON.stringify(divisaoParceiros.value) !== JSON.stringify(newValue.divisao_parceiros || [])
  
  if (hasChanges) {
    isUpdatingFromProps.value = true
    dividirEntreSocios.value = newValue.dividir_entre_socios || false
    advogadoResponsavel.value = newValue.advogado_responsavel_id || ''
    divisaoSocios.value = newValue.divisao_socios || []
    dividirEntreParceiros.value = newValue.dividir_entre_parceiros || false
    percentualSocios.value = String(newValue.percentual_socios ?? 50)
    percentualParceiros.value = String(newValue.percentual_parceiros ?? 50)
    divisaoParceiros.value = newValue.divisao_parceiros || []
    
    nextTick(() => {
      isUpdatingFromProps.value = false
    })
  }
}, { immediate: true, deep: true })

// Carrega advogados ao montar o componente
onMounted(() => {
  fetchAdvogados()
})
</script>
