<template>
  <div class="bg-white rounded-xl shadow-lg border border-gray-200 overflow-hidden">
    <!-- Formulário -->
    <form @submit.prevent="handleSubmit" class="p-6 space-y-6">
      <!-- Cliente - Campo de Busca/Autocomplete -->
      <div class="w-full relative">
        <label
          for="cliente-search"
          class="block text-sm font-semibold text-gray-800 mb-2.5 tracking-tight"
        >
          Cliente
          <span class="text-danger-500 ml-0.5">*</span>
        </label>
        <div class="relative">
          <Input
            id="cliente-search"
            v-model="clienteSearch"
            placeholder="Digite para buscar cliente..."
            :error="errors.cliente_id"
            @update:model-value="handleClienteSearch"
            @focus="showClienteResults = true"
            @blur="handleClienteBlur"
          />
          
          <!-- Dropdown de resultados -->
          <div
            v-if="showClienteResults && filteredClientes.length > 0"
            class="absolute z-50 w-full mt-1 bg-white border border-gray-200 rounded-xl shadow-lg max-h-60 overflow-y-auto"
          >
            <div
              v-for="cliente in filteredClientes"
              :key="cliente.id"
              class="px-4 py-3 hover:bg-gray-50 cursor-pointer transition-colors border-b border-gray-100 last:border-b-0"
              @mousedown.prevent="selectCliente(cliente)"
            >
              <div class="flex items-center justify-between">
                <div>
                  <p class="text-sm font-medium text-gray-900">
                    {{ cliente.nome || cliente.razao_social }}
                  </p>
                  <p v-if="cliente.nome_fantasia" class="text-xs text-gray-500 mt-0.5">
                    {{ cliente.nome_fantasia }}
                  </p>
                </div>
                <span
                  :class="[
                    'px-2 py-1 text-xs font-medium rounded-full',
                    cliente.tipo === 'PF'
                      ? 'bg-blue-100 text-blue-800'
                      : 'bg-green-100 text-green-800'
                  ]"
                >
                  {{ cliente.tipo }}
                </span>
              </div>
            </div>
          </div>
          
          <!-- Mensagem quando não há resultados -->
          <div
            v-if="showClienteResults && filteredClientes.length === 0 && clienteSearch.length > 0"
            class="absolute z-50 w-full mt-1 bg-white border border-gray-200 rounded-xl shadow-lg p-4"
          >
            <p class="text-sm text-gray-500 text-center">
              Nenhum cliente encontrado
            </p>
          </div>
        </div>
        <p
          v-if="errors.cliente_id"
          class="mt-2 text-sm text-danger-600 font-medium flex items-center gap-1.5"
        >
          <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
          </svg>
          {{ errors.cliente_id }}
        </p>
      </div>

      <!-- Número do Processo -->
      <Input
        v-model="formData.numero_processo"
        label="Número do Processo"
        placeholder="Digite o número do processo"
        required
        :error="errors.numero_processo"
      />

      <!-- Parte no Processo -->
      <Dropdown
        v-model="formData.parte"
        label="Parte no Processo"
        :options="parteOptions"
        placeholder="Selecione a parte no processo"
        required
        :error="errors.parte"
        @change="handleParteChange"
      />

      <!-- Descrição da Parte (quando for "outro") -->
      <Input
        v-if="formData.parte === 'outro'"
        v-model="formData.parte_outro_descricao"
        label="Descrição da Parte"
        placeholder="Descreva a parte no processo"
        :error="errors.parte_outro_descricao"
      />

      <!-- Valor Total -->
      <div class="w-full">
        <label
          for="valor-total"
          class="block text-sm font-semibold text-gray-800 mb-2.5 tracking-tight"
        >
          Valor Total
          <span class="text-danger-500 ml-0.5">*</span>
        </label>
        <div class="relative">
          <span class="absolute left-5 top-1/2 -translate-y-1/2 text-gray-600 font-medium z-10">
            R$
          </span>
          <input
            id="valor-total"
            v-model="valorTotalFormatted"
            type="text"
            placeholder="0,00"
            required
            :class="[
              'w-full pl-12 pr-5 py-3.5 border rounded-xl text-gray-900 placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-offset-0 transition-all duration-200 ease-in-out shadow-sm hover:shadow-md focus:shadow-lg',
              errors.valor_total
                ? 'border-danger-400 focus:ring-danger-500 focus:border-danger-500 bg-danger-50/30'
                : 'border-gray-200 focus:ring-primary-500 focus:border-primary-500 bg-white hover:border-gray-300'
            ]"
            @input="handleValorTotalInput"
            @blur="handleValorTotalBlur"
            @focus="handleValorTotalFocus"
          />
        </div>
        <p
          v-if="errors.valor_total"
          class="mt-2 text-sm text-danger-600 font-medium flex items-center gap-1.5"
        >
          <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
          </svg>
          {{ errors.valor_total }}
        </p>
        <p
          v-if="!errors.valor_total"
          class="mt-2 text-sm text-gray-500 font-normal"
        >
          Valor total do honorário
        </p>
      </div>

      <!-- Data de Contratação -->
      <InputData
        v-model="formData.data_contratacao"
        label="Data de Contratação"
        required
        :error="errors.data_contratacao"
        :max-date="maxDate"
      />

      <!-- Histórico -->
      <div class="w-full">
        <label
          for="descricao"
          class="block text-sm font-semibold text-gray-800 mb-2.5 tracking-tight"
        >
          Histórico
        </label>
        <textarea
          id="descricao"
          v-model="formData.descricao"
          rows="4"
          placeholder="Digite uma descrição sobre o honorário (opcional)"
          class="w-full px-5 py-3.5 border border-gray-200 rounded-xl text-gray-900 placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-offset-0 focus:ring-primary-500 focus:border-primary-500 bg-white hover:border-gray-300 shadow-sm hover:shadow-md focus:shadow-lg transition-all duration-200 ease-in-out resize-none"
        ></textarea>
      </div>

      <!-- Forma de Pagamento -->
      <Dropdown
        v-model="formData.forma_pagamento"
        label="Forma de Pagamento"
        :options="formaPagamentoOptions"
        placeholder="Selecione a forma de pagamento"
        required
        :error="errors.forma_pagamento"
        @change="handleFormaPagamentoChange"
      />

      <!-- Número de Parcelas (quando forma de pagamento for parcelado) -->
      <Input
        v-if="formData.forma_pagamento === 'parcelado'"
        v-model="formData.numero_parcelas"
        type="number"
        label="Número de Parcelas"
        placeholder="Digite o número de parcelas"
        :error="errors.numero_parcelas"
        hint="Número de parcelas para pagamento"
        min="1"
        required
        @update:model-value="handleNumeroParcelasChange"
      />

      <!-- Parcelamentos (quando forma de pagamento for parcelado) -->
      <Parcelamentos
        v-if="formData.forma_pagamento === 'parcelado' && formData.numero_parcelas && parseInt(formData.numero_parcelas) > 0"
        v-model="parcelasData"
        :numero-parcelas="parseInt(formData.numero_parcelas) || 0"
        :valor-total="formData.valor_total"
        :honorario-id="props.honorarioId"
        :errors="parcelasErrors"
        @validation="handleParcelasValidation"
      />

      <!-- Seção: Definir Divisão de Honorários -->
      <div class="w-full space-y-4 p-6 bg-gray-50 rounded-xl border border-gray-200">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">
          Definir Divisão de Honorários
        </h3>
        
        <div class="space-y-4">
          <!-- Dividir entre Sócios -->
          <Toggle
            v-model="formData.dividir_entre_socios"
            label="Dividir entre Sócios"
            description="Dividir entre sócios"
            @change="handleDividirSociosChange"
          />

          <!-- Dividir entre Advogados Parceiros -->
          <Toggle
            v-model="formData.dividir_entre_advogados_parceiros"
            label="Dividir entre Advogados Parceiros"
            description="Dividir entre advogados parceiros"
            @change="handleDividirAdvogadosParceirosChange"
          />
        </div>
      </div>

      <!-- Sócios (quando dividir entre sócios) -->
      <AdvogadosPercentual
        v-if="formData.dividir_entre_socios"
        v-model="advogadosPercentuais"
        :error="errors.advogados_total"
        @validation="handleAdvogadosValidation"
      />

      <!-- Advogados Parceiros (quando dividir entre advogados parceiros) -->
      <AdvogadosParceirosPercentual
        v-if="formData.dividir_entre_advogados_parceiros"
        v-model="advogadosParceirosPercentuais"
        :error="errors.advogados_parceiros_total"
        @validation="handleAdvogadosParceirosValidation"
      />

      <!-- Advogado Responsável (quando NÃO dividir entre sócios) -->
      <Dropdown
        v-if="!formData.dividir_entre_socios"
        v-model="formData.advogado_responsavel_id"
        label="Advogado Responsável"
        :options="advogadosOptions"
        placeholder="Selecione o advogado responsável"
        required
        :error="errors.advogado_responsavel_id"
      />

      <!-- Botões de Ação -->
      <div class="flex items-center justify-end gap-4 pt-4 border-t border-gray-200">
        <Button
          type="button"
          variant="outline"
          @click="handleCancel"
        >
          Cancelar
        </Button>
        <Button
          type="submit"
          :disabled="isSubmitting"
        >
          {{ isSubmitting ? 'Salvando...' : 'Salvar' }}
        </Button>
      </div>
    </form>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, watch } from 'vue'
