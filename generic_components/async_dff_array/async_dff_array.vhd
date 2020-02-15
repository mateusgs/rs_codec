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

entity async_dff_array is 
    generic (
        NUM_OF_ELEMENTS : natural range 1 to 1024; 
        WORD_LENGTH : natural range 1 to 10
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        d : in std_logic_vector_array(NUM_OF_ELEMENTS-1 downto 0)(WORD_LENGTH-1 downto 0);
        q : out std_logic_vector_array(NUM_OF_ELEMENTS-1 downto 0)(WORD_LENGTH-1 downto 0)
    );
end async_dff_array;

architecture behavioral of async_dff_array is
begin 
process (clk,rst) 
begin 
    if (rst = '1') then 
        for I in NUM_OF_ELEMENTS-1 downto 0 loop
            q(I) <= (others => '0');
        end loop;
    elsif (rising_edge(clk)) then
        q <= d; 
    end if; 
end process; 
end behavioral;
