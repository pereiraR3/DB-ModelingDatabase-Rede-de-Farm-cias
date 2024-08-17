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