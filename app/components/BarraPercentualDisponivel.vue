<template>
  <div class="w-full space-y-1">
    <div class="h-2 rounded-full bg-gray-100 overflow-hidden">
      <div
        class="h-full rounded-full bg-green-500 transition-all"
        :style="{ width: larguraPercentual + '%' }"
      />
    </div>
    <p v-if="mostrarTexto" class="text-xs text-gray-500">
      {{ percentualFormatado }}% já disponível
    </p>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  /** Percentual já disponível para resgate (0–100) */
  percentual: {
    type: Number,
    default: 0,
    validator: (v) => v >= 0 && v <= 100
  },
  /** Exibe o texto "X% já disponível" abaixo da barra */
  mostrarTexto: {
    type: Boolean,
    default: true
  }
})

const larguraPercentual = computed(() => Math.min(100, Math.max(0, props.percentual)))

const percentualFormatado = computed(() => larguraPercentual.value.toFixed(1))
</script>
