library ieee;
use IEEE.MATH_REAL.ceil;
use IEEE.MATH_REAL.log2;
use IEEE.std_logic_1164.all;
library work;
use work.GENERIC_TYPES.std_logic_vector_array;
use work.GENERIC_FUNCTIONS.get_log_round;

entity demultiplexer_array is
    generic (
        WORD_LENGTH : integer;
        NUM_OF_ELEMENTS : integer
    );
    port (
        i : in std_logic_vector(WORD_LENGTH-1 downto 0);
        i_sel : in std_logic_vector(get_log_round(NUM_OF_ELEMENTS)-1 downto 0);   
        o_array : out std_logic_vector_array(NUM_OF_ELEMENTS-1 downto 0)(WORD_LENGTH-1 downto 0)
    );
end demultiplexer_array;

architecture behavioral of demultiplexer_array is
begin
    --constant RS_ENCODER_SELECTOR_LENGTH : natural := get_log_round(NUM_OF_ELEMENTS);
    --process (i, i_sel)
    --begin
    --    for I in NUM_OF_ELEMENTS-1 downto 0 loop
    --        o_array(I) <= (others => '0');
    --    end loop;
    --    o_array(i_sel) <= i;
    --end process;
end behavioral;
