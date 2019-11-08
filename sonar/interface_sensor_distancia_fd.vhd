-- FD

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity interface_sensor_distancia_fd is 
    port ( clock, zera, conta:      in std_logic;
           registra, gera:          in std_logic;
			  echo:                    in std_logic;
           trigger,trigger_pronto:                 out std_logic;
			  
			  distancia:               out std_logic_vector(15 downto 0)
    );
end interface_sensor_distancia_fd;

architecture arch_interface_sensor_distancia_fd of interface_sensor_distancia_fd is
    signal s_zera, s_conta, s_registra, s_gera, s_pulso_trigger, s_fim_medida: std_logic;
    signal s_distancia, s_D, s_Q: std_logic_vector(15 downto 0); 
    signal s_dig0, s_dig1, s_dig2, s_dig3: std_logic_vector(3 downto 0);
	 signal s_echo, s_pulso_subida, s_pulso_descida: std_logic;
	 signal s_conta_milimetro,s_trigger: std_logic;

	 component contador_bcd
	 port ( 
	       clock, zera, conta:     in std_logic;
         dig3, dig2, dig1, dig0: out std_logic_vector(3 downto 0);
         fim:                    out std_logic
    );
	 end component;
	 
	 component gerador_pulso
	 generic (
      largura: integer
    );
    port(
      clock, reset:   in std_logic;
      gera, para:     in std_logic;
      pulso, pronto:  out std_logic
    ); 
	 end component;
	
	 component detector_borda
	 port (
      clock, reset  : in  std_logic;
      entrada       : in  std_logic;
      pulso_subida  : out std_logic;
      pulso_descida : out std_logic
	);
  end component;
  
  component registrador_n 
    generic (
         constant N: integer);
    port (clock, limpa, registra: in std_logic;
          D: in std_logic_vector(N-1 downto 0);
          Q: out std_logic_vector (N-1 downto 0) );
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
	
  U1: contador_bcd port map (clock=>clock, zera=>s_registra, conta=>s_conta_milimetro,
                            dig3=>s_dig3, dig2=>s_dig2, dig1=>s_dig1, dig0=>s_dig0, fim=>open
      );
	
  U2: gerador_pulso generic map (largura=>500)
	                 port map (clock=>clock, reset=>s_zera, gera=>s_gera, para=>'0',
                              pulso=>s_pulso_trigger, pronto=> s_trigger
      );
	
  --U3: detector_borda port map (clock=>clock, reset=>s_zera, entrada=> s_echo,
  --                             pulso_subida=> s_pulso_subida, pulso_descida=> s_pulso_descida
  --    );
		
  U4: contador_mm generic map (M=>294) port map (clock=>clock, zera=> s_zera, conta=> s_echo, 
																 Q => s_conta_milimetro
		);
  
  U5: registrador_n generic map (N=>16) port map (clock=>clock, limpa=>s_zera, registra=>s_registra, D=>s_D,
                                                  Q=>s_Q
      );

  s_echo<=echo;
  s_zera<=zera;
  s_conta<=conta;
  s_registra<=registra;
  s_gera<=gera;
  trigger<=s_pulso_trigger;
  trigger_pronto<=s_trigger;


  s_D(15 downto 0)<= s_dig3(3 downto 0) & s_dig2(3 downto 0) & s_dig1(3 downto 0) & s_dig0(3 downto 0);
  distancia(15 downto 0)<=s_Q(15 downto 0);
  
end arch_interface_sensor_distancia_fd;