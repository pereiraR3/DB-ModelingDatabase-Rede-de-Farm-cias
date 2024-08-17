CREATE OR REPLACE FUNCTION diminuir_quantidade_no_lote()
RETURNS TRIGGER AS $$
DECLARE 
    loteRecente DATE; 
BEGIN
    -- Verifica se a quantidade atual no lote é suficiente
    IF (SELECT quantidade FROM lote WHERE id_produto = NEW.id_produto ORDER BY data_despacho DESC LIMIT 1) >= NEW.quantidade THEN

        -- Obtendo a data do despacho mais recente
        SELECT data_despacho INTO loteRecente FROM lote WHERE id_produto = NEW.id_produto ORDER BY data_despacho DESC LIMIT 1;
        
        -- Diminui a quantidade do lote mais recente
        UPDATE lote
        SET quantidade = quantidade - NEW.quantidade
        WHERE id_produto = NEW.id_produto AND data_despacho = loteRecente;
		
    ELSE
        -- Lança um erro se a venda exceder a quantidade disponível no lote mais recente
        RAISE EXCEPTION 'Quantidade insuficiente no lote para o produto %', NEW.id_produto;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_diminuir_quantidade_no_lote
BEFORE INSERT ON tem_venda
FOR EACH ROW
EXECUTE FUNCTION diminuir_quantidade_no_lote();

COMMENT ON FUNCTION diminuir_quantidade_no_lote() IS $$
Esta trigger é responsável por atualizar a quantidade de produtos em estoque no 
lote mais recente após uma venda ser realizada. Ela verifica se a quantidade 
disponível é suficiente e diminui essa quantidade no lote de acordo com a 
quantidade vendida. Um erro é lançado caso a venda exceda a quantidade disponível. $$;

-----------

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

-----------

CREATE OR REPLACE FUNCTION verificar_atualizar_contato_funcionario()
RETURNS TRIGGER AS $$
BEGIN
    -- Exemplo de verificação de formato de telefone
    IF NEW.telefone !~ '^\d{11}$' THEN
        RAISE EXCEPTION 'Formato de telefone inválido para funcionário: %', NEW.telefone;
    END IF;

    -- Exemplo de verificação de formato de email
    IF NEW.email NOT LIKE '%@%' THEN
        RAISE EXCEPTION 'Formato de email inválido para funcionário: %', NEW.email;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER verificar_contato_funcionario
BEFORE INSERT OR UPDATE ON funcionario
FOR EACH ROW EXECUTE FUNCTION verificar_atualizar_contato_funcionario();

COMMENT ON FUNCTION verificar_atualizar_contato_funcionario() IS $$
Esta trigger é usada para garantir que os dados de contato dos funcionários, como telefone e e-mail, estejam em formatos válidos antes de serem inseridos ou atualizados na tabela de funcionários. A função impede a inserção ou atualização de dados inválidos, lançando uma exceção se os formatos não atenderem aos critérios especificados. $$;

--------

CREATE OR REPLACE FUNCTION permissao_venda() RETURNS TRIGGER AS $$
DECLARE
	func RECORD;
BEGIN
	SELECT * INTO func FROM funcionario WHERE id = new.id_funcionario;
	IF func.cargo = 'Faxineira' THEN
		raise notice 'Uma faxineira não pode realizar as vendas da farmácia';
		RETURN NULL;
	ELSE
		RETURN NEW;
	END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_permissao_venda
BEFORE INSERT ON venda
FOR EACH ROW
EXECUTE FUNCTION permissao_venda();

COMMENT ON FUNCTION permissao_venda() IS $$
Esta trigger verifica o cargo do funcionário antes de permitir que uma venda seja registrada. 
Se o funcionário tiver um cargo não autorizado a realizar vendas, como 'Faxineira', a venda será
bloqueada e um aviso será emitido. A venda prossegue normalmente para cargos autorizados, como 
vendedores e farmacêuticos. $$;

-----

CREATE OR REPLACE FUNCTION verificar_atualizar_contato_cliente()
RETURNS TRIGGER AS $$
BEGIN
    -- Verificação de formato de telefone
    IF NEW.telefone !~ '^\d{11}$' THEN
        RAISE EXCEPTION 'Formato de telefone inválido para cliente: %', NEW.telefone;
    END IF;

    -- Verificação de formato de email
    IF NEW.email NOT LIKE '%@%' THEN
        RAISE EXCEPTION 'Formato de email inválido para cliente: %', NEW.email;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER verificar_contato_cliente
BEFORE INSERT OR UPDATE ON cliente
FOR EACH ROW EXECUTE FUNCTION verificar_atualizar_contato_cliente();

COMMENT ON FUNCTION verificar_atualizar_contato_cliente() IS $$
Esta trigger é utilizada para garantir que os dados de contato dos clientes, como telefone e e-mail, estejam em formatos válidos antes de serem inseridos ou atualizados na tabela de clientes. A função impede a inserção ou atualização de dados inválidos, lançando uma exceção se os formatos não atenderem aos critérios especificados. $$;

-----

