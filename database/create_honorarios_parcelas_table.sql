-- =====================================================
-- Criação da Tabela: honorarios_parcelas
-- Descrição: Tabela para armazenar as parcelas dos honorários parcelados
-- =====================================================

-- Remove a tabela se já existir (use com cuidado em produção)
-- DROP TABLE IF EXISTS honorarios_parcelas CASCADE;

-- Criação da tabela honorarios_parcelas
CREATE TABLE IF NOT EXISTS honorarios_parcelas (
  -- Coluna de identificação única (UUID padrão do Supabase)
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Identificação do Honorário (Foreign Key)
  honorario_id UUID NOT NULL REFERENCES honorarios(id) ON DELETE CASCADE,
  
  -- Número do Processo (armazenado diretamente para facilitar consultas)
  numero_processo VARCHAR(255) NOT NULL,
  
  -- Número da Parcela (sequencial: 1, 2, 3, ...)
  numero_da_parcela INTEGER NOT NULL CHECK (numero_da_parcela > 0),
  
  -- Valor da Parcela (valor total dividido pela quantidade de parcelas)
  valor_parcela DECIMAL(15, 2) NOT NULL CHECK (valor_parcela > 0),
  
  -- Valor Pago da Parcela (valor já pago parcialmente)
  -- Permite pagamento parcial da parcela
  valor_pago_parcela DECIMAL(15, 2) NOT NULL DEFAULT 0 CHECK (valor_pago_parcela >= 0),
  
  -- Status da Parcela
  -- Valores possíveis: 'paga' ou 'pendente'
  status VARCHAR(20) NOT NULL DEFAULT 'pendente' CHECK (status IN ('paga', 'pendente')),
  
  -- Data de Vencimento da Parcela
  data_vencimento DATE NOT NULL,
  
  -- Data de Pagamento (preenchida quando a parcela for paga)
  data_pagamento DATE,
  
  -- Colunas padrões do Supabase
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  
  -- Constraint para garantir que valor_pago_parcela não seja maior que valor_parcela
  CONSTRAINT honorarios_parcelas_valor_check CHECK (
    valor_pago_parcela <= valor_parcela
  ),
  
  -- Constraint para garantir que não haja parcelas duplicadas para o mesmo honorário
  CONSTRAINT honorarios_parcelas_unique_check UNIQUE (honorario_id, numero_da_parcela)
);

-- =====================================================
-- Índices para melhorar performance
-- =====================================================

-- Índice para busca por honorário
CREATE INDEX IF NOT EXISTS idx_honorarios_parcelas_honorario_id 
ON honorarios_parcelas(honorario_id);

-- Índice para busca por número do processo
CREATE INDEX IF NOT EXISTS idx_honorarios_parcelas_numero_processo 
ON honorarios_parcelas(numero_processo);

-- Índice para busca por status
CREATE INDEX IF NOT EXISTS idx_honorarios_parcelas_status 
ON honorarios_parcelas(status);

-- Índice para busca por data de vencimento (útil para relatórios de vencimentos)
CREATE INDEX IF NOT EXISTS idx_honorarios_parcelas_data_vencimento 
ON honorarios_parcelas(data_vencimento);

-- Índice composto para buscar parcelas pendentes por data de vencimento
CREATE INDEX IF NOT EXISTS idx_honorarios_parcelas_status_vencimento 
ON honorarios_parcelas(status, data_vencimento) 
WHERE status = 'pendente';

-- Índice para ordenação por número da parcela dentro de um honorário
CREATE INDEX IF NOT EXISTS idx_honorarios_parcelas_honorario_numero 
ON honorarios_parcelas(honorario_id, numero_da_parcela);

-- =====================================================
-- Trigger para atualizar updated_at automaticamente
-- =====================================================

-- Trigger que executa a função antes de atualizar
-- (A função update_updated_at_column já deve existir da tabela honorarios)
CREATE TRIGGER update_honorarios_parcelas_updated_at
BEFORE UPDATE ON honorarios_parcelas
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- Trigger para atualizar status automaticamente
-- =====================================================

-- Função para atualizar o status da parcela baseado no valor pago
CREATE OR REPLACE FUNCTION update_parcela_status()
RETURNS TRIGGER AS $$
BEGIN
  -- Se o valor pago for igual ou maior que o valor da parcela, marca como paga
  IF NEW.valor_pago_parcela >= NEW.valor_parcela THEN
    NEW.status := 'paga';
    -- Se ainda não tiver data de pagamento, define como a data atual
    IF NEW.data_pagamento IS NULL THEN
      NEW.data_pagamento := CURRENT_DATE;
    END IF;
  -- Se o valor pago for menor que o valor da parcela, marca como pendente
  ELSIF NEW.valor_pago_parcela < NEW.valor_parcela THEN
    NEW.status := 'pendente';
    -- Se estava paga e agora tem pagamento parcial, limpa a data de pagamento
    IF OLD.status = 'paga' AND NEW.valor_pago_parcela < NEW.valor_parcela THEN
      NEW.data_pagamento := NULL;
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger que executa a função antes de inserir ou atualizar
CREATE TRIGGER update_honorarios_parcelas_status
BEFORE INSERT OR UPDATE ON honorarios_parcelas
FOR EACH ROW
EXECUTE FUNCTION update_parcela_status();

-- =====================================================
-- Função para calcular saldo devedor (útil para views ou consultas)
-- =====================================================

