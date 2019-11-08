-- Sonar FD

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity sonar_fd is
	port (
		clock, reset: in std_logic;
		reset_1s, start_1s, start_transmissao: in std_logic;
		dig3, dig2, dig1 : in std_logic_vector(3 downto 0);
		largura_pwm: out std_logic_vector(4 downto 0);
		fim_1s: out std_logic;
		saida_56bits,saida_bruta: out std_logic_vector(55 downto 0)			
	);
end sonar_fd;

architecture arch_sonar_fd of sonar_fd is
	signal s_dig3, s_dig2, s_dig1: std_logic_vector(3 downto 0);
	signal s_reset_1s, s_start_1s,s_fim_conta,s_fim_conta_r: std_logic;
	signal s_start_transmissao, s_fim_1s: std_logic;
	signal s_largura,s_largura_pwm, s_largura_rx: std_logic_vector(4 downto 0);
	signal s_D: std_logic_vector(55 downto 0);
	signal s_saida_56bits: std_logic_vector(55 downto 0);
	signal s_rom_dig1, s_rom_dig2, s_rom_dig3: std_logic_vector(6 downto 0);
	signal s_rom_reg: std_logic_vector (20 downto 0);

	component contador_mm
		generic (
			constant M: integer   
		);
		port (
			clock, zera, conta: in std_logic;
			Q: out std_logic
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

	component rom_generic
		generic ( 
			posicoes: integer;  
         	palavra: integer;  
         	arq_mif: string
		);
		port (
			endereco : in  std_logic_vector(natural(ceil(log2(real(posicoes))))-1 downto 0);
         	saida    : out std_logic_vector(palavra-1 downto 0) 
		);
	end component;	
	
	component registrador_n
	  generic (
			 constant N: integer);
	  port (clock, limpa, registra: in std_logic;
			  D: in std_logic_vector (N-1 downto 0);
			  Q: out std_logic_vector (N-1 downto 0) );
	end component;
	
	component contador_m_rx
    generic (
        constant M: integer; -- modulo do contador
        constant N: integer   -- numero de bits da saida
    );
   port (
        clock, zera, conta: in STD_LOGIC;
        Q: out std_logic_vector (N-1 downto 0);
        fim, meio: out STD_LOGIC 
   );
	end component;
begin
	CONTA_SEG: contador_mm 	generic map(50000000)
							port map (clock=>clock, zera=>s_reset_1s, conta=>s_start_1s, 
									 Q=>s_fim_1s);

	ANGULO: contador_m 		generic map (20,5)
							port map (clock=>clock, zera=>reset, conta=>s_fim_1s,
									  Q=>s_largura, fim=>s_fim_conta);
							
	ANGULO_VOLTA: contador_m_rx	generic map (10,5)
							port map (clock=>clock, zera=>reset, conta=>s_fim_1s,
									  Q=>s_largura_rx, fim=>s_fim_conta_r, meio=> open);
												 
	ROM: rom_generic 		generic map (posicoes=>20, palavra=>21, arq_mif=>"rom_angulos_extendido.mif" )
							port map (endereco=>s_largura,
										saida=>s_rom_reg);
												 
	ROM_DIG1: rom_generic	generic map (posicoes=>10, palavra=>7, arq_mif=>"rom_numeros.mif" )
							port map (endereco=>s_dig1,
								      saida=>s_rom_dig1);
													   
	ROM_DIG2: rom_generic	generic map (posicoes=>10, palavra=>7, arq_mif=>"rom_numeros.mif" )
							port map (endereco=>s_dig2,
									  saida=>s_rom_dig2);
												
	ROM_DIG3: rom_generic	generic map (posicoes=>10, palavra=>7, arq_mif=>"rom_numeros.mif" )
							port map (endereco=>s_dig3,
									  saida=>s_rom_dig3);
	REG: registrador_n 		generic map (56)
							port map (clock=>clock, limpa=>s_fim_1s, registra=>s_start_transmissao, D=>s_D,
									  Q=>s_saida_56bits);
	

	s_reset_1s<=reset_1s;
	s_start_1s<=start_1s;
	s_start_transmissao<=start_transmissao;
	s_dig1<=dig1;
	s_dig2<=dig2;
	s_dig3<=dig3;
--	s_D(55 downto 0)<= s_rom_reg(20 downto 0) & "0101100"  &  s_rom_dig3  & s_rom_dig2  & s_rom_dig1& "0101110";
	s_D(55 downto 0)<= s_rom_reg(20 downto 0) & "0101100" & "011" &  s_dig3 & "011" & s_dig2 & "011" & s_dig1& "0101110";
	saida_bruta <= s_D;
	largura_pwm<=s_largura;
	fim_1s<=s_fim_1s;
	saida_56bits<=s_saida_56bits;
end arch_sonar_fd;