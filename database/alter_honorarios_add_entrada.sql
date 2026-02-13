-- =====================================================
-- Migração: Honorários — suporte a valor de entrada
-- Descrição: Adiciona colunas possui_entrada, valor_entrada e data_entrada
-- =====================================================

-- 1. Adicionar coluna possui_entrada
ALTER TABLE public.honorarios
ADD COLUMN IF NOT EXISTS possui_entrada BOOLEAN NOT NULL DEFAULT FALSE;

COMMENT ON COLUMN public.honorarios.possui_entrada IS 'Indica se o honorário possui valor de entrada pago à vista';

-- 2. Adicionar coluna valor_entrada
ALTER TABLE public.honorarios
ADD COLUMN IF NOT EXISTS valor_entrada DECIMAL(15, 2) NOT NULL DEFAULT 0;

COMMENT ON COLUMN public.honorarios.valor_entrada IS 'Valor da entrada (não abate nas parcelas; conta como valor já pago)';

-- 3. Adicionar coluna data_entrada
ALTER TABLE public.honorarios
ADD COLUMN IF NOT EXISTS data_entrada DATE NULL;

COMMENT ON COLUMN public.honorarios.data_entrada IS 'Data em que a entrada foi paga';

-- 4. Constraint para garantir coerência quando possui_entrada = true
ALTER TABLE public.honorarios
DROP CONSTRAINT IF EXISTS honorarios_valor_entrada_check;

ALTER TABLE public.honorarios
ADD CONSTRAINT honorarios_valor_entrada_check CHECK (
  (NOT possui_entrada AND valor_entrada = 0) OR
  (possui_entrada AND valor_entrada >= 0 AND valor_entrada < valor_total)
);
