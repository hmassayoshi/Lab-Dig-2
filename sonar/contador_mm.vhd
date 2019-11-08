-- Conta os milimetros de distancia baseado na largura do pulso echo.
-- Para um clock de 50MHz, cada 294 ciclos de clock correspondem a 1mm de distancia

-- contador_m.vhd
--
-- contador modulo m
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador_mm is
    generic (
        constant M: integer   -- modulo do contador
    );
    port (
        clock, zera, conta: in std_logic;
		  Q: out std_logic
    );
end contador_mm;

architecture contador_m_arch of contador_mm is
  signal IQ: integer range 0 to M-1;
begin
  
  process (clock,zera,conta,IQ)
  begin
    if zera='1' then IQ <= 0; 
    elsif clock'event and clock='1' then
      if conta='1' then 
        if IQ=M-1 then IQ <= 0; 
        else IQ <= IQ + 1; 
        end if;
      end if;
    end if;
    
    if IQ=M-1 then Q <= '1'; 
	 else Q <= '0';
    end if;
	 
  end process;
end contador_m_arch;