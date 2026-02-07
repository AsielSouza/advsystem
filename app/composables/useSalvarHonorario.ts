/**
 * Composable para salvar honorário no banco de dados.
 * Persiste em honorarios, honorarios_historico, honorarios_parcelas,
 * honorarios_socios e honorarios_parceiros conforme o formulário.
 */

interface ParcelaExistente {
  id: string
  numero_da_parcela: number
  valor_pago_parcela: number
  data_pagamento: string | null
}

export interface FormDataHonorario {
  cliente: {
    id: string
    tipo: string
    nome: string
    nome_fantasia?: string | null
  } | null
  processo: {
    numero_processo: string
    valor_causa: string
    historico: string
  }
  financeiro: {
    data_contratacao: string
    valor_honorario: string
    forma_pagamento: string
    data_pagamento: string
    parcelas: Array<{
      numero: number
      dataPagamento: string
      valor: number
    }>
  }
  honorarios: {
    dividir_entre_socios: boolean
    advogado_responsavel_id: string
    divisao_socios: Array<{
      id_advogado: string
      nome: string
      percentual: number
    }>
    dividir_entre_parceiros: boolean
    percentual_socios: number
    percentual_parceiros: number
    divisao_parceiros: Array<{
      id_advogado: string
      nome: string
      percentual: number
    }>
  }
}

