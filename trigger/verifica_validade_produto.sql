CREATE OR REPLACE FUNCTION verifica_validade_produto()
RETURNS TRIGGER AS $$
BEGIN
    -- Verifica se a data de despacho é posterior à data de validade do produto
    IF NEW.data_despacho > (SELECT data_validade FROM produto WHERE id = NEW.id_produto) THEN
        RAISE EXCEPTION 'Não é possível inserir lote com produtos vencidos.';
    END IF;
    RETURN NEW; -- Retorna o novo registro para ser inserido
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER verifica_validade_antes_inserir_lote
BEFORE INSERT ON lote
FOR EACH ROW
EXECUTE FUNCTION verifica_validade_produto();

COMMENT ON FUNCTION verifica_validade_produto() IS $$
Esta trigger é acionada antes de inserir um novo lote na tabela de lotes. Ela verifica se a data de despacho do lote é anterior à data de validade do produto associado. Caso a data de despacho seja posterior à data de validade, a inserção é bloqueada e uma exceção é lançada para prevenir o armazenamento de produtos vencidos. $$;