import Input from './Input.vue'
import InputData from './InputData.vue'
import Dropdown from './Dropdown.vue'
import Toggle from './Toggle.vue'
import Button from './Button.vue'
import AdvogadosPercentual from './AdvogadosPercentual.vue'
import AdvogadosParceirosPercentual from './AdvogadosParceirosPercentual.vue'
import Parcelamentos from './Parcelamentos.vue'

const props = defineProps({
  honorarioId: {
    type: String,
    default: null
  }
})

const emit = defineEmits(['submit', 'cancel', 'error'])

const supabase = useSupabaseClient()
const toast = useToast()

const isSubmitting = ref(false)
const clientes = ref([])
const advogados = ref([])
const clienteSearch = ref('')
const showClienteResults = ref(false)
const clienteSelecionado = ref(null)
const advogadosPercentuais = ref([])
const advogadosValidation = ref({ isValid: false, total: 0, errors: {} })
const advogadosParceirosPercentuais = ref([])
const advogadosParceirosValidation = ref({ isValid: false, total: 0, errors: {} })
const valorTotalFormatted = ref('')
const parcelasData = ref([])
const parcelasValidation = ref({ isValid: false, errors: {} })
const parcelasErrors = ref({})

// Opções de enum
const parteOptions = [
  { value: 'autor', label: 'Autor' },
  { value: 'reu', label: 'Réu' },
  { value: 'terceiro_interessado', label: 'Terceiro Interessado' },
  { value: 'outro', label: 'Outro' }
]

