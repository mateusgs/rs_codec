library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity comparator is
	generic (
		WORD_LENGTH : natural);
	port (
--		en : in std_logic;
		i_r : in std_logic_vector ((WORD_LENGTH - 1) downto 0);
		i : in std_logic_vector ((WORD_LENGTH - 1) downto 0);
		lt : out std_logic;
		eq : out std_logic);
end comparator;

architecture bh_comp of comparator is
	begin
		lt <= '1' when ((to_integer (unsigned (i))) < (to_integer (unsigned (i_r)))) else --Sets if less than.
				'0';
		eq <= '1' when ((to_integer (unsigned (i))) = (to_integer (unsigned (i_r)))) else	--Sets if equal to.
				'0';
end bh_comp;