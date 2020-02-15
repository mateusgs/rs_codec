library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.MATH_REAL.ceil;
use IEEE.MATH_REAL.log2;
library work;
use work.GENERIC_FUNCTIONS.to_slv;
use work.GENERIC_FUNCTIONS.to_slva;
use work.GENERIC_TYPES.std_logic_vector_array;

entity rs_shifter_acc is
    generic (
        WORD_LENGTH : natural range 2 to 10;
        TWO_TIMES_T : natural range 1 to 1022
    );
    port (
        i_shifter : in std_logic_vector_array(TWO_TIMES_T-3 downto 0)(WORD_LENGTH-1 downto 0);
        i_num_shift : in integer range 0 to TWO_TIMES_T;
        o_shifter : out std_logic_vector_array(TWO_TIMES_T-2 downto 0)(WORD_LENGTH-1 downto 0)
    );
end rs_shifter_acc;

architecture behavioral of rs_shifter_acc is
    constant TWO_TIMES_T : natural range 1 to (2**WORD_LENGTH-2)
    constant word_zero : std_logic_vector(WORD_LENGTH-1 downto 0) := (others => '0');
    signal w_shift_slv_in : std_logic_vector((TWO_TIMES_T-1)*WORD_LENGTH - 1 downto 0);
    signal w_shift_slv_out : std_logic_vector((TWO_TIMES_T-1)*WORD_LENGTH - 1 downto 0);
begin
    assert (TWO_TIMES_T <= 2**WORD_LENGTH-2) 
		report "ASSERT FAILURE - T <= 2**WORD_LENGTH-2" 
		severity failure;
    process (all)
    begin
        w_shift_slv_in <=  word_zero & to_slv(i_shifter, WORD_LENGTH);
        w_shift_slv_out <= w_shift_slv_in sll WORD_LENGTH*i_num_shift;
        o_shifter <= to_slva(w_shift_slv_out, WORD_LENGTH);
    end process;
end behavioral;