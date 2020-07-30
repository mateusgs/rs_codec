---------------------------------------------------------------------------
-- Universidade Federal de Minas Gerais (UFMG)
---------------------------------------------------------------------------
-- Project: Generic Components
-- Design: D Flop
---------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity async_dff is 
    generic (
        WORD_LENGTH : natural range 1 to 1024
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        d : in std_logic_vector(WORD_LENGTH-1 downto 0);
        q : out std_logic_vector(WORD_LENGTH-1 downto 0)
    );
end async_dff;

architecture behavioral of async_dff is
begin 
	process (clk,rst) 
	begin 
		 if (rst = '1') then 
			  q <= (others => '0');
		 elsif (rising_edge(clk)) then
			  q <= d; 
		 end if; 
	end process; 
end behavioral;
