library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity half_adder_unit is

	port (
		input : in std_logic;
		c_in : in std_logic;
		output : out std_logic;
		c_out : out std_logic
	);

end half_adder_unit;

architecture dataflow_hau of half_adder_unit is
	begin
		
		c_out <= input and c_in;	--Sets the carry out, depending on whether a number greater than 2 is resulted from the operation.
		
		output <= input xor c_in;	--Sets the output, adding the carry in to the input.

end dataflow_hau;