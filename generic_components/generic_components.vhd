library IEEE;
use IEEE.MATH_REAL.ceil;
use IEEE.MATH_REAL.log2;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
library work;
use work.GENERIC_TYPES.all;
use work.GENERIC_FUNCTIONS.get_log_round;
use work.GENERIC_FUNCTIONS.max;


package GENERIC_COMPONENTS is    
    component async_dff is 
        generic (
            WORD_LENGTH : natural range 1 to 1024
        );
        port (
            clk : in std_logic;
            rst : in std_logic;
            d : in std_logic_vector(WORD_LENGTH-1 downto 0);
            q : out std_logic_vector(WORD_LENGTH-1 downto 0)
        );
    end component;

    component async_dff_gen_rst is 
        generic (
            WORD_LENGTH : natural range 1 to 10
        );
        port (
            clk : in std_logic;
            rst : in std_logic;
            rst_value : in std_logic_vector(WORD_LENGTH-1  downto 0);
            d : in std_logic_vector(WORD_LENGTH-1 downto 0);
            q : out std_logic_vector(WORD_LENGTH-1 downto 0)
        );
    end component;

    component dff_array is 
        generic (
            NUM_OF_ELEMENTS : natural range 1 to 1024; 
            WORD_LENGTH : natural range 1 to 10
        );
        port (
            clk : in std_logic;
            rst : in std_logic;
            d : in std_logic_vector_array(NUM_OF_ELEMENTS-1 downto 0)(WORD_LENGTH-1 downto 0);
            q : out std_logic_vector_array(NUM_OF_ELEMENTS-1 downto 0)(WORD_LENGTH-1 downto 0)
        );
    end component;

    component config_dff_array is 
        generic (
            NUM_OF_ELEMENTS : natural range 1 to 1024; 
            WORD_LENGTH : natural range 1 to 10
        );
        port (
            clk : in std_logic;
            en : in std_logic;
            d : in std_logic_vector_array(NUM_OF_ELEMENTS-1 downto 0)(WORD_LENGTH-1 downto 0);
            q : out std_logic_vector_array(NUM_OF_ELEMENTS-1 downto 0)(WORD_LENGTH-1 downto 0)
        );
    end component;

    component demultiplexer_array is
		 generic (
			  WORD_LENGTH : integer;
			  NUM_OF_ELEMENTS : integer
		 );
		 port (
			  i : in std_logic_vector(WORD_LENGTH-1 downto 0);
			  i_sel : in std_logic_vector(get_log_round(NUM_OF_ELEMENTS)-1 downto 0);   
			  o_array : out std_logic_vector_array(NUM_OF_ELEMENTS-1 downto 0)(WORD_LENGTH-1 downto 0)
		 );
    end component;

    component dff_gen_rst is 
        generic (
            WORD_LENGTH : natural range 1 to 10
        );
        port (
            clk : in std_logic;
            rst : in std_logic;
            reset_value : in std_logic_vector(WORD_LENGTH-1  downto 0);
            d : in std_logic_vector(WORD_LENGTH-1 downto 0);
            q : out std_logic_vector(WORD_LENGTH-1 downto 0)
        );
    end component;
    
	 component  multiplexer_array is
		 generic (
			  WORD_LENGTH : integer;
			  NUM_OF_ELEMENTS : integer
		 );
		 port (
			  i_array : out std_logic_vector_array(NUM_OF_ELEMENTS-1 downto 0)(WORD_LENGTH-1 downto 0);
			  i_sel : in std_logic_vector(get_log_round(NUM_OF_ELEMENTS)-1 downto 0);   
			  o : in std_logic_vector(WORD_LENGTH-1 downto 0)   
		 );
	 end component;

    component no_rst_dff is 
        generic (
            WORD_LENGTH : natural range 1 to 20
        );
        port (
            clk : in std_logic;
            d : in std_logic_vector(WORD_LENGTH-1 downto 0);
            q : out std_logic_vector(WORD_LENGTH-1 downto 0)
        );
    end component;

    component generic_buffer is
        generic (
            INPUT_LENGTH : natural;
            OUTPUT_LENGTH : natural;
            MEMORY_BIT_SIZE : natural
        );
        port (
            clk : in std_logic;
            rst : in std_logic;
            i_rd_en : in std_logic;
            i_wr_en : in std_logic;
            i_wr_data : in std_logic_vector(INPUT_LENGTH-1 downto 0);
            o_full_buffer : out std_logic;
            o_empty_buffer : out std_logic;
            o_rd_data : out std_logic_vector(OUTPUT_LENGTH-1 downto 0)
        );
    end component;

    component shifter_left is
        generic (
            N : natural range 1 to 10;
            S : natural range 1 to 4
        );
        port (
            i : in std_logic_vector(N-1 downto 0);
            sel : in std_logic_vector(S-1 downto 0);
            o : out std_logic_vector(N-1 downto 0)
        );
    end component;

    component register_shifter is
		 generic (NUM_OF_ELEMENTS : natural;
					 WORD_LENGTH : natural);
		 port (clk : in std_logic;
				 rst : in std_logic;
			    reset_value : in std_logic_vector_array(NUM_OF_ELEMENTS-1 downto 0)(WORD_LENGTH-1 downto 0);
				 i_first_input : in std_logic_vector(WORD_LENGTH-1 downto 0);
				 o_array: out std_logic_vector_array(NUM_OF_ELEMENTS-1 downto 0)(WORD_LENGTH-1 downto 0));
    end component;

    component register_feedback_shifter is
		 generic (NUM_OF_ELEMENTS : natural;
					 WORD_LENGTH : natural);
		 port (clk : in std_logic;
				 rst : in std_logic;
				 reset_value : in std_logic_vector_array(NUM_OF_ELEMENTS-1 downto 0)(WORD_LENGTH-1 downto 0);
				 i_load_input_array: in std_logic;
				 i_array: in std_logic_vector_array(NUM_OF_ELEMENTS-1 downto 0)(WORD_LENGTH-1 downto 0);
				 o_array: out std_logic_vector_array(NUM_OF_ELEMENTS-1 downto 0)(WORD_LENGTH-1 downto 0));
    end component;

    component reg_fifo is
        generic (
            WORD_LENGTH : natural := 10;
            NUM_OF_ELEMENTS : integer := 1024
        );
        port (
            clk : in std_logic;
            rst : in std_logic;

            -- FIFO Write Interface
            i_wr_en   : in  std_logic;
            i_wr_data : in  std_logic_vector(WORD_LENGTH-1 downto 0);
            o_full    : out std_logic;
        
            -- FIFO Read Interface
            i_rd_en   : in  std_logic;
            o_rd_data : out std_logic_vector(WORD_LENGTH-1 downto 0);
            o_empty   : out std_logic
        );
    end component;

    component reg_fifo_array is
        generic (
            ARRAY_WIDTH : natural range 1 to 1024;
            NUM_OF_ELEMENTS : natural range 1 to 1024;
            WORD_LENGTH : natural range 1 to 10
        );
        port (
            clk : in std_logic;
            rst : in std_logic;

            -- FIFO Write Interface
            i_wr_en   : in  std_logic;
            i_wr_data : in std_logic_vector_array(ARRAY_WIDTH-1 downto 0)(WORD_LENGTH-1 downto 0);
            o_full    : out std_logic;
        
            -- FIFO Read Interface
            i_rd_en   : in  std_logic;
            o_rd_data : out std_logic_vector_array(ARRAY_WIDTH-1 downto 0)(WORD_LENGTH-1 downto 0);
            o_empty   : out std_logic
        );
    end component;

    component sync_dff is 
        generic (
            WORD_LENGTH : natural range 1 to 10
        );
        port (
            clk : in std_logic;
            rst : in std_logic;
            d : in std_logic_vector(WORD_LENGTH-1 downto 0);
            q : out std_logic_vector(WORD_LENGTH-1 downto 0)
        );
    end component;

    component sync_dff_gen_rst is 
        generic (
            WORD_LENGTH : natural range 1 to 10
        );
        port (
            clk : in std_logic;
            rst : in std_logic;
				rst_value : in std_logic_vector(WORD_LENGTH-1  downto 0);
            d : in std_logic_vector(WORD_LENGTH-1 downto 0);
            q : out std_logic_vector(WORD_LENGTH-1 downto 0)
        );
    end component;

    component async_dff_array is 
        generic (
            NUM_OF_ELEMENTS : natural range 1 to 1024; 
            WORD_LENGTH : natural range 1 to 10
        );
        port (
            clk : in std_logic;
            rst : in std_logic;
            d : in std_logic_vector_array(NUM_OF_ELEMENTS-1 downto 0)(WORD_LENGTH-1 downto 0);
            q : out std_logic_vector_array(NUM_OF_ELEMENTS-1 downto 0)(WORD_LENGTH-1 downto 0)
        );
    end component;

    component sync_dff_array is 
        generic (
            NUM_OF_ELEMENTS : natural range 1 to 1024; 
            WORD_LENGTH : natural range 1 to 10
        );
        port (
            clk : in std_logic;
            rst : in std_logic;
            d : in std_logic_vector_array(NUM_OF_ELEMENTS-1 downto 0)(WORD_LENGTH-1 downto 0);
            q : out std_logic_vector_array(NUM_OF_ELEMENTS-1 downto 0)(WORD_LENGTH-1 downto 0)
        );
    end component;

    component two_input_size_generic_buffer is
		 generic (
			 INPUT_1_LENGTH : natural;
			 INPUT_2_LENGTH : natural;
			 OUTPUT_LENGTH : natural;
			 NUM_OF_OUTPUT_ELEMENTS : natural
		 );
		 port (
			 clk : in std_logic;
			 rst : in std_logic;
			 i_data_length_selector : in std_logic;
			 i_rd_en : in  std_logic;
			 i_wr_en : in std_logic;
			 i_wr_data : in std_logic_vector(max(INPUT_1_LENGTH, INPUT_2_LENGTH)-1 downto 0);
			 o_full_buffer : out std_logic;
			 o_empty_buffer : out std_logic;
			 o_rd_data : out std_logic_vector(OUTPUT_LENGTH-1 downto 0)
		 );
    end component;

    component single_port_ram is
		 generic (
			  NUMBER_OF_ELEMENTS : natural;
			  WORD_LENGTH : natural
		 );
		 port (
			  clk : in std_logic;
			  i_ram_wr_en : in std_logic;
			  i_ram_addr : in std_logic_vector(get_log_round(NUMBER_OF_ELEMENTS)-1 downto 0);
			  i_ram_data : in std_logic_vector(WORD_LENGTH-1 downto 0);
			  o_ram_data : in std_logic_vector(WORD_LENGTH-1 downto 0)  
		 );
    end component;

    component up_counter is
        generic(
            WORD_LENGTH : natural
        );
        port ( 
            clk : in std_logic; -- clock input
            rst : in std_logic; -- reset input
            i_inc : in std_logic;
            o_counter : out std_logic_vector(WORD_LENGTH-1 downto 0) -- output 4-bit counter
         );
    end component;

    component dual_clock_generic_buffer is
        generic (
          INPUT_LENGTH : natural;
          OUTPUT_LENGTH : natural
        );
        port (
          clk_rd : in std_logic;
          clk_wr : in std_logic;
          rst : in std_logic;
          i_rd_en : in  std_logic;
          i_wr_en : in std_logic;
          i_wr_data : in std_logic_vector(INPUT_LENGTH-1 downto 0);
          o_full_buffer : out std_logic;
          o_empty_buffer : out std_logic;
          o_rd_data : out std_logic_vector(OUTPUT_LENGTH-1 downto 0)
        );
    end component;

end package GENERIC_COMPONENTS;
