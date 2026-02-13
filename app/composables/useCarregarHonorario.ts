/**
 * Composable para carregar um honorário existente e retornar no formato do formulário (formData).
 */

import type { FormDataHonorario } from './useSalvarHonorario'

export const useCarregarHonorario = () => {
  const supabase = useSupabaseClient()

  const carregar = async (honorarioId: string): Promise<FormDataHonorario | null> => {
    const { data: honorario, error: errHonorario } = await supabase
      .from('honorarios')
      .select('*')
      .eq('id', honorarioId)
      .single()

    if (errHonorario || !honorario) {
      console.error('Erro ao carregar honorário:', errHonorario)
      return null
    }

    let cliente: FormDataHonorario['cliente'] = null
    if (honorario.cliente_pessoa_fisica_id) {
      const { data: pf } = await supabase
        .from('clientes_pessoa_fisica')
        .select('id, nome_completo')
        .eq('id', honorario.cliente_pessoa_fisica_id)
        .single()
      if (pf) {
        cliente = {
          id: pf.id,
          tipo: 'fisica',
          nome: pf.nome_completo || '',
          nome_fantasia: null
        }
      }
    } else if (honorario.cliente_pessoa_juridica_id) {
      const { data: pj } = await supabase
        .from('clientes_pessoa_juridica')
        .select('id, razao_social, nome_fantasia')
        .eq('id', honorario.cliente_pessoa_juridica_id)
        .single()
      if (pj) {
        cliente = {
          id: pj.id,
          tipo: 'juridica',
          nome: pj.razao_social || '',
          nome_fantasia: pj.nome_fantasia || null
        }
      }
    }

    const { data: historicos } = await supabase
      .from('honorarios_historico')
      .select('historico')
      .eq('honorario_id', honorarioId)
      .order('created_at', { ascending: false })
      .limit(1)

    const historicoTexto = historicos?.[0]?.historico ?? ''

    const { data: parcelasDb } = await supabase
      .from('honorarios_parcelas')
      .select('numero_da_parcela, data_vencimento, valor_parcela, data_pagamento')
      .eq('honorario_id', honorarioId)
      .order('numero_da_parcela', { ascending: true })

    const formaPagamento = honorario.forma_pagamento === 'avista' ? 'a_vista' : (honorario.forma_pagamento || 'parcelado')
    const isAVista = formaPagamento === 'a_vista'
    const dataPagamento = isAVista && parcelasDb?.[0]?.data_pagamento
      ? parcelasDb[0].data_pagamento
      : ''

    const parcelas = (parcelasDb || []).map((p) => ({
      numero: p.numero_da_parcela,
      dataPagamento: p.data_vencimento || '',
      valor: parseFloat(p.valor_parcela) || 0
    }))

    const { data: sociosDb } = await supabase
      .from('honorarios_socios')
      .select('id_advogado, nome_advogado, percentual_valor')
      .eq('honorario_id', honorarioId)

    const divisaoSocios = (sociosDb || []).map((s) => ({
      id_advogado: s.id_advogado,
      nome: s.nome_advogado || '',
      percentual: parseFloat(s.percentual_valor) || 0
    }))

    const { data: parceirosDb } = await supabase
      .from('honorarios_parceiros')
      .select('id_advogado, nome_advogado, percentual_valor')
      .eq('honorario_id', honorarioId)

    const divisaoParceiros = (parceirosDb || []).map((p) => ({
      id_advogado: p.id_advogado,
      nome: p.nome_advogado || '',
      percentual: parseFloat(p.percentual_valor) || 0
    }))

    const valorTotal = honorario.valor_total != null ? String(honorario.valor_total) : ''
    const valorCausa = honorario.valor_causa != null ? String(honorario.valor_causa) : ''
    const rawDataContratacao = honorario.data_contratacao
    const dataContratacao = rawDataContratacao
      ? (typeof rawDataContratacao === 'string'
          ? rawDataContratacao
          : (rawDataContratacao instanceof Date
              ? rawDataContratacao.toISOString().slice(0, 10)
              : String(rawDataContratacao)))
      : ''

    return {
      cliente,
      processo: {
        numero_processo: honorario.numero_processo || '',
        valor_causa: valorCausa,
        historico: historicoTexto
      },
      financeiro: {
        data_contratacao: dataContratacao,
        valor_honorario: valorTotal,
        forma_pagamento: formaPagamento,
        data_pagamento: dataPagamento,
        possui_entrada: !!honorario.possui_entrada,
        valor_entrada: honorario.valor_entrada != null ? String(honorario.valor_entrada) : '',
        data_entrada: honorario.data_entrada
          ? (typeof honorario.data_entrada === 'string'
              ? honorario.data_entrada
              : (honorario.data_entrada instanceof Date
                  ? honorario.data_entrada.toISOString().slice(0, 10)
                  : String(honorario.data_entrada)))
          : '',
        parcelas
      },
      honorarios: {
        dividir_entre_socios: !!honorario.dividir_entre_socios,
        advogado_responsavel_id: honorario.advogado_responsavel_id ? String(honorario.advogado_responsavel_id) : '',
        divisao_socios: divisaoSocios,
        dividir_entre_parceiros: !!honorario.dividir_entre_parceiros,
        percentual_socios: honorario.percentual_socios ?? 50,
        percentual_parceiros: honorario.percentual_parceiros ?? 50,
        divisao_parceiros: divisaoParceiros
      }
    }
  }

  return { carregar }
}
