library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity half_subtractor_unit is

	port (
		i : in std_logic;
		ci : in std_logic;
		o : out std_logic;
		co : out std_logic
	);

end half_subtractor_unit;

architecture dataflow_hsu of half_subtractor_unit is	
	begin
		
		co <= not (i) and ci;	--Sets the carry out, depending on whether a 2 from the next bits is required.
		
		o <= i xor ci;	--Sets the output, subtracting the carry in from the input.

end dataflow_hsu;