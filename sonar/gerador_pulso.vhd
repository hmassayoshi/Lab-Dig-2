-- gerador_pulso.vhd
--
-- LabDig - 15/09/2019 - v1

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gerador_pulso is
   generic (
      largura: integer:= 25
   );
   port(
      clock, reset:   in std_logic;
      gera, para:     in std_logic;
      pulso, pronto: out std_logic
   );
end gerador_pulso;

architecture fsm_arch of gerador_pulso is

   type tipo_estado is (parado, contagem, final);
   signal reg_estado, prox_estado: tipo_estado;
   signal reg_cont, prox_cont: integer range 0 to largura-1;

begin

   -- estado e contagem
   process(clock,reset)
   begin
      if (reset='1') then
         reg_estado <= parado;
         reg_cont <= 0;
      elsif (clock'event and clock='1') then
         reg_estado <= prox_estado;
         reg_cont <= prox_cont;
      end if;
   end process;

   -- logica de proximo estado e contagem
   process(reg_estado, gera, para, reg_cont)
   begin
      pulso <= '0';
      pronto <= '0';
      prox_cont <= reg_cont;

      case reg_estado is

         when parado =>
            if gera='1' then
               prox_estado <= contagem;
            else
               prox_estado <= parado;
            end if;
            prox_cont <= 0;

         when contagem =>
            if para='1' then
               prox_estado <=parado;
            else
               if (reg_cont=largura-1) then
                  prox_estado <=final;
               else
                  prox_estado <=contagem;
                  prox_cont <= reg_cont + 1;
               end if;
            end if;
            pulso <= '1';

         when final =>
            prox_estado <=parado;
            pronto <= '1';
      end case;
   end process;

end fsm_arch;