const formaPagamentoOptions = [
  { value: 'avista', label: 'À Vista' },
  { value: 'parcelado', label: 'Parcelado' }
]

const statusOptions = [
  { value: 'pendente', label: 'Pendente' },
  { value: 'pago', label: 'Pago' },
  { value: 'cancelado', label: 'Cancelado' }
]

// Dados do formulário
const formData = reactive({
  cliente_id: '',
  cliente_tipo: '', // 'fisica' ou 'juridica'
  numero_processo: '',
  parte: '',
  parte_outro_descricao: '',
  valor_total: '',
  data_contratacao: '',
  descricao: '',
  forma_pagamento: '',
  numero_parcelas: null,
  status: 'pendente',
  dividir_entre_socios: true,
  dividir_entre_advogados_parceiros: false,
  advogado_responsavel_id: ''
})

// Erros de validação
const errors = reactive({
  cliente_id: '',
  numero_processo: '',
  parte: '',
  parte_outro_descricao: '',
  valor_total: '',
  data_contratacao: '',
  forma_pagamento: '',
  numero_parcelas: '',
  status: '',
  advogado_responsavel_id: '',
  advogados_total: '',
  advogados_parceiros_total: ''
})

// Clientes filtrados por busca
const filteredClientes = computed(() => {
  if (!clienteSearch.value || clienteSearch.value.trim() === '') {
    return clientes.value.slice(0, 10) // Limita a 10 resultados quando não há busca
  }

  const query = clienteSearch.value.toLowerCase().trim()
  
  return clientes.value.filter(cliente => {
    const nome = (cliente.nome || cliente.nome_completo || cliente.razao_social || '').toLowerCase()
    const nomeFantasia = (cliente.nome_fantasia || '').toLowerCase()
    
    return nome.includes(query) || nomeFantasia.includes(query)
  }).slice(0, 10) // Limita a 10 resultados
})

// Opções de advogados para o dropdown
const advogadosOptions = computed(() => {
  return advogados.value
    .filter(advogado => advogado.ativo !== false) // Filtra apenas advogados ativos
    .map(advogado => ({
      value: advogado.id,
      label: `${advogado.nome}${advogado.oab_numero ? ` - OAB ${advogado.oab_numero}/${advogado.oab_uf}` : ''}`
    }))
})

// Data máxima (hoje) - formato YYYY-MM-DD
const maxDate = computed(() => {
  const today = new Date()
  const year = today.getFullYear()
  const month = String(today.getMonth() + 1).padStart(2, '0')
  const day = String(today.getDate()).padStart(2, '0')
  return `${year}-${month}-${day}`
})

// Função para limpar erros
const clearErrors = () => {
  Object.keys(errors).forEach(key => {
    errors[key] = ''
  })
}

// Funções para formatação de moeda brasileira
const formatCurrency = (value) => {
  if (!value && value !== 0) return ''
  
  // Converte para número se for string
  const numValue = typeof value === 'string' ? parseFloat(value.replace(/[^\d,.-]/g, '').replace(',', '.')) : value
  
  if (isNaN(numValue)) return ''
  
  // Formata como moeda brasileira
  return new Intl.NumberFormat('pt-BR', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  }).format(numValue)
}

const unformatCurrency = (value) => {
  if (!value) return ''
  
  // Remove tudo exceto números, vírgula e ponto
  const cleaned = value.toString().replace(/[^\d,.-]/g, '')
  
  // Substitui vírgula por ponto para conversão
  const normalized = cleaned.replace(',', '.')
  
  // Remove pontos que não sejam decimais (separadores de milhar)
  const parts = normalized.split('.')
  if (parts.length > 2) {
    // Se há múltiplos pontos, mantém apenas o último como decimal
    const integerPart = parts.slice(0, -1).join('')
    const decimalPart = parts[parts.length - 1]
    return `${integerPart}.${decimalPart}`
  }
  
  return normalized
}

// Handlers para o campo Valor Total
const handleValorTotalInput = (event) => {
  let inputValue = event.target.value
  
  // Remove apenas caracteres não permitidos (mantém números, vírgula e ponto)
  inputValue = inputValue.replace(/[^\d,.-]/g, '')
  
  // Se está vazio, limpa tudo
  if (inputValue === '' || inputValue === '.' || inputValue === ',') {
    formData.valor_total = ''
    valorTotalFormatted.value = ''
    if (errors.valor_total) {
      errors.valor_total = ''
    }
    return
  }
  
  // Atualiza o valor formatado (sem formatar ainda, apenas limpa caracteres inválidos)
  valorTotalFormatted.value = inputValue
  
  // Converte para número para atualizar formData (mas não formata ainda)
  let normalized = inputValue.replace(',', '.')
  
  // Trata múltiplos pontos/vírgulas
  const parts = normalized.split('.')
  if (parts.length > 2) {
    const integerPart = parts.slice(0, -1).join('')
    const decimalPart = parts[parts.length - 1]
    normalized = `${integerPart}.${decimalPart}`
  }
  
  const numValue = parseFloat(normalized)
  
  if (!isNaN(numValue) && numValue >= 0) {
    // Atualiza o valor numérico no formData
    formData.valor_total = numValue.toString()
  } else {
    // Se não é válido ainda, mantém vazio no formData
    formData.valor_total = ''
  }
  
  // Limpa erro se houver
  if (errors.valor_total) {
    errors.valor_total = ''
  }
}

