CREATE OR REPLACE FUNCTION resetar_status_aniversario_ano_novo()
RETURNS VOID AS $$

BEGIN
    -- Atualiza status_aniversario para NULL (ou FALSE) para todos os clientes
    UPDATE cliente
    SET status_aniversario = FALSE; 
END;

$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION resetar_status_aniversario_ano_novo() IS $$
Esta função zera o status_aniversario de todos os clientes no primeiro dia de cada 
ano novo. Garante que todos os clientes sejam elegíveis para receber descontos de
aniversário novamente no próximo ano. $$;