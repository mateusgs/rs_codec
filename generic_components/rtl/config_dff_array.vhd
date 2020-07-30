---------------------------------------------------------------------------
-- Universidade Federal de Minas Gerais (UFMG)
---------------------------------------------------------------------------
-- Project: Generic Components
-- Design: D Flop Array
---------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.GENERIC_TYPES.all;

entity config_dff_array is 
    generic (
        NUM_OF_ELEMENTS : natural range 1 to 1024; 
        WORD_LENGTH : natural range 1 to 10
    );
    port (
        clk : in std_logic;
        en : in std_logic;
        d : in std_logic_vector_array(NUM_OF_ELEMENTS-1 downto 0)(WORD_LENGTH-1 downto 0);
        q : out std_logic_vector_array(NUM_OF_ELEMENTS-1 downto 0)(WORD_LENGTH-1 downto 0)
    );
end config_dff_array;

architecture behavioral of config_dff_array is
signal w_q : std_logic_vector_array(NUM_OF_ELEMENTS-1 downto 0)(WORD_LENGTH-1 downto 0);
    
begin 
    process (clk) 
    begin 
        if (rising_edge(clk)) then
            if (en = '1') then 
                w_q <= d;
            else
                w_q <= w_q; 
            end if;
        end if; 
    end process;
	 q <= w_q;
end behavioral;
