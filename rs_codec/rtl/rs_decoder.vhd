library IEEE;
use IEEE.MATH_REAL.ceil;
use IEEE.MATH_REAL.log2;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
library work;
use work.GENERIC_TYPES.std_logic_vector_array;
use work.GENERIC_COMPONENTS.async_dff;
use work.GENERIC_COMPONENTS.dff_array;
use work.GENERIC_COMPONENTS.flop_cascade;
use work.GENERIC_COMPONENTS.reg_fifo_array;
use work.GENERIC_COMPONENTS.reg_fifo;
use work.RS_TYPES.all;
use work.RS_COMPONENTS.rs_adder;
use work.RS_COMPONENTS.rs_chien_forney;
use work.RS_COMPONENTS.rs_euclidean;
use work.RS_COMPONENTS.rs_syndrome;
use WORK.RS_COMPONENTS.rs_berlekamp_massey;
use work.RS_FUNCTIONS.get_word_length_from_rs_gf;
use work.RS_FUNCTIONS.get_t;

entity rs_decoder is
	  generic (
            N : natural range 2 to 1023;
			K : natural range 1 to 1022;
            RS_GF : RSGFSize := RS_GF_NONE;
            OUTPUT_PARITY_SYMBOLS : boolean := true;
            TEST_MODE : boolean := false
	  );
	  port (
			clk : in std_logic;
			rst : in std_logic;
			i_end_codeword : in std_logic;
			i_start_codeword : in std_logic;
            i_valid: in std_logic;
            i_consume : in std_logic;
			i_symbol : in std_logic_vector(get_word_length_from_rs_gf(N, RS_GF)-1 downto 0);				
			o_in_ready : out std_logic;
			o_end_codeword : out std_logic;
			o_start_codeword : out std_logic;
			o_valid : out std_logic;
			o_error : out std_logic;
			o_symbol : out std_logic_vector(get_word_length_from_rs_gf(N, RS_GF)-1 downto 0)
	  );
end rs_decoder;

architecture behavioral of rs_decoder is
	 constant WORD_LENGTH : natural := get_word_length_from_rs_gf(N, RS_GF);
	 constant TWO_TIMES_T : natural := N - K;
	 constant T : natural := get_t(TWO_TIMES_T);
	
	 --Quartus This cause errro !!
	 signal one_array : std_logic_vector_array(0 downto 0)(WORD_LENGTH-1 downto 0) ;
	 
    --output INPUT_D_FLOP signals
    signal r_symbol : std_logic_vector(WORD_LENGTH-1 downto 0);

    --output rs_SYNDROME_INST signals
    signal w_syndrome_error : std_logic;
    signal w_syndrome_fifo_input : std_logic_vector_array(TWO_TIMES_T-1 downto 0)(WORD_LENGTH-1 downto 0);
    signal w_syndrome_valid : std_logic;
    signal w_wr_number_of_symbols : std_logic;
    signal w_wr_symbol : std_logic;
    signal w_number_of_symbols_input : std_logic_vector(WORD_LENGTH-1 downto 0);

    --output SYNDROME_FIFO_ARRAY_INST signals
    signal w_syndrome_fifo_empty : std_logic;
    signal w_syndrome_fifo_full : std_logic;
    signal w_syndrome_fifo_output : std_logic_vector_array(TWO_TIMES_T-1 downto 0)(WORD_LENGTH-1 downto 0);
    signal w_syndrome_fifo_output_aux : std_logic_vector_array(0 to TWO_TIMES_T-1)(WORD_LENGTH-1 downto 0);

    --output rs_EUCLIDEAN_INST signals
    signal w_euclidean_error : std_logic;
    signal w_rd_syndrome : std_logic;
    signal w_wr_bm : std_logic;
    signal w_chien_fifo_input_ref : std_logic_vector_array(T downto 0)(WORD_LENGTH-1 downto 0);
    signal w_chien_fifo_input : std_logic_vector_array(T-1 downto 0)(WORD_LENGTH-1 downto 0);
    signal w_forney_fifo_input : std_logic_vector_array(T-1 downto 0)(WORD_LENGTH-1 downto 0);
   
    --output CHIEN_FIFO_ARRAY_INST signals
    signal w_chien_fifo_empty : std_logic;
    signal w_chien_fifo_full : std_logic;
    signal w_chien_fifo_output : std_logic_vector_array(T downto 0)(WORD_LENGTH-1 downto 0);

    --output FORNEY_FIFO_ARRAY_INST signals
    signal w_forney_fifo_empty : std_logic;
    signal w_forney_fifo_full : std_logic;
    signal w_forney_fifo_output : std_logic_vector_array(T-1 downto 0)(WORD_LENGTH-1 downto 0);

    --output rs_CHIEN_FORNEY_INST signals
    signal w_chien_forney_error : std_logic;
    signal w_rd_chien_forney : std_logic;
    signal w_rd_number_of_symbols : std_logic;
    signal w_rd_symbol : std_logic;
    signal w_symbol_correction : std_logic_vector(WORD_LENGTH-1 downto 0);

    --output SYMBOL_FIFO_INST signals
    signal w_symbol_fifo_empty : std_logic;
    signal w_symbol_fifo_full : std_logic;
    signal w_symbol_fifo_output : std_logic_vector(WORD_LENGTH-1 downto 0);

    --output NUMBER_OF_SYMBOLS_FIFO_INST signals
    signal w_number_of_symbols_fifo_empty : std_logic;
    signal w_number_of_symbols_fifo_full : std_logic;
    signal w_number_of_symbols_fifo_output : std_logic_vector(WORD_LENGTH-1 downto 0);
	 
	 signal w_error : std_logic;

