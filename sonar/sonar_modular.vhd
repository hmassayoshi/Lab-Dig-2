--Top Hierarchy

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sonar_modular is
	port (
		clock, reset, liga: in std_logic;
		echo:               in std_logic;
		entrada_serial:	  in std_logic;
		modo, trigger, dispara_trigger,pwm: out std_logic;
		saida_serial      : out std_logic;
		db_hex3,db_hex2,db_hex1, db_hex4,db_hex5,db_hex6: out std_logic_vector(6 downto 0);
		db_estado:			  out std_logic_vector(3 downto 0);
		pause, pronto:          out std_logic
	);
end sonar_modular;

architecture arch_sonar_modular of sonar_modular is
	signal s_liga, s_echo, s_trigger, s_pwm, s_saida_serial, s_pronto_transmissao: std_logic;
	signal s_fim_move, s_fim_medicao, s_fim_selecao, s_reset_1s, s_start_1s: std_logic;
	signal s_start_mede, s_start_pwm, s_start_transmissao,s_fim_1s: std_logic;
	signal s_sel: std_logic_vector (2 downto 0);
	signal s_dig0, s_dig1, s_dig2, s_dig3: std_logic_vector(3 downto 0);
	signal s_largura_pwm: std_logic_vector(4 downto 0);
	signal s_saida_56bits,s_saida_bruta: std_logic_vector(55 downto 0);
	signal s_hex6,s_hex5,s_hex4,s_hex3, s_hex2, s_hex1, s_saida_mux,s_db_rom: std_logic_vector(6 downto 0);
	signal s_dados_ascii: std_logic_vector (9 downto 0);
	signal s_paridade, s_conta_sel, s_zera_sel: std_logic;
	signal s_pronto_rx, s_paridade_ok, s_dado_serial: std_logic;
	signal s_dado_0, s_dado_1, s_estado: std_logic_vector(3 downto 0);
	signal s_pause, s_pronto: std_logic;

	component sonar_fd 
		port (
			clock, reset: in std_logic;
			reset_1s, start_1s: in std_logic;
			dig3, dig2, dig1: in std_logic_vector(3 downto 0);
			largura_pwm: out std_logic_vector(4 downto 0);
			fim_1s: out std_logic;
			saida_56bits,saida_bruta: out std_logic_vector(55 downto 0)			
		);
	end component;
	
	component sonar_uc
		port(
			clock, reset, liga, modo:               in std_logic;
			fim_1s,fim_medicao, fim_transmissao: 	 in std_logic;
			fim_selecao: 									 in std_logic;
			o_dado0, o_dado1: 							 in std_logic_vector(3 downto 0);
			reset_1s, start_1s, start_mede:         out std_logic;
			start_pwm, start_transmissao:           out std_logic;
			conta_sel, zera_sel:                    out std_logic;
			db_estado:										 out std_logic_vector(3 downto 0);
			pause, pronto:          					 out std_logic
		);
	end component;
	
	component interface_sensor_distancia
		 port ( 
			clock, reset, medir:    in std_logic;
			echo:                   in std_logic;
			dig3, dig2, dig1, dig0: out std_logic_vector(3 downto 0);
			trigger, pronto:        out std_logic
		 );
	end component;

	component circuito_pwm
		port (
			clock    : in  std_logic;
			reset    : in  std_logic;
			start_pwm: in  std_logic;
			largura  : in  std_logic_vector(4 downto 0);
			pwm      : out std_logic 
		);
	end component;

	component tx_serial_base
		port (
			clock, reset, partida, paridade: in std_logic;
			dados_ascii: 					 in std_logic_vector (6 downto 0);
			saida_serial, pronto : 			 out std_logic
		);
	end component;
	
	component rx_serial_base
		port (
		  i_reset, i_recebe_dado: 		in std_logic;
		  i_clock, i_dado_serial: 		in std_logic;
		  o_paridade_ok, o_pronto:    out std_logic;
		  o_tem_dado: 						out std_logic;
		  o_dado0, o_dado1: 					out std_logic_vector(3 downto 0)
		);
	end component;
	
	component hex7seg 
		port (
         binario : in std_logic_vector(3 downto 0);
         enable  : in std_logic;
         display : out std_logic_vector(6 downto 0)
		);
	end component;
	
	component mux_4x1_n
    generic (
        constant BITS: integer
    );
    port( D7, D6, D5, D4, D3, D2, D1, D0 : in  std_logic_vector (BITS-1 downto 0);
          SEL:             in  std_logic_vector (2 downto 0);
          MUX_OUT:         out std_logic_vector (BITS-1 downto 0)
    );
	end component;
	
	component contador_m
		generic (
        constant M: integer;  
        constant N: integer    
		);
		port (
			clock, zera, conta: in std_logic;
         Q: out std_logic_vector (N-1 downto 0);
         fim: out std_logic
		);
	end component;
	
