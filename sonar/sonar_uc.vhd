library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sonar_uc is
    port(
        clock, reset, liga, modo:               in std_logic;
        fim_1s,fim_medicao, fim_transmissao:    in std_logic;
		  fim_selecao:										in std_logic;
		  o_dado0, o_dado1: 							   in std_logic_vector(3 downto 0);
        reset_1s, start_1s, start_mede:         out std_logic;
        start_pwm, start_transmissao:           out std_logic;
		  conta_sel, zera_sel:                    out std_logic;
		  db_estado:										out std_logic_vector(3 downto 0);
		  pause, pronto:          					   out std_logic
    );
end sonar_uc;

architecture arch_uc of sonar_uc is
    type tipo_estado is (
        inicial, escolhe_modo, comeca_contagem, move_servo, 
        mede_distancia, espera_medicao, transmite, espera_tx, prox_dado,
		  espera_final_1s, reseta_contagem
    );
    signal Eatual: tipo_estado; --estado atual
    signal Eprox:  tipo_estado; --proximo estado

begin
    --memoria de estado
    process(reset, clock, liga, o_dado0, o_dado1)
    begin
        if reset='1' or (o_dado0="0011" and (o_dado1="0111" or o_dado1 = "0101")) then
            Eatual<=inicial;
		  elsif liga='0' or(o_dado0="0000" and (o_dado1="0101" or o_dado1 = "0111")) then
            Eatual<=inicial;
        elsif clock'event and clock='1' then
            Eatual<=Eprox;
        end if;
    end process;

	 --(o_dado0="0000" and (o_dado1="0101" or o_dado1 = "0111")) p P 70 50
	 --(o_dado0="0011" and (o_dado1="0100" or o_dado1 = "0110")) c C 63 43
	 --(o_dado0="0011" and (o_dado1="0111" or o_dado1 = "0101")) s S 73 53
	 --(o_dado0="0100" and (o_dado1="0101" or o_dado1 = "0100")) d D 64 44
	 --(o_dado0="0001" and (o_dado1="0101" or o_dado1 = "0100")) a A 61 41
	 --(o_dado1="0010" and (o_dado0="1011" or o_dado0 = "1101")) + - 2b 2d
    --logica do proximo estado
    process(liga, modo, fim_medicao, fim_transmissao, fim_selecao, fim_1s, o_dado0, o_dado1)--sinais de entrada fim_move
    begin
        case Eatual is
            when inicial =>         if liga='1' or (o_dado0="0011" and (o_dado1="0100" or o_dado1 = "0110")) then Eprox <= escolhe_modo;
                                    else Eprox <= inicial;
                                    end if;

            when escolhe_modo =>    if modo='1' then Eprox <= comeca_contagem;
                                    else Eprox <= escolhe_modo;
                                    end if;

            when comeca_contagem => Eprox <= move_servo;

            when move_servo =>      Eprox <= mede_distancia;
            -- start pwm

            when mede_distancia =>  Eprox <= espera_medicao;
            -- start sensor

            when espera_medicao =>  if fim_medicao='1' or fim_1s = '1' then Eprox <= transmite;
                                    else Eprox <= espera_medicao;
                                    end if;
            -- wait sensor

            when transmite =>       Eprox <= espera_tx;
            -- start tx serial

            when espera_tx =>       if fim_transmissao = '1' then 
													if fim_selecao = '1' then Eprox <= espera_final_1s;
													else Eprox <= prox_dado;
													end if;
												else Eprox <= espera_tx;
                                    end if;
            -- wait tx serial
				
				when prox_dado => Eprox <= transmite;

            when espera_final_1s => if fim_1s = '0' then Eprox <= espera_final_1s;
                                    else Eprox <= reseta_contagem;
                                    end if;
            -- wait 1s
				
				when reseta_contagem => Eprox <= comeca_contagem;
				
            when others =>          Eprox<=inicial;
        end case;
    end process;

    --logica de saida (Moore):
    with Eatual select
        start_1s            <='0' when inicial, '0' when escolhe_modo,'0' when reseta_contagem, '1' when others;
	 with Eatual select
		  pause          		 <= '1' when inicial, '0' when others;
	 with Eatual select
		  pronto         		 <= '1' when reseta_contagem, '0' when others;	  
    with Eatual select
        start_pwm           <='0' when espera_medicao, '1' when others;
    with Eatual select
        start_mede          <='1' when mede_distancia, '0' when others;
    with Eatual select
        start_transmissao   <='1' when transmite, '1' when espera_tx, '0' when others;
	 with Eatual select      
		  conta_sel           <='1' when prox_dado, '0' when others;
	 with Eatual select
		  reset_1s            <= '1' when reseta_contagem, '0' when others;
	 with Eatual select
		  zera_sel          <= '1' when espera_final_1s, '0' when others;
		  
	 with Eatual select
			db_estado <=	"0000" when inicial,
								"0001" when escolhe_modo,
								"0010" when comeca_contagem,
								"0011" when move_servo,
								"0100" when mede_distancia,
								"0101" when espera_medicao,
								"0110" when transmite,
								"0111" when espera_tx,
								"1000" when espera_final_1s,
								"1001" when reseta_contagem,
								"1111" when others;

end arch_uc;
            