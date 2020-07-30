library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.MATH_REAL.ceil;
use IEEE.MATH_REAL.log2;
use IEEE.NUMERIC_STD.all;

entity single_port_2D_ram is
	generic (
		NUMBER_OF_ELEMENTS : natural;
   	NUMBER_OF_LINES : natural;
		WORD_LENGTH : natural);
		
	port (
		clk : in std_logic;
		i_ram_data : in std_logic_vector(WORD_LENGTH-1 downto 0);
		i_ram_wr_en : in std_logic;
		i_lin_addr : in std_logic_vector(integer(ceil(log2(real(NUMBER_OF_LINES))))-1 downto 0);
		i_col_addr : in std_logic_vector(integer(ceil(log2(real(NUMBER_OF_ELEMENTS/NUMBER_OF_LINES))))-1 downto 0);
		o_ram_data : out std_logic_vector(WORD_LENGTH-1 downto 0)
	);
end single_port_2D_ram;

architecture behavioral of single_port_2D_ram is

	constant LINE_ADDR_LENGTH : natural := integer(ceil(log2(real(NUMBER_OF_LINES))));
	
	constant COLUMN_ADDR_LENGTH : natural := integer(ceil(log2(real(NUMBER_OF_ELEMENTS/NUMBER_OF_LINES))));
	
	type col_array is array (((NUMBER_OF_ELEMENTS/NUMBER_OF_LINES) - 1) downto 0) of std_logic_vector ((WORD_LENGTH - 1) downto 0);
	type row_array is array ((NUMBER_OF_LINES - 1) downto 0) of col_array;
	signal memory : row_array;
	
	begin
		write_data : process (clk, i_ram_data, i_ram_wr_en, i_lin_addr, i_col_addr)
			begin
				if (rising_edge (clk)) then
					if (i_ram_wr_en = '1') then
						memory (to_integer (unsigned (i_lin_addr))) (to_integer (unsigned (i_col_addr))) <= i_ram_data;
					end if;
				end if;		
		end process;
		
		o_ram_data <= memory (to_integer (unsigned (i_lin_addr))) (to_integer (unsigned (i_col_addr)));

		--o_memory <= memory;
		
end behavioral;