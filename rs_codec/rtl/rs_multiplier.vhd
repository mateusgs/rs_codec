library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.RS_COMPONENTS.rs_full_multiplier;
use work.RS_COMPONENTS.rs_inverse;

entity rs_multiplier is
	generic (
        WORD_LENGTH : natural range 2 to 10;
		MULT_CONSTANT : natural range 0 to 1023;
        TEST_MODE : boolean := false
    );
	port (
    	i : in std_logic_vector(WORD_LENGTH-1 downto 0);
        o : out std_logic_vector(WORD_LENGTH-1 downto 0)
    );
end rs_multiplier;

architecture behavioral of rs_multiplier is

component rs_multiplier_lut is
    generic (
        WORD_LENGTH : natural range 2 to 10;
		MULT_CONSTANT : natural range 0 to 1023
    );
    port (
    	i : in std_logic_vector(WORD_LENGTH-1 downto 0);
        o : out std_logic_vector(WORD_LENGTH-1 downto 0)
    );
end component;

signal w_inverse : std_logic_vector(WORD_LENGTH-1 downto 0);
signal w_original_input : std_logic_vector(WORD_LENGTH-1 downto 0);
signal w_o : std_logic_vector(WORD_LENGTH-1 downto 0);
begin
MULT_LUT: rs_multiplier_lut 
          generic map (WORD_LENGTH, MULT_CONSTANT) 
          port map (i,
                    w_o);
TEST_MODE_LOGIC: if (TEST_MODE = true) generate
    INVERSE: rs_inverse
             generic map (WORD_LENGTH => WORD_LENGTH)
             port map(std_logic_vector(to_unsigned(MULT_CONSTANT, WORD_LENGTH)),
                      w_inverse);
    FULL_MULLTIPLIER : rs_full_multiplier
                       generic map (WORD_LENGTH => WORD_LENGTH)
                       port map (i1 => w_inverse,
                                 i2 => w_o,
                                 o => w_original_input);
    assert (w_original_input = i);
end generate;
o <= w_o;
end behavioral;
