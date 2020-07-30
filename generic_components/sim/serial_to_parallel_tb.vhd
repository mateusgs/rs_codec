library IEEE;
use IEEE.std_logic_1164.all;

entity serial_to_parallel_tb is
	generic (
		N : natural := 4
	);
end serial_to_parallel_tb;

architecture test of serial_to_parallel_tb is
	signal clk, rst, i_consume, i_valid, i_data, o_in_ready, o_valid : std_logic;
	signal o_data : std_logic_vector((N - 1) downto 0);
	
	component serial_to_parallel is
	generic (
		N : natural := 4
	);
	port (
		clk : in std_logic;
		rst : in std_logic;
		i_consume : in std_logic;
		i_valid : in std_logic;
		i_data : in std_logic;
		o_data : out std_logic_vector((N - 1) downto 0);
		o_in_ready : out std_logic;
		o_valid : out std_logic
	);
	end component;
	
	begin
	
		STP_INST :  serial_to_parallel
			generic map (
				N => N
			)
			port map (
				clk => clk,
				rst => rst,
				i_consume => i_consume,
				i_valid => i_valid,
				i_data => i_data,
				o_data => o_data,
				o_in_ready => o_in_ready,
				o_valid => o_valid
			);
		
		process
		begin
			clk <= '0';
			wait for 5 ns;
			clk <= '1';
			wait for 10 ns;
			clk <= '0';
			wait for 5 ns;
		end process;	
		
		rst <= '1', '0' after 25001 ps;
		i_valid <= '0', '1' after 45001 ps, '0' after 125001 ps, '1' after 165001 ps, '0' after 245001 ps;
		i_data <= '1', '0' after 125001 ps;
		i_consume <= '0', '1' after 165001 ps, '0' after 185001 ps, '1' after 285001 ps, '0' after 305001 ps;
			
end test;