-- Função que calcula o saldo devedor de uma parcela
CREATE OR REPLACE FUNCTION calcular_saldo_devedor_parcela(parcela_id UUID)
RETURNS DECIMAL(15, 2) AS $$
DECLARE
  saldo DECIMAL(15, 2);
BEGIN
  SELECT (valor_parcela - valor_pago_parcela)
  INTO saldo
  FROM honorarios_parcelas
  WHERE id = parcela_id;
  
  RETURN COALESCE(saldo, 0);
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- Comentários nas colunas para documentação
-- =====================================================

COMMENT ON TABLE honorarios_parcelas IS 'Tabela para armazenar as parcelas dos honorários parcelados';
COMMENT ON COLUMN honorarios_parcelas.id IS 'Identificador único da parcela (UUID)';
COMMENT ON COLUMN honorarios_parcelas.honorario_id IS 'Referência ao honorário ao qual a parcela pertence';
COMMENT ON COLUMN honorarios_parcelas.numero_processo IS 'Número do processo judicial (armazenado para facilitar consultas)';
COMMENT ON COLUMN honorarios_parcelas.numero_da_parcela IS 'Número sequencial da parcela (1, 2, 3, ...)';
COMMENT ON COLUMN honorarios_parcelas.valor_parcela IS 'Valor total da parcela em reais (R$)';
COMMENT ON COLUMN honorarios_parcelas.valor_pago_parcela IS 'Valor já pago da parcela (permite pagamento parcial)';
COMMENT ON COLUMN honorarios_parcelas.status IS 'Status da parcela: paga ou pendente (atualizado automaticamente)';
COMMENT ON COLUMN honorarios_parcelas.data_vencimento IS 'Data de vencimento da parcela';
COMMENT ON COLUMN honorarios_parcelas.data_pagamento IS 'Data em que a parcela foi paga (preenchida automaticamente quando status = paga)';
COMMENT ON COLUMN honorarios_parcelas.created_at IS 'Data e hora de criação do registro';
COMMENT ON COLUMN honorarios_parcelas.updated_at IS 'Data e hora da última atualização do registro';

-- =====================================================
-- Políticas RLS (Row Level Security) - Ajuste conforme necessário
-- =====================================================

-- Habilita RLS na tabela
ALTER TABLE honorarios_parcelas ENABLE ROW LEVEL SECURITY;

-- Política padrão: usuários autenticados podem ler todas as parcelas
CREATE POLICY "Usuários autenticados podem visualizar parcelas"
ON honorarios_parcelas
FOR SELECT
TO authenticated
USING (true);

-- Política padrão: usuários autenticados podem inserir parcelas
CREATE POLICY "Usuários autenticados podem inserir parcelas"
ON honorarios_parcelas
FOR INSERT
TO authenticated
WITH CHECK (true);

-- Política padrão: usuários autenticados podem atualizar parcelas
CREATE POLICY "Usuários autenticados podem atualizar parcelas"
ON honorarios_parcelas
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

-- Política padrão: usuários autenticados podem deletar parcelas
CREATE POLICY "Usuários autenticados podem deletar parcelas"
ON honorarios_parcelas
FOR DELETE
TO authenticated
USING (true);

-- =====================================================
-- View útil: Parcelas com Saldo Devedor
-- =====================================================

-- View que calcula automaticamente o saldo devedor de cada parcela
CREATE OR REPLACE VIEW vw_parcelas_com_saldo AS
SELECT 
  id,
  honorario_id,
  numero_processo,
  numero_da_parcela,
  valor_parcela,
  valor_pago_parcela,
  (valor_parcela - valor_pago_parcela) AS saldo_devedor,
  status,
  data_vencimento,
  data_pagamento,
  created_at,
  updated_at
FROM honorarios_parcelas;

COMMENT ON VIEW vw_parcelas_com_saldo IS 'View que exibe as parcelas com o cálculo automático do saldo devedor';

-- =====================================================
-- FIM DO SCRIPT
-- =====================================================
-- 
-- NOTAS IMPORTANTES:
-- 
-- 1. A tabela armazena o numero_processo diretamente para facilitar consultas
--    sem necessidade de JOIN com a tabela honorarios.
--
-- 2. O trigger update_parcela_status atualiza automaticamente o status da parcela
--    baseado no valor_pago_parcela:
--    - Se valor_pago_parcela >= valor_parcela → status = 'paga'
--    - Se valor_pago_parcela < valor_parcela → status = 'pendente'
--
-- 3. A constraint honorarios_parcelas_valor_check garante que o valor pago
--    nunca seja maior que o valor da parcela.
--
-- 4. A constraint honorarios_parcelas_unique_check garante que não haja
--    parcelas duplicadas (mesmo número de parcela para o mesmo honorário).
--
-- 5. O ON DELETE CASCADE na foreign key garante que quando um honorário for
--    deletado, todas suas parcelas também serão deletadas automaticamente.
--
-- 6. A função calcular_saldo_devedor_parcela pode ser usada em consultas
--    para calcular o saldo devedor de uma parcela específica.
--
-- 7. A view vw_parcelas_com_saldo facilita consultas que precisam do saldo
--    devedor calculado automaticamente.
--
-- 8. Os índices foram criados para otimizar consultas comuns, especialmente
--    busca por honorário, status e data de vencimento.
--
-- =====================================================

