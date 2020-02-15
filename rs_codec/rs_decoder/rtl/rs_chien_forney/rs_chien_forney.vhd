library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.MATH_REAL.ceil;
use IEEE.MATH_REAL.log2;
library work;
use work.GENERIC_COMPONENTS.no_rst_dff;
use work.GENERIC_TYPES.std_logic_vector_array;
use work.RS_COMPONENTS.rs_chien;
use work.RS_COMPONENTS.rs_forney;
use work.RS_FUNCTIONS.get_t;

entity rs_chien_forney is
    generic (
        WORD_LENGTH : natural range 2 to 10;
		TWO_TIMES_T : natural range 1 to 1022
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        i_fifos_ready : in std_logic;
        i_number_of_symbols : in std_logic_vector(WORD_LENGTH-1 downto 0);
	    i_chien : in std_logic_vector_array(get_t(TWO_TIMES_T) downto 0)(WORD_LENGTH-1 downto 0);
        i_forney : in std_logic_vector_array(get_t(TWO_TIMES_T)-1 downto 0)(WORD_LENGTH-1 downto 0);
        o_end_codeword : out std_logic;
        o_error : out std_logic;
	    o_rd_chien_forney : out std_logic;
        o_rd_number_of_symbols : out std_logic;
        o_rd_symbol : out std_logic;
        o_start_codeword : out std_logic;
	    o_symbol_correction : out std_logic_vector(WORD_LENGTH-1 downto 0)
    );
end rs_chien_forney;

architecture behavioral of rs_chien_forney is
    constant T : natural := get_t(TWO_TIMES_T);

    --i_fifos_ready is delay by 1-cycle to give time to register omega and lambda
    --in chien and forney units
    signal r_fifos_ready : std_logic;

    --NUMBER_OF_SYMBOLS_FLOP signals
    signal w_number_of_symbols : std_logic_vector(WORD_LENGTH-1 downto 0);
    signal r_number_of_symbols : std_logic_vector(WORD_LENGTH-1 downto 0);

    --output rs_CHIEN_INST signals
    signal w_has_error : std_logic;
    signal w_rd_chien_forney : std_logic;
    signal w_derivative : std_logic_vector(WORD_LENGTH-1 downto 0);

    --output rs_CHIEN_FORNEY_CONTROL_INST signals
    signal w_select_input : std_logic;
    
    component rs_chien_forney_control is
        generic (
            WORD_LENGTH : natural range 2 to 10
        );
        port(
            clk : in std_logic;
            rst : in std_logic;
            i_fifos_ready : in std_logic;
            i_number_of_symbols : in std_logic_vector(WORD_LENGTH-1 downto 0);
            i_reg_number_of_symbols : in std_logic_vector(WORD_LENGTH-1 downto 0);
            o_error : out std_logic;
            o_rd_chien_forney : out std_logic;
            o_rd_number_of_symbols : out std_logic;
            o_rd_symbol : out std_logic;
            o_select_input : out std_logic;
            o_start_codeword : out std_logic;
            o_end_codeword : out std_logic
        );
    end component;
begin
	assert (TWO_TIMES_T <= 2**WORD_LENGTH-2) 
		  report "ASSERT FAILURE - T <= 2**WORD_LENGTH-2" 
          severity failure;
    FIFO_READY_FLOP : no_rst_dff 
    generic map (WORD_LENGTH => 1) 
    port map (clk => clk,
              d(0) => i_fifos_ready,
              q(0) => r_fifos_ready);
    
    --TODO: This flop should be placed inside the control unit
    w_number_of_symbols <= i_number_of_symbols when w_select_input else r_number_of_symbols;
    NUMBER_OF_SYMBOLS_FLOP : no_rst_dff 
                             generic map (WORD_LENGTH => WORD_LENGTH) 
                             port map (clk => clk,
                                       d => w_number_of_symbols,
                                       q => r_number_of_symbols);
    RS_CHIEN_INST: rs_chien
                   generic map (WORD_LENGTH => WORD_LENGTH, 
                                T => T)
                   port map(clk => clk,
                            i_select_input => w_select_input,
                            i_terms => i_chien,
                            o_has_error => w_has_error,
                            o_derivative => w_derivative);

    RS_FORNEY_INST: rs_forney
                    generic map (WORD_LENGTH => WORD_LENGTH, 
                                 T => T)
                    port map(clk => clk,
                             i_has_error => w_has_error,
                             i_select_input => w_select_input,
                             i_derivative => w_derivative,
                             i_terms => i_forney,
                             o_symbol_correction => o_symbol_correction);
                             
    RS_CHIEN_FORNEY_CONTROL_INST: rs_chien_forney_control
        generic map(WORD_LENGTH => WORD_LENGTH)
        port map(clk => clk,
                 rst => rst,
                 i_fifos_ready => r_fifos_ready,
                 i_number_of_symbols => i_number_of_symbols,
                 i_reg_number_of_symbols => r_number_of_symbols,
                 o_error => o_error,
                 o_rd_chien_forney => o_rd_chien_forney,
                 o_rd_number_of_symbols => o_rd_number_of_symbols,
                 o_rd_symbol => o_rd_symbol,
                 o_select_input => w_select_input,
                 o_start_codeword => o_start_codeword,
                 o_end_codeword => o_end_codeword);
