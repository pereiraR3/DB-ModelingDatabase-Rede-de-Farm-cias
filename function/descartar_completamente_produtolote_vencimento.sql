CREATE OR REPLACE FUNCTION descartar_completamente_produtolote_vencimento()
RETURNS VOID AS $$
BEGIN
    -- Primeiro, exclui os lotes dos produtos que serão descartados
    DELETE FROM lote
    WHERE id_produto IN (
        SELECT id FROM produto
        WHERE data_validade BETWEEN CURRENT_DATE + INTERVAL '1 day' 
        AND CURRENT_DATE + INTERVAL '30 days'
    );
        
    -- Em seguida, exclui os produtos próximos do vencimento
    DELETE FROM produto
    WHERE data_validade BETWEEN CURRENT_DATE + INTERVAL '1 day' 
    AND CURRENT_DATE + INTERVAL '30 days';
    END;
    $$ LANGUAGE plpgsql;

COMMENT ON FUNCTION descartar_produtolote_vencimento() IS $$
Esta função exclui produtos e lotes que estão entre 1 e 30 dias antes
da data de validade. A função é usada para garantir que produtos
expirados sejam removidos do estoque e não sejam vendidos aos
consumidores. $$;