---------------------------------------------------------------------------
-- Universidade Federal de Minas Gerais (UFMG)
---------------------------------------------------------------------------
-- Project: Generic Types
-- Design: package generic_Components
---------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package GENERIC_TYPES is
    type std_logic_vector_array is array (natural range <>) of std_logic_vector;
    type array_of_integers is array(integer range <>) of integer;
    type integer_array is array(integer range <>) of integer;
end package GENERIC_TYPES;