begin

	 assert (K < N) 
		  report "ASSERT FAILURE - K cannot be >= N" 
		  severity failure;
	 
    INPUT_ASYNC_DFF: async_dff
                     generic map (WORD_LENGTH => WORD_LENGTH) 
                     port map (d => i_symbol,
                               clk => clk,
                               rst => rst,
                               q => r_symbol);

    RS_SYNDROME_INST : rs_syndrome
                       generic map(N => N,
                                   K => K,
                                   WORD_LENGTH => WORD_LENGTH, 
                                   TWO_TIMES_T => TWO_TIMES_T,
                                   OUTPUT_PARITY_SYMBOLS => OUTPUT_PARITY_SYMBOLS,
                                   TEST_MODE => TEST_MODE)
                       port map(clk => clk,
                                rst => rst,
                                i_end_codeword => i_end_codeword,
                                i_number_of_symbols_fifo_full => w_number_of_symbols_fifo_full,
                                i_start_codeword => i_start_codeword,
                                i_symbol_fifo_full => w_symbol_fifo_full,
                                i_syndrome_fifo_full => w_syndrome_fifo_full,
                                i_valid => i_valid,
                                i_symbol => r_symbol,
                                o_in_ready => o_in_ready,
                                o_error => w_syndrome_error,
                                o_valid => w_syndrome_valid,
                                o_wr_number_of_symbols => w_wr_number_of_symbols,
                                o_wr_symbol => w_wr_symbol,
                                o_number_of_symbols => w_number_of_symbols_input,
                                o_syndrome => w_syndrome_fifo_input);
                                
    SYNDROME_FIFO_ARRAY_INST : reg_fifo_array
                               generic map(ARRAY_WIDTH => TWO_TIMES_T, 
                                           NUM_OF_ELEMENTS => 1, 
                                           WORD_LENGTH => WORD_LENGTH)
                               port map(clk => clk,
                                        rst => rst,
                                        i_wr_en => w_syndrome_valid,
                                        i_wr_data => w_syndrome_fifo_input,
                                        o_full => w_syndrome_fifo_full,
                                        i_rd_en => w_rd_syndrome,
                                        o_rd_data => w_syndrome_fifo_output,
                                        o_empty => w_syndrome_fifo_empty);

    w_syndrome_fifo_output_aux <= w_syndrome_fifo_output;
    RS_BERLEKAMP_MASSEY_INST: rs_berlekamp_massey
                              generic map(WORD_LENGTH => WORD_LENGTH, 
                                          TWO_TIMES_T => TWO_TIMES_T,
                                          TEST_MODE => TEST_MODE)
                              port map(clk => clk,
                                       rst => rst,
                                       i_fifo_chien_forney_full => w_chien_fifo_full or w_forney_fifo_full,
                                       i_syndrome_ready => not w_syndrome_fifo_empty,
                                       i_syndrome => w_syndrome_fifo_output_aux,
                                       o_rd_syndrome => w_rd_syndrome, 
                                       o_berlekamp_massey_ready => w_wr_bm,
                                       o_locator_poly => w_chien_fifo_input,
                                       o_value_poly => w_forney_fifo_input);

    --rs_EUCLIDEAN_INST BEGIN
    --rs_EUCLIDEAN_INST: rs_euclidean 
    --                   generic map(WORD_LENGTH => WORD_LENGTH, 
    --                            TWO_TIMES_T => TWO_TIMES_T)
    --                   port map(clk => clk,
    --                            rst => rst,
    --                            i_fifo_chien_forney_full => w_chien_fifo_full or w_forney_fifo_full,
    --                            i_syndrome_ready => not w_syndrome_fifo_empty,
    --                            i_syndrome => w_syndrome_fifo_output,
    --                            o_error => w_euclidean_error,
    --                            o_rd_syndrome => w_rd_syndrome, 
    --                            o_wr_euclidean => w_wr_bm,
    --                            o_chien => w_chien_fifo_input_ref,
    --                            o_forney => w_forney_fifo_input);
    --rs_EUCLIDEAN_INST END
	 
	w_chien_fifo_input_ref(T downto 1) <= w_chien_fifo_input;
	w_chien_fifo_input_ref(0) <= std_logic_vector(to_unsigned(1, WORD_LENGTH));
    CHIEN_FIFO_ARRAY_INST : reg_fifo_array
                            generic map(ARRAY_WIDTH => T + 1, 
                                        NUM_OF_ELEMENTS => 1, 
                                        WORD_LENGTH => WORD_LENGTH)
                            port map(clk => clk,
                                     rst => rst,
                                     i_wr_en => w_wr_bm,
                                     i_wr_data => w_chien_fifo_input_ref,
                                     o_full => w_chien_fifo_full,
                                     i_rd_en => w_rd_chien_forney,
                                     o_rd_data => w_chien_fifo_output,
                                     o_empty => w_chien_fifo_empty);

    FORNEY_FIFO_ARRAY_INST : reg_fifo_array
                             generic map(ARRAY_WIDTH => T, 
                                         NUM_OF_ELEMENTS => 1, 
                                         WORD_LENGTH => WORD_LENGTH)
                             port map(clk => clk,
                                      rst => rst,
                                      i_wr_en => w_wr_bm,
                                      i_wr_data => w_forney_fifo_input,
                                      o_full => w_forney_fifo_full,
                                      i_rd_en => w_rd_chien_forney,
                                      o_rd_data => w_forney_fifo_output,
                                      o_empty => w_forney_fifo_empty);

    RS_CHIEN_FORNEY_INST : rs_chien_forney
                           generic map(WORD_LENGTH => WORD_LENGTH,
                                       TWO_TIMES_T => TWO_TIMES_T,
                                       OUTPUT_PARITY_SYMBOLS => OUTPUT_PARITY_SYMBOLS,
                                       TEST_MODE => TEST_MODE)
                           port map(clk => clk,
                                    rst => rst,
                                    i_consume => i_consume,
                                    i_fifos_ready => (not w_chien_fifo_empty) and 
                                                     (not w_forney_fifo_empty) and
                                                     (not w_symbol_fifo_empty) and 
                                                     (not w_number_of_symbols_fifo_empty),
                                    i_number_of_symbols => w_number_of_symbols_fifo_output,
                                    i_chien => w_chien_fifo_output,
                                    i_forney => w_forney_fifo_output,
                                    o_end_codeword => o_end_codeword,
                                    o_error => w_chien_forney_error,
                                    o_rd_chien_forney => w_rd_chien_forney,
                                    o_rd_number_of_symbols => w_rd_number_of_symbols,
                                    o_rd_symbol => w_rd_symbol,
                                    o_start_codeword => o_start_codeword,
                                    o_valid => o_valid,
                                    o_symbol_correction => w_symbol_correction);

    GEN_NO_PARITY_OUTPUT_FALSE: if OUTPUT_PARITY_SYMBOLS = false generate
        signal r_o_cascade_valid : std_logic;
        signal r_o_cascade_data : std_logic_vector(WORD_LENGTH-1 downto 0);
    begin
        FLOP_CASCADE_INST : flop_cascade
                            generic map(WORD_LENGTH => WORD_LENGTH,
                                        CASCADE_LENGTH => N - K)
                            port map(clk => clk,
                                     rst => rst or w_wr_number_of_symbols,
                                     i_valid => w_wr_symbol, 
                                     i_data => r_symbol,
                                     o_valid => r_o_cascade_valid,
                                     o_data => r_o_cascade_data);
        --If "NUM_OF_ELEMENTS => N*5 + 2", fifo is never full
        SYMBOL_FIFO_INST : reg_fifo
                           generic map(NUM_OF_ELEMENTS => N*5 + 1, 
                                       WORD_LENGTH => WORD_LENGTH,
                                       O_FULL_MINUS_ONE => true)
                           port map(clk => clk,
                                    rst => rst,
                                    i_wr_en => r_o_cascade_valid,
                                    i_wr_data => r_o_cascade_data,
                                    o_full => w_symbol_fifo_full,
                                    i_rd_en => w_rd_symbol and not w_error,
                                    o_rd_data => w_symbol_fifo_output,
                                    o_empty => w_symbol_fifo_empty);
    end generate;
    --If "NUM_OF_ELEMENTS => N*5 + 2", fifo is never full
    GEN_NO_PARITY_OUTPUT_TRUE: if OUTPUT_PARITY_SYMBOLS = true generate
        SYMBOL_FIFO_INST : reg_fifo
                           generic map(NUM_OF_ELEMENTS => N*5 + 1, 
                                       WORD_LENGTH => WORD_LENGTH,
                                       O_FULL_MINUS_ONE => true)
                           port map(clk => clk,
                                    rst => rst,
                                    i_wr_en => w_wr_symbol,
                                    i_wr_data => r_symbol,
                                    o_full => w_symbol_fifo_full,
                                    i_rd_en => w_rd_symbol and not w_error,
                                    o_rd_data => w_symbol_fifo_output,
                                    o_empty => w_symbol_fifo_empty);
    end generate;               
    --If "NUM_OF_ELEMENTS => 5", fifo is never full             
    NUMBER_OF_SYMBOLS_FIFO_INST : reg_fifo
                                  generic map(NUM_OF_ELEMENTS => 4, 
                                              WORD_LENGTH => WORD_LENGTH)
                                  port map(clk => clk,
                                           rst => rst,
                                           i_wr_en => w_wr_number_of_symbols,
                                           i_wr_data => w_number_of_symbols_input,
                                           o_full => w_number_of_symbols_fifo_full,
                                           i_rd_en => w_rd_number_of_symbols,
                                           o_rd_data => w_number_of_symbols_fifo_output,
                                           o_empty => w_number_of_symbols_fifo_empty);                                 

    ERROR_CORRECTION_ADDER_INST: rs_adder 
                                 generic map (WORD_LENGTH => WORD_LENGTH,
                                              TEST_MODE => TEST_MODE)
                                 port map (i1 => w_symbol_fifo_output,
                                           i2 => w_symbol_correction,
                                           o => o_symbol);
                         
    w_error <= w_syndrome_error or w_chien_forney_error;  
	o_error <= w_error;
end behavioral;
