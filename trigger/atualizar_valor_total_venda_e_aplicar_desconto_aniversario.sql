CREATE OR REPLACE FUNCTION atualizar_valor_total_venda_e_aplicar_desconto_aniversario()
RETURNS TRIGGER AS $$
DECLARE
    valorDesconto DECIMAL(10,2) := 0.00; -- Inicializa o desconto com zero
    valorProduto MONEY;
    novoValorTotal MONEY;
    aniversario BOOL;
BEGIN
    -- Verifica se hoje é aniversário do cliente e se o status_aniversario é TRUE
    SELECT (EXTRACT(MONTH FROM data_nascimento) = EXTRACT(MONTH FROM CURRENT_DATE)
            AND EXTRACT(DAY FROM data_nascimento) = EXTRACT(DAY FROM CURRENT_DATE)
            AND status_aniversario = TRUE)
    INTO aniversario
    FROM cliente
    WHERE id = (SELECT id_cliente FROM venda WHERE id = NEW.id_venda);
    
    -- Determina o desconto aplicável
    IF aniversario THEN
        valorDesconto := 0.30; -- Desconto de 30% para aniversário
        
        -- Atualiza o status_aniversario para FALSE após aplicar o desconto
        UPDATE cliente
        SET status_aniversario = FALSE
        WHERE id = (SELECT id_cliente FROM venda WHERE id = NEW.id_venda);
    ELSE
        valorDesconto := NEW.desconto; -- Utiliza o desconto original da venda, se não for aniversário
    END IF;

    -- Calcula o valor do produto vendido multiplicado pela quantidade e aplica o desconto
    SELECT preco INTO valorProduto FROM produto WHERE id = NEW.id_produto;
    novoValorTotal = valorProduto * NEW.quantidade * (1 - valorDesconto);

    -- Atualiza o valor total na venda com ou sem desconto de aniversário
    UPDATE venda
    SET valor_total = valor_total + novoValorTotal
    WHERE id = NEW.id_venda;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_atualizar_valor_total_venda_e_aplicar_desconto_aniversario
AFTER INSERT ON tem_venda
FOR EACH ROW
EXECUTE FUNCTION atualizar_valor_total_venda_e_aplicar_desconto_aniversario();

COMMENT ON FUNCTION atualizar_valor_total_venda_e_aplicar_desconto_aniversario() IS $$
Esta trigger é acionada após a inserção de uma venda e verifica se o cliente está 
fazendo aniversário, aplicando um desconto de 30% se for o caso. Ela também 
atualiza o valor total da venda, considerando os descontos aplicados, e reseta o 
status de aniversário do cliente para evitar descontos múltiplos no mesmo dia. $$;