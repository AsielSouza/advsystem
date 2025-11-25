<template>
  <div class="w-full">
    <!-- Timeline de Atualizações -->
    <div v-if="historico && historico.length > 0" class="relative">
      <!-- Linha vertical da timeline -->
      <div class="absolute left-4 top-0 bottom-0 w-0.5 bg-gray-200"></div>

      <!-- Itens da Timeline -->
      <div class="space-y-6">
        <div
          v-for="(item, index) in historico"
          :key="item.id"
          class="relative flex gap-4"
        >
          <!-- Círculo da Timeline -->
          <div class="relative z-10 flex-shrink-0">
            <div class="h-8 w-8 rounded-full bg-primary-500 border-4 border-white shadow-md flex items-center justify-center">
              <div class="h-2 w-2 rounded-full bg-white"></div>
            </div>
          </div>

          <!-- Conteúdo da Atualização -->
          <div class="flex-1 pb-6">
            <div class="bg-white rounded-lg border border-gray-200 shadow-sm hover:shadow-md transition-shadow p-4">
              <!-- Data, Hora e Usuário -->
              <div class="flex items-center justify-between mb-2">
                <div class="flex items-center gap-2 flex-wrap">
                  <span class="text-xs font-medium text-gray-500">
                    {{ formatarDataHora(item.created_at) }}
                  </span>
                  <!-- Se foi editado, mostra "Editado por", senão mostra "Criado por" -->
                  <span v-if="item.editado_por" class="text-xs text-orange-500">
                    • Editado por {{ item.editado_por }}
                  </span>
                  <span v-else-if="item.criado_por" class="text-xs text-gray-400">
                    • Criado por {{ item.criado_por }}
                  </span>
                  <span v-else-if="item.usuario_nome" class="text-xs text-gray-400">
                    • Criado por {{ item.usuario_nome }}
                  </span>
                </div>
                <ButtonEdit
                  @click="$emit('editar', item)"
                  title="Editar atualização"
                />
              </div>

              <!-- Texto do Histórico -->
              <div class="text-sm text-gray-900 whitespace-pre-wrap">
                {{ item.historico }}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Mensagem quando não há histórico -->
    <div v-else class="text-center py-12 bg-gray-50 rounded-lg border border-gray-200">
      <svg
        class="mx-auto h-12 w-12 text-gray-400 mb-4"
        fill="none"
        stroke="currentColor"
        viewBox="0 0 24 24"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
        />
      </svg>
      <p class="text-gray-500 text-sm">Nenhuma atualização registrada ainda</p>
      <p class="text-gray-400 text-xs mt-1">Clique em "Atualizar Histórico" para adicionar a primeira atualização</p>
    </div>
  </div>
</template>

<script setup>
import ButtonEdit from './ButtonEdit.vue'

const props = defineProps({
  historico: {
    type: Array,
    default: () => []
  }
})

defineEmits(['editar'])

// Formata data e hora
const formatarDataHora = (data) => {
  if (!data) return '-'
  const d = new Date(data)
  const dataFormatada = d.toLocaleDateString('pt-BR', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric'
  })
  const horaFormatada = d.toLocaleTimeString('pt-BR', {
    hour: '2-digit',
    minute: '2-digit'
  })
  return `${dataFormatada} às ${horaFormatada}`
}
</script>

