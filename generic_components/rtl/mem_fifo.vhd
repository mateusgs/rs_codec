-- FIFO implementation

library ieee;
use ieee.std_logic_1164.all;

entity mem_fifo is
generic (
    O_SIZE : integer;					-- output size
    I_SIZE : integer;					-- input size
    MEM_SIZE: integer					-- memory size
  );
port (
    clk : in std_logic;					-- system clock		
    rst : in std_logic;					-- reset
    i_wr_en : in std_logic;				-- enables memory to be written
    i_data : in std_logic_vector(I_SIZE - 1 downto 0);	-- input data
    i_rd_en : in std_logic;				-- enables memory to be read
    o_data : out std_logic_vector(O_SIZE - 1 downto 0);	-- output data
    o_empty_buffer : out std_logic := '1';		-- '1' when memory is empty, '0', when it is not
    o_full_buffer : out std_logic := '0'		-- '1' when memory is full, '0' when it is not
  );
end mem_fifo;  

architecture behavioral of mem_fifo is
	signal mem: std_logic_vector(MEM_SIZE-1 downto 0) := (others => '0');		--memory
	subtype index_type is integer range 0 to MEM_SIZE-1;
	signal head : index_type := 0;							-- indicates the last element that got in the memory
	signal tail : index_type := 0;							-- indicates the first element that got in the memory
	signal r_count : integer range 0 to MEM_SIZE := 0;				-- counts how many elements are written in the memory at each clock cycle
	signal r_full_buffer: std_logic := '0';						-- internal signal representing o_full_buffer
	signal r_empty_buffer: std_logic := '1';					-- internal signal representing o_empty_buffer

	begin

		r_empty_buffer <= '1' when (r_count < O_SIZE) else '0';			-- when r_count >= O_SIZE, there is at least one word to be read
		r_full_buffer <= '1' when (r_count = MEM_SIZE) else '0';		-- when r_count = MEM_SIZE, memory is full

		o_empty_buffer <= r_empty_buffer;
		o_full_buffer <= r_full_buffer;
    
    ----------------------------------------------------------------------
    -- mem_process:
    -- describes FIFO behaviour for reset, write and read

			mem_process : process(clk, rst)
				variable v_head : index_type;					-- variable representing signal head inside process
				variable v_tail : index_type;					-- variable representing signal tail inside process
    				variable v_count : integer range 0 to MEM_SIZE;			-- variable representing signal r_count inside process
    				variable v_data: std_logic_vector(O_SIZE - 1 downto 0);		-- variable representing signal o_data inside process
    				variable v_mem: std_logic_vector(MEM_SIZE-1 downto 0);		-- variable representing signal mem inside process

				begin
	 				if(rst = '1') then					--when reset is HIGH, memory will be empty
	    					v_head := 0;
						v_tail := 0;
						v_data := (others => '0');
						v_mem := (others => '0');
						v_count := 0;
	  				else 
						if (rising_edge(clk)) then
	    						v_count := r_count;
							v_head := head;
							v_tail := tail;
							v_mem := mem;
							v_data := o_data;
							if(i_wr_en = '1' and r_full_buffer = '0') then		-- write i_data in memory
		    						for I in 0 to I_SIZE-1 loop
		        						v_mem(v_head) := i_data(I);
		        						if v_head = MEM_SIZE-1 then 		-- atualize head
	      									v_head := 0;
	    								else
	      									v_head := v_head + 1;
	    								end if;
		   	 					end loop;
		     						v_count := v_count + I_SIZE; 			-- atualize counter
		 					end if;
		 					if(i_rd_en = '1' and r_empty_buffer = '0') then 	-- read memory
		    						for I in 0 to O_SIZE-1 loop
		        						v_data(I) := v_mem(v_tail);		-- v_data receives data from memory
		        						if v_tail = MEM_SIZE-1 then		-- atualize tail
	      									v_tail := 0;
	    								else
	      									v_tail := v_tail + 1;
	    								end if;
		    						end loop;
		    						v_count := v_count - O_SIZE; 			-- atualize counter
		  					end if;
	      					end if;
	    				end if;
					head <= v_head;		--atualize signals with their corresponding variables
				    	tail <= v_tail;
				    	mem <= v_mem;
				    	r_count <= v_count;
				    	o_data <= v_data;
			end process;
end behavioral;
