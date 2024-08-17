CREATE OR REPLACE FUNCTION descartar_produtolote_vencimento()
RETURNS VOID AS $$
BEGIN
        UPDATE produto SET preco = preco * 0.7 
        WHERE data_validade BETWEEN CURRENT_DATE + INTERVAL '1 day' AND CURRENT_DATE + INTERVAL '45 days';
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION descartar_produtolote_vencimento() IS $$
Esta função atualiza o preço dos produtos que estão entre 1 e 45 dias
antes da data de validade, aplicando um desconto de 30%. Destina-se a
incentivar a venda de produtos próximos ao vencimento e minimizar
perdas. $$;