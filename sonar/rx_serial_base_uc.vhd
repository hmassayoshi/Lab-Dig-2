-- rx_serial_uc.vhd
--

library ieee;
use ieee.std_logic_1164.all;

entity rx_serial_uc is 
  port ( 	clock,dado_serial, fim:   in std_logic;
				recebe_dado, reset, tick: in std_logic;
				carrega, conta, desloca:  out std_logic;
				estado:						  out std_logic_vector(3 downto 0);
				limpa, pronto: 			  out std_logic;
				registra, tem_dado, zera: out std_logic);
end rx_serial_uc;

architecture rx_serial_uc_arch of rx_serial_uc is

    type tipo_estado is (inicial, preparacao, espera, recepcao, armazena, final);
    signal Eatual: tipo_estado;  -- estado atual
    signal Eprox:  tipo_estado;  -- proximo estado

begin 

  -- memoria de estado
  process (reset, clock)
  begin
      if reset = '1' then
          Eatual <= inicial;
      elsif clock'event and clock = '1' then
          Eatual <= Eprox; 
      end if;
  end process;
  
    -- logica de proximo estado
  process (dado_serial, fim, tick, Eatual) 
  begin

    case Eatual is

      when inicial =>      if dado_serial='1' then Eprox <= inicial;
                           else                Eprox <= preparacao;
                           end if;

      when preparacao =>   Eprox <= espera;

      when espera =>  if tick = '0' and fim = '0' then Eprox <= espera;
							 elsif tick = '1' and fim = '0' then Eprox <= recepcao;
							 else                             Eprox <= armazena;
							 end if;

		when recepcao => Eprox <= espera;
		
		when armazena => Eprox <= final;
		
      when final =>        Eprox <= inicial;

      when others =>       Eprox <= inicial;

    end case;
  end process;

  -- logica de saida (Moore)
  with Eatual select 
      carrega <= '1' when preparacao, '0' when others;
		
  with Eatual select
		limpa <= '1' when preparacao, '0' when others;

  with Eatual select
      zera <= '1' when preparacao, '0' when others;

  with Eatual select
      desloca <= '1' when recepcao, '0' when others;

  with Eatual select
      conta <= '1' when recepcao, '0' when others;
		
  with Eatual select
		registra <= '1' when armazena, '0' when others;
		
  with Eatual select
      pronto <= '1' when final, '0' when others;

  with Eatual select
		estado <= "0000" when inicial,
					 "0001" when preparacao,
					 "0010" when espera,
					 "0011" when recepcao,
					 "0100" when armazena,
					 "0101" when final,
					 "0110" when others;
	
end rx_serial_uc_arch;

