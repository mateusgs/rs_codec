library IEEE;
use IEEE.MATH_REAL.ceil;
use IEEE.MATH_REAL.log2;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.GENERIC_FUNCTIONS.to_slv;
use work.GENERIC_FUNCTIONS.to_slva;
use work.GENERIC_TYPES.std_logic_vector_array;

entity rs_shitfer_zero_significant_positions is
    generic(
        WORD_LENGTH : natural range 2 to 10;
        TWO_TIMES_T : natural range 1 to 1022
    );
    port (
        i_shifter : in std_logic_vector_array(TWO_TIMES_T-1 downto 0)(WORD_LENGTH-1 downto 0);
        o_num_shift_zeros : out integer range 0 to 2**get_szs(TWO_TIMES_T)-1;
        o_shifter : out std_logic_vector_array(TWO_TIMES_T-1 downto 0)(WORD_LENGTH-1 downto 0)
    );
end rs_shitfer_zero_significant_positions;

architecture behavioral of rs_shitfer_zero_significant_positions is
    constant word_zero : std_logic_vector(WORD_LENGTH-1 downto 0) := (others => '0');
    signal w_shift_slv_in : std_logic_vector(TWO_TIMES_T*WORD_LENGTH - 1 downto 0);
    signal w_shift_slv_out : std_logic_vector(TWO_TIMES_T*WORD_LENGTH - 1 downto 0);
begin
    process (all)
        variable v_counter : natural range 0 to TWO_TIMES_T := 0;
    begin
        v_counter := 0;
        for I in TWO_TIMES_T-1 downto 0 loop
            if (i_shifter(I) /= word_zero) then
                if (v_counter = 0) then
                    o_shifter <= i_shifter;
                else
                    w_shift_slv_in <= to_slv(i_shifter, WORD_LENGTH);
                    w_shift_slv_out <= w_shift_slv_in sll (I*WORD_LENGTH);
                    o_shifter <= to_slva(w_shift_slv_out, WORD_LENGTH);
                end if;
                exit;
            end if;
            v_counter := v_counter + 1;
        end loop;
        o_num_shift_zeros <= v_counter;
    end process;
end behavioral;