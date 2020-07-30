---------------------------------------------------------------------------
-- Universidade Federal de Minas Gerais (UFMG)
---------------------------------------------------------------------------
-- Project: Generic Components
-- Design: no_rst_dff
---------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity no_rst_dff is 
    generic (
        WORD_LENGTH : natural range 1 to 10
    );
    port (
        clk : in std_logic;
        d : in std_logic_vector(WORD_LENGTH-1 downto 0);
        q : out std_logic_vector(WORD_LENGTH-1 downto 0)
    );
end no_rst_dff;

architecture behavioral of no_rst_dff is
begin 
process (clk) 
begin 
    if (rising_edge(clk)) then
        q <= d; 
    end if; 
end process; 
end behavioral;
