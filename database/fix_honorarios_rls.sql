-- =====================================================
-- Script para verificar e corrigir políticas RLS na tabela honorarios
-- =====================================================

-- 1. Verificar se RLS está habilitado
SELECT 
  tablename,
  CASE 
    WHEN rowsecurity THEN 'Habilitado'
    ELSE 'Desabilitado'
  END as rls_status
FROM pg_tables 
WHERE schemaname = 'public' AND tablename = 'honorarios';

-- 2. Verificar políticas existentes
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies 
WHERE schemaname = 'public' AND tablename = 'honorarios';

-- 3. Remover políticas existentes e recriar (para garantir que estão corretas)
DO $$
BEGIN
  -- Remover políticas existentes para recriar com configurações corretas
  DROP POLICY IF EXISTS "Usuários autenticados podem visualizar honorários" ON honorarios;
  DROP POLICY IF EXISTS "Usuários autenticados podem inserir honorários" ON honorarios;
  DROP POLICY IF EXISTS "Usuários autenticados podem atualizar honorários" ON honorarios;
  DROP POLICY IF EXISTS "Usuários autenticados podem deletar honorários" ON honorarios;
  
  RAISE NOTICE 'Políticas antigas removidas (se existiam).';
END $$;

-- 4. Criar políticas com configurações corretas
DO $$
BEGIN
  -- Criar política de SELECT
  CREATE POLICY "Usuários autenticados podem visualizar honorários"
  ON honorarios
  FOR SELECT
  TO authenticated
  USING (true);
  
  RAISE NOTICE 'Política de SELECT criada com sucesso.';

  -- Criar política de INSERT
  CREATE POLICY "Usuários autenticados podem inserir honorários"
  ON honorarios
  FOR INSERT
  TO authenticated
  WITH CHECK (true);
  
  RAISE NOTICE 'Política de INSERT criada com sucesso.';

  -- Criar política de UPDATE
  CREATE POLICY "Usuários autenticados podem atualizar honorários"
  ON honorarios
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);
  
  RAISE NOTICE 'Política de UPDATE criada com sucesso.';

  -- Criar política de DELETE
  CREATE POLICY "Usuários autenticados podem deletar honorários"
  ON honorarios
  FOR DELETE
  TO authenticated
  USING (true);
  
  RAISE NOTICE 'Política de DELETE criada com sucesso.';
END $$;

-- 5. Garantir que RLS está habilitado
ALTER TABLE honorarios ENABLE ROW LEVEL SECURITY;

-- 6. Verificar se há honorários na tabela (para debug)
SELECT COUNT(*) as total_honorarios FROM honorarios;

-- 7. Verificar o estado final das políticas
SELECT 
  policyname,
  cmd as operacao,
  roles,
  qual as condicao_using,
  with_check as condicao_check
FROM pg_policies 
WHERE schemaname = 'public' AND tablename = 'honorarios'
ORDER BY policyname;

-- 8. Teste: Verificar se há honorários (deve funcionar se as políticas estiverem corretas)
-- (Isso deve funcionar se as políticas estiverem corretas)

-- =====================================================
-- FIM DO SCRIPT
-- =====================================================
-- 
-- INSTRUÇÕES:
-- 
-- 1. Execute este script no SQL Editor do Supabase
-- 2. Verifique os resultados das consultas
-- 3. Se houver mensagens de erro, verifique se o usuário tem permissão para criar políticas
-- 4. Após executar, recarregue a página do dashboard e verifique se os honorários aparecem
-- 
