library IEEE;
use IEEE.MATH_REAL.ceil;
use IEEE.MATH_REAL.log2;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.GENERIC_TYPES.std_logic_vector_array;

package GENERIC_FUNCTIONS is
    function max(A, B: natural) return natural;
    function get_even_indexes(slva: std_logic_vector_array; WORD_LENGTH: natural) return std_logic_vector_array;
    function get_odd_indexes(slva: std_logic_vector_array; WORD_LENGTH: natural) return std_logic_vector_array;
    function get_log_round(N: natural) return natural;
    function init_flop_value(iteration, WORD_LENGTH, CONDITION: natural) return std_logic_vector;
    function to_slv(slva: std_logic_vector_array; WORD_LENGTH: natural) return std_logic_vector;
    function to_slva(slv: std_logic_vector; WORD_LENGTH: natural) return std_logic_vector_array;
    function xor_array_reducer(array_input: std_logic_vector_array; WORD_LENGTH: natural) return std_logic_vector;
end package GENERIC_FUNCTIONS;

package body GENERIC_FUNCTIONS is    

	 function max(A, B: natural) return natural is
	 begin
		 if (A > B) then
			 return A;
		 else
			 return B;
		 end if;
	 end;

    function get_even_indexes(slva: std_logic_vector_array; WORD_LENGTH: natural) return std_logic_vector_array is
        variable slva_even : std_logic_vector_array((slva'length+1)/2-1 downto 0)(WORD_LENGTH-1 downto 0);
    begin
        if (slva'length = 1) then 
            slva_even := slva;
        else
            for i in 0 to (slva'length+1)/2-1 loop
                slva_even(i) := slva(i*2);
            end loop;
        end if;
        return slva_even;
    end function;

    function get_odd_indexes(slva: std_logic_vector_array; WORD_LENGTH: natural) return std_logic_vector_array is
        variable slva_odd : std_logic_vector_array(slva'length/2-1 downto 0)(WORD_LENGTH-1 downto 0);
    begin
        if (slva'length = 1) then 
            slva_odd := (others => std_logic_vector(to_unsigned(0, WORD_LENGTH)));
        else
            for i in 0 to slva'length/2-1 loop
                slva_odd(i) := slva(i*2 + 1);
            end loop;
        end if;
        return slva_odd;
    end function;

	function get_log_round(N: natural) return natural is
	begin
		return integer(ceil(log2(real(N))));
	end;
	 
    function to_slv(slva: std_logic_vector_array; WORD_LENGTH: natural) return std_logic_vector is
        variable slv : std_logic_vector((slva'length * WORD_LENGTH - 1) downto 0);
    begin
        for i in slva'range loop
            slv((i * WORD_LENGTH) + WORD_LENGTH-1 downto (i * WORD_LENGTH)) := slva(i);
        end loop;
        return slv;
    end function;

    function to_slva(slv: std_logic_vector; WORD_LENGTH: natural) return std_logic_vector_array is
        variable slva : std_logic_vector_array(slv'length/WORD_LENGTH-1 downto 0)(WORD_LENGTH-1 downto 0);
    begin
        for i in slva'range loop
            slva(i) := slv((i * WORD_LENGTH) + WORD_LENGTH-1 downto (i * WORD_LENGTH));
        end loop;
        return slva;
    end function;

    function init_flop_value(iteration, WORD_LENGTH, CONDITION: natural) return std_logic_vector is
    begin
        if iteration = CONDITION then
            return std_logic_vector(to_unsigned(1, WORD_LENGTH));
        else
            return std_logic_vector(to_unsigned(0, WORD_LENGTH));
        end if;
    end function;

    function xor_array_reducer(array_input: std_logic_vector_array; WORD_LENGTH: natural) return std_logic_vector is
        variable ret : std_logic_vector(WORD_LENGTH-1 downto 0) := (others => '0');
    begin
        for i in array_input'range loop
            ret := ret xor array_input(i);
        end loop;
        return ret;
    end function;
end package body GENERIC_FUNCTIONS;
