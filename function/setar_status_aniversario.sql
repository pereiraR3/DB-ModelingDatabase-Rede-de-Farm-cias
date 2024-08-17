CREATE OR REPLACE FUNCTION setar_status_aniversario()
RETURNS VOID AS $$

BEGIN
    -- Atualiza status_aniversario para TRUE para clientes que fazem aniversário hoje
    UPDATE cliente
    SET status_aniversario = TRUE
    WHERE EXTRACT(MONTH FROM data_nascimento) = EXTRACT(MONTH FROM CURRENT_DATE)
      AND EXTRACT(DAY FROM data_nascimento) = EXTRACT(DAY FROM CURRENT_DATE);
END;

$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION setar_status_aniversario() IS $$
Atualiza o status_aniversario para TRUE para todos os clientes que fazem 
aniversário na data atual. Isso permite que descontos de aniversário sejam 
aplicados automaticamente na primeira compra do cliente no seu dia de aniversário. $$;