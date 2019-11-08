-- rx_serial_fd.vhd
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rx_serial_fd is
    port (
        conta, zera, carrega:               in std_logic;
        clock, reset, desloca, dado_serial: in std_logic;
		  limpa, registra:              		  in std_logic;
		  fim:                          		  out std_logic;
		  db_bits_recebidos: 					  out std_logic_vector (10 downto 0);
        dado_recebido:               		  out std_logic_vector (6 downto 0);	  
        paridade_ok:                 	  	  out std_logic
        
    );
end rx_serial_fd;

architecture rx_serial_fd_arch of rx_serial_fd is
	 signal s_paridade, s_par_ok, s_dado_serial: std_logic;
	 signal s_dado:        	   std_logic_vector (6 downto 0);
	 signal s_D, s_Q:        	   std_logic_vector (7 downto 0);
    signal s_saida: 	   std_logic_vector (10 downto 0);
     
    component deslocador_n
    generic (
        constant N: integer 
    );
    port (
        clock, reset: in std_logic;
        carrega, desloca, entrada_serial: in std_logic; 
        dados: in  std_logic_vector (N-1 downto 0);
        saida: out std_logic_vector (N-1 downto 0));
    end component;

    component contador_m_rx
    generic (
        constant M: integer;
        constant N: integer
    );
    port (
        clock, conta, zera: in STD_LOGIC;
        Q: out STD_LOGIC_VECTOR (N-1 downto 0);
        fim, meio: out STD_LOGIC);  
    end component;
	 
	 component testador_paridade
	 port (
        dado:      in std_logic_vector (6 downto 0);
        paridade:  in std_logic;
        par_ok:    out std_logic;
        impar_ok:  out std_logic
    );
	 end component; 
	 
	 component registrador_n
        generic (
            constant N: integer );
        port (clock, limpa, registra: in std_logic;
            D: in std_logic_vector(N-1 downto 0);
            Q: out std_logic_vector (N-1 downto 0) );
	 end component;
	 
begin
					  
     U1: deslocador_n generic map (N => 11)  port map (clock, reset, carrega, desloca, s_dado_serial, "11111111111",
                                                       s_saida);
																		 
     U2: registrador_n generic map (N => 8) port map (clock, limpa, registra, s_D, 
                                                      s_Q);

     U3: testador_paridade port map (s_dado, s_paridade, 
                                     s_par_ok, open );

     U4: contador_m_rx generic map (M => 12, N => 4) port map (clock, conta, zera, open, 
                                 fim, open);
    s_dado <=s_saida(7 downto 1);
	 s_paridade <= s_saida(8);
    s_D(6 downto 0) <= s_saida(7 downto 1);
	 s_D(7) <= s_par_ok;
	 s_dado_serial <= dado_serial;
    
	 
	 db_bits_recebidos<= s_saida;
	 dado_recebido <= s_Q(6 downto 0);
    paridade_ok <= s_Q(7);
    
     
end rx_serial_fd_arch;
