-- =====================================================
-- Criação da Tabela: honorarios_historico
-- Descrição: Tabela para armazenar o histórico de andamento dos processos relacionados aos honorários
-- =====================================================

-- Remove a tabela se já existir (use com cuidado em produção)
-- DROP TABLE IF EXISTS honorarios_historico CASCADE;

-- Criação da tabela honorarios_historico
CREATE TABLE IF NOT EXISTS honorarios_historico (
  -- Coluna de identificação única (UUID padrão do Supabase)
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Identificação do Honorário (Foreign Key)
  honorario_id UUID NOT NULL REFERENCES honorarios(id) ON DELETE CASCADE,
  
  -- Número do Processo (armazenado diretamente para facilitar consultas)
  numero_processo VARCHAR(255) NOT NULL,
  
  -- Histórico do Andamento do Processo
  -- Campo de texto longo para registrar eventos, atualizações e observações
  historico TEXT NOT NULL,
  
  -- Colunas padrões do Supabase
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- =====================================================
-- Índices para melhorar performance
-- =====================================================

-- Índice para busca por honorário (mais comum)
CREATE INDEX IF NOT EXISTS idx_honorarios_historico_honorario_id 
ON honorarios_historico(honorario_id);

-- Índice para busca por número do processo
CREATE INDEX IF NOT EXISTS idx_honorarios_historico_numero_processo 
ON honorarios_historico(numero_processo);

-- Índice para ordenação por data de criação (mais recentes primeiro)
CREATE INDEX IF NOT EXISTS idx_honorarios_historico_created_at 
ON honorarios_historico(created_at DESC);

-- Índice composto para buscar histórico de um honorário ordenado por data
CREATE INDEX IF NOT EXISTS idx_honorarios_historico_honorario_data 
ON honorarios_historico(honorario_id, created_at DESC);

-- =====================================================
-- Trigger para atualizar updated_at automaticamente
-- =====================================================

-- Trigger que executa a função antes de atualizar
-- (A função update_updated_at_column já deve existir da tabela honorarios)
CREATE TRIGGER update_honorarios_historico_updated_at
BEFORE UPDATE ON honorarios_historico
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- Índice Full-Text Search para busca no campo histórico
-- =====================================================

-- Cria um índice GIN para busca full-text no campo histórico
-- Isso permite buscas eficientes por palavras-chave dentro do texto
CREATE INDEX IF NOT EXISTS idx_honorarios_historico_fulltext 
ON honorarios_historico USING gin(to_tsvector('portuguese', historico));

-- =====================================================
-- Função para busca full-text no histórico
-- =====================================================

-- Função auxiliar para buscar no histórico usando full-text search
CREATE OR REPLACE FUNCTION buscar_historico_por_texto(
  texto_busca TEXT,
  honorario_id_param UUID DEFAULT NULL
)
RETURNS TABLE (
  id UUID,
  honorario_id UUID,
  numero_processo VARCHAR,
  historico TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  updated_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
  IF honorario_id_param IS NOT NULL THEN
    RETURN QUERY
    SELECT 
      h.id,
      h.honorario_id,
      h.numero_processo,
      h.historico,
      h.created_at,
      h.updated_at
    FROM honorarios_historico h
    WHERE h.honorario_id = honorario_id_param
      AND to_tsvector('portuguese', h.historico) @@ plainto_tsquery('portuguese', texto_busca)
    ORDER BY h.created_at DESC;
  ELSE
    RETURN QUERY
    SELECT 
      h.id,
      h.honorario_id,
      h.numero_processo,
      h.historico,
      h.created_at,
      h.updated_at
    FROM honorarios_historico h
    WHERE to_tsvector('portuguese', h.historico) @@ plainto_tsquery('portuguese', texto_busca)
    ORDER BY h.created_at DESC;
  END IF;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION buscar_historico_por_texto IS 'Função para buscar registros de histórico usando full-text search. Pode filtrar por honorário específico ou buscar em todos.';

-- =====================================================
-- Comentários nas colunas para documentação
-- =====================================================

COMMENT ON TABLE honorarios_historico IS 'Tabela para armazenar o histórico de andamento dos processos relacionados aos honorários';
COMMENT ON COLUMN honorarios_historico.id IS 'Identificador único do registro de histórico (UUID)';
COMMENT ON COLUMN honorarios_historico.honorario_id IS 'Referência ao honorário ao qual o histórico pertence';
COMMENT ON COLUMN honorarios_historico.numero_processo IS 'Número do processo judicial (armazenado para facilitar consultas)';
COMMENT ON COLUMN honorarios_historico.historico IS 'Texto do histórico contendo informações sobre o andamento do processo';
COMMENT ON COLUMN honorarios_historico.created_at IS 'Data e hora de criação do registro de histórico';
COMMENT ON COLUMN honorarios_historico.updated_at IS 'Data e hora da última atualização do registro de histórico';

-- =====================================================
-- Políticas RLS (Row Level Security) - Ajuste conforme necessário
-- =====================================================

-- Habilita RLS na tabela
ALTER TABLE honorarios_historico ENABLE ROW LEVEL SECURITY;

-- Política padrão: usuários autenticados podem ler todos os históricos
CREATE POLICY "Usuários autenticados podem visualizar histórico"
ON honorarios_historico
FOR SELECT
TO authenticated
USING (true);

-- Política padrão: usuários autenticados podem inserir histórico
CREATE POLICY "Usuários autenticados podem inserir histórico"
ON honorarios_historico
FOR INSERT
TO authenticated
WITH CHECK (true);

-- Política padrão: usuários autenticados podem atualizar histórico
CREATE POLICY "Usuários autenticados podem atualizar histórico"
ON honorarios_historico
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

-- Política padrão: usuários autenticados podem deletar histórico
CREATE POLICY "Usuários autenticados podem deletar histórico"
ON honorarios_historico
FOR DELETE
TO authenticated
USING (true);

-- =====================================================
-- View útil: Histórico com informações do honorário
-- =====================================================

-- View que une o histórico com informações básicas do honorário
CREATE OR REPLACE VIEW vw_historico_completo AS
SELECT 
  h.id,
  h.honorario_id,
  h.numero_processo,
  h.historico,
  h.created_at,
  h.updated_at,
  -- Informações do honorário (se necessário em consultas futuras)
  hon.valor_total,
  hon.data_contratacao,
  hon.parte
FROM honorarios_historico h
LEFT JOIN honorarios hon ON h.honorario_id = hon.id
ORDER BY h.created_at DESC;

COMMENT ON VIEW vw_historico_completo IS 'View que exibe o histórico com informações complementares do honorário';

-- =====================================================
-- FIM DO SCRIPT
-- =====================================================
-- 
-- NOTAS IMPORTANTES:
-- 
-- 1. A tabela armazena o numero_processo diretamente para facilitar consultas
--    sem necessidade de JOIN com a tabela honorarios.
--
-- 2. O campo historico é do tipo TEXT, permitindo textos longos sem limitação
--    de tamanho (até 1GB no PostgreSQL).
--
-- 3. Foi criado um índice GIN para busca full-text no campo historico, permitindo
--    buscas eficientes por palavras-chave dentro do texto usando a função
--    buscar_historico_por_texto().
--
-- 4. O índice full-text usa o dicionário 'portuguese' para melhor suporte
--    à língua portuguesa. Certifique-se de que a extensão está instalada:
--    CREATE EXTENSION IF NOT EXISTS pg_trgm;
--
-- 5. A função buscar_historico_por_texto() permite buscar em todos os históricos
--    ou filtrar por um honorário específico.
--
-- 6. O ON DELETE CASCADE na foreign key garante que quando um honorário for
--    deletado, todo seu histórico também será deletado automaticamente.
--
-- 7. Os índices foram criados para otimizar consultas comuns, especialmente
--    busca por honorário e ordenação por data.
--
-- 8. A view vw_historico_completo facilita consultas que precisam de informações
--    tanto do histórico quanto do honorário relacionado.
--
-- 9. Exemplo de uso da função de busca:
--    SELECT * FROM buscar_historico_por_texto('sentença', 'uuid-do-honorario');
--    SELECT * FROM buscar_historico_por_texto('audiência');
--
-- =====================================================

