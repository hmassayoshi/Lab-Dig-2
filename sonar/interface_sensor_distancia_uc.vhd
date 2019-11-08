-- UC

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity interface_sensor_distancia_uc is 
    port (   
	    clock, reset, echo:           in std_logic;  
        medir,pronto_trigger:                        in std_logic;
        trigger, pronto:              out std_logic
    );
end interface_sensor_distancia_uc;

architecture arch_interface_sensor_distancia_uc of interface_sensor_distancia_uc is
	type tipo_estado is (inicial, aguarda_medida, envia_trigger,aguarda_trigger, aguarda_echo, le_echo, final);
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
    process (medir, echo, Eatual) 
    begin
	 
	     case Eatual is
		      when inicial => Eprox <= aguarda_medida;
				
				when aguarda_medida => if medir = '0' then Eprox <= aguarda_medida;
									   else Eprox <= envia_trigger;
									   end if;
				
				when envia_trigger => Eprox <= aguarda_trigger;
				
				when aguarda_trigger => if pronto_trigger = '0' then Eprox <= aguarda_trigger;
												else Eprox <= aguarda_echo;
												end if;
				when aguarda_echo => if echo = '0' then Eprox <= aguarda_echo;
									 else Eprox <= le_echo;
									 end if;
				when le_echo => if echo = '1' then Eprox <= le_echo;
									 else Eprox <= final;
									 end if;
				when final => Eprox <= inicial;
	     end case;
	 end process;
	 
	 -- logica de saida (Moore)
    with Eatual select 
        trigger <= '1' when envia_trigger, '0' when others;
		
    with Eatual select
	    pronto <= '1' when final, '0' when others;

		
end arch_interface_sensor_distancia_uc;