export const useSalvarHonorario = () => {
  const supabase = useSupabaseClient()

  const salvar = async (
    formData: FormDataHonorario,
    honorarioIdExistente?: string | null
  ): Promise<{ id: string } | { error: string }> => {
    const { cliente, processo, financeiro, honorarios } = formData

    if (!cliente?.id) {
      return { error: 'Cliente é obrigatório.' }
    }

    if (!processo?.numero_processo?.trim()) {
      return { error: 'Número do processo é obrigatório.' }
    }

    const valorTotal = parseFloat(financeiro?.valor_honorario || '0')
    if (!valorTotal || valorTotal <= 0) {
      return { error: 'Valor do honorário é obrigatório e deve ser maior que zero.' }
    }

    const dataContratacao = financeiro?.data_contratacao || null
    if (!dataContratacao) {
      return { error: 'Data da contratação é obrigatória.' }
    }

    const formaPagamentoRaw = (financeiro?.forma_pagamento || '').trim()
    if (!formaPagamentoRaw || (formaPagamentoRaw !== 'a_vista' && formaPagamentoRaw !== 'avista' && formaPagamentoRaw !== 'parcelado')) {
      return { error: 'Forma de pagamento é obrigatória. Escolha "À vista" ou "Parcelado".' }
    }
    if (formaPagamentoRaw === 'parcelado') {
      const parcelas = financeiro?.parcelas ?? []
      if (parcelas.length < 1) {
        return { error: 'No pagamento parcelado, a quantidade de parcelas deve ser igual ou superior a 1.' }
      }
    }

    if (honorarios?.dividir_entre_parceiros) {
      const divisaoParceiros = honorarios.divisao_parceiros ?? []
      if (divisaoParceiros.length === 0) {
        return { error: 'Com "Dividir entre parceiros" ativo, é obrigatório adicionar pelo menos 1 advogado parceiro.' }
      }
      const totalParceiros = divisaoParceiros.reduce((sum, p) => sum + (Number(p.percentual) || 0), 0)
      if (Math.abs(totalParceiros - 100) > 0.01) {
        return { error: 'A divisão entre advogados parceiros deve totalizar 100%.' }
      }
    }

    const formaPagamento = formaPagamentoRaw
    const isParcelado = formaPagamento === 'parcelado'
    const isAVista = formaPagamento === 'a_vista' || formaPagamento === 'avista'

    const clientePfId = cliente.tipo === 'fisica' ? cliente.id : null
    const clientePjId = cliente.tipo === 'juridica' ? cliente.id : null

    const formaPagamentoDb = isAVista ? 'avista' : isParcelado ? 'parcelado' : null
    const numeroParcelas = isParcelado && financeiro.parcelas?.length
      ? financeiro.parcelas.length
      : null

    const valorCausa = processo.valor_causa
      ? parseFloat(String(processo.valor_causa).replace(',', '.'))
      : null
    const valorCausaNum = valorCausa != null && !Number.isNaN(valorCausa) ? valorCausa : null

    const payloadHonorario = {
      cliente_pessoa_fisica_id: clientePfId,
      cliente_pessoa_juridica_id: clientePjId,
      numero_processo: processo.numero_processo.trim(),
      valor_total: valorTotal,
      valor_causa: valorCausaNum,
      data_contratacao: dataContratacao,
      forma_pagamento: formaPagamentoDb,
      numero_parcelas: numeroParcelas,
      descricao: null,
      status: 'pendente' as const,
      dividir_entre_socios: honorarios?.dividir_entre_socios ?? false,
      advogado_responsavel_id: honorarios?.advogado_responsavel_id?.trim() || null,
      dividir_entre_parceiros: honorarios?.dividir_entre_parceiros ?? false,
      percentual_socios: honorarios?.percentual_socios ?? 100,
      percentual_parceiros: honorarios?.percentual_parceiros ?? 0
    }

    let honorarioId: string

    if (honorarioIdExistente?.trim()) {
      const { error: errUpdate } = await supabase
        .from('honorarios')
        // @ts-expect-error schema Supabase pode não incluir todas as colunas de honorarios
        .update(payloadHonorario)
        .eq('id', honorarioIdExistente)

      if (errUpdate) {
        console.error('Erro ao atualizar honorário:', errUpdate)
        return { error: errUpdate.message || 'Erro ao atualizar honorário.' }
      }
      honorarioId = honorarioIdExistente
    } else {
      const { data: honorarioInserido, error: errHonorario } = await supabase
        .from('honorarios')
        .insert(payloadHonorario as any)
        .select('id')
        .single()

      if (errHonorario) {
        console.error('Erro ao inserir honorário:', errHonorario)
        return { error: errHonorario.message || 'Erro ao salvar honorário.' }
      }

      const id = (honorarioInserido as { id: string } | null)?.id
      if (!id) {
        return { error: 'Erro ao obter ID do honorário salvo.' }
      }
      honorarioId = id
    }

    const numeroProcesso = processo.numero_processo.trim()

    if (honorarioIdExistente?.trim()) {
      const { data: historicos } = await supabase
        .from('honorarios_historico')
        .select('id')
        .eq('honorario_id', honorarioId)
        .order('created_at', { ascending: false })
        .limit(1)

      if (historicos?.length && processo.historico?.trim()) {
        const primeiro = historicos[0]
        const idHistorico = primeiro && 'id' in primeiro ? (primeiro as { id: string }).id : null
        if (idHistorico) {
          await supabase
            .from('honorarios_historico')
            // @ts-expect-error schema Supabase pode não incluir honorarios_historico
            .update({
              numero_processo: numeroProcesso,
              historico: processo.historico.trim()
            })
            .eq('id', idHistorico)
        }
      } else if (processo.historico?.trim()) {
        await supabase
          .from('honorarios_historico')
          .insert({
            honorario_id: honorarioId,
            numero_processo: numeroProcesso,
            historico: processo.historico.trim()
          } as any)
      }
    } else if (processo.historico?.trim()) {
      const { error: errHistorico } = await supabase
        .from('honorarios_historico')
        .insert({
          honorario_id: honorarioId,
          numero_processo: numeroProcesso,
          historico: processo.historico.trim()
        } as any)

      if (errHistorico) {
        console.error('Erro ao inserir histórico:', errHistorico)
      }
    }

    if (honorarioIdExistente?.trim()) {
      const { data: parcelasExistentes } = await supabase
        .from('honorarios_parcelas')
        .select('id, numero_da_parcela, valor_pago_parcela, data_pagamento')
        .eq('honorario_id', honorarioId)

      const lista = (parcelasExistentes || []) as ParcelaExistente[]
      const mapaExistente = new Map<number, ParcelaExistente>(
        lista.map((p) => [p.numero_da_parcela, p])
      )

      if (isAVista) {
        const dataVencimento = financeiro.data_pagamento || dataContratacao
        await supabase.from('honorarios_parcelas').delete().eq('honorario_id', honorarioId)
        await supabase
          .from('honorarios_parcelas')
          .insert({
            honorario_id: honorarioId,
            numero_processo: numeroProcesso,
            numero_da_parcela: 1,
            valor_parcela: valorTotal,
            valor_pago_parcela: valorTotal,
            status: 'paga',
            data_vencimento: dataVencimento,
            data_pagamento: financeiro.data_pagamento || dataContratacao,
            forma_pagamento: 'À Vista'
          } as any)
      } else if (isParcelado && financeiro.parcelas?.length) {
        const numerosForm = new Set(financeiro.parcelas.map((p) => p.numero))
        for (const p of financeiro.parcelas) {
          const existente = mapaExistente.get(p.numero)
          const valorPago = existente?.valor_pago_parcela ?? 0
          const dataPagamento = existente?.data_pagamento ?? null
          const status = valorPago >= p.valor ? 'paga' : 'pendente'
          if (existente) {
            await supabase
              .from('honorarios_parcelas')
              // @ts-expect-error schema Supabase pode não incluir honorarios_parcelas
              .update({
                numero_processo: numeroProcesso,
                valor_parcela: p.valor,
                valor_pago_parcela: valorPago,
                status,
                data_vencimento: p.dataPagamento,
                data_pagamento: dataPagamento,
                forma_pagamento: 'Parcelado'
              })
              .eq('id', existente.id)
          } else {
            await supabase
              .from('honorarios_parcelas')
              .insert({
                honorario_id: honorarioId,
                numero_processo: numeroProcesso,
                numero_da_parcela: p.numero,
                valor_parcela: p.valor,
                valor_pago_parcela: 0,
                status: 'pendente',
                data_vencimento: p.dataPagamento,
                data_pagamento: null,
                forma_pagamento: 'Parcelado'
              } as any)
          }
        }
        for (const [num, row] of mapaExistente) {
          if (!numerosForm.has(num) && Number(row.valor_pago_parcela) === 0) {
            await supabase.from('honorarios_parcelas').delete().eq('id', row.id)
          }
        }
      } else {
        await supabase.from('honorarios_parcelas').delete().eq('honorario_id', honorarioId)
      }
    } else {
      if (isAVista) {
        const dataVencimento = financeiro.data_pagamento || dataContratacao
        const { error: errParcela } = await supabase
          .from('honorarios_parcelas')
          .insert({
            honorario_id: honorarioId,
            numero_processo: numeroProcesso,
            numero_da_parcela: 1,
            valor_parcela: valorTotal,
            valor_pago_parcela: valorTotal,
            status: 'paga',
            data_vencimento: dataVencimento,
            data_pagamento: financeiro.data_pagamento || dataContratacao,
            forma_pagamento: 'À Vista'
          } as any)

        if (errParcela) {
          console.error('Erro ao inserir parcela à vista:', errParcela)
        }
      } else if (isParcelado && financeiro.parcelas?.length) {
        const parcelasInsert = financeiro.parcelas.map((p) => ({
          honorario_id: honorarioId,
          numero_processo: numeroProcesso,
          numero_da_parcela: p.numero,
          valor_parcela: p.valor,
          valor_pago_parcela: 0,
          status: 'pendente' as const,
          data_vencimento: p.dataPagamento,
          data_pagamento: null,
          forma_pagamento: 'Parcelado' as const
        }))

        const { error: errParcelas } = await supabase
          .from('honorarios_parcelas')
          .insert(parcelasInsert as any)

        if (errParcelas) {
          console.error('Erro ao inserir parcelas:', errParcelas)
        }
      }
    }

    if (honorarioIdExistente?.trim()) {
      await supabase.from('honorarios_socios').delete().eq('honorario_id', honorarioId)
      await supabase.from('honorarios_parceiros').delete().eq('honorario_id', honorarioId)
    }

    if (honorarios?.dividir_entre_socios && honorarios.divisao_socios?.length) {
      const sociosInsert = honorarios.divisao_socios.map((s) => ({
        honorario_id: honorarioId,
        numero_processo: numeroProcesso,
        id_advogado: s.id_advogado,
        nome_advogado: s.nome || '',
        percentual_valor: s.percentual
      }))

      const { error: errSocios } = await supabase
        .from('honorarios_socios')
        .insert(sociosInsert as any)

      if (errSocios) {
        console.error('Erro ao inserir sócios:', errSocios)
      }
    }

    if (honorarios?.dividir_entre_parceiros && honorarios.divisao_parceiros?.length) {
      const parceirosInsert = honorarios.divisao_parceiros.map((p) => ({
        honorario_id: honorarioId,
        numero_processo: numeroProcesso,
        id_advogado: p.id_advogado,
        nome_advogado: p.nome || '',
        percentual_valor: p.percentual
      }))

      const { error: errParceiros } = await supabase
        .from('honorarios_parceiros')
        .insert(parceirosInsert as any)

      if (errParceiros) {
        console.error('Erro ao inserir parceiros:', errParceiros)
      }
    }

    return { id: honorarioId }
  }

  return { salvar }
}
