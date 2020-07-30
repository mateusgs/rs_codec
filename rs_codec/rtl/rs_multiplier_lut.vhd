library IEEE;
use ieee.STD_LOGIC_1164.all;
use ieee.NUMERIC_STD.all;
library work;
use work.RS_CONSTANTS.mt_2;
use work.RS_CONSTANTS.mt_3;
use work.RS_CONSTANTS.mt_4;
use work.RS_CONSTANTS.mt_5;
use work.RS_CONSTANTS.mt_6;
use work.RS_CONSTANTS.mt_7;
use work.RS_CONSTANTS.mt_8;
use work.RS_CONSTANTS.mt_9;
use work.RS_CONSTANTS.mt_10;

entity rs_multiplier_lut is
    generic (
        WORD_LENGTH : natural range 2 to 10;
		MULT_CONSTANT : natural range 0 to 1023
    );
    port (
    	i : in std_logic_vector(WORD_LENGTH-1 downto 0);
        o : out std_logic_vector(WORD_LENGTH-1 downto 0)
    );
end rs_multiplier_lut;

architecture lut of rs_multiplier_lut is
begin
	assert (MULT_CONSTANT < 2**WORD_LENGTH) 
		  report "ASSERT FAILURE - MULT_CONSTANT < 2**WORDLENGTH is not valid" 
		  severity failure;
		  
    GEN_WORD_LENGTH_2: if WORD_LENGTH = 2 generate
        o <= std_logic_vector(to_unsigned(mt_2(MULT_CONSTANT)(to_integer(unsigned(i))), WORD_LENGTH));
    end generate;
    GEN_WORD_LENGTH_3: if WORD_LENGTH = 3 generate
        o <= std_logic_vector(to_unsigned(mt_3(MULT_CONSTANT)(to_integer(unsigned(i))), WORD_LENGTH));
    end generate;
    GEN_WORD_LENGTH_4: if WORD_LENGTH = 4 generate
        o <= std_logic_vector(to_unsigned(mt_4(MULT_CONSTANT)(to_integer(unsigned(i))), WORD_LENGTH));
    end generate;
    GEN_WORD_LENGTH_5: if WORD_LENGTH = 5 generate
        o <= std_logic_vector(to_unsigned(mt_5(MULT_CONSTANT)(to_integer(unsigned(i))), WORD_LENGTH));
    end generate;
    GEN_WORD_LENGTH_6: if WORD_LENGTH = 6 generate
        o <= std_logic_vector(to_unsigned(mt_6(MULT_CONSTANT)(to_integer(unsigned(i))), WORD_LENGTH));
    end generate;
    GEN_WORD_LENGTH_7: if WORD_LENGTH = 7 generate
        o <= std_logic_vector(to_unsigned(mt_7(MULT_CONSTANT)(to_integer(unsigned(i))), WORD_LENGTH));
    end generate;
    GEN_WORD_LENGTH_8: if WORD_LENGTH = 8 generate
        o <= std_logic_vector(to_unsigned(mt_8(MULT_CONSTANT)(to_integer(unsigned(i))), WORD_LENGTH));
    end generate;
    --TODO: WORD_LENGTH 0 and 1 should be covered here as well.
    GEN_WORD_LENGTH_NOT_SUPPORTED: if WORD_LENGTH > 8 generate
        o <= (others => '0');
    end generate;
end architecture;
