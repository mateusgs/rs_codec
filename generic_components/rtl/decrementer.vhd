library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity decrementer is
	generic (
	WORD_LENGTH : natural);
	
	port (
	i : in std_logic_vector ((WORD_LENGTH - 1) downto 0);
	o : out std_logic_vector ((WORD_LENGTH - 1) downto 0);
	co : out std_logic);

end decrementer;

architecture dataflow_dec of decrementer is
	
	signal wire : std_logic_vector (WORD_LENGTH downto 0);
	
	component half_subtractor_unit is
		port (
			i : in std_logic;
			ci : in std_logic;
			o : out std_logic;
			co : out std_logic
		);
	end component;
	
	begin
	
		GENERATE_HALF_SUBTRACTOR_UNITS : for it0 in 0 to (WORD_LENGTH - 1) generate	--Generates multiple basic units according to the number of bits.
			HSUX : half_subtractor_unit port map (
			i => i (it0),
			ci => wire (it0),
			o => o (it0),
			co => wire (it0 + 1));		
		end generate;
		
		wire (0) <= '1';
		co <= wire (WORD_LENGTH);
		
end dataflow_dec;