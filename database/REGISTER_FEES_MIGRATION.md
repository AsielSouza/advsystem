# Migração do Banco de Dados — Fluxo Register Fees

Este documento descreve o mapeamento completo do fluxo de cadastro de honorários (Register Fees) para o banco de dados e os scripts SQL necessários para suportar a nova estrutura.

---

## 1. Visão Geral do Fluxo

O cadastro de honorários possui 4 passos:

| Step | Nome | Campos do Formulário |
|------|------|----------------------|
| 0 | Cliente | Nome do cliente (PF ou PJ) |
| 1 | Dados do Processo | Nº do processo, Valor da causa, Histórico |
| 2 | Financeiro | Data da contratação, Valor do honorário, Forma de pagamento (À vista / Parcelado), Parcelas (se parcelado) |
| 3 | Honorários | Toggle "Dividir entre sócios", Advogado responsável OU Divisão entre sócios, Toggle "Dividir entre parceiros", Percentual Sócios/Parceiros, Divisão entre parceiros |

---

## 2. Mapeamento Formulário → Banco de Dados

### 2.1 Tabela `honorarios` (principal)

| Campo Formulário | Coluna DB | Tipo | Observações |
|------------------|-----------|------|-------------|
| **Step 1 - Cliente** | | | |
| cliente.id (tipo=fisica) | `cliente_pessoa_fisica_id` | UUID | FK → clientes_pessoa_fisica |
| cliente.id (tipo=juridica) | `cliente_pessoa_juridica_id` | UUID | FK → clientes_pessoa_juridica |
| **Step 2 - Processo** | | | |
| processo.numero_processo | `numero_processo` | VARCHAR(255) | ✓ já existe |
| processo.valor_causa | `valor_causa` | NUMERIC(15,2) | **NOVO** — adicionar coluna |
| processo.historico | (honorarios_historico) | TEXT | vai para tabela `honorarios_historico` |
| — | `parte` | VARCHAR(50) | obrigatório no DB; não coletado no form. Usar default `'outro'` ou adicionar campo ao ProcessoCadFees |
| **Step 3 - Financeiro** | | | |
| financeiro.data_contratacao | `data_contratacao` | DATE | ✓ já existe |
| financeiro.valor_honorario | `valor_total` | NUMERIC(15,2) | ✓ já existe |
| financeiro.forma_pagamento | `forma_pagamento` | VARCHAR(50) | mapear: `a_vista`→`avista` ou adicionar `a_vista` ao check |
| financeiro.parcelas.length | `numero_parcelas` | INTEGER | ✓ já existe |
| **Step 4 - Honorários** | | | |
| honorarios.dividir_entre_socios | `dividir_entre_socios` | BOOLEAN | ✓ já existe |
| honorarios.advogado_responsavel_id | `advogado_responsavel_id` | UUID | ✓ já existe (quando não divide entre sócios) |
| honorarios.dividir_entre_parceiros | `dividir_entre_parceiros` | BOOLEAN | **NOVO** — adicionar coluna |
| honorarios.percentual_socios | `percentual_socios` | NUMERIC(5,2) | **NOVO** — adicionar coluna |
| honorarios.percentual_parceiros | `percentual_parceiros` | NUMERIC(5,2) | **NOVO** — adicionar coluna |

### 2.2 Tabela `honorarios_historico`

| Campo Formulário | Coluna DB | Observações |
|------------------|-----------|-------------|
| processo.historico | `historico` | TEXT |
| processo.numero_processo | `numero_processo` | para denormalização |
| honorario_id | `honorario_id` | FK → honorarios |

### 2.3 Tabela `honorarios_parcelas`

| Campo Formulário | Coluna DB | Observações |
|------------------|-----------|-------------|
| parcela.numero | `numero_da_parcela` | INTEGER |
| parcela.dataPagamento | `data_vencimento` | DATE (data prevista de pagamento) |
| parcela.valor | `valor_parcela` | NUMERIC(15,2) |
| — | `data_pagamento` | DATE | preenchido quando parcela for paga |

### Contrato de Parcelas (Frontend ↔ Backend)

**Formato esperado no formulário (`financeiro.parcelas`):**

| Campo           | Tipo    | Formato       | Descrição                                      |
|-----------------|---------|---------------|------------------------------------------------|
| `numero`        | number  | 1, 2, 3, ...  | Número sequencial da parcela                   |
| `dataPagamento` | string  | `YYYY-MM-DD`  | Data de vencimento (mapea para `data_vencimento`) |
| `valor`         | number  | decimal       | Valor da parcela em R$                         |

**Mapeamento no backend:**
- `numero` → `numero_da_parcela`
- `dataPagamento` → `data_vencimento` (coluna DATE)
- `valor` → `valor_parcela`

**Validações:**
- `dataPagamento` deve ser string no formato ISO `YYYY-MM-DD`
- Ao carregar, `data_vencimento` (DATE) é retornado como string no mesmo formato

### 2.4 Tabela `honorarios_socios`

