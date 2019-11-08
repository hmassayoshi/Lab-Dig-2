-- mux_4x1_n.vhd
--             multiplexador 4x1 com entradas de BITS bits (generic)
--
-- adaptado a partir do codigo my_4t1_mux.vhd do livro "Free Range VHDL" 
--
--
library IEEE;
use IEEE.std_logic_1164.all;

entity mux_4x1_n is
    generic (
        constant BITS: integer
    );
    port( D7, D6, D5, D4, D3, D2, D1, D0 : in  std_logic_vector (BITS-1 downto 0);
          SEL:             in  std_logic_vector (2 downto 0);
          MUX_OUT:         out std_logic_vector (BITS-1 downto 0)
    );
end mux_4x1_n;

architecture arch_mux_4x1_n of mux_4x1_n is
begin
    MUX_OUT <= D7 when (SEL = "111") else
					D6 when (SEL = "110") else
               D5 when (SEL = "101") else
               D4 when (SEL = "100") else
					D3 when (SEL = "011") else
               D2 when (SEL = "010") else
               D1 when (SEL = "001") else
               D0 when (SEL = "000") else
               (others => '1');
end arch_mux_4x1_n;
