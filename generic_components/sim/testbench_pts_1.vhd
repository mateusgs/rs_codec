library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.GENERIC_FUNCTIONS.get_log_round;

entity testbench_pts is
	generic (
			N : natural := 4);
end testbench_pts;

architecture dataflow_tbpts of testbench_pts is
	signal clk, rst, i_consume, i_valid, o_data, o_in_ready, o_valid : std_logic;
	signal i_data : std_logic_vector((N - 1) downto 0);
	signal counter : std_logic_vector((get_log_round(N) - 1) downto 0);
	signal shift_register : std_logic_vector((N - 1) downto 0);
	
	component parallel_to_serial is
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
			
			counter : out std_logic_vector((get_log_round(N) - 1) downto 0);
			shift_register : out std_logic_vector((N - 1) downto 0);
			
			o_valid : out std_logic);
	end component;
	
		begin
			PTS0 : parallel_to_serial
				generic map (
					N => N)
				port map (
					clk => clk,
					rst => rst,
					i_consume => i_consume,
					i_valid => i_valid,
					i_data => i_data,
					
					counter => counter,
					shift_register => shift_register,
					
					o_data => o_data,
					o_in_ready => o_in_ready,
					o_valid => o_valid);
			
			process
				begin
					clk <= '0';
					wait for 5 ns;
					clk <= '1';
					wait for 10 ns;
					clk <= '0';
					wait for 5 ns;
			end process;
		
		i_consume <= '1', '0' after 165001 ps, '1' after 205001 ps, '0' after 485001 ps;
		i_data <= "UUUU", "0010" after 65001 ps, "0101" after 85001 ps, "1010" after 165001 ps, "1101" after 325001 ps, "UUUU" after 405001 ps;
		rst <= '1', '0' after 25001 ps;
		i_valid <= '0', '1' after 65001 ps, '0' after 265001 ps, '1' after 305001 ps, '0' after 405001 ps;
		
end dataflow_tbpts;
