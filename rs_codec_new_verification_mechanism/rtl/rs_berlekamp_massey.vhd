library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

entity rs_berlekamp_massey_control is
    generic (
        WORD_LENGTH : natural range 2 to 10;
		TWO_TIMES_T : natural range 1 to 1022
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        i_fifo_chien_forney_full : in std_logic;
        i_syndrome_ready : in std_logic;
        o_rst_bm_unit : out std_logic;
        o_location_poly_phase : out std_logic;
        o_value_poly_phase : out std_logic;
        o_clear_syn : out std_logic;
        o_rd_syndrome : out std_logic;
        o_berlekamp_massey_ready : out std_logic;
        o_syndrome_indexer : out integer range 0 to TWO_TIMES_T-1
    );
end rs_berlekamp_massey_control;

architecture behavioral of rs_berlekamp_massey_control is
	type State is (WAIT_FOR_SYNDROME,
                   START_BM, 
                   COMPUTE_LOCATION,
                   CLEAR_SYNDROME_REGS,
                   COMPUTE_VALUES,
                   END_BM);
    signal r_state : State;
    signal r_syndrome_indexer : integer range 0 to TWO_TIMES_T-1;
begin
   process (clk, rst)
	begin
		if (rst = '1') then
            r_syndrome_indexer <= 0;
			r_state <= WAIT_FOR_SYNDROME;
        elsif rising_edge(clk) then
            case r_state is
                when WAIT_FOR_SYNDROME =>
                    r_syndrome_indexer <= 0;
                    if (i_syndrome_ready = '0') then
                        r_state <= WAIT_FOR_SYNDROME;
                    else
                        r_state <= START_BM;
                    end if;
                when START_BM =>
                    r_syndrome_indexer <= r_syndrome_indexer + 1;
                    r_state <= COMPUTE_LOCATION;
                when COMPUTE_LOCATION =>
                    if (r_syndrome_indexer = 0) then
                        r_state <= CLEAR_SYNDROME_REGS;
                    else
                        if (r_syndrome_indexer = TWO_TIMES_T-1) then
                            --Prevents out of bounds behavior
                            r_syndrome_indexer <= 0;
                        else 
                            r_syndrome_indexer <= r_syndrome_indexer + 1;
                        end if;
                        r_state <= COMPUTE_LOCATION;
                    end if;
                when CLEAR_SYNDROME_REGS =>
                    r_syndrome_indexer <= 0;
                    r_state <= COMPUTE_VALUES;
                when COMPUTE_VALUES =>
                    r_syndrome_indexer <= r_syndrome_indexer + 1;
                    if (r_syndrome_indexer = TWO_TIMES_T/2) then
                        r_state <= END_BM;
                    else
                        r_state <= COMPUTE_VALUES;
                    end if;
                when END_BM =>
                    r_syndrome_indexer <= 0;
                    if (i_fifo_chien_forney_full = '1') then
                        r_state <= END_BM;
                    elsif (i_syndrome_ready = '1') then
                        r_state <= START_BM;
                    else
                        r_state <= WAIT_FOR_SYNDROME;
                    end if;
            end case;
        end if;
    end process;
    o_syndrome_indexer <= r_syndrome_indexer;
    process (rst, r_state, i_fifo_chien_forney_full)
    begin
        case r_state is
            when WAIT_FOR_SYNDROME =>
                o_location_poly_phase <= '0';
                o_value_poly_phase <= '0';
                o_rd_syndrome <= '0';
                o_berlekamp_massey_ready <= '0';
                o_clear_syn <= '0';   
                o_rst_bm_unit <= '1';            
            when START_BM =>
                o_location_poly_phase <= '1';
                o_value_poly_phase <= '0';
                o_rd_syndrome <= '1';
                o_berlekamp_massey_ready <= '0';
                o_clear_syn <= '0';
                o_rst_bm_unit <= '0';
            when COMPUTE_LOCATION =>
                o_location_poly_phase <= '1';
                o_value_poly_phase <= '0';
                o_rd_syndrome <= '0';
                o_berlekamp_massey_ready <= '0';
                o_clear_syn <= '0';
                o_rst_bm_unit <= '0';
            when CLEAR_SYNDROME_REGS =>
                o_location_poly_phase <= '0';
                o_value_poly_phase <= '0';
                o_rd_syndrome <= '0';
                o_berlekamp_massey_ready <= '0';
                o_clear_syn <= '1';
                o_rst_bm_unit <= '0';
            when COMPUTE_VALUES =>
                o_location_poly_phase <= '0';
                o_value_poly_phase <= '1';
                o_rd_syndrome <= '0';
                o_berlekamp_massey_ready <= '0';
                o_clear_syn <= '0';
                o_rst_bm_unit <= '0';
            when END_BM =>
                o_location_poly_phase <= '0';
                o_value_poly_phase <= '0';
                o_rd_syndrome <= '0';
                o_berlekamp_massey_ready <= not i_fifo_chien_forney_full;
                o_clear_syn <= '0';
                o_rst_bm_unit <= not i_fifo_chien_forney_full;
        end case;
    end process;
end behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.GENERIC_TYPES.std_logic_vector_array;
use work.GENERIC_FUNCTIONS.to_slv;
use work.GENERIC_FUNCTIONS.to_slva;

entity register_shifter is
    generic (NUM_OF_ELEMENTS : natural;
             WORD_LENGTH : natural);
    port (clk : in std_logic;
          rst : in std_logic;
		  reset_value : in std_logic_vector_array(NUM_OF_ELEMENTS-1 downto 0)(WORD_LENGTH-1 downto 0);
          i_first_input : in std_logic_vector(WORD_LENGTH-1 downto 0);
          o_array: out std_logic_vector_array(NUM_OF_ELEMENTS-1 downto 0)(WORD_LENGTH-1 downto 0));
end entity;

architecture behavioral of register_shifter is
signal r_array: std_logic_vector_array(NUM_OF_ELEMENTS-1 downto 0)(WORD_LENGTH-1 downto 0);
signal w_array: std_logic_vector_array(NUM_OF_ELEMENTS-1 downto 0)(WORD_LENGTH-1 downto 0);
begin
    OUTPUT_ASSIGNMENT: if (NUM_OF_ELEMENTS = 1) generate 
        w_array(0) <= i_first_input;
    end generate;
    NOT_OUTPUT_ASSIGNMENT: if (NUM_OF_ELEMENTS /= 1) generate 
        w_array(NUM_OF_ELEMENTS-1 downto 1) <= r_array(NUM_OF_ELEMENTS-2 downto 0);
	w_array(0) <= i_first_input;
    end generate;

    process (clk) 
    begin 
        if (rising_edge(clk)) then
            if (rst = '1') then
                r_array <= reset_value;
            else
                r_array <= w_array;
            end if;
        end if;   
    end process;
    o_array <= r_array;
end behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.GENERIC_TYPES.std_logic_vector_array;

entity register_feedback_shifter is
	generic (NUM_OF_ELEMENTS : natural;
            WORD_LENGTH : natural);
    port (clk : in std_logic;
		   rst : in std_logic;
		   reset_value : in std_logic_vector_array(NUM_OF_ELEMENTS-1 downto 0)(WORD_LENGTH-1 downto 0);
		   i_load_input_array: in std_logic;
		   i_array: in std_logic_vector_array(NUM_OF_ELEMENTS-1 downto 0)(WORD_LENGTH-1 downto 0);
		   o_array: out std_logic_vector_array(NUM_OF_ELEMENTS-1 downto 0)(WORD_LENGTH-1 downto 0));
end entity;

architecture behavioral of register_feedback_shifter is
signal r_array: std_logic_vector_array(NUM_OF_ELEMENTS-1 downto 0)(WORD_LENGTH-1 downto 0);
begin
    process (clk) 
    begin 
        if (rising_edge(clk)) then
            if (rst = '1') then
                r_array <= reset_value;
            elsif (i_load_input_array = '1') then
                r_array <= i_array;
            else
                r_array(NUM_OF_ELEMENTS-1 downto 1) <= r_array(NUM_OF_ELEMENTS-2 downto 0);
					 r_array(0) <= r_array(NUM_OF_ELEMENTS-1);
            end if;
        end if;   
    end process;
    o_array <= r_array;
end behavioral;

