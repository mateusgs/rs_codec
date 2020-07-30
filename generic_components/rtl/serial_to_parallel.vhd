library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

library work;
use work.GENERIC_FUNCTIONS.get_log_round;
use work.GENERIC_FUNCTIONS.int2slv;
use work.GENERIC_FUNCTIONS.slv2int;

entity serial_to_parallel is
	generic (
		N : natural := 4);
	port (
		clk : in std_logic;
		rst : in std_logic;
		i_consume : in std_logic;
		i_valid : in std_logic;
		i_data : in std_logic;
		o_data : out std_logic_vector((N - 1) downto 0);
		o_in_ready : out std_logic;
		o_valid : out std_logic);
end serial_to_parallel;

architecture behavior of serial_to_parallel is
signal r_full			       : std_logic;
signal r_data                         : std_logic_vector((N - 1) downto 0);
signal r_count                        : integer range 0 to N-1;


begin

	serial_to_parallel : process(clk)
	begin
  		if(rising_edge(clk)) then
  			if(rst = '1') then
  				r_count <= 0;
  				r_full <= '0';
  				r_data <= (others => '0');
  				o_valid <= '0';
  			elsif(r_full = '0') then
  				o_valid <= '0';
  				if(i_valid = '1') then	
  					r_data <= r_data(N-2 downto 0)& i_data;	
  					if(r_count >= N-1) then
  						r_count <= 0;
  						r_full <= '1';
  						o_valid <= '1';
  					else
  						r_count <= r_count + 1;
  						r_full <= '0';
  					end if;	
  				end if;
  			else
  				o_valid <= '1';
  				if(i_consume = '1') then
  					r_full <= '0';
  					o_valid <= '0';
  					if(i_valid = '1') then
  						r_data <= r_data(N-2 downto 0)& i_data;	
  						r_count <= r_count + 1;
  					end if;	
  				end if;		
  			end if;
  		end if;	
  	end process serial_to_parallel;
  	
  	o_data <= r_data;
  	o_in_ready <= '0' when ((r_full = '1' AND i_consume = '0')  OR rst = '1') else '1'; 
  	
end behavior;
