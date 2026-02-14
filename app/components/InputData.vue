<template>
  <div ref="rootRef" class="w-full">
    <label
      v-if="label"
      :for="inputId"
      class="block text-sm font-semibold text-gray-800 mb-2.5 tracking-tight"
    >
      {{ label }}
      <span v-if="required" class="text-danger-500 ml-0.5">*</span>
    </label>
    <div class="relative">
      <input
        ref="inputRef"
        :id="inputId"
        type="text"
        inputmode="numeric"
        :value="valorExibicao"
        :placeholder="placeholder || 'DD/MM/AAAA'"
        :disabled="disabled"
        :required="required"
        :maxlength="10"
        autocomplete="off"
        :class="inputClasses"
        @input="onInput"
        @blur="onBlur"
        @focus="onFocus"
      />
      <button
        type="button"
        :disabled="disabled"
        :aria-label="'Abrir calendário'"
        class="absolute right-3 top-1/2 -translate-y-1/2 p-1.5 rounded-lg text-gray-500 hover:text-primary-600 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-inset disabled:opacity-50 disabled:cursor-not-allowed"
        @click="abrirCalendario"
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
        </svg>
      </button>
      <Transition name="calendario">
        <div
          v-if="calendarioVisivel && !disabled"
          class="absolute left-0 right-0 mt-2 z-50 bg-white rounded-xl border border-gray-200 shadow-xl p-4"
          @mousedown.prevent
        >
          <div class="flex items-center justify-between mb-3">
            <button
              type="button"
              class="p-1.5 rounded-lg hover:bg-gray-100 text-gray-600 hover:text-gray-900 focus:outline-none focus:ring-2 focus:ring-primary-500"
              aria-label="Mês anterior"
              @click="mesAnterior"
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" /></svg>
            </button>
            <span class="text-sm font-semibold text-gray-800">{{ mesAnoLabel }}</span>
            <button
              type="button"
              class="p-1.5 rounded-lg hover:bg-gray-100 text-gray-600 hover:text-gray-900 focus:outline-none focus:ring-2 focus:ring-primary-500"
              aria-label="Mês seguinte"
              @click="mesSeguinte"
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" /></svg>
            </button>
          </div>
          <div class="grid grid-cols-7 gap-1 text-center text-xs font-medium text-gray-500 mb-2">
            <span v-for="d in diasSemana" :key="d">{{ d }}</span>
          </div>
          <div class="grid grid-cols-7 gap-1">
            <button
              v-for="(cell, idx) in diasCalendario"
              :key="idx"
              type="button"
              :disabled="cell.disabled"
              :class="[
                'py-2 text-sm rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500',
                cell.outroMes ? 'text-gray-300' : '',
                cell.disabled ? 'text-gray-300 cursor-not-allowed' : 'hover:bg-gray-100',
                cell.hoje ? 'font-semibold text-primary-600' : '',
                cell.selecionado ? 'bg-primary-500 text-white hover:bg-primary-600' : 'text-gray-900'
              ]"
              @click="selecionarDia(cell)"
            >
              {{ cell.dia }}
            </button>
          </div>
        </div>
      </Transition>
    </div>
    <p
      v-if="error"
      class="mt-2 text-sm text-danger-600 font-medium flex items-center gap-1.5"
    >
      <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
        <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
      </svg>
      {{ error }}
    </p>
    <p
      v-if="hint && !error"
      class="mt-2 text-sm text-gray-500 font-normal"
    >
      {{ hint }}
    </p>
  </div>
</template>

<script setup>
import { computed, ref, watch, onMounted, onUnmounted } from 'vue'

const MESES = ['Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', 'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro']
const DIAS_SEMANA = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb']

const props = defineProps({
  modelValue: {
    type: String,
    default: ''
  },
  label: {
    type: String,
    default: ''
  },
  placeholder: {
    type: String,
    default: ''
  },
  error: {
    type: String,
    default: ''
  },
  hint: {
    type: String,
    default: ''
  },
  disabled: {
    type: Boolean,
    default: false
  },
  required: {
    type: Boolean,
    default: false
  },
  id: {
    type: String,
    default: ''
  },
  maxDate: {
    type: String,
    default: ''
  },
  minDate: {
    type: String,
    default: ''
  }
})

