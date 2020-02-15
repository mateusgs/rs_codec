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
		  
    MULT_LUT: case WORD_LENGTH generate
        when 2 =>
            o <= std_logic_vector(to_unsigned(mt_2(MULT_CONSTANT)(to_integer(unsigned(i))), WORD_LENGTH));
        when 3 =>
            o <= std_logic_vector(to_unsigned(mt_3(MULT_CONSTANT)(to_integer(unsigned(i))), WORD_LENGTH));
        when 4 =>
            o <= std_logic_vector(to_unsigned(mt_4(MULT_CONSTANT)(to_integer(unsigned(i))), WORD_LENGTH));
        when 5 =>
            o <= std_logic_vector(to_unsigned(mt_5(MULT_CONSTANT)(to_integer(unsigned(i))), WORD_LENGTH));
        when 6 =>
            o <= std_logic_vector(to_unsigned(mt_6(MULT_CONSTANT)(to_integer(unsigned(i))), WORD_LENGTH));
        when 7 =>
            o <= std_logic_vector(to_unsigned(mt_7(MULT_CONSTANT)(to_integer(unsigned(i))), WORD_LENGTH));
        when 8 =>
            o <= std_logic_vector(to_unsigned(mt_8(MULT_CONSTANT)(to_integer(unsigned(i))), WORD_LENGTH));
        when others => 
            o <= (others => '0');
    end generate;
end architecture;
