library IEEE;
use IEEE.MATH_REAL.ceil;
use IEEE.MATH_REAL.log2;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

entity single_port_linear_ram is
	generic (
		NUMBER_OF_ELEMENTS : natural := 8;
		WORD_LENGTH : natural := 4);

	port (
		clk : in std_logic;
		i_ram_data : in std_logic_vector(WORD_LENGTH-1 downto 0);
		i_ram_wr_en : in std_logic;
		i_ram_addr : in std_logic_vector(integer(ceil(log2(real(NUMBER_OF_ELEMENTS))))-1 downto 0);
		o_ram_data : out std_logic_vector(WORD_LENGTH-1 downto 0)
	);
end single_port_linear_ram;

architecture behavioral of single_port_linear_ram is

	constant ADDR_LENGTH : natural := integer(ceil(log2(real(NUMBER_OF_ELEMENTS))));

	type linear_array is array ((NUMBER_OF_ELEMENTS - 1) downto 0) of std_logic_vector ((WORD_LENGTH - 1) downto 0);
	signal memory : linear_array;

	begin
		write_data : process (clk, i_ram_data, i_ram_wr_en, i_ram_addr)
			begin
				if (rising_edge (clk)) then
					if (i_ram_wr_en = '1') then
						memory (to_integer (unsigned (i_ram_addr))) <= i_ram_data;
					end if;
				end if;		
		end process;

		o_ram_data <= memory (to_integer (unsigned (i_ram_addr)));

end behavioral;