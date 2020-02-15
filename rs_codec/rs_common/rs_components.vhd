library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.MATH_REAL.ceil;
use IEEE.MATH_REAL.log2;
library work;
use work.GENERIC_TYPES.std_logic_vector_array;
use work.RS_FUNCTIONS.get_word_length_from_rs_gf;
use work.RS_FUNCTIONS.get_t;
use work.RS_FUNCTIONS.get_szs;
use work.RS_TYPES.all;

package RS_COMPONENTS is
    component rs_remainder_unit is
        generic (
            WORD_LENGTH : natural range 2 to 10;
			   MULT_CONSTANT : natural range 0 to 1023
        );
        port (
            clk : in std_logic;
            rst : in std_logic;
            i_stall : in std_logic;
            i_symbol : in std_logic_vector(WORD_LENGTH-1 downto 0);
            i_upper_lv : in std_logic_vector(WORD_LENGTH-1 downto 0);
            o : out std_logic_vector(WORD_LENGTH-1 downto 0)
        );
    end component;

    component rs_adder is
        generic (
            WORD_LENGTH : natural range 2 to 10
        );
        port (
            i1 : in std_logic_vector(WORD_LENGTH-1 downto 0);
            i2 : in std_logic_vector(WORD_LENGTH-1 downto 0);
            o : out std_logic_vector(WORD_LENGTH-1 downto 0)
        );
    end component;

    component rs_multiplier is
        generic (
            WORD_LENGTH : natural range 2 to 10;
				MULT_CONSTANT : natural range 0 to 1023
        );
        port (
            i : in std_logic_vector(WORD_LENGTH-1 downto 0);
            o : out std_logic_vector(WORD_LENGTH-1 downto 0)
        );
    end component;

    component rs_syndrome_subunit is
    generic (
        WORD_LENGTH : natural range 2 to 10;
		  I : natural range 0 to 1021
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        i_select_feedback : in std_logic;
        i_stall : in std_logic;
        i_symbol : in std_logic_vector(WORD_LENGTH-1 downto 0);
        o_syndrome : out std_logic_vector(WORD_LENGTH-1 downto 0)
    );
    end component;

    component rs_inverse is
        generic (
            WORD_LENGTH : natural range 2 to 10
        );
        port (
            i : in std_logic_vector(WORD_LENGTH-1 downto 0);
            o : out std_logic_vector(WORD_LENGTH-1 downto 0)
        );
    end component;

    component rs_full_multiplier is
        generic (
            WORD_LENGTH : natural range 2 to 10
        );
        port (
            i1 : in std_logic_vector(WORD_LENGTH-1 downto 0);
            i2 : in std_logic_vector(WORD_LENGTH-1 downto 0);
            o : out std_logic_vector(WORD_LENGTH-1 downto 0)
    );
    end component;

    component rs_full_multiplier_core is
        generic (
            WORD_LENGTH : natural range 2 to 10
        );
        port (
            i1 : in std_logic_vector(WORD_LENGTH-1 downto 0);
            i2 : in std_logic_vector(WORD_LENGTH-1 downto 0);
            o : out std_logic_vector(WORD_LENGTH-1 downto 0)
    );
    end component;

    component rs_encoder is
        generic (
            N : natural range 2 to 1023;
				K : natural range 1 to 1022;
				RS_GF : RSGFSize := RS_GF_NONE
   	  );
        port (
            clk : in std_logic;
            rst : in std_logic;
            i_end_codeword : in std_logic;
            i_start_codeword : in std_logic;
            i_valid : in std_logic;
				i_symbol : in std_logic_vector(get_word_length_from_rs_gf(N, RS_GF)-1 downto 0);          
            o_end_codeword : out std_logic;
            o_error : out std_logic;
            o_in_ready : out std_logic;
            o_start_codeword : out std_logic;
            o_valid : out std_logic;
				o_symbol : out std_logic_vector(get_word_length_from_rs_gf(N, RS_GF)-1 downto 0)
        );
    end component;

    component rs_encoder_wrapper is
        generic (
            N : natural range 2 to 1023;
				K : natural range 1 to 1022;
            RS_GF : RSGFSize := RS_GF_NONE
        );
        port (
            clk : in std_logic;
            rst : in std_logic;
            i_end_codeword : in std_logic;
            i_start_codeword : in std_logic;
            i_valid : in std_logic;
            i_symbol : in std_logic_vector(get_word_length_from_rs_gf(N, RS_GF)-1 downto 0);
            o_end_codeword : out std_logic;
            o_error : out std_logic;
            o_in_ready : out std_logic;
            o_start_codeword : out std_logic;
            o_valid : out std_logic;
				o_symbol : out std_logic_vector(get_word_length_from_rs_gf(N, RS_GF)-1 downto 0);            
            o_syndrome : out std_logic_vector_array(N-K-1 downto 0)(get_word_length_from_rs_gf(N, RS_GF)-1 downto 0)
        );
    end component;

    component rs_forney is
        generic (
            WORD_LENGTH : natural range 2 to 10;
				T : natural range 1 to 1022
        );
        port (
            clk : in std_logic;
            i_has_error : in std_logic;
            i_select_input : in std_logic;
            i_derivative : in std_logic_vector(WORD_LENGTH-1 downto 0);	
            i_terms : in std_logic_vector_array(T-1 downto 0)(WORD_LENGTH-1 downto 0);
            o_symbol_correction : out std_logic_vector(WORD_LENGTH-1 downto 0)
        );
    end component;

    component rs_chien is
        generic (
            WORD_LENGTH : natural range 2 to 10;
				T : natural range 1 to 1022
        );
        port (
            clk : in std_logic;
            i_select_input : in std_logic;
            i_terms : in std_logic_vector_array(T downto 0)(WORD_LENGTH-1 downto 0);         
            o_has_error : out std_logic;
            o_derivative : out std_logic_vector(WORD_LENGTH-1 downto 0)
        );
    end component;

    component rs_chien_forney is
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
    end component;

    component rs_syndrome is
        generic (
            N : natural range 2 to 1023;
            K : natural range 1 to 1022;
            WORD_LENGTH : natural range 2 to 10;
				TWO_TIMES_T : natural range 1 to 1022
        );
        port (
            clk : in std_logic;
            rst : in std_logic;
            i_end_codeword : in std_logic;
            i_number_of_symbols_fifo_full : in std_logic;
            i_start_codeword : in std_logic;
            i_symbol_fifo_full : in std_logic;
            i_syndrome_fifo_full : in std_logic;
            i_valid : in std_logic;
            i_symbol : in std_logic_vector(WORD_LENGTH-1 downto 0);
            o_in_ready : out std_logic;
            o_error : out std_logic;
            o_valid : out std_logic;
            o_wr_number_of_symbols : out std_logic;
            o_wr_symbol : out std_logic;
            o_number_of_symbols : out std_logic_vector(WORD_LENGTH-1 downto 0);
            o_syndrome : out std_logic_vector_array(TWO_TIMES_T-1 downto 0)(WORD_LENGTH-1 downto 0)
        );
    end component;

    component rs_euclidean is
    generic (
        WORD_LENGTH : natural range 2 to 10;
        TWO_TIMES_T : natural range 1 to 1022
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        i_fifo_chien_forney_full : in std_logic;
        i_syndrome_ready : in std_logic;
        i_syndrome : in std_logic_vector_array(TWO_TIMES_T-1 downto 0)(WORD_LENGTH-1 downto 0);
        o_error : out std_logic;
        o_rd_syndrome : out std_logic;
        o_wr_euclidean : out std_logic;
        o_chien : out std_logic_vector_array(TWO_TIMES_T-2 downto 0)(WORD_LENGTH-1 downto 0);
        o_forney : out std_logic_vector_array(TWO_TIMES_T-3 downto 0)(WORD_LENGTH-1 downto 0)
    );
    end component;

    component rs_decoder is
        generic (
            N : natural range 2 to 1023;
				K : natural range 1 to 1022;
            RS_GF : RSGFSize := RS_GF_NONE
        );
        port (
            clk : in std_logic;
            rst : in std_logic;
            i_end_codeword : in std_logic;
            i_start_codeword : in std_logic;
            i_valid: in std_logic;
				i_symbol : in std_logic_vector(get_word_length_from_rs_gf(N, RS_GF)-1 downto 0);				
            o_in_ready : out std_logic;
            o_end_codeword : out std_logic;
            o_start_codeword : out std_logic;
            o_valid : out std_logic;
            o_error : out std_logic;
				o_symbol : out std_logic_vector(get_word_length_from_rs_gf(N, RS_GF)-1 downto 0)
        );
    end component;


    component rs_shifter_acc is
        generic (
            WORD_LENGTH : natural range 2 to 10;
				TWO_TIMES_T : natural range 1 to 1022
        );
        port (
            i_shifter : in std_logic_vector_array(TWO_TIMES_T-3 downto 0)(WORD_LENGTH-1 downto 0);
            i_num_shift : in integer range 0 to TWO_TIMES_T;
            o_shifter : out std_logic_vector_array(TWO_TIMES_T-2 downto 0)(WORD_LENGTH-1 downto 0)
        );
    end component;

    component rs_shitfer_zero_significant_positions is
        generic(
            WORD_LENGTH : natural range 2 to 10;
				TWO_TIMES_T : natural range 1 to 1022
        );
        port (
            i_shifter : in std_logic_vector_array(TWO_TIMES_T-1 downto 0)(WORD_LENGTH-1 downto 0);
            o_num_shift_zeros : out integer range 0 to 2**get_szs(TWO_TIMES_T)-1;
            o_shifter : out std_logic_vector_array(TWO_TIMES_T-1 downto 0)(WORD_LENGTH-1 downto 0)
        );
    end component;

    component rs_euclidean_acc_unit is
		 generic (
			  WORD_LENGTH : natural range 2 to 10;
			  TWO_TIMES_T : natural range 1 to 1022
		 );
		 port (
			  clk : in std_logic;
			  rst : in std_logic;
			  i_sync_rst : in std_logic;
			  i_swap : in std_logic;
			  i_num_shift : integer range 0 to TWO_TIMES_T;
			  i_quocient : in std_logic_vector(WORD_LENGTH-1 downto 0);
			  o_chien : out std_logic_vector_array(TWO_TIMES_T-2 downto 0)(WORD_LENGTH-1 downto 0)
		 );
    end component;

    component rs_euclidean_division_unit is
		 generic (
			 WORD_LENGTH : natural range 2 to 10;
			  TWO_TIMES_T : natural range 1 to 1022
		 );
		 port (
			  clk : in std_logic;
			  rst : in std_logic;
			  i_sync_rst : in std_logic;
			  i_swap : in std_logic;
			  i_syndrome : in std_logic_vector_array(TWO_TIMES_T-1 downto 0)(WORD_LENGTH-1 downto 0);
			  o_div_shift_zeros : out integer range 0 to 2**get_szs(TWO_TIMES_T)-1;
			  o_rem_shift_zeros : out integer range 0 to 2**get_szs(TWO_TIMES_T)-1;
			  o_quocient : out std_logic_vector(WORD_LENGTH-1 downto 0);
			  o_forney : out std_logic_vector_array(TWO_TIMES_T-3 downto 0)(WORD_LENGTH-1 downto 0)
		 );
    end component;

    component rs_reduce_adder is
        generic (
            NUM_OF_ELEMENTS : natural range 1 to 1024; 
            WORD_LENGTH : natural range 1 to 10
        );
        port (
            i : in std_logic_vector_array(NUM_OF_ELEMENTS-1 downto 0)(WORD_LENGTH-1 downto 0);
            o : out std_logic_vector(WORD_LENGTH-1 downto 0)
        );
    end component;

    component rs_berlekamp_massey is
        generic (
            WORD_LENGTH : natural range 2 to 10;
				TWO_TIMES_T : natural range 1 to 1022
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
    end component;
    
    component rs_syndrome_unit is
        generic (
            WORD_LENGTH : natural range 2 to 10;
				TWO_TIMES_T : natural range 1 to 1022
        );
        port (
            clk : in std_logic;
            rst : in std_logic;
            i_select_feedback : in std_logic;
            i_stall : in std_logic;
            i_symbol : in std_logic_vector(WORD_LENGTH-1 downto 0);
            o_syndrome : out std_logic_vector_array(TWO_TIMES_T-1 downto 0)(WORD_LENGTH-1 downto 0)
        );
    end component;

    component rs_disturber is
        generic (
            N : natural range 2 to 1023;
            RS_GF : RSGFSize := RS_GF_NONE
        );
        port (
            clk : in std_logic;
            rst : in std_logic;
            
            --Undriven signals responsible for error modelling
            i_corrupt_symbol : in std_logic;  
				i_error_symbol : in std_logic_vector(get_word_length_from_rs_gf(N, RS_GF)-1 downto 0); 
				
            --Signals from rs_encoder
            i_o_encoder_start_codeword : in std_logic;
            i_o_encoder_end_codeword : in std_logic;
            i_o_encoder_valid : in std_logic;
				i_o_encoder_symbol : in std_logic_vector(get_word_length_from_rs_gf(N, RS_GF)-1 downto 0);

            --Signals from rs_decoder    
            i_consume_fifo : in std_logic;   
            i_o_decoder_symbol : in std_logic_vector(get_word_length_from_rs_gf(N, RS_GF)-1 downto 0);  
				
            o_i_decoder_valid : out std_logic;
            o_i_decoder_start_codeword : out std_logic;
            o_i_decoder_end_codeword : out std_logic;
            o_enable_encoder_valid : out std_logic;
            o_fifo_empty : out std_logic;
            o_fifo_xor_decoder_symbol : out std_logic;
				o_error_counter : out std_logic_vector(get_word_length_from_rs_gf(N, RS_GF)-1 downto 0);
            o_i_decoder_symbol : out std_logic_vector(get_word_length_from_rs_gf(N, RS_GF)-1 downto 0)
        );
    end component;
end package RS_COMPONENTS;
