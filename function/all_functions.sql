-----

CREATE OR REPLACE FUNCTION atualizar_salario_mensal_funcionarios()
RETURNS VOID AS $$
DECLARE
    funcionario_record RECORD;
BEGIN
    FOR funcionario_record IN SELECT id, salario_fixo, comissao FROM funcionario LOOP
        DECLARE
            total_vendas DECIMAL(10,2) DEFAULT 0;
            comissao_total DECIMAL(10,2);
        BEGIN
            -- Calcula o total de vendas do funcionário no mês atual
            SELECT COALESCE(SUM(valor_total), 0) INTO total_vendas
            FROM venda
            WHERE id_funcionario = funcionario_record.id
            AND EXTRACT(MONTH FROM data_venda) = EXTRACT(MONTH FROM CURRENT_DATE)
            AND EXTRACT(YEAR FROM data_venda) = EXTRACT(YEAR FROM CURRENT_DATE);

            -- Calcula o total da comissão
            comissao_total := total_vendas * funcionario_record.comissao / 100;

            -- Atualiza o salário mensal do funcionário
            UPDATE funcionario
            SET salario_mensal = funcionario_record.salario_fixo + comissao_total
            WHERE id = funcionario_record.id;
        END;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION atualizar_salario_mensal_funcionarios() IS $$
Esta função calcula e atualiza automaticamente o salário mensal dos funcionários 
com base nas comissões obtidas das vendas do mês anterior. É ideal executar esta 
função no início de cada mês para assegurar que os salários sejam ajustados 
conforme o desempenho de vendas. $$;

---- 

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

---- 

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

----

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

---- 

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