| Campo Formulário | Coluna DB | Observações |
|------------------|-----------|-------------|
| divisao_socios[].id_advogado | `id_advogado` | UUID |
| divisao_socios[].nome | `nome_advogado` | VARCHAR(255) |
| divisao_socios[].percentual | `percentual_valor` | NUMERIC(5,2) |

### 2.5 Nova Tabela `honorarios_parceiros`

| Campo Formulário | Coluna DB | Observações |
|------------------|-----------|-------------|
| divisao_parceiros[].id_advogado | `id_advogado` | UUID |
| divisao_parceiros[].nome | `nome_advogado` | VARCHAR(255) |
| divisao_parceiros[].percentual | `percentual_valor` | NUMERIC(5,2) — percentual dentro do grupo Parceiros |

---

## 3. Inconsistências e Ajustes Necessários

### 3.1 Forma de pagamento

- **Frontend** (`FinanceiroCadFees.vue`): usa `a_vista` e `parcelado`
- **Banco** (`honorarios`): check atual aceita `avista` e `parcelado`

**Solução:** Incluir `a_vista` no CHECK da coluna `forma_pagamento` para compatibilidade com o formulário.

### 3.2 Campo `parte` obrigatório

A coluna `parte` é `NOT NULL` em `honorarios`, mas o formulário `ProcessoCadFees` não coleta esse dado.

**Opções:**
1. **Recomendado:** Adicionar o campo "Parte" (Autor/Réu/Terceiro Interessado/Outro) ao `ProcessoCadFees.vue`
2. **Alternativa:** Garantir que a camada de persistência envie `'outro'` como valor padrão ao salvar

---

## 4. Scripts SQL

Execute os scripts na ordem indicada.

### 4.1 Alterar tabela `honorarios`

```sql
-- =====================================================
-- Migração: Honorários — suporte ao fluxo Register Fees
-- Data: 2025-02-01
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

-- 6. Índices para novas colunas (opcional, para consultas futuras)
CREATE INDEX IF NOT EXISTS idx_honorarios_dividir_parceiros
ON public.honorarios(dividir_entre_parceiros) WHERE dividir_entre_parceiros = TRUE;

CREATE INDEX IF NOT EXISTS idx_honorarios_valor_causa
ON public.honorarios(valor_causa) WHERE valor_causa IS NOT NULL;
```

### 4.2 Criar tabela `honorarios_parceiros`

```sql
-- =====================================================
-- Criação da Tabela: honorarios_parceiros
-- Descrição: Divisão de honorários entre advogados parceiros/associados
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

-- Trigger para manter nome_advogado sincronizado
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
```

---

## 5. RLS (Row Level Security)

Se o projeto usa RLS no Supabase, será necessário adicionar políticas para `honorarios_parceiros`:

```sql
-- Habilitar RLS na nova tabela (se o restante do projeto usar)
ALTER TABLE public.honorarios_parceiros ENABLE ROW LEVEL SECURITY;

-- Exemplo de política (ajustar conforme as políticas existentes de honorarios)
-- CREATE POLICY "..." ON public.honorarios_parceiros FOR ALL USING (...);
```

---

## 6. Fluxo de Persistência Sugerido

Ao implementar o handler de submit em `register-fees.vue`, sugere-se a seguinte ordem de inserção:

1. **honorarios** — registro principal (incluindo `parte` = `'outro'` se não coletado)
2. **honorarios_historico** — histórico do processo
3. **honorarios_parcelas** — se forma_pagamento = `parcelado`
4. **honorarios_socios** — se dividir_entre_socios = true
5. **honorarios_parceiros** — se dividir_entre_parceiros = true

**Mapeamento de valores ao salvar:**
- `forma_pagamento`: enviar `'avista'` ou `'a_vista'` para À vista; `'parcelado'` para Parcelado
- `parte`: usar `'outro'` como padrão ou incluir campo no formulário

---

## 7. Resumo das Alterações

| Ação | Objeto | Descrição |
|------|--------|-----------|
| ALTER | honorarios | Adicionar valor_causa, dividir_entre_parceiros, percentual_socios, percentual_parceiros |
| ALTER | honorarios | Atualizar CHECK forma_pagamento para aceitar 'a_vista' |
| ALTER | honorarios | Adicionar CHECK para percentuais dos grupos |
| CREATE | honorarios_parceiros | Nova tabela para divisão entre parceiros |
| MANTER | honorarios_socios | Sem alterações |
| MANTER | honorarios_historico | Sem alterações |
| MANTER | honorarios_parcelas | Sem alterações |

---

## 8. Observações Finais

- **ID principal:** O `id` da tabela `honorarios` continua sendo o identificador único do honorário.
- **Compatibilidade:** Os scripts são idempotentes (usam `IF NOT EXISTS`, `IF EXISTS`) para permitir execução segura em múltiplas rodadas.
- **Rollback:** Em caso de necessidade, as novas colunas podem ser removidas e a tabela `honorarios_parceiros` pode ser dropada; verifique dependências antes.
