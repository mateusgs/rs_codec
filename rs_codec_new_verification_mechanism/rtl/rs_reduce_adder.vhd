---------------------------------------------------------------------------
-- Universidade Federal de Minas Gerais (UFMG)
---------------------------------------------------------------------------
-- Project: Reed-Solomon Encoder
-- Design: RS reduce adder
---------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.GENERIC_TYPES.std_logic_vector_array;
use work.GENERIC_FUNCTIONS.xor_array_reducer;

entity rs_reduce_adder is
    generic (
        NUM_OF_ELEMENTS : natural range 1 to 1024; 
        WORD_LENGTH : natural range 1 to 10
    );
	port (
        i : in std_logic_vector_array(NUM_OF_ELEMENTS-1 downto 0)(WORD_LENGTH-1 downto 0);
        o : out std_logic_vector(WORD_LENGTH-1 downto 0)
    );
end rs_reduce_adder;

architecture behavioral of rs_reduce_adder is
begin
    process (i)
    begin
        o <= xor_array_reducer(i, WORD_LENGTH);
    end process;
end behavioral;
