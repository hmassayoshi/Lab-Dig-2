-- circuito_pwm.vhd - descrição rtl
--
-- gera saída com modulacao pwm
--
-- parametros: CONTAGEM_MAXIMA e largura_pwm
--             (clock a 50MHz ou 20ns)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity circuito_pwm is
port (
      clock    : in  std_logic;
      reset    : in  std_logic;
		start_pwm: in  std_logic;
      largura  : in  std_logic_vector(4 downto 0);  --  00=0,  01=1us  10=10us  11=20us
      pwm      : out std_logic );
end circuito_pwm;

architecture rtl of circuito_pwm is

  constant CONTAGEM_MAXIMA : integer := 1000000;  -- frequencia da saida 40KHz 50Hz
                                               -- ou periodo de 25us 20ms
  signal contagem     : integer range 0 to CONTAGEM_MAXIMA-1;
  signal largura_pwm  : integer range 0 to CONTAGEM_MAXIMA-1;
  signal s_largura    : integer range 0 to CONTAGEM_MAXIMA-1;
  
begin

  process(clock,reset,largura)
  begin
    -- inicia contagem e largura
    if(reset='1') then
      contagem    <= 0;
      pwm         <= '0';
      largura_pwm <= s_largura;
    elsif(rising_edge(clock) and start_pwm = '1') then
        -- saida
        if(contagem < largura_pwm) then
          pwm  <= '1';
        else
          pwm  <= '0';
        end if;
        -- atualiza contagem e largura
        if(contagem=CONTAGEM_MAXIMA-1) then
          contagem   <= 0;
          largura_pwm <= s_largura;
        else
          contagem   <= contagem + 1;
        end if;
    end if;
  end process;

  process(largura)
  begin
    case largura is
		when "00000" =>    s_largura <=    30000;
		when "00001" =>    s_largura <=    39000;  -- pulso de  1 us 0
      when "00010" =>    s_largura <=    48000;  -- pulso de 10 us 18 
      when "00011" =>    s_largura <=    57000;  -- pulso de 20 us 36 
		when "00100" =>    s_largura <=    66000;  -- pulso de 20 us 54 
		when "00101" =>    s_largura <=    75000;  -- pulso de 20 us 72
		when "00110" =>    s_largura <=    84000;  -- pulso de 20 us 90 x
      when "00111" =>    s_largura <=    93000;  -- pulso de 20 us 108x
      when "01000" =>    s_largura <=   102000;  -- pulso de 20 us 126 x
      when "01001" =>    s_largura <=   111000;  -- pulso de 20 us 144
      when "01010" =>    s_largura <=   120000;  -- pulso de 20 us 162
      when "01100" =>    s_largura <=   111000;  -- pulso de 20 us 180
      when "01101" =>    s_largura <=   102000;  -- pulso de 20 us 162
      when "01110" =>    s_largura <=    93000;  -- pulso de 20 us 144
      when "01111" =>    s_largura <=    84000;  -- pulso de 20 us 126
      when "10000" =>    s_largura <=    75000;  -- pulso de 20 us 108
      when "10001" =>    s_largura <=    66000;  -- pulso de 20 us 90
      when "10010" =>    s_largura <=    57000;  -- pulso de 20 us 72
      when "10011" =>    s_largura <=    48000;  -- pulso de 20 us 54
      when "10100" =>    s_largura <=    39000;  -- pulso de 20 us 36
      when others =>   s_largura <=     	 0;  -- nulo   saida 0
    end case;
  end process;
  
end rtl;