<template>
  <div class="flex flex-wrap items-end gap-4">
    <div class="flex-1 min-w-[180px]">
      <InputData
        id="filtro-periodo-data-inicial"
        v-model="dataInicialLocal"
        label="Data inicial"
        :max="dataFinalLocal || undefined"
        @update:model-value="emitPeriodo"
      />
    </div>
    <div class="flex-1 min-w-[180px]">
      <InputData
        id="filtro-periodo-data-final"
        v-model="dataFinalLocal"
        label="Data final"
        :min="dataInicialLocal || undefined"
        @update:model-value="emitPeriodo"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import InputData from './InputData.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({ dataInicial: '', dataFinal: '' })
  }
})

const emit = defineEmits(['update:modelValue'])

const dataInicialLocal = ref(props.modelValue?.dataInicial ?? getPrimeiroDiaMes())
const dataFinalLocal = ref(props.modelValue?.dataFinal ?? getUltimoDiaMes())

watch(
  () => props.modelValue,
  (newVal) => {
    if (newVal?.dataInicial !== undefined) dataInicialLocal.value = newVal.dataInicial
    if (newVal?.dataFinal !== undefined) dataFinalLocal.value = newVal.dataFinal
  },
  { deep: true }
)

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

function emitPeriodo() {
  emit('update:modelValue', {
    dataInicial: dataInicialLocal.value || '',
    dataFinal: dataFinalLocal.value || ''
  })
}
</script>