const handleValorTotalBlur = () => {
  // Formata o valor ao sair do campo
  if (valorTotalFormatted.value) {
    const unformatted = unformatCurrency(valorTotalFormatted.value)
    const numValue = parseFloat(unformatted)
    
    if (!isNaN(numValue) && numValue >= 0) {
      // Atualiza formData com o valor numérico
      formData.valor_total = numValue.toString()
      // Formata para exibição
      valorTotalFormatted.value = formatCurrency(numValue)
    } else {
      // Se não é válido, limpa
      formData.valor_total = ''
      valorTotalFormatted.value = ''
    }
  } else {
    formData.valor_total = ''
  }
}

const handleValorTotalFocus = (event) => {
  // Remove formatação ao focar para facilitar edição
  // Converte o valor formatado de volta para número simples
  if (formData.valor_total) {
    const numValue = parseFloat(formData.valor_total)
    if (!isNaN(numValue)) {
      // Mostra o valor sem formatação para facilitar edição
      // Mas mantém com vírgula como separador decimal
      valorTotalFormatted.value = numValue.toString().replace('.', ',')
    }
  }
  // Seleciona todo o texto
  setTimeout(() => {
    event.target.select()
  }, 0)
}

// Handler para mudança do toggle "Dividir entre Sócios"
const handleDividirSociosChange = (value) => {
  if (!value) {
    // Quando desativa, limpa os advogados e percentuais
    advogadosPercentuais.value = []
    errors.advogados_total = ''
    
    // Se ambos os toggles estiverem desativados, limpa o advogado responsável
    if (!formData.dividir_entre_advogados_parceiros) {
      formData.advogado_responsavel_id = ''
      errors.advogado_responsavel_id = ''
    }
  } else {
    // Quando ativa, limpa o advogado responsável único (se ambos os toggles não estiverem ativos)
    if (!formData.dividir_entre_advogados_parceiros) {
      formData.advogado_responsavel_id = ''
      errors.advogado_responsavel_id = ''
    }
  }
}

// Handler para mudança do toggle "Dividir entre Advogados Parceiros"
const handleDividirAdvogadosParceirosChange = (value) => {
  if (!value) {
    // Quando desativa, limpa os advogados parceiros e percentuais
    advogadosParceirosPercentuais.value = []
    errors.advogados_parceiros_total = ''
    
    // Se ambos os toggles estiverem desativados, limpa o advogado responsável
    if (!formData.dividir_entre_socios) {
      formData.advogado_responsavel_id = ''
      errors.advogado_responsavel_id = ''
    }
  } else {
    // Quando ativa, limpa o advogado responsável único (se ambos os toggles não estiverem ativos)
    if (!formData.dividir_entre_socios) {
      formData.advogado_responsavel_id = ''
      errors.advogado_responsavel_id = ''
    }
  }
}

// Handler para validação dos advogados
const handleAdvogadosValidation = (validation) => {
  advogadosValidation.value = validation
  
  if (!validation.isValid) {
    errors.advogados_total = validation.errors.total || 'A soma dos percentuais deve ser exatamente 100%'
  } else {
    errors.advogados_total = ''
  }
}

// Handler para validação dos advogados parceiros
const handleAdvogadosParceirosValidation = (validation) => {
  advogadosParceirosValidation.value = validation
  
  if (!validation.isValid) {
    errors.advogados_parceiros_total = validation.errors.total || 'A soma dos percentuais deve ser exatamente 100%'
  } else {
    errors.advogados_parceiros_total = ''
  }
}

// Validação do formulário
const validate = () => {
  clearErrors()
  let isValid = true

  // Validar cliente
  if (!formData.cliente_id || !formData.cliente_tipo) {
    errors.cliente_id = 'Cliente é obrigatório'
    isValid = false
  }

  // Validar número do processo
  if (!formData.numero_processo || formData.numero_processo.trim() === '') {
    errors.numero_processo = 'Número do processo é obrigatório'
    isValid = false
  }

  // Validar parte
  if (!formData.parte) {
    errors.parte = 'Parte no processo é obrigatória'
    isValid = false
  }

  // Validar descrição da parte se for "outro"
  if (formData.parte === 'outro' && (!formData.parte_outro_descricao || formData.parte_outro_descricao.trim() === '')) {
    errors.parte_outro_descricao = 'Descrição da parte é obrigatória quando selecionado "Outro"'
    isValid = false
  }

  // Validar advogados e percentuais (se dividir entre sócios)
  if (formData.dividir_entre_socios) {
    if (!advogadosValidation.value.isValid) {
      errors.advogados_total = advogadosValidation.value.errors.total || 'A soma dos percentuais deve ser exatamente 100%'
      isValid = false
    } else if (advogadosPercentuais.value.length === 0) {
      errors.advogados_total = 'Selecione pelo menos um advogado para dividir o honorário'
      isValid = false
    }
  }

  // Validar advogados parceiros e percentuais (se dividir entre advogados parceiros)
  if (formData.dividir_entre_advogados_parceiros) {
    if (!advogadosParceirosValidation.value.isValid) {
      errors.advogados_parceiros_total = advogadosParceirosValidation.value.errors.total || 'A soma dos percentuais deve ser exatamente 100%'
      isValid = false
    } else if (advogadosParceirosPercentuais.value.length === 0) {
      errors.advogados_parceiros_total = 'Selecione pelo menos um advogado parceiro para dividir o honorário'
      isValid = false
    }
  }

  // Validar advogado responsável (quando NÃO dividir entre sócios E NÃO dividir entre parceiros)
  if (!formData.dividir_entre_socios && !formData.dividir_entre_advogados_parceiros) {
    if (!formData.advogado_responsavel_id || formData.advogado_responsavel_id === '') {
      errors.advogado_responsavel_id = 'Advogado responsável é obrigatório'
      isValid = false
    }
  }

  // Validar valor total
  if (!formData.valor_total || formData.valor_total === '' || formData.valor_total === '0') {
    errors.valor_total = 'Valor total é obrigatório'
    isValid = false
  } else {
    const valor = parseFloat(formData.valor_total)
    if (isNaN(valor) || valor <= 0) {
      errors.valor_total = 'Valor total deve ser maior que zero'
      isValid = false
    }
  }

  // Validar data de contratação
  if (!formData.data_contratacao) {
    errors.data_contratacao = 'Data de contratação é obrigatória'
    isValid = false
  }

  // Validar forma de pagamento
  if (!formData.forma_pagamento) {
    errors.forma_pagamento = 'Forma de pagamento é obrigatória'
    isValid = false
  }

  // Validar número de parcelas se forma de pagamento for parcelado
  if (formData.forma_pagamento === 'parcelado') {
    if (!formData.numero_parcelas || formData.numero_parcelas === '') {
      errors.numero_parcelas = 'Número de parcelas é obrigatório quando forma de pagamento é parcelado'
      isValid = false
    } else {
      const numParcelas = parseInt(formData.numero_parcelas)
      if (isNaN(numParcelas) || numParcelas < 1) {
        errors.numero_parcelas = 'Número de parcelas deve ser maior que zero'
        isValid = false
      } else {
        // Valida as parcelas
        if (!parcelasValidation.value.isValid) {
          errors.numero_parcelas = 'Configure todas as parcelas corretamente'
          isValid = false
        }
        if (parcelasData.value.length !== numParcelas) {
          errors.numero_parcelas = 'Todas as parcelas devem ser configuradas'
          isValid = false
        }
      }
    }
  }

  return isValid
}

