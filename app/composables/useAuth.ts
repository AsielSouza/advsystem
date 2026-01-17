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

    // Limpar espaços em branco
    const cleanEmail = email.trim().toLowerCase()
    const cleanPassword = password.trim()

    if (!cleanEmail || !cleanPassword) {
      error.value = 'Por favor, preencha todos os campos.'
      return { success: false, error: error.value }
    }

    isLoading.value = true
    error.value = null

    try {
      const { data, error: authError } = await supabase.auth.signInWithPassword({
        email: cleanEmail,
        password: cleanPassword
      })

      isLoading.value = false

      if (authError) {
        // Mensagens de erro mais específicas
        let errorMessage = 'Erro ao fazer login.'
        
        if (authError.message) {
          // Verifica se é erro de email não confirmado
          if (authError.message.includes('email') && authError.message.includes('confirm')) {
            errorMessage = 'Por favor, confirme seu email antes de fazer login. Verifique sua caixa de entrada.'
          } else if (authError.message.includes('Invalid login credentials')) {
            errorMessage = 'Email ou senha incorretos. Verifique suas credenciais.'
          } else if (authError.message.includes('Email not confirmed')) {
            errorMessage = 'Email não confirmado. Verifique sua caixa de entrada e confirme seu email.'
          } else {
            errorMessage = authError.message
          }
        }
        
        error.value = errorMessage
        console.error('Erro no login:', authError)
        return { success: false, error: error.value }
      }

      if (data?.user) {
        // Verifica se o email foi confirmado
        if (data.user.email_confirmed_at === null) {
          error.value = 'Por favor, confirme seu email antes de fazer login. Verifique sua caixa de entrada.'
          return { success: false, error: error.value }
        }

        // Garante que o perfil existe (cria se não existir)
        const displayName = data.user.user_metadata?.display_name || data.user.email?.split('@')[0] || 'Usuário'
        try {
          await supabase
            .from('profiles')
            .upsert({
              id: data.user.id,
              display_name: displayName,
              email: data.user.email
            }, { onConflict: 'id' })
        } catch {
          // Ignora erros ao criar/atualizar perfil
        }

        // Login bem-sucedido - redireciona para index
        await router.push('/')
        return { success: true, user: data.user }
      }

      error.value = 'Erro ao realizar login.'
      return { success: false, error: error.value }
    } catch (err: any) {
      isLoading.value = false
      console.error('Erro no login (catch):', err)
      error.value = err?.message || 'Erro ao realizar login. Tente novamente.'
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

  /**
   * Registra um novo usuário no Supabase
   * 
   * @param email - Email do usuário
   * @param password - Senha do usuário
   * @param displayName - Nome de exibição do usuário
   * @returns Promise com resultado do registro
   */
  const register = async (email: string, password: string, displayName: string) => {
    // Validação básica
    if (!email || !password || !displayName) {
      error.value = 'Por favor, preencha todos os campos.'
      return { success: false, error: error.value }
    }

    // Limpar espaços em branco
    const cleanEmail = email.trim().toLowerCase()
    const cleanPassword = password.trim()
    const cleanDisplayName = displayName.trim()

    if (!cleanEmail || !cleanPassword || !cleanDisplayName) {
      error.value = 'Por favor, preencha todos os campos.'
      return { success: false, error: error.value }
    }

    isLoading.value = true
    error.value = null

    try {
      // Registra o usuário no Supabase Auth
      const { data, error: authError } = await supabase.auth.signUp({
        email: cleanEmail,
        password: cleanPassword,
        options: {
          data: {
            display_name: cleanDisplayName
          },
          emailRedirectTo: `${window.location.origin}/confirm`
        }
      })

      if (authError) {
        isLoading.value = false
        error.value = authError.message || 'Erro ao registrar usuário.'
        return { success: false, error: error.value }
      }

      if (data?.user) {
        // Cria o perfil na tabela profiles
        try {
          await supabase
            .from('profiles')
            .upsert({
              id: data.user.id,
              display_name: cleanDisplayName,
              email: cleanEmail
            }, { onConflict: 'id' })
        } catch (profileError) {
          console.error('Erro ao criar/atualizar perfil:', profileError)
        }

        isLoading.value = false
        return { success: true, user: data.user }
      }

      isLoading.value = false
      error.value = 'Erro ao registrar usuário.'
      return { success: false, error: error.value }
    } catch (err) {
      isLoading.value = false
      error.value = 'Erro ao registrar usuário. Tente novamente.'
      return { success: false, error: error.value }
    }
  }

  return {
    // Estados
    isLoading,
    error,
    
    // Métodos
    login,
    logout,
    register,
    getCurrentUser,
    isAuthenticated
  }
}

