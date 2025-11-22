-- =====================================================
-- Alteração da Tabela: honorarios_parcelas
-- Descrição: Adiciona a coluna forma_pagamento e atualiza triggers
-- =====================================================

-- =====================================================
-- 1. Adicionar a coluna forma_pagamento
-- =====================================================

ALTER TABLE honorarios_parcelas
ADD COLUMN IF NOT EXISTS forma_pagamento VARCHAR(20) NOT NULL DEFAULT 'Parcelado'
CHECK (forma_pagamento IN ('Parcelado', 'À Vista'));

-- =====================================================
-- 2. Adicionar comentário na nova coluna
-- =====================================================

COMMENT ON COLUMN honorarios_parcelas.forma_pagamento IS 'Forma de pagamento da parcela: Parcelado ou À Vista';

-- =====================================================
-- 3. Atualizar a função do trigger para considerar forma_pagamento
-- =====================================================

-- Remove o trigger antigo
DROP TRIGGER IF EXISTS update_honorarios_parcelas_status ON honorarios_parcelas;

-- Recria a função com a nova lógica
CREATE OR REPLACE FUNCTION update_parcela_status()
RETURNS TRIGGER AS $$
BEGIN
  -- Se a forma de pagamento for "À Vista", status sempre será "paga"
  IF NEW.forma_pagamento = 'À Vista' THEN
    NEW.status := 'paga';
    NEW.valor_pago_parcela := NEW.valor_parcela; -- Marca como totalmente pago
    -- Se ainda não tiver data de pagamento, define como a data atual
    IF NEW.data_pagamento IS NULL THEN
      NEW.data_pagamento := CURRENT_DATE;
    END IF;
  
  -- Se a forma de pagamento for "Parcelado", aplica a lógica de valor pago
  ELSIF NEW.forma_pagamento = 'Parcelado' THEN
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
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Recria o trigger
CREATE TRIGGER update_honorarios_parcelas_status
BEFORE INSERT OR UPDATE ON honorarios_parcelas
FOR EACH ROW
EXECUTE FUNCTION update_parcela_status();

-- =====================================================
-- 4. Atualizar registros existentes (se houver)
-- =====================================================

-- Se já existirem registros na tabela, atualiza a forma_pagamento baseado no status atual
-- Parcelas pendentes → 'Parcelado'
-- Parcelas pagas → 'À Vista' (assumindo que foram pagas à vista)
UPDATE honorarios_parcelas
SET forma_pagamento = CASE 
  WHEN status = 'pendente' THEN 'Parcelado'
  WHEN status = 'paga' THEN 'À Vista'
  ELSE 'Parcelado'
END
WHERE forma_pagamento IS NULL OR forma_pagamento = 'Parcelado';

-- =====================================================
-- 5. Adicionar índice para a nova coluna (opcional, mas recomendado)
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_honorarios_parcelas_forma_pagamento 
ON honorarios_parcelas(forma_pagamento);

-- =====================================================
-- 6. Atualizar a view vw_parcelas_com_saldo para incluir forma_pagamento
-- =====================================================

DROP VIEW IF EXISTS vw_parcelas_com_saldo;

CREATE OR REPLACE VIEW vw_parcelas_com_saldo AS
SELECT 
  id,
  honorario_id,
  numero_processo,
  numero_da_parcela,
  valor_parcela,
  valor_pago_parcela,
  (valor_parcela - valor_pago_parcela) AS saldo_devedor,
  forma_pagamento,
  status,
  data_vencimento,
  data_pagamento,
  created_at,
  updated_at
FROM honorarios_parcelas;

COMMENT ON VIEW vw_parcelas_com_saldo IS 'View que exibe as parcelas com o cálculo automático do saldo devedor e forma de pagamento';

-- =====================================================
-- FIM DO SCRIPT
-- =====================================================
-- 
-- NOTAS IMPORTANTES:
-- 
-- 1. A coluna forma_pagamento foi adicionada com valor padrão 'Parcelado'
--    para garantir compatibilidade com registros existentes.
--
-- 2. O trigger foi atualizado para aplicar a regra:
--    - Se forma_pagamento = 'À Vista' → status = 'paga' e valor_pago_parcela = valor_parcela
--    - Se forma_pagamento = 'Parcelado' → status baseado no valor_pago_parcela
--
-- 3. Registros existentes serão atualizados automaticamente:
--    - Parcelas pendentes → forma_pagamento = 'Parcelado'
--    - Parcelas pagas → forma_pagamento = 'À Vista'
--
-- 4. A view vw_parcelas_com_saldo foi atualizada para incluir a nova coluna.
--
-- 5. Foi criado um índice na coluna forma_pagamento para otimizar consultas.
--
-- 6. IMPORTANTE: Execute este script em ordem, pois alguns comandos dependem
--    de outros terem sido executados primeiro.
--
-- =====================================================

