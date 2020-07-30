library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity generic_buffer is 
	generic (
		INPUT_LENGTH : natural := 3;	--Number of inputs to the fifo.
		OUTPUT_LENGTH : natural := 2;	--Number of outputs to the fifo.
		MEMORY_BIT_SIZE : natural range 3 to 30000 := 8);	--Size of the memory. Number of bits it can store.
	
	port (
	
		head, tail : out std_logic_vector (31 downto 0);	--Temporary output. Helps debugging the code. Head shows the current state of the head pointer. Tail does the same for the tail.
		mem : out std_logic_vector ((MEMORY_BIT_SIZE - 1) downto 0);	--Temporary output. Helps debugging the code. Mem indicates how the fifo is being filled.
		
		clk : in std_logic;	--Clock. For synchronous circuits.
		rst : in std_logic;	--Reset. Useful for the staroff of the circuit.
		i_rd_en : in std_logic;	--Enable for the process of reading.
		i_wr_en : in std_logic;	--Enable for the process of writing.
		i_wr_data : in std_logic_vector ((INPUT_LENGTH - 1) downto 0);	--Input data to the memory.
		o_full_buffer : out std_logic;	--Indicates for previous circuits that there is no space in the fifo. Actually, there will be one empty space to indicate this fact (that the fifo is full).
		o_empty_buffer : out std_logic;	--Indicates for the following circuits that there is nothing to be read.
		o_rd_data : out std_logic_vector ((OUTPUT_LENGTH - 1) downto 0));	--Carries the output of the circuit.
end generic_buffer;

