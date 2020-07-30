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

entity sync_dff_array is 
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
end sync_dff_array;

architecture behavioral of sync_dff_array is
begin 
process (clk) 
begin 
    if (rising_edge(clk)) then
        if (rst = '1') then 
            for I in NUM_OF_ELEMENTS-1 downto 0 loop
                q(I) <= (others => '0');
            end loop;
        else
            q <= d; 
        end if;
    end if; 
end process; 
end behavioral;
