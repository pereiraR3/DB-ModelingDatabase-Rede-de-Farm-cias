
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