// Buscar clientes
const fetchClientes = async () => {
  try {
    // Busca clientes pessoa física
    const { data: dataFisica, error: errorFisica } = await supabase
      .from('clientes_pessoa_fisica')
      .select('id, nome_completo')
      .order('nome_completo', { ascending: true })

    // Busca clientes pessoa jurídica
    const { data: dataJuridica, error: errorJuridica } = await supabase
      .from('clientes_pessoa_juridica')
      .select('id, razao_social, nome_fantasia')
      .order('razao_social', { ascending: true })

    if (errorFisica) {
      console.error('Erro ao buscar clientes pessoa física:', errorFisica)
    }

    if (errorJuridica) {
      console.error('Erro ao buscar clientes pessoa jurídica:', errorJuridica)
    }

    // Mapeia os dados adicionando tipo
    const clientesPF = (dataFisica || []).map(cliente => ({
      ...cliente,
      tipo: 'PF',
      nome: cliente.nome_completo,
      tipo_cliente: 'fisica'
    }))

    const clientesPJ = (dataJuridica || []).map(cliente => ({
      ...cliente,
      tipo: 'PJ',
      nome: cliente.razao_social,
      tipo_cliente: 'juridica'
    }))

    // Combina e ordena todos os clientes
    clientes.value = [...clientesPF, ...clientesPJ].sort((a, b) => {
      const nomeA = a.nome || a.razao_social || ''
      const nomeB = b.nome || b.razao_social || ''
      return nomeA.localeCompare(nomeB, 'pt-BR', { sensitivity: 'base' })
    })
  } catch (error) {
    console.error('Erro inesperado ao buscar clientes:', error)
  }
}

// Buscar advogados
const fetchAdvogados = async () => {
  try {
    const { data, error } = await supabase
      .from('advogados')
      .select('id, nome, oab_numero, oab_uf, ativo')
      .order('nome', { ascending: true })

    if (error) {
      console.error('Erro ao buscar advogados:', error)
      return
    }

    advogados.value = data || []
  } catch (error) {
    console.error('Erro inesperado ao buscar advogados:', error)
  }
}

// Handlers
const handleClienteSearch = () => {
  showClienteResults.value = true
}

const handleClienteBlur = () => {
  // Delay para permitir click no resultado
  setTimeout(() => {
    showClienteResults.value = false
  }, 200)
}

const selectCliente = (cliente) => {
  clienteSelecionado.value = cliente
  formData.cliente_id = cliente.id
  formData.cliente_tipo = cliente.tipo_cliente
  clienteSearch.value = cliente.nome || cliente.razao_social
  showClienteResults.value = false
  
  // Limpa erro se houver
  if (errors.cliente_id) {
    errors.cliente_id = ''
  }
}

const handleParteChange = () => {
  // Limpa a descrição quando muda a parte
  if (formData.parte !== 'outro') {
    formData.parte_outro_descricao = ''
  }
}

const handleFormaPagamentoChange = () => {
  // Limpa número de parcelas quando muda a forma de pagamento
  if (formData.forma_pagamento !== 'parcelado') {
    formData.numero_parcelas = null
    parcelasData.value = []
    parcelasErrors.value = {}
  }
  
  // Define o status automaticamente baseado na forma de pagamento
  if (formData.forma_pagamento === 'parcelado') {
    formData.status = 'pendente'
  } else if (formData.forma_pagamento === 'avista') {
    formData.status = 'pago'
  }
}

// Handler para mudança no número de parcelas
const handleNumeroParcelasChange = () => {
  // Limpa erros de parcelas quando muda o número
  parcelasErrors.value = {}
  // O componente Parcelamentos vai reagir automaticamente à mudança
}

