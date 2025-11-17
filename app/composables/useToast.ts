import { ref } from 'vue'

/**
 * Composable para gerenciar notificações toast
 * 
 * Fornece funções para exibir mensagens de:
 * - Sucesso
 * - Erro
 * - Aviso
 * - Informação
 */
export const useToast = () => {
  const showToast = ref(false)
  const toastMessage = ref('')
  const toastType = ref<'success' | 'error' | 'warning' | 'info'>('error')
  const toastDuration = ref(10000) // 10 segundos por padrão

  /**
   * Exibe uma notificação toast
   * 
   * @param message - Mensagem a ser exibida
   * @param type - Tipo da notificação (success, error, warning, info)
   * @param duration - Duração em milissegundos (padrão: 10000)
   */
  const show = (
    message: string,
    type: 'success' | 'error' | 'warning' | 'info' = 'error',
    duration: number = 10000
  ) => {
    toastMessage.value = message
    toastType.value = type
    toastDuration.value = duration
    showToast.value = true
  }

  /**
   * Exibe uma notificação de sucesso
   * 
   * @param message - Mensagem de sucesso
   * @param duration - Duração em milissegundos
   */
  const success = (message: string, duration?: number) => {
    show(message, 'success', duration)
  }

  /**
   * Exibe uma notificação de erro
   * 
   * @param message - Mensagem de erro
   * @param duration - Duração em milissegundos
   */
  const showError = (message: string, duration?: number) => {
    show(message, 'error', duration)
  }

  /**
   * Exibe uma notificação de aviso
   * 
   * @param message - Mensagem de aviso
   * @param duration - Duração em milissegundos
   */
  const warning = (message: string, duration?: number) => {
    show(message, 'warning', duration)
  }

  /**
   * Exibe uma notificação de informação
   * 
   * @param message - Mensagem informativa
   * @param duration - Duração em milissegundos
   */
  const info = (message: string, duration?: number) => {
    show(message, 'info', duration)
  }

  /**
   * Fecha a notificação toast
   */
  const close = () => {
    showToast.value = false
  }

  return {
    // Estados
    showToast,
    toastMessage,
    toastType,
    toastDuration,
    
    // Métodos
    show,
    success,
    showError,
    warning,
    info,
    close
  }
}

