-- =====================================================
-- Adiciona campos de usuário na tabela honorarios_historico
-- Descrição: Adiciona campos para armazenar informações do usuário que criou/editou a atualização
-- =====================================================

-- Adiciona a coluna usuario_nome (pode ser NULL para registros antigos)
ALTER TABLE honorarios_historico 
ADD COLUMN IF NOT EXISTS usuario_nome VARCHAR(255);

-- Adiciona a coluna criado_por (pode ser NULL para registros antigos)
ALTER TABLE honorarios_historico 
ADD COLUMN IF NOT EXISTS criado_por VARCHAR(255);

-- Adiciona a coluna editado_por (pode ser NULL para registros antigos)
ALTER TABLE honorarios_historico 
ADD COLUMN IF NOT EXISTS editado_por VARCHAR(255);

-- Comentários nas colunas
COMMENT ON COLUMN honorarios_historico.usuario_nome IS 'Nome do usuário que criou a atualização no histórico (legado)';
COMMENT ON COLUMN honorarios_historico.criado_por IS 'Nome do usuário que criou a atualização';
COMMENT ON COLUMN honorarios_historico.editado_por IS 'Nome do usuário que editou a atualização';

-- =====================================================
-- FIM DO SCRIPT
-- =====================================================

