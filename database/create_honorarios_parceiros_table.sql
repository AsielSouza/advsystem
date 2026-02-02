-- =====================================================
-- Criação da Tabela: honorarios_parceiros
-- Descrição: Divisão de honorários entre advogados parceiros/associados
-- Referência: REGISTER_FEES_MIGRATION.md
-- =====================================================

CREATE TABLE IF NOT EXISTS public.honorarios_parceiros (
  id UUID NOT NULL DEFAULT gen_random_uuid(),
  honorario_id UUID NOT NULL,
  numero_processo VARCHAR(255) NOT NULL,
  id_advogado UUID NOT NULL,
  nome_advogado VARCHAR(255) NOT NULL,
  percentual_valor NUMERIC(5, 2) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

  CONSTRAINT honorarios_parceiros_pkey PRIMARY KEY (id),
  CONSTRAINT honorarios_parceiros_unique_check UNIQUE (honorario_id, id_advogado),
  CONSTRAINT honorarios_parceiros_honorario_id_fkey
    FOREIGN KEY (honorario_id) REFERENCES public.honorarios(id) ON DELETE CASCADE,
  CONSTRAINT honorarios_parceiros_id_advogado_fkey
    FOREIGN KEY (id_advogado) REFERENCES public.advogados(id) ON DELETE RESTRICT,
  CONSTRAINT honorarios_parceiros_percentual_valor_check
    CHECK (percentual_valor > 0 AND percentual_valor <= 100)
) TABLESPACE pg_default;

-- Índices
CREATE INDEX IF NOT EXISTS idx_honorarios_parceiros_honorario_id
ON public.honorarios_parceiros(honorario_id);

CREATE INDEX IF NOT EXISTS idx_honorarios_parceiros_id_advogado
ON public.honorarios_parceiros(id_advogado);

CREATE INDEX IF NOT EXISTS idx_honorarios_parceiros_numero_processo
ON public.honorarios_parceiros(numero_processo);

CREATE INDEX IF NOT EXISTS idx_honorarios_parceiros_honorario_advogado
ON public.honorarios_parceiros(honorario_id, id_advogado);

CREATE INDEX IF NOT EXISTS idx_honorarios_parceiros_created_at
ON public.honorarios_parceiros(created_at DESC);

-- Trigger updated_at
CREATE TRIGGER update_honorarios_parceiros_updated_at
BEFORE UPDATE ON public.honorarios_parceiros
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Função e trigger para manter nome_advogado sincronizado
CREATE OR REPLACE FUNCTION update_nome_advogado_parceiros()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' OR NEW.nome_advogado IS NULL OR NEW.nome_advogado = ''
     OR (TG_OP = 'UPDATE' AND NEW.id_advogado IS DISTINCT FROM OLD.id_advogado) THEN
    SELECT nome INTO NEW.nome_advogado
    FROM public.advogados WHERE id = NEW.id_advogado;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_honorarios_parceiros_nome_advogado
BEFORE INSERT OR UPDATE ON public.honorarios_parceiros
FOR EACH ROW
EXECUTE FUNCTION update_nome_advogado_parceiros();

COMMENT ON TABLE public.honorarios_parceiros IS 'Divisão de honorários entre advogados parceiros/associados';
COMMENT ON COLUMN public.honorarios_parceiros.percentual_valor IS 'Percentual do valor do grupo Parceiros destinado a este advogado (total do grupo = 100%)';
