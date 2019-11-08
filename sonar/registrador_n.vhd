-- registrador_n.vhd
--    registrador com numero de bits como generic
--
library IEEE;
use IEEE.std_logic_1164.all;

entity registrador_n is
  generic (
       constant N: integer);
  port (clock, limpa, registra: in std_logic;
        D: in std_logic_vector (N-1 downto 0);
        Q: out std_logic_vector (N-1 downto 0) );
end entity;

architecture comportamental of registrador_n is
  signal IQ: std_logic_vector (N-1 downto 0);
begin

  process(clock, limpa, registra, IQ)
  begin
    if (limpa = '1') then IQ <= (others => '0');
    elsif (clock'event and clock='1') then
      if (registra='1') then IQ <= D; end if;
    end if;
    Q <= IQ;
  end process;
  
end comportamental;