begin
	UC: sonar_uc port map (clock=>clock, reset=>reset, liga=>s_liga, modo=>'1',o_dado0=>s_dado_0, o_dado1=>s_dado_1,
							fim_1s=>s_fim_1s, fim_medicao=>s_fim_medicao, fim_transmissao=>s_pronto_transmissao, fim_selecao => s_fim_selecao,
							reset_1s=>s_reset_1s, start_1s=>s_start_1s, start_mede=>s_start_mede,
							start_pwm=>s_start_pwm, start_transmissao=>s_start_transmissao, conta_sel => s_conta_sel,
							zera_sel => s_zera_sel, db_estado=>s_estado,pause=>s_pause, pronto=>s_pronto
							);

	FD: sonar_fd port map(clock=>clock, reset=>reset,
						  reset_1s=>s_reset_1s, start_1s=>s_start_1s, 
						  dig3=>s_dig2, dig2=>s_dig1, dig1=>s_dig0,	

						  largura_pwm=>s_largura_pwm, fim_1s=>s_fim_1s, saida_56bits=>s_saida_56bits,saida_bruta=>s_saida_bruta					  
						);


	RADAR: interface_sensor_distancia port map(clock=>clock, reset=>s_reset_1s, echo=>s_echo,
												medir=>s_start_mede,
												trigger=>s_trigger,
												pronto=>s_fim_medicao,	
												dig3=>s_dig3, dig2=>s_dig2, dig1=>s_dig1, dig0=>s_dig0									
												);

	SERVO: circuito_pwm port map(clock=>clock, reset=>reset,
								largura=>s_largura_pwm,
								start_pwm=>s_start_pwm,
								pwm=>s_pwm
								);

	TRANSMISSAO: tx_serial_base port map(clock=>clock, reset=>reset,
										partida=>s_start_transmissao, paridade=>s_paridade,
										dados_ascii=>s_saida_mux,										
										saida_serial=>s_saida_serial, 
										pronto=>s_pronto_transmissao
										);
										
	RECEPCAO: rx_serial_base port map(i_reset => reset, i_recebe_dado => '1', i_clock => clock,
												 i_dado_serial => s_dado_serial,
												 o_paridade_ok => s_paridade_ok, o_pronto => s_pronto_rx,
												 o_tem_dado => open, o_dado0 => s_dado_0, o_dado1 => s_dado_1 
									 );
	
	MUX_SAIDA: mux_4x1_n                           	
    generic map (                                 
        BITS=> 7                                  					
    )                                             			
    port map( 
			 D7=>"0101110", D6=>"011" & s_saida_bruta(10 downto 7), 
			 D5=>"011" & s_saida_bruta(17 downto 14), D4=>"011" & s_saida_bruta(24 downto 21),
			 D3=>"0101100", D2=>"011" & s_saida_bruta(38 downto 35), 
			 D1=>"011" & s_saida_bruta(45 downto 42), D0=>"011" & s_saida_bruta(52 downto 49), 
          SEL=> s_sel,
          MUX_OUT=> s_saida_mux
    );
	 
	 CONTA_TRANSMISSAO: contador_m generic map (8,3)
							port map (clock=>clock, zera=>reset or s_zera_sel, conta=>s_conta_sel,
									  Q=>s_sel, fim=>s_fim_selecao);
								
										
										
										
	HEX0: hex7seg port map (binario=>s_dig0, enable=>'1', 
							display=>s_hex1);
	 
	HEX1: hex7seg port map (binario=>s_dig1, enable=>'1', 
							display=>s_hex2);
							
	HEX2: hex7seg port map (binario=>s_dig2, enable=>'1',
							display=>s_hex3);
							
	HEX_A0: hex7seg port map (binario=>s_estado, enable=>'1',
	display=>s_hex6);
	
	HEX_A1: hex7seg port map (binario=>s_dado_1, enable=>'1',
	display=>s_hex5);
	
	HEX_A2: hex7seg port map (binario=>s_dado_0, enable=>'1',
	display=>s_hex4);

	s_liga<=liga;
	s_echo<=echo;
	s_paridade <= s_saida_mux(0) xor s_saida_mux(1) xor s_saida_mux(2) xor s_saida_mux(3) xor s_saida_mux(4) xor s_saida_mux(5) xor s_saida_mux(6);
	s_dado_serial <= entrada_serial;

	modo<=s_liga;
	saida_serial<=s_saida_serial;
	trigger<=s_trigger;
	pwm<=s_pwm;
	
	db_hex3<=s_hex3;
	db_hex2<=s_hex2;
	db_hex1<=s_hex1;
	db_hex4<=s_hex4;
	db_hex5<=s_hex5;
	db_hex6<=s_hex6;
	
	pause<=s_pause;
	pronto<=s_pronto;
	
	
end arch_sonar_modular;