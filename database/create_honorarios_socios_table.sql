-- =====================================================
-- Criação da Tabela: honorarios_socios
-- Descrição: Tabela para armazenar a divisão de honorários entre advogados/sócios
-- =====================================================

-- Remove a tabela se já existir (use com cuidado em produção)
-- DROP TABLE IF EXISTS honorarios_socios CASCADE;

-- Criação da tabela honorarios_socios
CREATE TABLE IF NOT EXISTS honorarios_socios (
  -- Coluna de identificação única (UUID padrão do Supabase)
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Identificação do Honorário (Foreign Key)
  honorario_id UUID NOT NULL REFERENCES honorarios(id) ON DELETE CASCADE,
  
  -- Número do Processo (armazenado diretamente para facilitar consultas)
  numero_processo VARCHAR(255) NOT NULL,
  
  -- Identificação do Advogado (Foreign Key)
  id_advogado UUID NOT NULL REFERENCES advogados(id) ON DELETE RESTRICT,
  
  -- Nome do Advogado (armazenado diretamente para facilitar consultas e relatórios)
  nome_advogado VARCHAR(255) NOT NULL,
  
  -- Percentual do Valor que o advogado tem direito
  -- Armazenado como DECIMAL para permitir valores como 25.5, 33.33, etc.
  percentual_valor DECIMAL(5, 2) NOT NULL CHECK (percentual_valor > 0 AND percentual_valor <= 100),
  
  -- Colunas padrões do Supabase
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  
  -- Constraint para garantir que não haja advogados duplicados no mesmo honorário
  CONSTRAINT honorarios_socios_unique_check UNIQUE (honorario_id, id_advogado)
);

-- =====================================================
-- Índices para melhorar performance
-- =====================================================

-- Índice para busca por honorário (mais comum)
CREATE INDEX IF NOT EXISTS idx_honorarios_socios_honorario_id 
ON honorarios_socios(honorario_id);

-- Índice para busca por advogado
CREATE INDEX IF NOT EXISTS idx_honorarios_socios_id_advogado 
ON honorarios_socios(id_advogado);

-- Índice para busca por número do processo
CREATE INDEX IF NOT EXISTS idx_honorarios_socios_numero_processo 
ON honorarios_socios(numero_processo);

-- Índice composto para buscar divisão de um honorário específico
CREATE INDEX IF NOT EXISTS idx_honorarios_socios_honorario_advogado 
ON honorarios_socios(honorario_id, id_advogado);

-- Índice para ordenação por data de criação
CREATE INDEX IF NOT EXISTS idx_honorarios_socios_created_at 
ON honorarios_socios(created_at DESC);

-- =====================================================
-- Trigger para atualizar updated_at automaticamente
-- =====================================================

-- Trigger que executa a função antes de atualizar
-- (A função update_updated_at_column já deve existir da tabela honorarios)
CREATE TRIGGER update_honorarios_socios_updated_at
BEFORE UPDATE ON honorarios_socios
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- Trigger para atualizar nome_advogado automaticamente
-- =====================================================

-- Função para atualizar o nome do advogado quando o id_advogado for alterado
CREATE OR REPLACE FUNCTION update_nome_advogado()
RETURNS TRIGGER AS $$
BEGIN
  -- Se o id_advogado foi alterado ou o nome está vazio, busca o nome atualizado
  IF NEW.id_advogado IS DISTINCT FROM OLD.id_advogado OR NEW.nome_advogado IS NULL OR NEW.nome_advogado = '' THEN
    SELECT nome INTO NEW.nome_advogado
    FROM advogados
    WHERE id = NEW.id_advogado;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger que executa a função antes de inserir ou atualizar
CREATE TRIGGER update_honorarios_socios_nome_advogado
BEFORE INSERT OR UPDATE ON honorarios_socios
FOR EACH ROW
EXECUTE FUNCTION update_nome_advogado();

-- =====================================================
-- Função para validar soma dos percentuais
-- =====================================================

