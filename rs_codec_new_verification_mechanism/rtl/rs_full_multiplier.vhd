---------------------------------------------------------------------------
-- Universidade Federal de Minas Gerais (UFMG)
---------------------------------------------------------------------------
-- Project: Reed-Solomon Encoder
-- Design: RS Multiplier
---------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.RS_COMPONENTS.rs_full_multiplier_core;
use work.RS_COMPONENTS.rs_inverse;

entity rs_full_multiplier is
    generic (
        WORD_LENGTH : natural range 2 to 10;
        TEST_MODE : boolean := false
    );
    port (
        i1 : in std_logic_vector(WORD_LENGTH-1 downto 0);
        i2 : in std_logic_vector(WORD_LENGTH-1 downto 0);
        o : out std_logic_vector(WORD_LENGTH-1 downto 0)
    );
end rs_full_multiplier;

architecture behavioral of rs_full_multiplier is
signal w_inverse : std_logic_vector(WORD_LENGTH-1 downto 0);
signal w_i1 : std_logic_vector(WORD_LENGTH-1 downto 0);
signal w_o : std_logic_vector(WORD_LENGTH-1 downto 0);
constant c_zeros : std_logic_vector(WORD_LENGTH-1 downto 0) := (others => '0');
begin
FULL_MULTIPLIER : rs_full_multiplier_core
                  generic map (WORD_LENGTH => WORD_LENGTH)
                  port map(i1 => i1,
                           i2 => i2,
                           o => w_o);
TEST_MODE_LOGIC: if (TEST_MODE = true) generate
    INVERSE: rs_inverse
             generic map (WORD_LENGTH => WORD_LENGTH)
             port map(i2,
                      w_inverse);
    FULL_MULLTIPLIER : rs_full_multiplier_core
                       generic map (WORD_LENGTH => WORD_LENGTH)
                       port map (i1 => w_inverse,
                                 i2 => w_o,
                                 o => w_i1);
    assert ((i1 = c_zeros) or (i2 = c_zeros) or (w_i1 = i1));
end generate;
o <= w_o;
end behavioral;
