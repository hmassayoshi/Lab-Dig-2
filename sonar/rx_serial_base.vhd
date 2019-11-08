-- rx_serial_base.vhd
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity rx_serial_base is
    port (
		  i_reset, i_recebe_dado: 		in std_logic;
		  i_clock, i_dado_serial: 		in std_logic;
		  o_paridade_ok, o_pronto:    out std_logic;
		  o_tem_dado: 						out std_logic;
		  o_dado0, o_dado1: 					out std_logic_vector(3 downto 0)
		  
		  --db_estado:					 out std_logic_vector(6 downto 0)
	 );
end rx_serial_base;

architecture arch_rx_serial_base of rx_serial_base is
    signal s_carrega, s_conta, s_desloca, s_limpa: std_logic;
	 signal s_registra, s_zera, s_fim, s_tick:      std_logic;
	 signal s_dado_serial, s_paridade_ok, s_pronto: std_logic;
	 signal s_tem_dado, s_reset, s_recebe_dado:     std_logic;
    signal s_estado, s_binario_0, s_binario_1:	   std_logic_vector(3 downto 0);
    signal s_dado_recebido: 							   std_logic_vector(6 downto 0); 
	 signal s_bits_recebidos:                       std_logic_vector(10 downto 0);	
    component rx_serial_uc port ( 
			   clock,dado_serial, fim:   in std_logic;
				recebe_dado, reset, tick: in std_logic;
				carrega, conta, desloca:  out std_logic;
				estado:						  out std_logic_vector(3 downto 0);
				limpa, pronto: 			  out std_logic;
				registra, tem_dado, zera: out std_logic);										
    end component;

    component rx_serial_fd port (
		  conta, zera, carrega, clock, reset:	  in std_logic;	
		  desloca, dado_serial, limpa, registra: in std_logic;
		  fim:							  				  out std_logic;
		  db_bits_recebidos:   						  out std_logic_vector(10 downto 0);
		  dado_recebido:								  out std_logic_vector(6 downto 0);
		  paridade_ok:							  		  out std_logic);
    end component;
	 
	 component contador_m_rx generic (
			  constant M: integer;
			  constant N: integer
		 );
		 port (
			  clock, zera, conta: in STD_LOGIC;
			  Q: 						out std_logic_vector (N-1 downto 0);
			  fim, meio: 			out STD_LOGIC );
		 end component;
	 
	 component hex7seg port (
		  binario: in std_logic_vector(3 downto 0);
		  enable:  in std_logic;
		  display: out std_logic_vector(6 downto 0));
	 end component;
	 
begin
	 
	 o_paridade_ok <= s_paridade_ok;
	 o_pronto <= s_pronto;
	 o_tem_dado <= s_tem_dado;
	 o_dado0<=s_binario_0;
	 o_dado1<=s_binario_1;
	 s_recebe_dado <= i_recebe_dado;
	 s_reset <= i_reset;

	 --s_binario_0 <= s_dado_recebido(3) & s_dado_recebido(1) & s_dado_recebido(1) & s_dado_recebido(0);
	 --s_binario_1 <= '0' & s_dado_recebido(6) & s_dado_recebido(5) & s_dado_recebido(4);
	 s_binario_0 <= s_dado_recebido(3 downto 0);
	 s_binario_1(2 downto 0) <= s_dado_recebido(6 downto 4);
	 s_binario_1(3) <= '0';
	 s_dado_serial <= i_dado_serial;

    UC: rx_serial_uc port map (i_clock, s_dado_serial, s_fim, s_recebe_dado, s_reset, s_tick,
                               s_carrega, s_conta, s_desloca, s_estado, s_limpa, s_pronto, s_registra, s_tem_dado, s_zera);

    FD: rx_serial_fd port map (s_conta, s_zera, s_carrega, i_clock, s_reset, s_desloca, s_dado_serial, s_limpa, s_registra,
										 s_fim, s_bits_recebidos, s_dado_recebido, s_paridade_ok);
										 
	 TICK: contador_m_rx generic map (M => 434, N => 4)
						   port map (clock=>i_clock, zera=>s_zera,conta=>'1', Q=> open,
							          fim=>open,meio=> s_tick);
	 
	 HEX0: hex7seg 	port map (s_binario_0, '1', 
										 open);
	 
	 HEX1: hex7seg 	port map (s_binario_1, '1', 
										 open);
	 
	 --HEX5: hex7seg 	port map (s_estado, '1', 
	 --									 db_estado);
	 
end arch_rx_serial_base;