-- =====================================================
-- Criação da Tabela: profiles
-- Descrição: Tabela para armazenar informações de perfil dos usuários
-- =====================================================

-- Remove a tabela se já existir (use com cuidado em produção)
-- DROP TABLE IF EXISTS profiles CASCADE;

-- Criação da tabela profiles
CREATE TABLE IF NOT EXISTS profiles (
  -- Coluna de identificação única (UUID que referencia auth.users)
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Nome de exibição do usuário
  display_name TEXT,
  
  -- Email do usuário (mantido para referência rápida)
  email TEXT,
  
  -- Colunas padrões do Supabase
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- =====================================================
-- Índices para melhorar performance
-- =====================================================

-- Índice para busca por email
CREATE INDEX IF NOT EXISTS idx_profiles_email 
ON profiles(email) 
WHERE email IS NOT NULL;

-- Índice para busca por display_name
CREATE INDEX IF NOT EXISTS idx_profiles_display_name 
ON profiles(display_name) 
WHERE display_name IS NOT NULL;

-- =====================================================
-- Trigger para atualizar updated_at automaticamente
-- =====================================================

-- Trigger que executa a função antes de atualizar
CREATE TRIGGER update_profiles_updated_at
BEFORE UPDATE ON profiles
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- Comentários nas colunas para documentação
-- =====================================================

COMMENT ON TABLE profiles IS 'Tabela para armazenar informações de perfil dos usuários autenticados';
COMMENT ON COLUMN profiles.id IS 'Identificador único do perfil (UUID que referencia auth.users)';
COMMENT ON COLUMN profiles.display_name IS 'Nome de exibição do usuário';
COMMENT ON COLUMN profiles.email IS 'Email do usuário (mantido para referência rápida)';
COMMENT ON COLUMN profiles.created_at IS 'Data e hora de criação do registro';
COMMENT ON COLUMN profiles.updated_at IS 'Data e hora da última atualização do registro';

-- =====================================================
-- Políticas RLS (Row Level Security)
-- =====================================================

-- Habilita RLS na tabela
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Política: usuários autenticados podem visualizar todos os perfis
-- (ajuste conforme suas regras de negócio se necessário restringir)
CREATE POLICY "Usuários autenticados podem visualizar perfis"
ON profiles
FOR SELECT
TO authenticated
USING (true);

-- Política: usuários podem inserir apenas seu próprio perfil
CREATE POLICY "Usuários podem inserir seu próprio perfil"
ON profiles
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = id);

-- Política: usuários podem atualizar apenas seu próprio perfil
CREATE POLICY "Usuários podem atualizar seu próprio perfil"
ON profiles
FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Política: usuários podem deletar apenas seu próprio perfil
CREATE POLICY "Usuários podem deletar seu próprio perfil"
ON profiles
FOR DELETE
TO authenticated
USING (auth.uid() = id);

-- =====================================================
-- FIM DO SCRIPT
-- =====================================================
-- 
-- NOTAS IMPORTANTES:
-- 
-- 1. Esta tabela está vinculada à tabela auth.users do Supabase através
--    da chave primária id, que referencia auth.users(id).
--
-- 2. O ON DELETE CASCADE garante que quando um usuário é deletado do
--    auth.users, seu perfil também é removido automaticamente.
--
-- 3. As políticas RLS garantem que:
--    - Usuários podem ver todos os perfis (ajuste se necessário)
--    - Usuários só podem inserir/atualizar/deletar seu próprio perfil
--
-- 4. O trigger de updated_at garante que o campo seja atualizado
--    automaticamente a cada modificação no registro.
--
-- 5. Os índices foram criados para otimizar consultas por email e
--    display_name.
--
-- =====================================================