end behavioral;

library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

entity rs_chien_forney_control is
    generic (
        WORD_LENGTH : natural range 2 to 10
    );
    port(
        clk : in std_logic;
        rst : in std_logic;
        i_fifos_ready : in std_logic;
        i_number_of_symbols : in std_logic_vector(WORD_LENGTH-1 downto 0);
        i_reg_number_of_symbols : in std_logic_vector(WORD_LENGTH-1 downto 0);
        o_error : out std_logic;
        o_rd_chien_forney : out std_logic;
        o_rd_number_of_symbols : out std_logic;
        o_rd_symbol : out std_logic;
        o_select_input : out std_logic;
        o_start_codeword : out std_logic;
        o_end_codeword : out std_logic
    );
end rs_chien_forney_control;

architecture behavioral of rs_chien_forney_control is
constant END_INDEX : natural := 2**WORD_LENGTH - 1;
    type State is (WAIT_FOR_EUCLIDEAN_TERMS,
                   ADVANCE_VOID_POSITIONS,
                   START_CHIEN_FORNEY,
                   COMPUTE_CHIEN_FORNEY,
                   END_CHIEN_FORNEY);
    signal r_state : State;
    signal r_counter : integer range 0 to END_INDEX;
begin
    process (clk, rst)
    begin
        if (rst = '1') then
            r_counter <= 0;
            r_state <= WAIT_FOR_EUCLIDEAN_TERMS;
        elsif rising_edge(clk) then
            case r_state is
                when WAIT_FOR_EUCLIDEAN_TERMS | END_CHIEN_FORNEY =>
                    r_counter <= 0;
                    if (i_fifos_ready = '1') then
                        if (to_integer(unsigned(i_number_of_symbols)) = END_INDEX - 1) then
                            r_state <= START_CHIEN_FORNEY;
                        else
                            r_state <= ADVANCE_VOID_POSITIONS;
                        end if;
                    else
                        r_state <= WAIT_FOR_EUCLIDEAN_TERMS;
                    end if;
                when ADVANCE_VOID_POSITIONS =>
                    r_counter <= r_counter + 1;
                    if (r_counter =  END_INDEX - to_integer(unsigned(i_reg_number_of_symbols)) - 2) then
                        r_state <= START_CHIEN_FORNEY;
                    else
                        r_state <= ADVANCE_VOID_POSITIONS;
                    end if;
                when START_CHIEN_FORNEY =>
                    r_counter <= r_counter + 1;
                    r_state <= COMPUTE_CHIEN_FORNEY;
                when COMPUTE_CHIEN_FORNEY =>
                    r_counter <= r_counter + 1;
                    if (r_counter = END_INDEX - 2) then
                        r_state <= END_CHIEN_FORNEY;
					else
						r_state <= COMPUTE_CHIEN_FORNEY;
                    end if;
            end case;
        end if;
    end process;

    process (rst, r_state, i_fifos_ready)
    begin
        case r_state is
            when WAIT_FOR_EUCLIDEAN_TERMS =>
                o_error <= '0';
                o_rd_chien_forney <= i_fifos_ready;
                o_rd_number_of_symbols <= i_fifos_ready;
                o_rd_symbol <= '0';
                o_select_input <= '1';
                o_start_codeword <= '0';
                o_end_codeword <= '0';
            when ADVANCE_VOID_POSITIONS =>
                o_error <= '0';
                o_rd_chien_forney <= '0';
                o_rd_number_of_symbols <= '0';
                o_rd_symbol <= '0';
                o_select_input <= '0';
                o_start_codeword <= '0';
                o_end_codeword <= '0';
            when START_CHIEN_FORNEY =>
                o_error <= '0';
                o_rd_chien_forney <= '0';
                o_rd_number_of_symbols <= '0';
                o_rd_symbol <= '1';
                o_select_input <= '0';
                o_start_codeword <= '1';
                o_end_codeword <= '0';
            when COMPUTE_CHIEN_FORNEY =>
                o_error <= '0';
                o_rd_chien_forney <= '0';
                o_rd_number_of_symbols <= '0';
                o_rd_symbol <= '1';
                o_select_input <= '0';
                o_start_codeword <= '0';
                o_end_codeword <= '0';
            when END_CHIEN_FORNEY =>
                o_error <= '0';
                o_rd_chien_forney <= i_fifos_ready;
                o_rd_number_of_symbols <= i_fifos_ready;
                o_rd_symbol <= '1';
                o_select_input <= '1';
                o_start_codeword <= '0';
                o_end_codeword <= '1';
        end case;
    end process;
end behavioral;
