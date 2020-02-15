---------------------------------------------------------------------------
-- Universidade Federal de Minas Gerais (UFMG)
---------------------------------------------------------------------------
-- Project: Generic Components
-- Design: D Flop
---------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity sync_dff is 
    generic (
        WORD_LENGTH : natural range 1 to 10
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        d : in std_logic_vector(WORD_LENGTH-1 downto 0);
        q : out std_logic_vector(WORD_LENGTH-1 downto 0)
    );
end sync_dff;

architecture behavioral of sync_dff is
begin 
    process (clk) 
    begin 
        if (rising_edge(clk)) then
            if (rst = '1') then 
                q <= (others => '0');
            else
                q <= d; 
            end if;
        end if; 
    end process; 
end behavioral;
