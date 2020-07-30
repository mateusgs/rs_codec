library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

library work;
use work.GENERIC_FUNCTIONS.get_log_round;
use work.GENERIC_FUNCTIONS.int2slv;
use work.GENERIC_FUNCTIONS.slv2int;

entity parallel_to_serial is
	generic (
		N : natural := 4);
	port (
		clk : in std_logic;
		rst : in std_logic;
		i_consume : in std_logic;
		i_valid : in std_logic;
		i_data : in std_logic_vector((N - 1) downto 0);
		o_data : out std_logic;
		o_in_ready : out std_logic;
		o_valid : out std_logic);
end parallel_to_serial;

architecture behavior_pts of parallel_to_serial is
	signal r_counter : std_logic_vector((get_log_round(N) - 1) downto 0);
	signal r_data : std_logic_vector((N - 1) downto 0);
	signal r_empty : std_logic;
	signal w_last_bit : std_logic;

	begin
	
		serialize : process(clk, rst, i_consume, i_valid, i_data, r_counter, r_data, r_empty, w_last_bit)
			begin
				if(rising_edge(clk)) then
					if(rst = '1') then
						r_counter <= (others => '0');
--						r_data <= i_data;
						r_empty <= '1';
					elsif(r_empty = '1') then
						if(i_valid = '1') then
							r_counter <= int2slv((N - 1), get_log_round(N));
							r_data <= i_data;
							r_empty <= '0';
						end if;
					elsif(i_consume = '1') then
						if(w_last_bit = '1') then
							if(i_valid = '1') then
								r_counter <= int2slv((N - 1), get_log_round(N));
								r_data <= i_data;
--								r_empty <= '0';
							else
--								r_counter <= int2slv(0, get_log_round(N));
--								r_data(0) <= '0';
--								for it in (N - 1) downto 1 loop
--									r_data(it) <= r_data(it - 1);
--								end loop;
								r_empty <= '1';
							end if;
						else
							r_counter <= int2slv((slv2int(r_counter) - 1), get_log_round(N));
--							r_data(0) <= '0';
							for it in (N - 1) downto 1 loop
								r_data(it) <= r_data(it - 1);
							end loop;
--							r_empty <= '0';
						end if;
					end if;
				end if;
		end process;
		
		w_last_bit <= '1' when r_counter = int2slv(0, get_log_round(N)) else
						  '0';
		
		o_data <= r_data(N - 1);
		o_in_ready <= ((w_last_bit AND i_consume) OR (r_empty)) AND NOT (rst);
		o_valid <= NOT(r_empty OR rst);
end behavior_pts;