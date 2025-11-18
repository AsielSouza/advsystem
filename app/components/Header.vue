<template>
  <header class="bg-white shadow-md border-b border-gray-200">
    <div class="max-w-full mx-auto px-6 py-4">
      <div class="flex items-center justify-between">
        <!-- Logo/Home Button à esquerda -->
        <button
          class="text-2xl font-bold text-primary-600 hover:text-primary-700 transition-colors"
        >
          AdvSystem
        </button>

        <!-- Nome do usuário, Configuração e Logout à direita -->
        <div class="flex items-center gap-4">
          <span v-if="displayName" class="text-gray-700 font-medium">
            {{ displayName }}
          </span>
          <span v-else class="text-gray-400 font-medium text-sm">
            Carregando...
          </span>
          <Configuration />
          <LogoutButton />
        </div>
      </div>
    </div>
  </header>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import Configuration from './Configuration.vue'
import LogoutButton from './LogoutButton.vue'

// useSupabaseClient é auto-importado pelo Nuxt
const supabase = useSupabaseClient()
const displayName = ref('')

const fetchUserDisplayName = async () => {
  try {
    // Busca o usuário autenticado
    const { data: { user } } = await supabase.auth.getUser()
    
    if (!user) {
      displayName.value = ''
      return
    }

    // Tenta buscar o display_name da tabela de perfis
    // Primeiro, tenta buscar de uma tabela 'profiles'
    const { data: profile, error: profileError } = await (supabase
      .from('profiles') as any)
      .select('display_name')
      .eq('id', user.id)
      .single()

    if (!profileError && profile?.display_name) {
      displayName.value = profile.display_name
      return
    }

    // Se não encontrar na tabela profiles, tenta user_metadata
    if (user.user_metadata?.display_name) {
      displayName.value = user.user_metadata.display_name
      return
    }

    // Se não encontrar display_name, usa o email como fallback
    if (user.email) {
      displayName.value = user.email.split('@')[0]
      return
    }

    displayName.value = 'Usuário'
  } catch (error) {
    console.error('Erro ao buscar display name:', error)
    displayName.value = 'Usuário'
  }
}

// Busca o display name quando o componente é montado
onMounted(() => {
  fetchUserDisplayName()

  // Escuta mudanças na autenticação
  supabase.auth.onAuthStateChange(() => {
    fetchUserDisplayName()
  })
})
</script>

