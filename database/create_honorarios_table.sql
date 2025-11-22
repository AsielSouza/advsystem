-- =====================================================
-- Criação da Tabela: honorarios
-- Descrição: Tabela principal para armazenar informações básicas dos honorários
-- =====================================================

-- Remove a tabela se já existir (use com cuidado em produção)
-- DROP TABLE IF EXISTS honorarios CASCADE;

-- Criação da tabela honorarios
CREATE TABLE IF NOT EXISTS honorarios (
  -- Coluna de identificação única (UUID padrão do Supabase)
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Cliente (Pessoa Física ou Jurídica)
  -- Apenas uma das duas colunas será preenchida por registro
  cliente_pessoa_fisica_id UUID REFERENCES clientes_pessoa_fisica(id) ON DELETE RESTRICT,
  cliente_pessoa_juridica_id UUID REFERENCES clientes_pessoa_juridica(id) ON DELETE RESTRICT,
  
  -- Número do Processo
  numero_processo VARCHAR(255) NOT NULL,
  
  -- Parte no Processo
  -- Valores possíveis: 'autor', 'reu', 'terceiro_interessado', 'outro'
  parte VARCHAR(50) NOT NULL CHECK (parte IN ('autor', 'reu', 'terceiro_interessado', 'outro')),
  
  -- Valor Total do Honorário
  valor_total DECIMAL(15, 2) NOT NULL CHECK (valor_total > 0),
  
  -- Data de Contratação
  data_contratacao DATE NOT NULL,
  
  -- Colunas padrões do Supabase
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  
  -- Constraint para garantir que apenas um tipo de cliente seja preenchido
  CONSTRAINT honorarios_cliente_check CHECK (
    (cliente_pessoa_fisica_id IS NOT NULL AND cliente_pessoa_juridica_id IS NULL) OR
    (cliente_pessoa_fisica_id IS NULL AND cliente_pessoa_juridica_id IS NOT NULL)
  )
);

-- =====================================================
-- Índices para melhorar performance
-- =====================================================

-- Índice para busca por cliente pessoa física
CREATE INDEX IF NOT EXISTS idx_honorarios_cliente_pf 
ON honorarios(cliente_pessoa_fisica_id) 
WHERE cliente_pessoa_fisica_id IS NOT NULL;

-- Índice para busca por cliente pessoa jurídica
CREATE INDEX IF NOT EXISTS idx_honorarios_cliente_pj 
ON honorarios(cliente_pessoa_juridica_id) 
WHERE cliente_pessoa_juridica_id IS NOT NULL;

-- Índice para busca por número do processo
CREATE INDEX IF NOT EXISTS idx_honorarios_numero_processo 
ON honorarios(numero_processo);

-- Índice para busca por data de contratação
CREATE INDEX IF NOT EXISTS idx_honorarios_data_contratacao 
ON honorarios(data_contratacao);

-- Índice para busca por parte no processo
CREATE INDEX IF NOT EXISTS idx_honorarios_parte 
ON honorarios(parte);

-- Índice para ordenação por data de criação
CREATE INDEX IF NOT EXISTS idx_honorarios_created_at 
ON honorarios(created_at DESC);

-- =====================================================
-- Trigger para atualizar updated_at automaticamente
-- =====================================================

-- Função para atualizar o campo updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger que executa a função antes de atualizar
CREATE TRIGGER update_honorarios_updated_at
BEFORE UPDATE ON honorarios
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- Comentários nas colunas para documentação
-- =====================================================

COMMENT ON TABLE honorarios IS 'Tabela principal para armazenar informações básicas dos honorários advocatícios';
COMMENT ON COLUMN honorarios.id IS 'Identificador único do honorário (UUID)';
COMMENT ON COLUMN honorarios.cliente_pessoa_fisica_id IS 'Referência ao cliente pessoa física (quando aplicável)';
COMMENT ON COLUMN honorarios.cliente_pessoa_juridica_id IS 'Referência ao cliente pessoa jurídica (quando aplicável)';
COMMENT ON COLUMN honorarios.numero_processo IS 'Número do processo judicial relacionado ao honorário';
COMMENT ON COLUMN honorarios.parte IS 'Parte no processo: autor, réu, terceiro_interessado ou outro';
COMMENT ON COLUMN honorarios.valor_total IS 'Valor total do honorário em reais (R$)';
COMMENT ON COLUMN honorarios.data_contratacao IS 'Data em que o honorário foi contratado';
COMMENT ON COLUMN honorarios.created_at IS 'Data e hora de criação do registro';
COMMENT ON COLUMN honorarios.updated_at IS 'Data e hora da última atualização do registro';

-- =====================================================
-- Políticas RLS (Row Level Security) - Ajuste conforme necessário
-- =====================================================

-- Habilita RLS na tabela
ALTER TABLE honorarios ENABLE ROW LEVEL SECURITY;

-- Política padrão: usuários autenticados podem ler todos os honorários
-- Ajuste conforme suas regras de negócio
CREATE POLICY "Usuários autenticados podem visualizar honorários"
ON honorarios
FOR SELECT
TO authenticated
USING (true);

-- Política padrão: usuários autenticados podem inserir honorários
CREATE POLICY "Usuários autenticados podem inserir honorários"
ON honorarios
FOR INSERT
TO authenticated
WITH CHECK (true);

-- Política padrão: usuários autenticados podem atualizar honorários
CREATE POLICY "Usuários autenticados podem atualizar honorários"
ON honorarios
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

-- Política padrão: usuários autenticados podem deletar honorários
CREATE POLICY "Usuários autenticados podem deletar honorários"
ON honorarios
FOR DELETE
TO authenticated
USING (true);

-- =====================================================
-- FIM DO SCRIPT
-- =====================================================
-- 
-- NOTAS IMPORTANTES:
-- 
-- 1. Este script cria apenas a tabela principal com os campos básicos.
--    Outros campos (descrição, forma de pagamento, parcelas, status, etc.)
--    serão armazenados em tabelas relacionadas conforme a arquitetura do sistema.
--
-- 2. As políticas RLS (Row Level Security) estão configuradas de forma permissiva.
--    Ajuste-as conforme as regras de acesso do seu sistema.
--
-- 3. Os índices foram criados para otimizar consultas comuns.
--    Monitore o desempenho e adicione mais índices se necessário.
--
-- 4. O trigger de updated_at garante que o campo seja atualizado automaticamente
--    a cada modificação no registro.
--
-- 5. A constraint honorarios_cliente_check garante que apenas um tipo de cliente
--    seja preenchido por registro (ou PF ou PJ, nunca ambos).
--
-- =====================================================

