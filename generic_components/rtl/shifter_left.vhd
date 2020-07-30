---------------------------------------------------------------------------
-- Universidade Federal de Minas Gerais (UFMG)
---------------------------------------------------------------------------
-- Project: Generic Components
-- Design: D Flop
---------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity shifter_left is
    generic (
        N : natural range 1 to 10;
        S : natural range 1 to 4
    );
    port (
        i : in std_logic_vector(N-1 downto 0);
        sel : in std_logic_vector(S-1 downto 0);
        o : out std_logic_vector(N-1 downto 0)
    );
end shifter_left;

architecture behavioral of shifter_left is
begin
    o <= std_logic_vector(unsigned(i) sll to_integer(unsigned(sel)));
end behavioral;
