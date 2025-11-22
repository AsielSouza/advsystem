-- =====================================================
-- Alteração da Tabela: honorarios
-- Descrição: Adiciona colunas que estão sendo usadas pelo frontend mas não existem na tabela
-- =====================================================

-- =====================================================
-- 1. Adicionar coluna parte_outro_descricao
-- =====================================================

ALTER TABLE honorarios
ADD COLUMN IF NOT EXISTS parte_outro_descricao VARCHAR(255);

COMMENT ON COLUMN honorarios.parte_outro_descricao IS 'Descrição da parte quando selecionado "outro" como parte no processo';

-- =====================================================
-- 2. Adicionar coluna descricao (Histórico)
-- =====================================================

ALTER TABLE honorarios
ADD COLUMN IF NOT EXISTS descricao TEXT;

COMMENT ON COLUMN honorarios.descricao IS 'Histórico/descrição do honorário';

-- =====================================================
-- 3. Adicionar coluna forma_pagamento
-- =====================================================

ALTER TABLE honorarios
ADD COLUMN IF NOT EXISTS forma_pagamento VARCHAR(50) 
CHECK (forma_pagamento IN ('avista', 'parcelado'));

COMMENT ON COLUMN honorarios.forma_pagamento IS 'Forma de pagamento: avista ou parcelado';

-- =====================================================
-- 4. Adicionar coluna numero_parcelas
-- =====================================================

ALTER TABLE honorarios
ADD COLUMN IF NOT EXISTS numero_parcelas INTEGER 
CHECK (numero_parcelas IS NULL OR numero_parcelas > 0);

COMMENT ON COLUMN honorarios.numero_parcelas IS 'Número de parcelas (quando forma de pagamento for parcelado)';

-- =====================================================
-- 5. Adicionar coluna status
-- =====================================================

ALTER TABLE honorarios
ADD COLUMN IF NOT EXISTS status VARCHAR(20) NOT NULL DEFAULT 'pendente'
CHECK (status IN ('pendente', 'pago', 'cancelado'));

COMMENT ON COLUMN honorarios.status IS 'Status do honorário: pendente, pago ou cancelado';

-- =====================================================
-- 6. Adicionar coluna dividir_entre_socios
-- =====================================================

ALTER TABLE honorarios
ADD COLUMN IF NOT EXISTS dividir_entre_socios BOOLEAN NOT NULL DEFAULT true;

COMMENT ON COLUMN honorarios.dividir_entre_socios IS 'Indica se o honorário será dividido entre sócios ou terá um advogado responsável único';

-- =====================================================
-- 7. Adicionar coluna advogado_responsavel_id
-- =====================================================

ALTER TABLE honorarios
ADD COLUMN IF NOT EXISTS advogado_responsavel_id UUID REFERENCES advogados(id) ON DELETE SET NULL;

COMMENT ON COLUMN honorarios.advogado_responsavel_id IS 'Referência ao advogado responsável (quando não dividir entre sócios)';

-- =====================================================
-- 8. Criar índices para as novas colunas
-- =====================================================

-- Índice para busca por forma de pagamento
CREATE INDEX IF NOT EXISTS idx_honorarios_forma_pagamento 
ON honorarios(forma_pagamento);

-- Índice para busca por status
CREATE INDEX IF NOT EXISTS idx_honorarios_status 
ON honorarios(status);

-- Índice para busca por advogado responsável
CREATE INDEX IF NOT EXISTS idx_honorarios_advogado_responsavel 
ON honorarios(advogado_responsavel_id) 
WHERE advogado_responsavel_id IS NOT NULL;

-- Índice para busca por dividir entre sócios
CREATE INDEX IF NOT EXISTS idx_honorarios_dividir_socios 
ON honorarios(dividir_entre_socios);

-- =====================================================
-- 9. Atualizar registros existentes (se houver)
-- =====================================================

-- Define status padrão baseado na forma de pagamento (se existir)
UPDATE honorarios
SET status = CASE 
  WHEN forma_pagamento = 'avista' THEN 'pago'
  WHEN forma_pagamento = 'parcelado' THEN 'pendente'
  ELSE 'pendente'
END
WHERE status IS NULL OR status = '';

-- =====================================================
-- FIM DO SCRIPT
-- =====================================================