const emit = defineEmits(['update:modelValue', 'blur', 'focus'])

const inputRef = ref(null)
const rootRef = ref(null)
const valorExibicao = ref('')
const calendarioVisivel = ref(false)
const mesCalendario = ref(new Date().getMonth())
const anoCalendario = ref(new Date().getFullYear())

/** Converte YYYY-MM-DD para DD/MM/YYYY */
function toDDMMYYYY(iso) {
  if (!iso || iso.length < 10) return ''
  const [y, m, d] = iso.slice(0, 10).split('-')
  if (!y || !m || !d) return ''
  return `${d}/${m}/${y}`
}

/** Converte DD/MM/YYYY para YYYY-MM-DD */
function toISO(ddmmYYYY) {
  const digits = (ddmmYYYY || '').replace(/\D/g, '')
  if (digits.length !== 8) return ''
  const d = digits.slice(0, 2)
  const m = digits.slice(2, 4)
  const y = digits.slice(4, 8)
  const day = parseInt(d, 10)
  const month = parseInt(m, 10)
  const year = parseInt(y, 10)
  if (day < 1 || day > 31 || month < 1 || month > 12 || year < 1900 || year > 2100) return ''
  return `${y}-${m}-${d}`
}

/** Formata dígitos como DD/MM/YYYY enquanto digita */
function formatarDigitacao(valor) {
  const digits = (valor || '').replace(/\D/g, '')
  if (digits.length <= 2) return digits
  if (digits.length <= 4) return `${digits.slice(0, 2)}/${digits.slice(2)}`
  return `${digits.slice(0, 2)}/${digits.slice(2, 4)}/${digits.slice(4, 8)}`
}

function validarData(iso) {
  if (!iso) return true
  const d = new Date(iso)
  if (isNaN(d.getTime())) return false
  if (props.minDate && iso < props.minDate) return false
  if (props.maxDate && iso > props.maxDate) return false
  return true
}

function onInput(e) {
  const raw = e.target.value
  const formatado = formatarDigitacao(raw)
  valorExibicao.value = formatado
  const digits = formatado.replace(/\D/g, '')
  if (digits.length === 0) {
    emit('update:modelValue', '')
  } else if (digits.length === 8) {
    const iso = toISO(formatado)
    emit('update:modelValue', iso || '')
  }
}

function onBlur(e) {
  const iso = toISO(valorExibicao.value)
  if (valorExibicao.value && !iso) {
    valorExibicao.value = ''
    emit('update:modelValue', '')
  } else if (iso && !validarData(iso)) {
    valorExibicao.value = toDDMMYYYY(props.modelValue) || ''
  } else if (iso) {
    valorExibicao.value = toDDMMYYYY(iso)
  }
  emit('blur', e)
}

function onFocus(e) {
  calendarioVisivel.value = true
  sincronizarMesAnoCalendario()
  emit('focus', e)
}

function abrirCalendario() {
  if (props.disabled) return
  calendarioVisivel.value = true
  sincronizarMesAnoCalendario()
  inputRef.value?.focus()
}

function sincronizarMesAnoCalendario() {
  const iso = props.modelValue || toISO(valorExibicao.value)
  if (iso) {
    const [y, m] = iso.split('-')
    anoCalendario.value = parseInt(y, 10)
    mesCalendario.value = parseInt(m, 10) - 1
  } else {
    const h = new Date()
    anoCalendario.value = h.getFullYear()
    mesCalendario.value = h.getMonth()
  }
}

function mesAnterior() {
  if (mesCalendario.value === 0) {
    mesCalendario.value = 11
    anoCalendario.value -= 1
  } else {
    mesCalendario.value -= 1
  }
}

function mesSeguinte() {
  if (mesCalendario.value === 11) {
    mesCalendario.value = 0
    anoCalendario.value += 1
  } else {
    mesCalendario.value += 1
  }
}

function diaDisabled(iso) {
  if (!iso) return false
  if (props.minDate && iso < props.minDate) return true
  if (props.maxDate && iso > props.maxDate) return true
  return false
}

