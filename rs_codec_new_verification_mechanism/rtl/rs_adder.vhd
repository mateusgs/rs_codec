library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity rs_adder is
    generic (
        WORD_LENGTH : natural range 2 to 10;
        TEST_MODE : boolean := false
    );
	port (
        i1 : in std_logic_vector(WORD_LENGTH-1 downto 0);
        i2 : in std_logic_vector(WORD_LENGTH-1 downto 0);
        o : out std_logic_vector(WORD_LENGTH-1 downto 0)
    );
end rs_adder;

architecture behavioral of rs_adder is
signal w_o : std_logic_vector(WORD_LENGTH-1 downto 0);
begin
	process (i1, i2)
	begin
		 w_o <= i1 xor i2;
    end process;
    GEN_TEST_MODE: if TEST_MODE = true generate
        assert ((w_o xor i2) = i1);
    end generate;
	o <= w_o;
end behavioral;
