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