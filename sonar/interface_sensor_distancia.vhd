-- Top level

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity interface_sensor_distancia is 
    port ( 
		clock, reset, medir:    in std_logic;
		echo:                   in std_logic;
		--sinais de medida
    	dig3, dig2, dig1, dig0: out std_logic_vector(3 downto 0);
    	trigger, pronto:        out std_logic
    );
end interface_sensor_distancia;

architecture arch_interface_sensor_distancia of interface_sensor_distancia is
    signal s_zera, s_conta, s_registra, s_gera, s_trigger, s_gerador_pulso: std_logic;
	 signal s_reset, s_medir,s_pronto_trigger, s_echo, s_pronto: std_logic;
    signal s_distancia, s_D, s_Q: std_logic_vector(15 downto 0); 
    signal s_dig0, s_dig1, s_dig2, s_dig3: std_logic_vector(3 downto 0);
	 
	 component interface_sensor_distancia_uc
		port (   
			clock, reset, echo:           in std_logic;  
			medir,pronto_trigger:            in std_logic;
			trigger, pronto:              out std_logic
		);
	 end component;
	 
	 component interface_sensor_distancia_fd
		port ( 
		clock, zera, conta:      in std_logic;
		registra, gera:          in std_logic;
		echo:                    in std_logic;
		trigger,trigger_pronto:                 out std_logic;
		distancia:               out std_logic_vector(15 downto 0)
		);
	 end component;
	 
	   component contador_mm
    generic (
        constant M: integer   -- modulo do contador
    );
    port (
        clock, zera, conta: in std_logic;
		  Q: out std_logic
    );
  end component;
	 

begin

	UC: interface_sensor_distancia_uc port map (clock=>clock, reset=>s_reset, medir=>s_medir, pronto_trigger=>s_pronto_trigger, echo=>s_echo,
											    trigger=>s_trigger, pronto=>s_pronto);
	 
	FD: interface_sensor_distancia_fd port map (clock=>clock, zera=>s_reset, conta=>s_medir, registra=>s_pronto, gera=>s_trigger, 
												echo=>s_echo, trigger=>s_gerador_pulso,trigger_pronto=>s_pronto_trigger, distancia=>s_D);
	
	 CONTA_SEG: contador_mm generic map (M=>50000000) port map (clock=>clock, zera=> s_reset, conta=> '1', 
																 Q => open
		);
	s_reset<=reset;
	s_medir<=medir;
	s_echo<=echo;
	trigger<=s_gerador_pulso;
	pronto<=s_pronto;

	s_dig0<=s_D(3 downto 0);
	s_dig1<=s_D(7 downto 4);
	s_dig2<=s_D(11 downto 8);
	s_dig3<=s_D(15 downto 12);

	dig0<=s_dig0;
	dig1<=s_dig1;
	dig2<=s_dig2;
	dig3<=s_dig3;


end arch_interface_sensor_distancia;