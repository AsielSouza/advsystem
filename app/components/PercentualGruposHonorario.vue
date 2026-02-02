<template>
  <div class="bg-gray-50 rounded-xl border border-gray-200 p-4 space-y-4">
    <p class="text-sm font-semibold text-gray-800">
      Percentual do honorário total para cada grupo
    </p>
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <div class="space-y-1">
        <label class="block text-sm font-medium text-gray-700">
          % para Sócios (ou advogado responsável)
        </label>
        <div class="flex items-center gap-2">
          <Input
            id="percentual-socios"
            v-model="percentualSociosLocal"
            type="number"
            placeholder="0"
            class="w-24"
            step="0.01"
            @blur="ajustarPercentuais"
          />
          <span class="text-sm text-gray-500">%</span>
        </div>
      </div>
      <div class="space-y-1">
        <label class="block text-sm font-medium text-gray-700">
          % para Advogados Parceiros
        </label>
        <div class="flex items-center gap-2">
          <Input
            id="percentual-parceiros"
            :model-value="percentualParceirosDisplay"
            type="number"
            placeholder="0"
            class="w-24"
            :disabled="true"
          />
          <span class="text-sm text-gray-500">%</span>
        </div>
      </div>
    </div>
    <p
      v-if="valorSociosForaDoIntervalo"
      class="text-xs text-danger-600 font-medium"
    >
      O valor para Sócios deve estar entre 0% e 100%
    </p>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import Input from './Input.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({
      percentual_socios: 50,
      percentual_parceiros: 50
    })
  }
})

const emit = defineEmits(['update:modelValue'])

const percentualSociosLocal = ref(String(props.modelValue?.percentual_socios ?? 50))

// Parceiros é sempre o complemento de Sócios (100% - Sócios); campo somente leitura
const percentualParceirosDisplay = computed(() => {
  const socios = Math.min(100, Math.max(0, parseFloat(percentualSociosLocal.value) || 0))
  return (100 - socios).toFixed(2)
})

const valorSociosForaDoIntervalo = computed(() => {
  const socios = parseFloat(percentualSociosLocal.value)
  if (Number.isNaN(socios)) return true
  return socios < 0 || socios > 100
})

const isUpdatingFromProps = ref(false)

const emitChange = () => {
  if (isUpdatingFromProps.value) return
  const socios = Math.min(100, Math.max(0, parseFloat(percentualSociosLocal.value) || 0))
  emit('update:modelValue', {
    percentual_socios: socios,
    percentual_parceiros: 100 - socios
  })
}

// Ao sair do campo Sócios: limita a 0–100% e reemite (Parceiros já é o complemento)
const ajustarPercentuais = () => {
  const socios = parseFloat(percentualSociosLocal.value) || 0
  if (socios > 100) {
    percentualSociosLocal.value = '100.00'
  } else if (socios < 0) {
    percentualSociosLocal.value = '0.00'
  }
  emitChange()
}

watch(percentualSociosLocal, () => {
  emitChange()
})

watch(() => props.modelValue, (newValue) => {
  if (!newValue) return
  const socios = String(newValue.percentual_socios ?? 50)
  if (percentualSociosLocal.value !== socios) {
    isUpdatingFromProps.value = true
    percentualSociosLocal.value = socios
    isUpdatingFromProps.value = false
  }
}, { deep: true })
</script>