// Handler para validação das parcelas
const handleParcelasValidation = (validation) => {
  parcelasValidation.value = validation
  parcelasErrors.value = validation.errors || {}
}

const handleSubmit = async () => {
  if (!validate()) {
    return
  }

  isSubmitting.value = true

  try {
    // Define o status automaticamente baseado na forma de pagamento
    let statusAutomatico = formData.status
    if (formData.forma_pagamento === 'parcelado') {
      statusAutomatico = 'pendente'
    } else if (formData.forma_pagamento === 'avista') {
      statusAutomatico = 'pago'
    }
    
    // Prepara os dados para salvar
    const dataToSave = {
      numero_processo: formData.numero_processo.trim(),
      parte: formData.parte,
      parte_outro_descricao: formData.parte_outro_descricao.trim() || null,
      valor_total: parseFloat(formData.valor_total),
      data_contratacao: formData.data_contratacao,
      descricao: formData.descricao.trim() || null,
      forma_pagamento: formData.forma_pagamento,
      numero_parcelas: formData.numero_parcelas ? parseInt(formData.numero_parcelas) : null,
      status: statusAutomatico,
      dividir_entre_socios: formData.dividir_entre_socios,
      advogado_responsavel_id: formData.dividir_entre_socios ? null : (formData.advogado_responsavel_id || null),
      updated_at: new Date().toISOString()
    }
    
    // Se dividir entre sócios, os advogados e percentuais serão salvos em uma tabela relacionada
    // Por enquanto, salvamos apenas no honorário principal
    // TODO: Implementar tabela de relacionamento honorarios_advogados no banco de dados

    // Define o cliente baseado no tipo
    if (formData.cliente_tipo === 'fisica') {
      dataToSave.cliente_pessoa_fisica_id = formData.cliente_id
      dataToSave.cliente_pessoa_juridica_id = null
    } else {
      dataToSave.cliente_pessoa_juridica_id = formData.cliente_id
      dataToSave.cliente_pessoa_fisica_id = null
    }

    let result
    if (props.honorarioId) {
      // Atualizar honorário existente
      result = await supabase
        .from('honorarios')
        .update(dataToSave)
        .eq('id', props.honorarioId)
        .select()
    } else {
      // Criar novo honorário
      result = await supabase
        .from('honorarios')
        .insert([dataToSave])
        .select()
    }

    const { data, error } = result

    if (error) {
      console.error('Erro ao salvar honorário:', error)
      const errorMessage = error.message || 'Erro ao salvar honorário. Tente novamente.'
      toast.showError(errorMessage, 5000)
      // Emite evento de erro para a página
      emit('error', errorMessage)
      isSubmitting.value = false
      return
    }

    // Se criou novo honorário, pega o ID
    let honorarioId = props.honorarioId
    if (data && data[0]) {
      honorarioId = data[0].id
    }

    // Salva movimentações financeiras (sempre, independente da forma de pagamento)
    if (honorarioId) {
      try {
        await saveParcelas(honorarioId)
      } catch (parcelasError) {
        console.error('Erro ao salvar movimentações financeiras:', parcelasError)
        toast.showError('Honorário salvo, mas houve erro ao salvar movimentações financeiras.', 5000)
      }
    }

    // Salva divisão entre sócios se dividir_entre_socios for true
    if (formData.dividir_entre_socios && advogadosPercentuais.value.length > 0 && honorarioId) {
      try {
        await saveAdvogadosSocios(honorarioId)
      } catch (sociosError) {
        console.error('Erro ao salvar divisão entre sócios:', sociosError)
        toast.showError('Honorário salvo, mas houve erro ao salvar divisão entre sócios.', 5000)
      }
    }

    // Salva histórico se houver descrição
    if (formData.descricao && formData.descricao.trim() !== '' && honorarioId) {
      try {
        await saveHistorico(honorarioId)
      } catch (historicoError) {
        console.error('Erro ao salvar histórico:', historicoError)
        // Não mostra erro para histórico, pois é opcional
      }
    }

    // Sucesso
    toast.success(`Honorário ${props.honorarioId ? 'atualizado' : 'cadastrado'} com sucesso!`, 3000)
    
    // Emite evento de sucesso
    emit('submit', data ? data[0] : null)
    
  } catch (error) {
    console.error('Erro inesperado ao salvar honorário:', error)
    const errorMessage = error?.message || 'Erro inesperado ao salvar honorário. Tente novamente.'
    toast.showError(errorMessage, 5000)
    // Emite evento de erro para a página
    emit('error', errorMessage)
  } finally {
    isSubmitting.value = false
  }
}

const handleCancel = () => {
  emit('cancel')
}