library IEEE;
use IEEE.MATH_REAL.ceil;
use IEEE.MATH_REAL.log2;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.GENERIC_COMPONENTS.config_dff_array;
use work.GENERIC_COMPONENTS.register_shifter;
use work.GENERIC_COMPONENTS.register_feedback_shifter;
use work.GENERIC_COMPONENTS.sync_dff;
use work.GENERIC_COMPONENTS.sync_dff_gen_rst;
use work.GENERIC_COMPONENTS.sync_dff_array;
use work.GENERIC_FUNCTIONS.to_slva;
use work.GENERIC_TYPES.std_logic_vector_array;
use work.RS_COMPONENTS.rs_full_multiplier;
use work.RS_COMPONENTS.rs_reduce_adder;
use work.RS_COMPONENTS.rs_inverse;
use work.RS_COMPONENTS.rs_adder;
use work.RS_FUNCTIONS.get_t;

entity rs_berlekamp_massey_unit is
    generic (
        WORD_LENGTH : natural range 2 to 10;
        TWO_TIMES_T : natural range 1 to 1022;
        TEST_MODE : boolean := false
    );
    port (
        clk : in std_logic;
        i_control_rst : in std_logic;
        i_clear_syn : in std_logic;
        i_location_poly_phase : in std_logic;
        i_value_poly_phase : in std_logic;
        i_syndrome : in std_logic_vector_array(TWO_TIMES_T-1 downto 0)(WORD_LENGTH-1 downto 0);
        i_syndrome_indexer : in integer range 0 to TWO_TIMES_T-1;
		o_locator_poly : out std_logic_vector_array(get_t(TWO_TIMES_T)-1 downto 0)(WORD_LENGTH-1 downto 0);
        o_value_poly : out std_logic_vector_array(get_t(TWO_TIMES_T)-1 downto 0)(WORD_LENGTH-1 downto 0)
    );
end rs_berlekamp_massey_unit;

architecture behavioral of rs_berlekamp_massey_unit is
	constant T : natural := get_t(TWO_TIMES_T);
    constant c_reset_syndrome_shifter: std_logic_vector_array(T-1 downto 0)(WORD_LENGTH-1 downto 0) := 
        (std_logic_vector(to_unsigned(0, WORD_LENGTH)), others => std_logic_vector(to_unsigned(0, WORD_LENGTH)));
    constant c_reset_connection_shifter: std_logic_vector_array(T-1 downto 0)(WORD_LENGTH-1 downto 0) := 
        (std_logic_vector(to_unsigned(1, WORD_LENGTH)), others => std_logic_vector(to_unsigned(0, WORD_LENGTH)));

    --SYNDROME_REGISTER_ARRAY signals
    signal r_syndrome : std_logic_vector_array(TWO_TIMES_T-1 downto 0)(WORD_LENGTH-1 downto 0);

    signal w_indexed_syndrome: std_logic_vector(WORD_LENGTH-1 downto 0);

    --FIRST_SYNDROME_REG signals
    signal r_first_syndrome: std_logic_vector(WORD_LENGTH-1 downto 0);

    --SYNDROME_SHIFTER signals
    signal r_syndrome_shifter: std_logic_vector_array(T-1 downto 0)(WORD_LENGTH-1 downto 0);
    
    --SYNDROME_TIMES_LOCATION_MULT signals
    signal w_syndrome_times_location: std_logic_vector_array(T-1 downto 0)(WORD_LENGTH-1 downto 0);

    --REDUCE_ADDER signals
	 signal w_reduce_adder: std_logic_vector_array(T downto 0)(WORD_LENGTH-1 downto 0);
    signal w_discrepancy: std_logic_vector(WORD_LENGTH-1 downto 0);

    --UPDATE_DISCREPANCY signals
    signal w_load_next_values : std_logic;
    signal r_2l : integer range 0 to 2*TWO_TIMES_T;
    signal r_discrepancy: std_logic_vector(WORD_LENGTH-1 downto 0);

    --DISCREPANCY_INVERTER signals
    signal w_inv_discrepancy: std_logic_vector(WORD_LENGTH-1 downto 0);

    signal w_select_discrepancy: std_logic_vector(WORD_LENGTH-1 downto 0);

    --DISCREPANCY_MULT signals
    signal w_mult_discrepancy: std_logic_vector(WORD_LENGTH-1 downto 0);

    --LOCATION_MULT signals
    signal w_location_mult: std_logic_vector_array(T-1 downto 0)(WORD_LENGTH-1 downto 0);

    --LOCATION_ADDER signals
    signal w_location_adder: std_logic_vector_array(T-1 downto 0)(WORD_LENGTH-1 downto 0);

    --LOCATION_POLY_REGISTER signals
    signal r_location_poly: std_logic_vector_array(T-1 downto 0)(WORD_LENGTH-1 downto 0);

    --CONNECTION_SHIFTER signals
	 signal w_connection_shifter: std_logic_vector_array(T-1 downto 0)(WORD_LENGTH-1 downto 0);
    signal r_connection_shifter: std_logic_vector_array(T-1 downto 0)(WORD_LENGTH-1 downto 0);

    --R_VALUE_REGISTER signals
    signal r_value_poly: std_logic_vector_array(T-1 downto 0)(WORD_LENGTH-1 downto 0);
