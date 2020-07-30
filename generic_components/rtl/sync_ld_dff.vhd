library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity sync_ld_dff is
	generic (
		WORD_LENGTH : natural);
	port (
		rst : in std_logic;
		clk : in std_logic;
		ld : in std_logic;
		i_data : in std_logic_vector ((WORD_LENGTH - 1) downto 0);
		o_data : out std_logic_vector ((WORD_LENGTH - 1) downto 0));
end sync_ld_dff;

architecture bh_reg of sync_ld_dff is
	begin
		store : process (rst, clk, ld, i_data)
			begin
				if (rising_edge (clk)) then	--Synchronous behaviour.
					if (rst = '1') then --Clears the register asynchronously.
						o_data <= (others => '0');
					elsif (ld = '1') then
						o_data <= i_data;
					end if;
				end if;
			end process;
end bh_reg;