library ieee;
use IEEE.MATH_REAL.ceil;
use IEEE.MATH_REAL.log2;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.GENERIC_TYPES.std_logic_vector_array;
use work.GENERIC_FUNCTIONS.get_log_round;

entity multiplexer_array is
    generic (
        WORD_LENGTH : integer := 4;
        NUM_OF_ELEMENTS : integer := 4
    );
    port (
        i_array : in std_logic_vector_array(NUM_OF_ELEMENTS-1 downto 0)(WORD_LENGTH-1 downto 0);
        i_sel : in std_logic_vector(get_log_round(NUM_OF_ELEMENTS)-1 downto 0);   
        o : out std_logic_vector(WORD_LENGTH-1 downto 0)   
    );
end multiplexer_array;

architecture behavior of multiplexer_array is
begin
	process(i_array, i_sel) is
	variable temp : std_logic_vector(WORD_LENGTH-1 downto 0);
	begin
		temp := (others => '0');
		for I in 0 to NUM_OF_ELEMENTS - 1 loop
			if (I = to_integer(unsigned(i_sel))) then
				temp := i_array(I);
			end if;
		end loop;
		o <= temp;
	end process;	
end behavior;