begin
    SYNDROME_REGISTER_ARRAY: config_dff_array
                             generic map (NUM_OF_ELEMENTS => TWO_TIMES_T,
                                          WORD_LENGTH => WORD_LENGTH)
                             port map (clk => clk,
                                       en => i_control_rst,
                                       d => i_syndrome,
                                       q => r_syndrome);

    --Only a selector for r_syndrome array that depends on an indexer driven by an input port.
    w_indexed_syndrome <= r_syndrome(i_syndrome_indexer);

    FIRST_SYNDROME_REG: sync_dff
                        generic map (WORD_LENGTH => WORD_LENGTH)
                        port map (clk => clk,
                                  rst => i_control_rst or i_clear_syn,
                                  d => w_indexed_syndrome,
                                  q => r_first_syndrome);

    SYNDROME_SHIFTER: register_shifter
                      generic map (NUM_OF_ELEMENTS => T,
                                   WORD_LENGTH => WORD_LENGTH)
                      port map (clk => clk,
                                rst => i_control_rst or i_clear_syn,
								reset_value => c_reset_syndrome_shifter,
                                i_first_input => r_first_syndrome,
                                o_array => r_syndrome_shifter);

    GEN_SYNDROME_TIMES_LOCATION: for I in 0 to T-1 generate
        SYNDROME_TIMES_LOCATION_MULT: rs_full_multiplier
                                      generic map (WORD_LENGTH => WORD_LENGTH,
                                                   TEST_MODE => TEST_MODE)
                                      port map (i1 => r_syndrome_shifter(I),
                                                i2 => r_location_poly(I),
                                                o => w_syndrome_times_location(I));  
    end generate GEN_SYNDROME_TIMES_LOCATION;

	w_reduce_adder(T downto 1) <= w_syndrome_times_location;
    w_reduce_adder(0) <= r_first_syndrome;
    
    REDUCE_ADDER: rs_reduce_adder
                  generic map(NUM_OF_ELEMENTS => T + 1,
                              WORD_LENGTH => WORD_LENGTH)
				  port map(i => w_reduce_adder,
                           o => w_discrepancy);

    process (i_syndrome_indexer, w_discrepancy, r_2l)
    begin
        if (w_discrepancy /= (w_discrepancy'range => '0') and (i_syndrome_indexer >= r_2l)) then
            w_load_next_values <= '1';
        else
            w_load_next_values <= '0';
        end if;
    end process;

    --update L
    process (clk)
    begin
        if (rising_edge(clk)) then
            if (i_control_rst = '1') then
                r_2l <= 0;
            elsif (w_load_next_values = '1') then
                r_2l <= to_integer(shift_left(to_unsigned(i_syndrome_indexer, WORD_LENGTH + 1), 1)) - r_2l;
            else
                r_2l <= r_2l;
            end if;
        end if;
    end process;

    --update r_discrepancy
    process (clk)
    begin
        if (rising_edge(clk)) then
            if (i_control_rst = '1') then 
                r_discrepancy <= std_logic_vector(to_unsigned(1, WORD_LENGTH));
            elsif (w_load_next_values = '1') then 
                r_discrepancy <= w_discrepancy;
            else 
                r_discrepancy <= r_discrepancy;
            end if;
        end if;
    end process;

    DISCREPANCY_INVERTER: rs_inverse
                          generic map(WORD_LENGTH => WORD_LENGTH,
                                      TEST_MODE => TEST_MODE)
                          port map(i => r_discrepancy,
                                   o => w_inv_discrepancy);

    w_select_discrepancy <= w_discrepancy when (i_location_poly_phase = '1') else (others => '0') ;

    DISCREPANCY_MULT: rs_full_multiplier
                      generic map (WORD_LENGTH => WORD_LENGTH,
                                   TEST_MODE => TEST_MODE)
                      port map (i1 => w_select_discrepancy,
                                i2 => w_inv_discrepancy,
                                o => w_mult_discrepancy);

    T_GREATER_THAN_ONE : if (T > 1) generate
        GEN_LOCATION_POLY_LOGIC: for I in 0 to T-1 generate
            LOCATION_MULT: rs_full_multiplier
                           generic map (WORD_LENGTH => WORD_LENGTH,
                                        TEST_MODE => TEST_MODE)
                           port map (i1 => w_mult_discrepancy,
                                     i2 => r_connection_shifter(I),
                                     o => w_location_mult(I));

            LOCATTION_ADDER: rs_adder
                             generic map (WORD_LENGTH => WORD_LENGTH,
                                          TEST_MODE => TEST_MODE)
                             port map (i1 => w_location_mult(I),
                                       i2 => r_location_poly(I),
                                       o => w_location_adder(I));   
        end generate GEN_LOCATION_POLY_LOGIC;

		w_connection_shifter(T-1 downto 1) <= r_location_poly(T-2 downto 0);
		w_connection_shifter(0) <= std_logic_vector(to_unsigned(1, WORD_LENGTH));
        CONNECTION_SHIFTER: register_feedback_shifter
                            generic map (NUM_OF_ELEMENTS => T,
                                         WORD_LENGTH => WORD_LENGTH)
                            port map (clk => clk,
                                      rst => i_control_rst,
									  reset_value => c_reset_connection_shifter,
                                      i_load_input_array => w_load_next_values,
                                      i_array => w_connection_shifter,
                                      o_array => r_connection_shifter);
    end generate;
    T_EQUAL_TO_ONE : if (T <= 1) generate
            LOCATTION_ADDER: rs_adder
                             generic map (WORD_LENGTH => WORD_LENGTH,
                                          TEST_MODE => TEST_MODE)
                             port map (i1 => r_location_poly(0),
                                       i2 => w_mult_discrepancy,
                                       o => w_location_adder(0));   
        
    end generate;

    LOCATION_POLY_REGISTER: sync_dff_array
                            generic map (NUM_OF_ELEMENTS => T,
                                        WORD_LENGTH => WORD_LENGTH)
                            port map (clk => clk,
                                      rst => i_control_rst,
                                      d => w_location_adder,
                                      q => r_location_poly);

    process (clk) 
    begin 
        if (rising_edge(clk)) then
            if (i_control_rst = '1') then
                for I in T-1 downto 0 loop
                    r_value_poly(I) <= (others => '0');
                end loop;
            elsif (i_value_poly_phase = '1' and i_syndrome_indexer >= 1) then
                r_value_poly(i_syndrome_indexer - 1) <= w_discrepancy;
            end if;
        end if;   
    end process;

    o_locator_poly <= r_location_poly;
    o_value_poly <= r_value_poly;
end behavioral;

library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;
use work.GENERIC_TYPES.std_logic_vector_array;
use work.RS_FUNCTIONS.get_t;

entity rs_berlekamp_massey is
        generic (
            WORD_LENGTH : natural range 2 to 10;
            TWO_TIMES_T : natural range 1 to 1022;
            TEST_MODE : boolean := false
        );
        port (
            clk : in std_logic;
            rst : in std_logic;
            i_fifo_chien_forney_full : in std_logic;
            i_syndrome_ready : in std_logic;
            i_syndrome : in std_logic_vector_array(TWO_TIMES_T-1 downto 0)(WORD_LENGTH-1 downto 0);
            o_rd_syndrome : out std_logic;
            o_berlekamp_massey_ready : out std_logic;
			o_locator_poly : out std_logic_vector_array(get_t(TWO_TIMES_T)-1 downto 0)(WORD_LENGTH-1 downto 0);
            o_value_poly : out std_logic_vector_array(get_t(TWO_TIMES_T)-1 downto 0)(WORD_LENGTH-1 downto 0)
        );
end rs_berlekamp_massey;

architecture behavioral of rs_berlekamp_massey is
    component rs_berlekamp_massey_control is
        generic (
            WORD_LENGTH : natural range 2 to 10;
			TWO_TIMES_T : natural range 1 to 1022
        );
        port (
            clk : in std_logic;
            rst : in std_logic;
            i_fifo_chien_forney_full : in std_logic;
            i_syndrome_ready : in std_logic;
            o_rst_bm_unit : out std_logic;
            o_location_poly_phase : out std_logic;
            o_value_poly_phase : out std_logic;
            o_clear_syn : out std_logic;
            o_rd_syndrome : out std_logic;
            o_berlekamp_massey_ready : out std_logic;
            o_syndrome_indexer : out integer range 0 to TWO_TIMES_T-1
        );
    end component;

    component rs_berlekamp_massey_unit is
        generic (
            WORD_LENGTH : natural range 2 to 10;
            TWO_TIMES_T : natural range 1 to 1022;
            TEST_MODE : boolean := false
        );
        port (
            clk : in std_logic;
            i_control_rst : in std_logic;
            i_clear_syn : in std_logic;
            i_location_poly_phase : in std_logic;
            i_value_poly_phase : in std_logic;
            i_syndrome : in std_logic_vector_array(TWO_TIMES_T-1 downto 0)(WORD_LENGTH-1 downto 0);
            i_syndrome_indexer : in integer range 0 to TWO_TIMES_T-1;
            o_locator_poly : out std_logic_vector_array(get_t(TWO_TIMES_T)-1 downto 0)(WORD_LENGTH-1 downto 0);
            o_value_poly : out std_logic_vector_array(get_t(TWO_TIMES_T)-1 downto 0)(WORD_LENGTH-1 downto 0)
        );
    end component;
	
	constant T : natural := get_t(TWO_TIMES_T);
    signal w_syndrome_indexer : integer range 0 to TWO_TIMES_T-1;
    signal w_clear_syn : std_logic;
    signal w_location_poly_phase : std_logic;
    signal w_value_poly_phase : std_logic;
    signal w_rst_bm_unit : std_logic;	 
begin
	 assert (TWO_TIMES_T <= 2**WORD_LENGTH-2) 
		  report "ASSERT FAILURE - TWO_TIMES_T <= 2**WORD_LENGTH-2" 
		  severity failure;
		  
    RS_BERLEKAMP_MASSEY_CONTROL_INST: rs_berlekamp_massey_control
                                      generic map (WORD_LENGTH => WORD_LENGTH,
                                                   TWO_TIMES_T => TWO_TIMES_T)
                                      port map(clk => clk,
                                               rst => rst,
                                               i_fifo_chien_forney_full => i_fifo_chien_forney_full,
                                               i_syndrome_ready => i_syndrome_ready,
                                               o_rst_bm_unit => w_rst_bm_unit,
                                               o_location_poly_phase => w_location_poly_phase,
                                               o_value_poly_phase => w_value_poly_phase,
                                               o_clear_syn => w_clear_syn,
                                               o_rd_syndrome => o_rd_syndrome,
                                               o_berlekamp_massey_ready => o_berlekamp_massey_ready,
                                               o_syndrome_indexer => w_syndrome_indexer);

    RS_BERLEKAMP_MASSEY_UNIT_INST: rs_berlekamp_massey_unit
                                   generic map (WORD_LENGTH => WORD_LENGTH,
                                                TWO_TIMES_T => TWO_TIMES_T,
                                                TEST_MODE => TEST_MODE)
                                   port map(clk => clk,
                                            i_control_rst => w_rst_bm_unit,
                                            i_clear_syn => w_clear_syn,
                                            i_syndrome => i_syndrome,
                                            i_syndrome_indexer => w_syndrome_indexer,
                                            i_location_poly_phase => w_location_poly_phase,
                                            i_value_poly_phase => w_value_poly_phase,
                                            o_locator_poly => o_locator_poly,
                                            o_value_poly => o_value_poly);
end behavioral;