// Função para salvar movimentações financeiras (parcelas)
const saveParcelas = async (honorarioId) => {
  try {
    // Primeiro, remove parcelas antigas (se estiver editando)
    if (props.honorarioId) {
      const { error: deleteError } = await supabase
        .from('honorarios_parcelas')
        .delete()
        .eq('honorario_id', honorarioId)

      if (deleteError) {
        console.error('Erro ao remover parcelas antigas:', deleteError)
      }
    }

    // Busca o número do processo, forma de pagamento e valor total do honorário
    const { data: honorarioData, error: honorarioError } = await supabase
      .from('honorarios')
      .select('numero_processo, forma_pagamento, valor_total, data_contratacao')
      .eq('id', honorarioId)
      .single()

    if (honorarioError) {
      console.error('Erro ao buscar dados do honorário:', honorarioError)
      throw honorarioError
    }

    let parcelasToInsert = []

    // Se for "À Vista", cria uma única parcela Nº 01
    if (honorarioData.forma_pagamento === 'avista') {
      parcelasToInsert = [{
        honorario_id: honorarioId,
        numero_processo: honorarioData.numero_processo,
        numero_da_parcela: 1,
        valor_parcela: parseFloat(honorarioData.valor_total) || 0,
        valor_pago_parcela: parseFloat(honorarioData.valor_total) || 0, // Totalmente pago
        forma_pagamento: 'À Vista',
        status: 'paga',
        data_vencimento: honorarioData.data_contratacao || new Date().toISOString().split('T')[0],
        data_pagamento: honorarioData.data_contratacao || new Date().toISOString().split('T')[0],
        updated_at: new Date().toISOString()
      }]
    } 
    // Se for "Parcelado", usa as parcelas do formulário
    else if (honorarioData.forma_pagamento === 'parcelado' && parcelasData.value.length > 0) {
      parcelasToInsert = parcelasData.value.map(parcela => ({
        honorario_id: honorarioId,
        numero_processo: honorarioData.numero_processo,
        numero_da_parcela: parcela.numero_parcela,
        valor_parcela: parseFloat(parcela.valor) || 0,
        valor_pago_parcela: parcela.pago ? parseFloat(parcela.valor) || 0 : 0,
        forma_pagamento: 'Parcelado',
        status: parcela.pago ? 'paga' : 'pendente',
        data_vencimento: parcela.data_vencimento,
        data_pagamento: parcela.pago ? (parcela.data_pagamento || new Date().toISOString().split('T')[0]) : null,
        updated_at: new Date().toISOString()
      }))
    }

    // Insere as parcelas (só se houver dados para inserir)
    if (parcelasToInsert.length > 0) {
      const { error: insertError } = await supabase
        .from('honorarios_parcelas')
        .insert(parcelasToInsert)

      if (insertError) {
        console.error('Erro ao salvar movimentações financeiras:', insertError)
        throw insertError
      }
    }
  } catch (error) {
    console.error('Erro inesperado ao salvar movimentações financeiras:', error)
    throw error
  }
}

// Função para carregar parcelas
const loadParcelas = async (honorarioId) => {
  try {
    const { data, error } = await supabase
      .from('honorarios_parcelas')
      .select('*')
      .eq('honorario_id', honorarioId)
      .order('numero_da_parcela', { ascending: true })

    if (error) {
      console.error('Erro ao carregar parcelas:', error)
      return
    }

    if (data && data.length > 0) {
      parcelasData.value = data.map(parcela => ({
        id: parcela.id,
        numero_parcela: parcela.numero_da_parcela,
        valor: parseFloat(parcela.valor_parcela) || 0,
        data_vencimento: parcela.data_vencimento,
        pago: parcela.status === 'paga' || false,
        data_pagamento: parcela.data_pagamento || null
      }))
    }
  } catch (error) {
    console.error('Erro inesperado ao carregar parcelas:', error)
  }
}

// Função para salvar divisão entre sócios
const saveAdvogadosSocios = async (honorarioId) => {
  try {
    // Primeiro, remove registros antigos (se estiver editando)
    if (props.honorarioId) {
      const { error: deleteError } = await supabase
        .from('honorarios_socios')
        .delete()
        .eq('honorario_id', honorarioId)

      if (deleteError) {
        console.error('Erro ao remover divisão antiga:', deleteError)
        throw deleteError
      }
    }

    // Busca o número do processo do honorário
    const { data: honorarioData, error: honorarioError } = await supabase
      .from('honorarios')
      .select('numero_processo')
      .eq('id', honorarioId)
      .single()

    if (honorarioError) {
      console.error('Erro ao buscar número do processo:', honorarioError)
      throw honorarioError
    }

    // Prepara dados dos advogados para inserção
    const sociosToInsert = advogadosPercentuais.value.map(advogado => {
      // Busca o nome do advogado
      const advogadoInfo = advogados.value.find(a => a.id === advogado.id)
      
      return {
        honorario_id: honorarioId,
        numero_processo: honorarioData.numero_processo,
        id_advogado: advogado.id,
        nome_advogado: advogadoInfo?.nome || advogado.nome || '',
        percentual_valor: parseFloat(advogado.percentual) || 0,
        updated_at: new Date().toISOString()
      }
    })

    // Insere os sócios
    const { error: insertError } = await supabase
      .from('honorarios_socios')
      .insert(sociosToInsert)

    if (insertError) {
      console.error('Erro ao salvar divisão entre sócios:', insertError)
      throw insertError
    }
  } catch (error) {
    console.error('Erro inesperado ao salvar divisão entre sócios:', error)
    throw error
  }
}

