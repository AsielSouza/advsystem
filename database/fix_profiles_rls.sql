-- =====================================================
-- Ajuste de RLS na tabela profiles
-- Execute no SQL Editor do Supabase se o POST em profiles retornar 403 no login.
-- Garante que usuários autenticados possam inserir/atualizar o próprio perfil.
-- =====================================================

-- Remove políticas antigas se existirem (para recriar sem conflito)
DROP POLICY IF EXISTS "Usuários podem inserir seu próprio perfil" ON profiles;
DROP POLICY IF EXISTS "Usuários podem atualizar seu próprio perfil" ON profiles;

-- Garante que RLS está ativo
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Usuários autenticados podem inserir apenas o próprio perfil (id = auth.uid())
CREATE POLICY "Usuários podem inserir seu próprio perfil"
ON profiles
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = id);

-- Usuários autenticados podem atualizar apenas o próprio perfil
CREATE POLICY "Usuários podem atualizar seu próprio perfil"
ON profiles
FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);