-- Função que verifica se a soma dos percentuais de um honorário é igual a 100%
CREATE OR REPLACE FUNCTION validar_soma_percentuais(honorario_id_param UUID)
RETURNS BOOLEAN AS $$
DECLARE
  soma_percentual DECIMAL(5, 2);
BEGIN
  SELECT COALESCE(SUM(percentual_valor), 0)
  INTO soma_percentual
  FROM honorarios_socios
  WHERE honorario_id = honorario_id_param;
  
  RETURN ABS(soma_percentual - 100) < 0.01; -- Permite pequena diferença de arredondamento
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION validar_soma_percentuais IS 'Valida se a soma dos percentuais de um honorário é igual a 100%';

-- =====================================================
-- Função para calcular valor do advogado
-- =====================================================

-- Função que calcula o valor em reais que um advogado tem direito baseado no percentual
CREATE OR REPLACE FUNCTION calcular_valor_advogado(
  honorario_id_param UUID,
  advogado_id_param UUID
)
RETURNS DECIMAL(15, 2) AS $$
DECLARE
  valor_total DECIMAL(15, 2);
  percentual DECIMAL(5, 2);
  valor_advogado DECIMAL(15, 2);
BEGIN
  -- Busca o valor total do honorário
  SELECT valor_total INTO valor_total
  FROM honorarios
  WHERE id = honorario_id_param;
  
  -- Busca o percentual do advogado
  SELECT percentual_valor INTO percentual
  FROM honorarios_socios
  WHERE honorario_id = honorario_id_param AND id_advogado = advogado_id_param;
  
  -- Calcula o valor
  IF valor_total IS NOT NULL AND percentual IS NOT NULL THEN
    valor_advogado := (valor_total * percentual) / 100;
  ELSE
    valor_advogado := 0;
  END IF;
  
  RETURN COALESCE(valor_advogado, 0);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION calcular_valor_advogado IS 'Calcula o valor em reais que um advogado tem direito baseado no percentual e valor total do honorário';

-- =====================================================
-- Comentários nas colunas para documentação
-- =====================================================

COMMENT ON TABLE honorarios_socios IS 'Tabela para armazenar a divisão de honorários entre advogados/sócios';
COMMENT ON COLUMN honorarios_socios.id IS 'Identificador único do registro (UUID)';
COMMENT ON COLUMN honorarios_socios.honorario_id IS 'Referência ao honorário ao qual a divisão pertence';
COMMENT ON COLUMN honorarios_socios.numero_processo IS 'Número do processo judicial (armazenado para facilitar consultas)';
COMMENT ON COLUMN honorarios_socios.id_advogado IS 'Referência ao advogado que participa da divisão';
COMMENT ON COLUMN honorarios_socios.nome_advogado IS 'Nome do advogado (atualizado automaticamente via trigger)';
COMMENT ON COLUMN honorarios_socios.percentual_valor IS 'Percentual do valor total que o advogado tem direito (0 a 100)';
COMMENT ON COLUMN honorarios_socios.created_at IS 'Data e hora de criação do registro';
COMMENT ON COLUMN honorarios_socios.updated_at IS 'Data e hora da última atualização do registro';

-- =====================================================
-- Políticas RLS (Row Level Security) - Ajuste conforme necessário
-- =====================================================

-- Habilita RLS na tabela
ALTER TABLE honorarios_socios ENABLE ROW LEVEL SECURITY;

-- Política padrão: usuários autenticados podem ler todas as divisões
CREATE POLICY "Usuários autenticados podem visualizar divisões"
ON honorarios_socios
FOR SELECT
TO authenticated
USING (true);

-- Política padrão: usuários autenticados podem inserir divisões
CREATE POLICY "Usuários autenticados podem inserir divisões"
ON honorarios_socios
FOR INSERT
TO authenticated
WITH CHECK (true);

-- Política padrão: usuários autenticados podem atualizar divisões
CREATE POLICY "Usuários autenticados podem atualizar divisões"
ON honorarios_socios
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