// Função para salvar histórico
const saveHistorico = async (honorarioId) => {
  try {
    // Busca o número do processo do honorário
    const { data: honorarioData, error: honorarioError } = await supabase
      .from('honorarios')
      .select('numero_processo')
      .eq('id', honorarioId)
      .single()

    if (honorarioError) {
      console.error('Erro ao buscar número do processo:', honorarioError)
      return // Não lança erro, pois histórico é opcional
    }

    // Verifica se já existe um histórico para este honorário (mais recente)
    const { data: historicosExistentes, error: checkError } = await supabase
      .from('honorarios_historico')
      .select('id, historico')
      .eq('honorario_id', honorarioId)
      .order('created_at', { ascending: false })
      .limit(1)

    // Se já existe e o texto é o mesmo, não cria novo registro
    if (!checkError && historicosExistentes && historicosExistentes.length > 0) {
      const historicoMaisRecente = historicosExistentes[0]
      if (historicoMaisRecente.historico === formData.descricao.trim()) {
        // Histórico já existe e é o mesmo, não precisa criar novo
        return
      }
    }

    // Insere novo registro de histórico
    const { error: insertError } = await supabase
      .from('honorarios_historico')
      .insert([{
        honorario_id: honorarioId,
        numero_processo: honorarioData.numero_processo,
        historico: formData.descricao.trim(),
        updated_at: new Date().toISOString()
      }])

    if (insertError) {
      console.error('Erro ao salvar histórico:', insertError)
      // Não lança erro, pois histórico é opcional
    }
  } catch (error) {
    console.error('Erro inesperado ao salvar histórico:', error)
    // Não lança erro, pois histórico é opcional
  }
}

// Função para carregar advogados relacionados
const loadAdvogadosSocios = async (honorarioId) => {
  try {
    const { data, error } = await supabase
      .from('honorarios_socios')
      .select('*')
      .eq('honorario_id', honorarioId)
      .order('created_at', { ascending: true })

    if (error) {
      console.error('Erro ao carregar divisão entre sócios:', error)
      return
    }

    if (data && data.length > 0) {
      advogadosPercentuais.value = data.map(socio => ({
        id: socio.id_advogado,
        nome: socio.nome_advogado,
        percentual: parseFloat(socio.percentual_valor) || 0
      }))
    }
  } catch (error) {
    console.error('Erro inesperado ao carregar divisão entre sócios:', error)
  }
}

// Watch clienteSearch para limpar seleção quando limpar o campo
watch(clienteSearch, (newValue) => {
  if (!newValue || newValue.trim() === '') {
    clienteSelecionado.value = null
    formData.cliente_id = ''
    formData.cliente_tipo = ''
  }
})

// Buscar dados ao montar o componente
onMounted(async () => {
  await fetchClientes()
  await fetchAdvogados()
  
  // Se tiver honorarioId, carregar dados
  if (props.honorarioId) {
    loadHonorario()
  }
})

// Função para carregar honorário (se estiver editando)
const loadHonorario = async () => {
  try {
    const { data, error } = await supabase
      .from('honorarios')
      .select('*')
      .eq('id', props.honorarioId)
      .single()

    if (error) {
      console.error('Erro ao carregar honorário:', error)
      toast.showError('Erro ao carregar dados do honorário.', 5000)
      return
    }

    if (data) {
      // Busca o cliente selecionado (espera os clientes serem carregados)
      await fetchClientes()
      
      if (data.cliente_pessoa_fisica_id) {
        const cliente = clientes.value.find(c => c.id === data.cliente_pessoa_fisica_id && c.tipo_cliente === 'fisica')
        if (cliente) {
          clienteSelecionado.value = cliente
          formData.cliente_id = cliente.id
          formData.cliente_tipo = 'fisica'
          clienteSearch.value = cliente.nome || cliente.nome_completo
        }
      } else if (data.cliente_pessoa_juridica_id) {
        const cliente = clientes.value.find(c => c.id === data.cliente_pessoa_juridica_id && c.tipo_cliente === 'juridica')
        if (cliente) {
          clienteSelecionado.value = cliente
          formData.cliente_id = cliente.id
          formData.cliente_tipo = 'juridica'
          clienteSearch.value = cliente.nome || cliente.razao_social
        }
      }

      // Preenche os dados
      formData.numero_processo = data.numero_processo || ''
      formData.parte = data.parte || ''
      formData.parte_outro_descricao = data.parte_outro_descricao || ''
      formData.valor_total = data.valor_total ? String(data.valor_total) : ''
      // Formata o valor total para exibição
      if (data.valor_total) {
        valorTotalFormatted.value = formatCurrency(data.valor_total)
      } else {
        valorTotalFormatted.value = ''
      }
      formData.data_contratacao = data.data_contratacao || ''
      formData.descricao = data.descricao || ''
      formData.forma_pagamento = data.forma_pagamento || ''
      formData.numero_parcelas = data.numero_parcelas || null
      // Define o status automaticamente baseado na forma de pagamento
      if (formData.forma_pagamento === 'parcelado') {
        formData.status = 'pendente'
      } else if (formData.forma_pagamento === 'avista') {
        formData.status = 'pago'
      } else {
        formData.status = data.status || 'pendente'
      }
      formData.dividir_entre_socios = data.dividir_entre_socios !== undefined ? data.dividir_entre_socios : true
      formData.dividir_entre_advogados_parceiros = data.dividir_entre_advogados_parceiros !== undefined ? data.dividir_entre_advogados_parceiros : false
      
      // Carrega advogado responsável ou lista de advogados (dependendo do modo)
      if (formData.dividir_entre_socios) {
        // Carrega advogados e percentuais da tabela relacionada
        await loadAdvogadosSocios(props.honorarioId)
      } else {
        formData.advogado_responsavel_id = data.advogado_responsavel_id || ''
      }

      // Carrega movimentações financeiras (sempre, independente da forma de pagamento)
      if (props.honorarioId) {
        await loadParcelas(props.honorarioId)
      }
    }
  } catch (error) {
    console.error('Erro inesperado ao carregar honorário:', error)
    toast.showError('Erro inesperado ao carregar dados do honorário.', 5000)
  }
}
</script>

