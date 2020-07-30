library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity adder is
	generic (
		WORD_LENGTH : natural);
	port (
		i0 : in std_logic_vector ((WORD_LENGTH - 1) downto 0);
		i1 : in std_logic_vector ((WORD_LENGTH - 1) downto 0);
		o : out std_logic_vector ((WORD_LENGTH - 1) downto 0);
		co : out std_logic);
end adder;

architecture bh_add of adder is
	signal output : std_logic_vector (WORD_LENGTH downto 0);
	begin
		output <= std_logic_vector (to_unsigned(to_integer (unsigned (i0)) + to_integer (unsigned (i1)), WORD_LENGTH + 1));
		o <= output ((WORD_LENGTH - 1) downto 0);
		co <= output (WORD_LENGTH);
end bh_add;