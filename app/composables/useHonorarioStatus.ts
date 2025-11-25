import { computed } from 'vue'

export const useHonorarioStatus = () => {
  // Contar parcelas em atraso
  const contarParcelasAtraso = (honorario: any) => {
    if (!honorario.parcelas || !Array.isArray(honorario.parcelas)) return 0
    
    const hoje = new Date()
    hoje.setHours(0, 0, 0, 0)
    
    return honorario.parcelas.filter((p: any) => {
      const status = p.status || 'pendente'
      const dataVencimento = new Date(p.data_vencimento)
      dataVencimento.setHours(0, 0, 0, 0)
      const valorParcela = parseFloat(p.valor_parcela) || 0
      const valorPago = parseFloat(p.valor_pago_parcela) || 0
      const saldo = valorParcela - valorPago
      
      return status === 'pendente' && dataVencimento < hoje && saldo > 0
    }).length
  }

  // Verificar se todas as parcelas estão pagas
  const todasParcelasPagas = (honorario: any) => {
    if (!honorario.parcelas || !Array.isArray(honorario.parcelas) || honorario.parcelas.length === 0) {
      return false
    }
    
    // Verifica se todas as parcelas têm valor_pago_parcela >= valor_parcela
    return honorario.parcelas.every((p: any) => {
      const valorParcela = parseFloat(p.valor_parcela) || 0
      const valorPago = parseFloat(p.valor_pago_parcela) || 0
      return valorPago >= valorParcela && valorParcela > 0
    })
  }

  // Verificar se há parcelas pendentes (não totalmente pagas)
  const temParcelasPendentes = (honorario: any) => {
    if (!honorario.parcelas || !Array.isArray(honorario.parcelas) || honorario.parcelas.length === 0) {
      return false
    }
    
    // Verifica se há pelo menos uma parcela que não está totalmente paga
    return honorario.parcelas.some((p: any) => {
      const valorParcela = parseFloat(p.valor_parcela) || 0
      const valorPago = parseFloat(p.valor_pago_parcela) || 0
      return valorParcela > 0 && valorPago < valorParcela
    })
  }

  // Formatar status do honorário
  const formatStatus = (honorario: any) => {
    const parcelasAtraso = contarParcelasAtraso(honorario)
    
    // Prioridade 1: Se houver parcelas em atraso, mostra a quantidade
    if (parcelasAtraso > 0) {
      return `${parcelasAtraso} ${parcelasAtraso === 1 ? 'Parcela em atraso' : 'Parcelas em atraso'}`
    }
    
    // Prioridade 2: Se todas as parcelas estão pagas, status é "Pago"
    if (todasParcelasPagas(honorario)) {
      return 'Pago'
    }
    
    // Prioridade 3: Se houver parcelas pendentes, status é "Pendente"
    if (temParcelasPendentes(honorario)) {
      return 'Pendente'
    }
    
    // Caso contrário, usa o status normal do honorário
    const status = honorario.status || 'pendente'
    const statusMap: Record<string, string> = {
      'pendente': 'Pendente',
      'pago': 'Pago',
      'cancelado': 'Cancelado',
      'paga': 'Paga'
    }
    return statusMap[status] || status || 'Não definido'
  }

  // Obter classe CSS do status
  const getStatusClass = (honorario: any) => {
    const parcelasAtraso = contarParcelasAtraso(honorario)
    
    // Se houver parcelas em atraso, retorna classe com animação piscante
    if (parcelasAtraso > 0) {
      return 'bg-red-100 text-red-800 status-atraso-piscante'
    }
    
    // Se todas as parcelas estão pagas, retorna classe verde
    if (todasParcelasPagas(honorario)) {
      return 'bg-green-100 text-green-800'
    }
    
    // Se houver parcelas pendentes, retorna classe amarela
    if (temParcelasPendentes(honorario)) {
      return 'bg-yellow-100 text-yellow-800'
    }
    
    // Caso contrário, usa o status normal
    const status = honorario.status || 'pendente'
    const statusClasses: Record<string, string> = {
      'pago': 'bg-green-100 text-green-800',
      'paga': 'bg-green-100 text-green-800',
      'pendente': 'bg-yellow-100 text-yellow-800',
      'cancelado': 'bg-red-100 text-red-800'
    }
    return statusClasses[status] || 'bg-gray-100 text-gray-800'
  }

  return {
    contarParcelasAtraso,
    todasParcelasPagas,
    temParcelasPendentes,
    formatStatus,
    getStatusClass
  }
}