architecture behavior_gb of generic_buffer is
	signal r_head, r_tail : std_logic_vector (31 downto 0) := (others => '0'); --The actual head and tail pointers for the fifo. 'r' is for register. Maybe it should have been something like 'c' for counter or 'p' for pointer.
	signal fifo : std_logic_vector ((MEMORY_BIT_SIZE - 1) downto 0) := (others => '0');	--Where the data will be stored.
	
	begin
		HEAD_ADJSUTMENT : process (clk, rst, r_head, r_tail, i_wr_en)	--As its name indicates, this process is used for updating the head pointer.
		
			variable current_h, current_t : integer;	--Copies for the current values of the head and the tail pointers. Useful for improving readability.
			
			begin
				current_h := to_integer (unsigned (r_head));
				current_t := to_integer (unsigned (r_tail));
				if (rst = '1') then
					r_head <= (others => '0');	--Resetting makes head move to "the beginning of the fifo". There is no beginnig, but its esier to move head and tail to a predeined point. In this case, zero. 
				else
					if (rising_edge (clk)) then	--To make it synchronous.
						if (current_h >= current_t) then --Covering two different situations (head greater than or equal to tail and head littler than tail).
							if (((MEMORY_BIT_SIZE - (current_h - current_t)) > INPUT_LENGTH) AND (i_wr_en = '1')) then	--Checks, for the first situation, if memory isn't full and if writing is enabled.
								if ((current_h + INPUT_LENGTH) > (MEMORY_BIT_SIZE - 1)) then	--Checks if head is about to return to zero position.
									r_head <= std_logic_vector (to_unsigned ((current_h + INPUT_LENGTH - MEMORY_BIT_SIZE), 32));	--Updates head.
								else
									r_head <= std_logic_vector (to_unsigned ((current_h + INPUT_LENGTH), 32));	--Updates head.
								end if;
							end if;
						else	--Second situation.
							if (((current_t - current_h) > INPUT_LENGTH) AND (i_wr_en = '1')) then	--Checks, for the second situation, if memory isn't full and if writing is enabled.
								if ((current_h + INPUT_LENGTH) > (MEMORY_BIT_SIZE - 1)) then	--Checks if head is about to return to zero position.
									r_head <= std_logic_vector (to_unsigned ((current_h + INPUT_LENGTH - MEMORY_BIT_SIZE), 32));	--Updates head.
								else
									r_head <= std_logic_vector (to_unsigned ((current_h + INPUT_LENGTH), 32));	--Updates head.
								end if;
							end if;
						end if;
					end if;
				end if;
			end process;
			
			head <= r_head;	--Setting one of the auxiliary outputs.
			
		WRITE_DATA : process (clk, rst, r_head, r_tail, i_wr_en, i_wr_data)	--This process will move data from the input to the memory when allowed to.
		
			variable current_h, current_t : integer;	--Copies for the current values of the head and the tail pointers.
			
			begin
				current_h := to_integer (unsigned (r_head));
				current_t := to_integer (unsigned (r_tail));
				if (rising_edge (clk)) then	--To make it synchronous. It should be noted that reset doesn't affect the memory. The reason for that is because all the data in the fifo, after the reset, will be treated as trash.
					if (current_h >= current_t) then	--Covering two different situations (head greater than or equal to tail and head littler than tail).
						if (((MEMORY_BIT_SIZE - (current_h - current_t)) > INPUT_LENGTH) AND (i_wr_en = '1')) then	--Checks, for the first situation, if memory isn't full and if writing is enabled.
							for it0 in 0 to (INPUT_LENGTH - 1) loop	--Transfer the data.
								if ((current_h + it0) < MEMORY_BIT_SIZE) then
									fifo (current_h + it0) <= i_wr_data (it0);
								else	--In case head has gone back to zero.
									fifo (current_h + it0 - MEMORY_BIT_SIZE) <= i_wr_data (it0);
								end if;
							end loop;
						end if;
					else
						if (((current_t - current_h) > INPUT_LENGTH) AND (i_wr_en = '1')) then	--Second situation.
							for it0 in 0 to (INPUT_LENGTH - 1) loop	--Transfer the data.
								if ((current_h + it0) < MEMORY_BIT_SIZE) then
									fifo (current_h + it0) <= i_wr_data (it0);
								else	--In case head has gone back to zero.
									fifo (current_h + it0 - MEMORY_BIT_SIZE) <= i_wr_data (it0);
								end if;
							end loop;
						end if;
					end if;
				end if;
		end process;
		
		mem <= fifo;	--Setting another auxiliary output.
		
		FULL_CHECKER : process (r_head, r_tail)	--Generates the output that indicates that the fifo is full.
		
			variable current_h, current_t : integer;	--Copies for the current values of the head and the tail pointers.
		
			begin
				current_t := to_integer (unsigned (r_tail));
				current_h := to_integer (unsigned (r_head));
				if (current_h >= current_t) then	--Covering two different situations (head greater than or equal to tail and head littler than tail).
					if ((MEMORY_BIT_SIZE - (current_h - current_t)) <= INPUT_LENGTH) then	--Checks, for the first situation, if memory is full.
							o_full_buffer <= '1';
						else
							o_full_buffer <= '0';
						end if;
					else
						if ((current_t - current_h) <= INPUT_LENGTH) then	--Checks, for the second situation, if memory is full.
							o_full_buffer <= '1';
						else
							o_full_buffer <= '0';
					end if;
				end if;
			end process;
		
		TAIL_ADJSUTMENT : process (clk, rst, r_head, r_tail, i_rd_en)	--Similar to the HEAD_ADJUSTMENT process. This process is used for updating the tail pointer.
		
			variable current_h, current_t : integer;	--Copies for the current values of the head and the tail pointers.
		
			begin
				current_h := to_integer(unsigned(r_head));
				current_t := to_integer(unsigned(r_tail));
				if (rst = '1') then
					r_tail <= (others => '0');	--Resetting makes tail move to the same place as head (zero position).
				else
					if (rising_edge (clk)) then	--To make it synchronous.
						if (current_t > current_h) then	--Covering two different situations (tail greater than head and tail littler than or equal to head).
							if (((MEMORY_BIT_SIZE - (current_t - current_h)) >= OUTPUT_LENGTH) AND (i_rd_en = '1')) then	--Checks, for the first situation, if memory isn't empty and if reading is enabled.
								if ((current_t + OUTPUT_LENGTH) > (MEMORY_BIT_SIZE - 1)) then	--Checks if tail is about to return to zero position.
									r_tail <= std_logic_vector (to_unsigned ((current_t + OUTPUT_LENGTH - MEMORY_BIT_SIZE), 32));	--Updates tail.	
								else
									r_tail <= std_logic_vector (to_unsigned ((current_t + OUTPUT_LENGTH), 32));	--Updates tail.
								end if;
							end if;
						else	--Second situation.
							if (((current_h - current_t) >= OUTPUT_LENGTH) AND (i_rd_en = '1')) then	--Checks, for the second situation, if memory isn't empty and if reading is enabled.
								if ((current_t + OUTPUT_LENGTH) > (MEMORY_BIT_SIZE - 1)) then	--Checks if tail is about to return to zero position.
									r_tail <= std_logic_vector (to_unsigned ((current_t + OUTPUT_LENGTH - MEMORY_BIT_SIZE), 32)); --Updates tail.
								else
									r_tail <= std_logic_vector (to_unsigned ((current_t + OUTPUT_LENGTH), 32));	--Updates tail.
								end if;
							end if;
						end if;
					end if;
				end if;
			end process;
			
			tail <= r_tail;	--Setting the last of the auxiliary outputs.
			
		READ_DATA : process (clk, rst, r_head, r_tail, i_rd_en, fifo)	--Moves data from the memory to the output.
			
			variable current_h, current_t : integer;	--Copies for the current values of the head and the tail pointers.
			
			begin
				current_h := to_integer(unsigned(r_head));
				current_t := to_integer(unsigned(r_tail));
				if (rst = '1') then
					o_rd_data <= (others => 'Z');	--Resetting makes output receive high impedance. Maybe it should be changed to a standard.
				else
					if (rising_edge (clk)) then	--To make it synchronous.
						if (current_t > current_h) then	--Covering two different situations (tail greater than head and tail littler than or equal to head).
							if (((MEMORY_BIT_SIZE - (current_t - current_h)) >= OUTPUT_LENGTH) AND (i_rd_en = '1')) then	--Checks, for the first situation, if memory isn't empty and if reading is enabled.
								for it1 in 0 to (OUTPUT_LENGTH - 1) loop	--Transfer the data.
									if ((current_t + it1) < MEMORY_BIT_SIZE) then
										o_rd_data (it1) <= fifo (current_t + it1);
									else	--In case tail has gone back to zero.
										o_rd_data (it1) <= fifo (current_t + it1 - MEMORY_BIT_SIZE);
									end if;
								end loop;
							end if;
						else	--Second situation.
							if (((current_h - current_t) >= OUTPUT_LENGTH) AND (i_rd_en = '1')) then	--Checks, for the second situation, if memory isn't empty and if reading is enabled.
								for it1 in 0 to (OUTPUT_LENGTH - 1) loop	--Transfer the data.
									if ((current_t + it1) < MEMORY_BIT_SIZE) then
										o_rd_data (it1) <= fifo (current_t + it1);
									else	--In case tail has gone back to zero.
										o_rd_data (it1) <= fifo (current_t + it1 - MEMORY_BIT_SIZE);
									end if;
								end loop;
							end if;
						end if;		
					end if;
				end if;
		end process;

		EMPTY_CHECKER : process (r_head, r_tail)	--Generates the empty output.
		
			variable current_h, current_t : integer;	--Copies for the current values of the head and the tail pointers.
			
			begin
				current_h := to_integer(unsigned(r_head));
				current_t := to_integer(unsigned(r_tail));
				if (current_t > current_h) then	--Covering two different situations (tail greater than head and tail littler than or equal to head).
					if ((MEMORY_BIT_SIZE - (current_t - current_h)) < OUTPUT_LENGTH) then	--Checks, for the first situation, if memory is empty.
						o_empty_buffer <= '1';
					else
						o_empty_buffer <= '0';
					end if;
				else	--Second situation.
					if ((current_h - current_t) < OUTPUT_LENGTH) then	--Checks, for the second situation, if memory is empty.
						o_empty_buffer <= '1';
					else
						o_empty_buffer <= '0';
					end if;
				end if;
			end process;

end behavior_gb;