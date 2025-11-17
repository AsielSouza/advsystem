import { ref } from 'vue'

/**
 * Composable para gerenciar autenticação com Supabase
 * 
 * Fornece funções e estados reativos para:
 * - Login de usuários
 * - Logout
 * - Verificação de autenticação
 * - Gerenciamento de estado de carregamento
 */
export const useAuth = () => {
  const router = useRouter()
  const supabase = useSupabaseClient()

  const isLoading = ref(false)
  const error = ref<string | null>(null)

  /**
   * Realiza login do usuário com email e senha
   * 
   * @param email - Email do usuário
   * @param password - Senha do usuário
   * @returns Promise com resultado do login
   */
  const login = async (email: string, password: string) => {
    // Validação básica
    if (!email || !password) {
      error.value = 'Por favor, preencha todos os campos.'
      return { success: false, error: error.value }
    }

    isLoading.value = true
    error.value = null

    try {
      const { data, error: authError } = await supabase.auth.signInWithPassword({
        email,
        password
      })

      isLoading.value = false

      if (authError) {
        error.value = 'As credenciais não são válidas.'
        return { success: false, error: error.value }
      }

      if (data?.user) {
        // Login bem-sucedido - redireciona para index
        await router.push('/')
        return { success: true, user: data.user }
      }

      error.value = 'Erro ao realizar login.'
      return { success: false, error: error.value }
    } catch (err) {
      isLoading.value = false
      error.value = 'As credenciais não são válidas.'
      return { success: false, error: error.value }
    }
  }

  /**
   * Realiza logout do usuário
   * 
   * @returns Promise com resultado do logout
   */
  const logout = async () => {
    isLoading.value = true
    error.value = null

    try {
      const { error: logoutError } = await supabase.auth.signOut()
      
      isLoading.value = false

      if (logoutError) {
        error.value = 'Erro ao realizar logout.'
        return { success: false, error: error.value }
      }

      await router.push('/login')
      return { success: true }
    } catch (err) {
      isLoading.value = false
      error.value = 'Erro ao realizar logout.'
      return { success: false, error: error.value }
    }
  }

  /**
   * Obtém o usuário autenticado atual
   * 
   * @returns Usuário autenticado ou null
   */
  const getCurrentUser = async () => {
    try {
      const { data: { user } } = await supabase.auth.getUser()
      return user
    } catch (err) {
      return null
    }
  }

  /**
   * Verifica se o usuário está autenticado
   * 
   * @returns true se autenticado, false caso contrário
   */
  const isAuthenticated = async () => {
    const user = await getCurrentUser()
    return !!user
  }

  return {
    // Estados
    isLoading,
    error,
    
    // Métodos
    login,
    logout,
    getCurrentUser,
    isAuthenticated
  }
}