function selecionarDia(cell) {
  if (cell.disabled) return
  const iso = cell.iso || `${anoCalendario.value}-${String(mesCalendario.value + 1).padStart(2, '0')}-${String(cell.dia).padStart(2, '0')}`
  if (!validarData(iso)) return
  valorExibicao.value = toDDMMYYYY(iso)
  emit('update:modelValue', iso)
  calendarioVisivel.value = false
}

function handleClickFora(e) {
  if (rootRef.value && !rootRef.value.contains(e.target)) {
    calendarioVisivel.value = false
  }
}

const diasSemana = DIAS_SEMANA

const mesAnoLabel = computed(() => `${MESES[mesCalendario.value]} ${anoCalendario.value}`)

const diasCalendario = computed(() => {
  const primeiroDia = new Date(anoCalendario.value, mesCalendario.value, 1)
  const ultimoDia = new Date(anoCalendario.value, mesCalendario.value + 1, 0)
  const diaSemanaInicio = primeiroDia.getDay()
  const totalDias = ultimoDia.getDate()
  const hoje = new Date()
  const hojeStr = `${hoje.getFullYear()}-${String(hoje.getMonth() + 1).padStart(2, '0')}-${String(hoje.getDate()).padStart(2, '0')}`

  const cells = []
  const valorAtual = props.modelValue || toISO(valorExibicao.value)

  for (let i = 0; i < diaSemanaInicio; i++) {
    const d = new Date(anoCalendario.value, mesCalendario.value, -diaSemanaInicio + i + 1)
    const iso = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
    cells.push({
      dia: d.getDate(),
      outroMes: true,
      disabled: diaDisabled(iso),
      hoje: false,
      selecionado: false,
      iso
    })
  }
  for (let d = 1; d <= totalDias; d++) {
    const iso = `${anoCalendario.value}-${String(mesCalendario.value + 1).padStart(2, '0')}-${String(d).padStart(2, '0')}`
    cells.push({
      dia: d,
      outroMes: false,
      disabled: diaDisabled(iso),
      hoje: iso === hojeStr,
      selecionado: valorAtual === iso,
      iso
    })
  }
  const restantes = 42 - cells.length
  for (let i = 1; i <= restantes; i++) {
    const d = new Date(anoCalendario.value, mesCalendario.value + 1, i)
    const iso = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
    cells.push({
      dia: d.getDate(),
      outroMes: true,
      disabled: diaDisabled(iso),
      hoje: false,
      selecionado: false,
      iso
    })
  }
  return cells
})

onMounted(() => {
  document.addEventListener('click', handleClickFora)
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickFora)
})

watch(
  () => props.modelValue,
  (novo) => {
    const exibicao = toDDMMYYYY(novo)
    if (exibicao !== valorExibicao.value) {
      valorExibicao.value = exibicao
    }
  },
  { immediate: true }
)

const hashString = (str) => {
  if (!str.length) return '0'
  let hash = 0
  for (let i = 0; i < str.length; i++) {
    const char = str.charCodeAt(i)
    hash = ((hash << 5) - hash) + char
    hash = hash & hash
  }
  return Math.abs(hash).toString(36)
}

const inputId = computed(() => {
  if (props.id) return props.id
  const key = `input-date-${props.label || ''}-${props.placeholder || ''}`
  return `input-date-${hashString(key)}`
})

const inputClasses = computed(() => [
  'w-full',
  'pl-5',
  'pr-12',
  'py-3.5',
  'border',
  'rounded-xl',
  'text-gray-900',
  'placeholder:text-gray-400',
  'focus:outline-none',
  'focus:ring-2',
  'focus:ring-offset-0',
  'transition-all',
  'duration-200',
  'ease-in-out',
  'shadow-sm',
  'hover:shadow-md',
  'focus:shadow-lg',
  'cursor-text',
  props.error
    ? 'border-danger-400 focus:ring-danger-500 focus:border-danger-500 bg-danger-50/30'
    : 'border-gray-200 focus:ring-primary-500 focus:border-primary-500 bg-white hover:border-gray-300',
  props.disabled ? 'bg-gray-50 cursor-not-allowed opacity-50 border-gray-200' : ''
])
</script>

<style scoped>
.calendario-enter-active,
.calendario-leave-active {
  transition: opacity 0.15s ease, transform 0.15s ease;
}
.calendario-enter-from,
.calendario-leave-to {
  opacity: 0;
  transform: translateY(-8px);
}
</style>
