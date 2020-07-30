library IEEE;
use IEEE.MATH_REAL.ceil;
use IEEE.MATH_REAL.log2;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

library work;
use work.generic_components.decrementer;
use work.generic_components.incrementer;
use work.generic_components.sync_ld_dff;

entity up_down_counter is
    generic(
          WORD_LENGTH : natural);
    port ( clk : in  std_logic;
			  rst : in std_logic;
           i_dir : in  std_logic; 			-- '0' for up, '1' for down
			  i_en : in std_logic;
           o_counter : out std_logic_vector (WORD_LENGTH - 1 downto 0));
end up_down_counter;

architecture arch of up_down_counter is
	
	signal r_counter : std_logic_vector (WORD_LENGTH - 1 downto 0);
	signal w_o_incrementer : std_logic_vector (WORD_LENGTH - 1 downto 0);
	signal w_o_decrementer : std_logic_vector (WORD_LENGTH - 1 downto 0);
	signal w_o_mux : std_logic_vector (WORD_LENGTH - 1 downto 0);
	
	begin
	
		reg : sync_ld_dff 
			generic map (WORD_LENGTH => WORD_LENGTH)
			port map (rst => rst,
						 clk => clk,
						 ld => i_en,
						 i_data => w_o_mux,
						 o_data => r_counter);
					 
		incrementer0 : incrementer
			generic map (WORD_LENGTH => WORD_LENGTH)
			port map	(i => r_counter,
						 o => w_o_incrementer,
						 co => open);
		DEC0 : decrementer 
			generic map (WORD_LENGTH => WORD_LENGTH)
			port map (i => r_counter,
						 o => w_o_decrementer,
						 co => open);					 
		
		w_o_mux <= w_o_incrementer when (i_dir = '0') else
					  w_o_decrementer;   
		
		o_counter <= r_counter;

end arch;
	
