<template>
  <div class="w-full space-y-4">
    <!-- Campo de Busca -->
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
          :error="error"
          @update:model-value="handleClienteSearch"
          @focus="showClienteResults = true"
          @blur="handleClienteBlur"
        />
        
        <!-- Dropdown de resultados -->
        <div
          v-if="showClienteResults && filteredClientes.length > 0"
          class="absolute z-[9999] w-full mt-1 bg-white border border-gray-200 rounded-xl shadow-lg max-h-60 overflow-y-auto"
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
          class="absolute z-[9999] w-full mt-1 bg-white border border-gray-200 rounded-xl shadow-lg p-4"
        >
          <p class="text-sm text-gray-500 text-center">
            Nenhum cliente encontrado
          </p>
        </div>
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
    </div>

    <!-- Campos de Visualização (somente leitura) -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mt-4">
      <!-- Telefone -->
      <Input
        :model-value="clienteDetalhes.telefone || ''"
        label="Telefone"
        placeholder="-"
        :disabled="true"
      />

      <!-- Estado Civil (sempre visível, preenchido apenas para Pessoa Física) -->
      <Input
        :model-value="clienteDetalhes.estado_civil || ''"
        label="Estado Civil"
        placeholder="-"
        :disabled="true"
      />

      <!-- CPF/CNPJ -->
      <Input
        :model-value="clienteDetalhes.documento || ''"
        :label="clienteSelecionado && clienteSelecionado.tipo === 'PF' ? 'CPF' : 'CNPJ'"
        placeholder="-"
        :disabled="true"
      />
    </div>

  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import Input from './Input.vue'
import Button from './Button.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: null
  },
  error: {
    type: String,
    default: ''
  }
})

const emit = defineEmits(['update:modelValue', 'change'])

const supabase = useSupabaseClient()

const clientes = ref([])
const clienteSearch = ref('')
const showClienteResults = ref(false)
const clienteSelecionado = ref(null)
const clienteDetalhes = ref({
  telefone: '',
  estado_civil: '',
  documento: '' // CPF ou CNPJ
})
const isLoading = ref(false)

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

// Buscar clientes
const fetchClientes = async () => {
  isLoading.value = true
  
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
  } finally {
    isLoading.value = false
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

const selectCliente = async (cliente) => {
  clienteSelecionado.value = cliente
  clienteSearch.value = cliente.nome || cliente.razao_social
  showClienteResults.value = false
  
  // Busca os detalhes completos do cliente
  await fetchClienteDetalhes(cliente)
  
  // Emite o cliente selecionado
  const clienteData = {
    id: cliente.id,
    tipo: cliente.tipo_cliente,
    nome: cliente.nome || cliente.razao_social,
    nome_fantasia: cliente.nome_fantasia || null
  }
  
  emit('update:modelValue', clienteData)
  emit('change', clienteData)
}

// Buscar detalhes completos do cliente selecionado
const fetchClienteDetalhes = async (cliente) => {
  try {
    if (cliente.tipo_cliente === 'fisica') {
      // Busca cliente pessoa física
      const { data, error } = await supabase
        .from('clientes_pessoa_fisica')
        .select('telefone, estado_civil, cpf')
        .eq('id', cliente.id)
        .single()

      if (error) {
        console.error('Erro ao buscar detalhes do cliente:', error)
        clienteDetalhes.value = {
          telefone: '',
          estado_civil: '',
          documento: ''
        }
        return
      }

      if (data) {
        clienteDetalhes.value = {
          telefone: data.telefone || '',
          estado_civil: data.estado_civil || '',
          documento: data.cpf || ''
        }
      }
    } else {
      // Busca cliente pessoa jurídica
      const { data, error } = await supabase
        .from('clientes_pessoa_juridica')
        .select('telefone, cnpj')
        .eq('id', cliente.id)
        .single()

      if (error) {
        console.error('Erro ao buscar detalhes do cliente:', error)
        clienteDetalhes.value = {
          telefone: '',
          estado_civil: '',
          documento: ''
        }
        return
      }

      if (data) {
        clienteDetalhes.value = {
          telefone: data.telefone || '',
          estado_civil: '', // Não aplicável para PJ
          documento: data.cnpj || ''
        }
      }
    }
  } catch (error) {
    console.error('Erro inesperado ao buscar detalhes do cliente:', error)
    clienteDetalhes.value = {
      telefone: '',
      estado_civil: '',
      documento: ''
    }
  }
}

// Watch clienteSearch para limpar seleção quando limpar o campo
watch(clienteSearch, (newValue) => {
  if (!newValue || newValue.trim() === '') {
    clienteSelecionado.value = null
    clienteDetalhes.value = {
      telefone: '',
      estado_civil: '',
      documento: ''
    }
    emit('update:modelValue', null)
    emit('change', null)
  }
})

// Watch para atualizar campo quando modelValue mudar externamente
watch(() => props.modelValue, async (newValue) => {
  if (newValue && newValue.id) {
    // Se há um cliente selecionado, atualiza o campo de busca
    clienteSearch.value = newValue.nome || newValue.razao_social || ''
    // Busca o cliente completo na lista
    const cliente = clientes.value.find(c => c.id === newValue.id)
    if (cliente) {
      clienteSelecionado.value = cliente
      // Busca os detalhes do cliente
      await fetchClienteDetalhes(cliente)
    }
  } else if (!newValue) {
    // Se modelValue for null, limpa o campo
    clienteSearch.value = ''
    clienteSelecionado.value = null
    clienteDetalhes.value = {
      telefone: '',
      estado_civil: '',
      documento: ''
    }
  }
}, { immediate: true })

// Buscar clientes ao montar
onMounted(async () => {
  await fetchClientes()
  
  // Se há um valor inicial, atualiza o campo
  if (props.modelValue && props.modelValue.id) {
    clienteSearch.value = props.modelValue.nome || props.modelValue.razao_social || ''
    const cliente = clientes.value.find(c => c.id === props.modelValue.id)
    if (cliente) {
      clienteSelecionado.value = cliente
      // Busca os detalhes do cliente
      await fetchClienteDetalhes(cliente)
    }
  }
})
</script>
