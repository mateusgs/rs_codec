---------------------------------------------------------------------------
-- Universidade Federal de Minas Gerais (UFMG)
---------------------------------------------------------------------------
-- Project: Generic Components
-- Design: package GENERIC_FUNCTIONS
---------------------------------------------------------------------------

library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.GENERIC_TYPES.std_logic_vector_array;

package GENERIC_FUNCTIONS is
    function init_flop_value(iteration, WORD_LENGTH, CONDITION: natural) return std_logic_vector;
    function to_slv(slva: std_logic_vector_array; WORD_LENGTH: natural) return std_logic_vector;
    function to_slva(slv: std_logic_vector; WORD_LENGTH: natural) return std_logic_vector_array;
    function xor_array_reducer(array_input: std_logic_vector_array; WORD_LENGTH: natural) return std_logic_vector;
end package GENERIC_FUNCTIONS;

package body GENERIC_FUNCTIONS is    
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
