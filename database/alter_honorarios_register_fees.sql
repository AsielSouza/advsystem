-- =====================================================
-- Migração: Honorários — suporte ao fluxo Register Fees
-- Data: 2025-02-01
-- Referência: REGISTER_FEES_MIGRATION.md
-- =====================================================

-- 1. Adicionar coluna valor_causa (Valor da causa do processo)
ALTER TABLE public.honorarios
ADD COLUMN IF NOT EXISTS valor_causa NUMERIC(15, 2) NULL;

COMMENT ON COLUMN public.honorarios.valor_causa IS 'Valor da causa do processo';

-- 2. Adicionar coluna dividir_entre_parceiros
ALTER TABLE public.honorarios
ADD COLUMN IF NOT EXISTS dividir_entre_parceiros BOOLEAN NOT NULL DEFAULT FALSE;

COMMENT ON COLUMN public.honorarios.dividir_entre_parceiros IS 'Indica se o honorário será dividido entre advogados parceiros/associados';

-- 3. Adicionar colunas percentual_socios e percentual_parceiros
ALTER TABLE public.honorarios
ADD COLUMN IF NOT EXISTS percentual_socios NUMERIC(5, 2) NOT NULL DEFAULT 100;

ALTER TABLE public.honorarios
ADD COLUMN IF NOT EXISTS percentual_parceiros NUMERIC(5, 2) NOT NULL DEFAULT 0;

COMMENT ON COLUMN public.honorarios.percentual_socios IS 'Percentual do honorário total destinado ao grupo Sócios (0-100)';
COMMENT ON COLUMN public.honorarios.percentual_parceiros IS 'Percentual do honorário total destinado ao grupo Parceiros (0-100)';

-- 4. Atualizar CHECK de forma_pagamento para aceitar 'a_vista' (usado pelo frontend)
ALTER TABLE public.honorarios
DROP CONSTRAINT IF EXISTS honorarios_forma_pagamento_check;

ALTER TABLE public.honorarios
ADD CONSTRAINT honorarios_forma_pagamento_check CHECK (
  forma_pagamento IS NULL OR forma_pagamento IN ('avista', 'a_vista', 'parcelado')
);

-- 5. Adicionar CHECK para percentuais dos grupos (validação de soma fica na aplicação)
ALTER TABLE public.honorarios
DROP CONSTRAINT IF EXISTS honorarios_percentuais_grupos_check;

ALTER TABLE public.honorarios
ADD CONSTRAINT honorarios_percentuais_grupos_check CHECK (
  percentual_socios >= 0 AND percentual_socios <= 100
  AND percentual_parceiros >= 0 AND percentual_parceiros <= 100
);

-- 6. Índices para novas colunas
CREATE INDEX IF NOT EXISTS idx_honorarios_dividir_parceiros
ON public.honorarios(dividir_entre_parceiros) WHERE dividir_entre_parceiros = TRUE;

CREATE INDEX IF NOT EXISTS idx_honorarios_valor_causa
ON public.honorarios(valor_causa) WHERE valor_causa IS NOT NULL;
