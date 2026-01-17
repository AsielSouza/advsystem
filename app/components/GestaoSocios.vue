<template>
  <div class="h-full w-full bg-gray-50 py-4 sm:py-8 px-4 sm:px-6 overflow-y-auto">
    <div class="max-w-7xl mx-auto w-full">
      <!-- Cabeçalho da página -->
      <div class="mb-8">
        <div class="flex items-center justify-between mb-4">
          <ButtonBack @click="handleVoltar" />
        </div>
        <div class="flex items-center justify-between">
          <div>
            <h1 class="text-3xl font-bold text-gray-900 mb-2">
              Gestão de Sócios
            </h1>
            <p class="text-gray-600">
              Gerencie sócios, parceiros e advogados do sistema
            </p>
          </div>
          <slot name="header-actions">
            <!-- Botões de ação podem ser passados via slot -->
          </slot>
        </div>
      </div>

      <!-- Navegação das Abas -->
      <div class="bg-white rounded-xl shadow-lg border border-gray-200 overflow-hidden">
        <div class="border-b border-gray-200">
          <nav class="flex space-x-8 px-6" aria-label="Tabs">
            <button
              v-for="tab in tabs"
              :key="tab.id"
              @click="abaAtiva = tab.id"
              :class="[
                'py-4 px-1 border-b-2 font-medium text-sm transition-colors',
                abaAtiva === tab.id
                  ? 'border-primary-500 text-primary-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              ]"
            >
              <div class="flex items-center gap-2">
                <template v-if="tab.icon">
                  <component
                    :is="tab.icon"
                    class="h-5 w-5"
                    :class="abaAtiva === tab.id ? 'text-primary-600' : 'text-gray-400'"
                  />
                </template>
                <span>{{ tab.label }}</span>
              </div>
            </button>
          </nav>
        </div>

        <!-- Conteúdo das Abas -->
        <div class="p-6">
          <!-- Aba: Sócios -->
          <div v-if="abaAtiva === 'socios'">
            <slot name="aba-socios">
              <TabelaSocios
                @edit="handleEdit"
                @delete="handleDelete"
              />
            </slot>
          </div>

          <!-- Aba: Parceiros (preparado para futuro) -->
          <div v-if="abaAtiva === 'parceiros'">
            <slot name="aba-parceiros">
              <div class="text-center py-12">
                <svg
                  class="mx-auto h-12 w-12 text-gray-400"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"
                  />
                </svg>
                <p class="mt-4 text-gray-600">Gestão de Parceiros em desenvolvimento</p>
              </div>
            </slot>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import ButtonBack from './ButtonBack.vue'
import TabelaSocios from './TabelaSocios.vue'

const router = useRouter()

// Props
const props = defineProps({
  // Permite definir a aba inicial
  abaInicial: {
    type: String,
    default: 'socios'
  }
})

// Emits
const emit = defineEmits(['edit', 'delete', 'voltar'])

// Aba ativa
const abaAtiva = ref(props.abaInicial)

// Definição das abas
const tabs = [
  {
    id: 'socios',
    label: 'Sócios',
    icon: null // Pode ser adicionado um componente de ícone
  },
  {
    id: 'parceiros',
    label: 'Parceiros',
    icon: null // Pode ser adicionado um componente de ícone
  }
]

// Função para voltar
const handleVoltar = () => {
  emit('voltar')
  router.push('/')
}

// Função para editar sócio
const handleEdit = (advogado) => {
  emit('edit', advogado)
}

// Função para excluir sócio
const handleDelete = (advogado) => {
  emit('delete', advogado)
}

// Expor métodos úteis (se necessário no futuro)
defineExpose({
  // Métodos podem ser adicionados aqui conforme necessário
})
</script>
