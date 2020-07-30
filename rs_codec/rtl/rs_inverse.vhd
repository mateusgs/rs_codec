library IEEE;
use ieee.STD_LOGIC_1164.all;
use ieee.NUMERIC_STD.all;
library work;
use work.RS_CONSTANTS.gp_inverse_2;
use work.RS_CONSTANTS.gp_inverse_3;
use work.RS_CONSTANTS.gp_inverse_4;
use work.RS_CONSTANTS.gp_inverse_5;
use work.RS_CONSTANTS.gp_inverse_6;
use work.RS_CONSTANTS.gp_inverse_7;
use work.RS_CONSTANTS.gp_inverse_8;
use work.RS_CONSTANTS.gp_inverse_9;
use work.RS_CONSTANTS.gp_inverse_10;

entity rs_inverse is
    generic (
        WORD_LENGTH : natural range 2 to 10;
        TEST_MODE : boolean := false
    );
    port (
    	i : in std_logic_vector(WORD_LENGTH-1 downto 0);
        o : out std_logic_vector(WORD_LENGTH-1 downto 0)
    );
end rs_inverse;

architecture lut of rs_inverse is
    signal w_o : std_logic_vector(WORD_LENGTH-1 downto 0);
begin
    GEN_WORD_LENGTH_2: if WORD_LENGTH = 2 generate
        w_o <= std_logic_vector(to_unsigned(gp_inverse_2(to_integer(unsigned(i))), WORD_LENGTH));
        GEN_TEST_MODE: if TEST_MODE = true generate
            assert(i = std_logic_vector(to_unsigned(gp_inverse_2(to_integer(unsigned(w_o))), WORD_LENGTH)));
        end generate;
    end generate;
    GEN_WORD_LENGTH_3: if WORD_LENGTH = 3 generate
        w_o <= std_logic_vector(to_unsigned(gp_inverse_3(to_integer(unsigned(i))), WORD_LENGTH));
        GEN_TEST_MODE: if TEST_MODE = true generate
            assert(i = std_logic_vector(to_unsigned(gp_inverse_3(to_integer(unsigned(w_o))), WORD_LENGTH)));
        end generate;
    end generate;
    GEN_WORD_LENGTH_4: if WORD_LENGTH = 4 generate
        w_o <= std_logic_vector(to_unsigned(gp_inverse_4(to_integer(unsigned(i))), WORD_LENGTH));
        GEN_TEST_MODE: if TEST_MODE = true generate
            assert(i = std_logic_vector(to_unsigned(gp_inverse_4(to_integer(unsigned(w_o))), WORD_LENGTH)));
        end generate;
    end generate;
    GEN_WORD_LENGTH_5: if WORD_LENGTH = 5 generate
        w_o <= std_logic_vector(to_unsigned(gp_inverse_5(to_integer(unsigned(i))), WORD_LENGTH));
        GEN_TEST_MODE: if TEST_MODE = true generate
            assert(i = std_logic_vector(to_unsigned(gp_inverse_5(to_integer(unsigned(w_o))), WORD_LENGTH)));
        end generate;    
    end generate;
    GEN_WORD_LENGTH_6: if WORD_LENGTH = 6 generate
        w_o <= std_logic_vector(to_unsigned(gp_inverse_6(to_integer(unsigned(i))), WORD_LENGTH));
        GEN_TEST_MODE: if TEST_MODE = true generate
            assert(i = std_logic_vector(to_unsigned(gp_inverse_6(to_integer(unsigned(w_o))), WORD_LENGTH)));
        end generate;                    
    end generate;
    GEN_WORD_LENGTH_7: if WORD_LENGTH = 7 generate
        w_o <= std_logic_vector(to_unsigned(gp_inverse_7(to_integer(unsigned(i))), WORD_LENGTH));
        GEN_TEST_MODE: if TEST_MODE = true generate
            assert(i = std_logic_vector(to_unsigned(gp_inverse_7(to_integer(unsigned(w_o))), WORD_LENGTH)));
        end generate;                                    
    end generate;
    GEN_WORD_LENGTH_8: if WORD_LENGTH = 8 generate
        w_o <= std_logic_vector(to_unsigned(gp_inverse_8(to_integer(unsigned(i))), WORD_LENGTH));
        GEN_TEST_MODE: if TEST_MODE = true generate
            assert(i = std_logic_vector(to_unsigned(gp_inverse_8(to_integer(unsigned(w_o))), WORD_LENGTH)));
        end generate;
    end generate;
    GEN_WORD_LENGTH_9: if WORD_LENGTH = 9 generate
        w_o <= std_logic_vector(to_unsigned(gp_inverse_9(to_integer(unsigned(i))), WORD_LENGTH));
        GEN_TEST_MODE: if TEST_MODE = true generate
            assert(i = std_logic_vector(to_unsigned(gp_inverse_9(to_integer(unsigned(w_o))), WORD_LENGTH)));
        end generate;
    end generate;
    GEN_WORD_LENGTH_10: if WORD_LENGTH = 10 generate
        w_o <= std_logic_vector(to_unsigned(gp_inverse_10(to_integer(unsigned(i))), WORD_LENGTH));
        GEN_TEST_MODE: if TEST_MODE = true generate
            assert(i = std_logic_vector(to_unsigned(gp_inverse_10(to_integer(unsigned(w_o))), WORD_LENGTH)));
        end generate;
    end generate;
    --TODO: WORD_LENGTH 0 and 1 should be covered here as well.
    GEN_WORD_LENGTH_NOT_SUPPORTED: if WORD_LENGTH > 10 generate
        w_o <= (others => '0');
    end generate;
    o <= w_o;
end architecture;
