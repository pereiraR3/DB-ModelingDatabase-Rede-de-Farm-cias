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