-- Política padrão: usuários autenticados podem deletar divisões
CREATE POLICY "Usuários autenticados podem deletar divisões"
ON honorarios_socios
FOR DELETE
TO authenticated
USING (true);

-- =====================================================
-- View útil: Divisão com valores calculados
-- =====================================================

-- View que calcula automaticamente o valor em reais de cada advogado
CREATE OR REPLACE VIEW vw_honorarios_socios_com_valor AS
SELECT 
  hs.id,
  hs.honorario_id,
  hs.numero_processo,
  hs.id_advogado,
  hs.nome_advogado,
  hs.percentual_valor,
  h.valor_total,
  (h.valor_total * hs.percentual_valor / 100) AS valor_advogado,
  hs.created_at,
  hs.updated_at
FROM honorarios_socios hs
LEFT JOIN honorarios h ON hs.honorario_id = h.id;

COMMENT ON VIEW vw_honorarios_socios_com_valor IS 'View que exibe a divisão de honorários com o cálculo automático do valor em reais de cada advogado';

-- =====================================================
-- View útil: Resumo de divisão por honorário
-- =====================================================

-- View que mostra o resumo da divisão de um honorário
CREATE OR REPLACE VIEW vw_resumo_divisao_honorario AS
SELECT 
  hs.honorario_id,
  hs.numero_processo,
  h.valor_total,
  COUNT(hs.id) AS quantidade_advogados,
  SUM(hs.percentual_valor) AS soma_percentuais,
  CASE 
    WHEN ABS(SUM(hs.percentual_valor) - 100) < 0.01 THEN true
    ELSE false
  END AS percentuais_validos,
  SUM(h.valor_total * hs.percentual_valor / 100) AS valor_total_distribuido
FROM honorarios_socios hs
LEFT JOIN honorarios h ON hs.honorario_id = h.id
GROUP BY hs.honorario_id, hs.numero_processo, h.valor_total;

COMMENT ON VIEW vw_resumo_divisao_honorario IS 'View que exibe o resumo da divisão de honorários, incluindo validação da soma dos percentuais';

-- =====================================================
-- FIM DO SCRIPT
-- =====================================================
-- 
-- NOTAS IMPORTANTES:
-- 
-- 1. A tabela armazena numero_processo e nome_advogado diretamente para facilitar
--    consultas sem necessidade de JOINs constantes.
--
-- 2. O trigger update_nome_advogado atualiza automaticamente o nome_advogado
--    quando o id_advogado é alterado ou quando o nome está vazio.
--
-- 3. A constraint honorarios_socios_unique_check garante que não haja
--    advogados duplicados no mesmo honorário.
--
-- 4. O percentual_valor aceita valores de 0 a 100, permitindo decimais
--    (ex: 25.5, 33.33, etc.).
--
-- 5. A função validar_soma_percentuais() pode ser usada para verificar se
--    a soma dos percentuais de um honorário é igual a 100%.
--
-- 6. A função calcular_valor_advogado() calcula o valor em reais que um
--    advogado tem direito baseado no percentual e valor total do honorário.
--
-- 7. O ON DELETE CASCADE na foreign key honorario_id garante que quando um
--    honorário for deletado, todas suas divisões também serão deletadas.
--
-- 8. O ON DELETE RESTRICT na foreign key id_advogado garante que não seja
--    possível deletar um advogado que está participando de divisões.
--
-- 9. A view vw_honorarios_socios_com_valor facilita consultas que precisam
--    do valor em reais calculado para cada advogado.
--
-- 10. A view vw_resumo_divisao_honorario facilita a validação e visualização
--     do resumo da divisão de um honorário.
--
-- 11. Exemplo de uso da função de validação:
--     SELECT validar_soma_percentuais('uuid-do-honorario');
--
-- 12. Exemplo de uso da função de cálculo:
--     SELECT calcular_valor_advogado('uuid-honorario', 'uuid-advogado');
--
-- =====================================================

