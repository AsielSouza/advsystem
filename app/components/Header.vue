<template>
  <header class="sticky top-0 z-50 bg-white shadow-md border-b border-gray-200 flex-shrink-0">
    <div class="w-full mx-auto px-4 sm:px-6 py-4">
      <div class="flex items-center justify-between min-w-0">
        <!-- Logo/Home Button à esquerda -->
        <button
          @click="goToHome"
          class="text-xl sm:text-2xl font-bold text-primary-600 hover:text-primary-700 transition-colors flex-shrink-0"
        >
          AdvSystem
        </button>

        <!-- Nome do usuário, Configuração e Logout à direita -->
        <div class="flex items-center gap-2 sm:gap-4 min-w-0 flex-shrink-0">
          <span v-if="displayName" class="text-gray-700 font-medium text-sm sm:text-base truncate max-w-[120px] sm:max-w-none">
            {{ displayName }}
          </span>
          <span v-else class="text-gray-400 font-medium text-xs sm:text-sm truncate">
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

const router = useRouter()
const supabase = useSupabaseClient()
const displayName = ref('')

const goToHome = () => {
  router.push('/')
}

const fetchUserDisplayName = async () => {
  try {
    // Busca o usuário autenticado
    const { data: { user } } = await supabase.auth.getUser()
    
    if (!user) {
      displayName.value = ''
      return
    }

    // Primeiro tenta usar user_metadata (mais rápido e não requer query)
    if (user.user_metadata?.display_name) {
      displayName.value = user.user_metadata.display_name
      
      // Cria/atualiza perfil em background (não bloqueia a UI)
      try {
        const profileData = {
          id: user.id,
          display_name: user.user_metadata.display_name,
          email: user.email
        }
        // Usa upsert para inserir ou atualizar automaticamente
        await supabase
          .from('profiles')
          .upsert(profileData, { onConflict: 'id' })
      } catch {
        // Ignora erros ao criar/atualizar perfil
      }
      
      return
    }

    // Se não tiver user_metadata, tenta buscar na tabela profiles
    const { data: profile } = await supabase
      .from('profiles')
      .select('display_name')
      .eq('id', user.id)
      .maybeSingle()

    if (profile?.display_name) {
      displayName.value = profile.display_name
      return
    }

    // Se não encontrar, usa o email como fallback
    if (user.email) {
      const emailName = user.email.split('@')[0]
      displayName.value = emailName
      
      // Cria perfil em background com o nome do email
      try {
        const profileData = {
          id: user.id,
          display_name: emailName,
          email: user.email
        }
        // Usa upsert para inserir ou atualizar automaticamente
        await supabase
          .from('profiles')
          .upsert(profileData, { onConflict: 'id' })
      } catch {
        // Ignora erros ao criar/atualizar perfil
      }
      
      return
    }

    displayName.value = 'Usuário'
  } catch (error) {
    // Em caso de erro, usa fallback simples
    const { data: { user } } = await supabase.auth.getUser()
    if (user?.user_metadata?.display_name) {
      displayName.value = user.user_metadata.display_name
    } else if (user?.email) {
      displayName.value = user.email.split('@')[0]
    } else {
      displayName.value = 'Usuário'
    }
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

