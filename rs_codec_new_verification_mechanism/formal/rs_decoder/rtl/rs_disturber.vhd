library IEEE;
use IEEE.MATH_REAL.ceil;
use IEEE.MATH_REAL.log2;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.GENERIC_COMPONENTS.async_dff;
use work.GENERIC_COMPONENTS.reg_fifo;
use work.GENERIC_COMPONENTS.up_counter;
use work.RS_TYPES.RSGFSize;
use work.RS_FUNCTIONS.get_word_length_from_rs_gf;
use work.RS_COMPONENTS.rs_adder;

entity rs_disturber is
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
end rs_disturber;

architecture behavioral of rs_disturber is
    constant WORD_LENGTH : natural := get_word_length_from_rs_gf(N, RS_GF);
    signal w_enable_error_insertion : std_logic;
    --ENABLE_ERROR_INSERTION_ASYNC_DFF outputs
    signal r_enable_error_insertion : std_logic;
    --ENCODER_VALID_ASYNC_DFF outputs
    signal r_o_encoder_valid : std_logic;
    --ENCODER_SYMBOL_ASYNC_DFF outputs
    signal r_encoder_symbol : std_logic_vector(WORD_LENGTH-1 downto 0);
    --ERROR_INSERTION_ADDER_INST outputs
    signal w_decoder_symbol : std_logic_vector(WORD_LENGTH-1 downto 0);
    --SYMBOL_FIFO_INST outputs
    signal w_symbol_fifo_empty : std_logic;
    signal w_symbol_fifo_output : std_logic_vector(WORD_LENGTH-1 downto 0);

    --ERROR_COUNTER_INST outputs
    signal w_error_counter : std_logic_vector(WORD_LENGTH-1 downto 0);

    --DECODER_CHECK_ADDER_INST outputs
    signal w_decoder_check_adder : std_logic_vector(WORD_LENGTH-1 downto 0);

    signal w_error_insertion_symbol : std_logic_vector(WORD_LENGTH-1 downto 0);
    signal w_valid_error_insertion : std_logic;
    signal w_counter_inc : std_logic;
    
begin

    ENCODER_START_CODEWORD_ASYNC_DFF : async_dff
                                       generic map (WORD_LENGTH => 1) 
                                       port map (d(0) => i_o_encoder_start_codeword,
                                                 clk => clk,
                                                 rst => rst,
                                                 q(0) => o_i_decoder_start_codeword);

    ENCODER_END_CODERWORD_ASYNC_DFF : async_dff
                                      generic map (WORD_LENGTH => 1) 
                                      port map (d(0) => i_o_encoder_end_codeword,
                                                clk => clk,
                                                rst => rst,
                                                q(0) => o_i_decoder_end_codeword);

    w_enable_error_insertion <= '0' when o_i_decoder_end_codeword and r_o_encoder_valid else 
                                '1' when i_o_encoder_start_codeword and i_o_encoder_valid else 
                                r_enable_error_insertion;

    ENABLE_ERROR_INSERTION_ASYNC_DFF : async_dff
                                       generic map (WORD_LENGTH => 1) 
                                       port map (d(0) => w_enable_error_insertion,
                                                 clk => clk,
                                                 rst => rst,
                                                 q(0) => r_enable_error_insertion);

    ENCODER_VALID_ASYNC_DFF : async_dff
                              generic map (WORD_LENGTH => 1) 
                              port map (d(0) => i_o_encoder_valid,
                                        clk => clk,
                                        rst => rst,
                                        q(0) => r_o_encoder_valid);

    ENCODER_SYMBOL_ASYNC_DFF : async_dff
                               generic map (WORD_LENGTH => WORD_LENGTH) 
                               port map (d => i_o_encoder_symbol,
                                         clk => clk,
                                         rst => rst,
                                         q => r_encoder_symbol);

    w_error_insertion_symbol <= i_error_symbol when (r_enable_error_insertion and i_corrupt_symbol) else (others => '0');
    ERROR_INSERTION_ADDER_INST : rs_adder 
                                generic map (WORD_LENGTH => WORD_LENGTH)
                                port map (i1 => r_encoder_symbol,
                                          i2 => w_error_insertion_symbol,
                                          o => w_decoder_symbol);
    SYMBOL_FIFO_INST : reg_fifo
                       generic map(NUM_OF_ELEMENTS => N, 
                                   WORD_LENGTH => WORD_LENGTH)
                       port map(clk => clk,
                                rst => rst,
                                i_wr_en => r_enable_error_insertion and r_o_encoder_valid,
                                i_wr_data => r_encoder_symbol,
                                o_full => open,
                                i_rd_en => i_consume_fifo,
                                o_rd_data => w_symbol_fifo_output,
                                o_empty => w_symbol_fifo_empty);

    w_valid_error_insertion <= or w_error_insertion_symbol;
    w_counter_inc <= i_corrupt_symbol and w_valid_error_insertion and r_o_encoder_valid;
    ERROR_COUNTER_INST : up_counter
                         generic map (WORD_LENGTH => WORD_LENGTH)
                         port map (clk => clk,
                                   rst => rst or (i_o_encoder_start_codeword and i_o_encoder_valid), 
                                   i_inc => w_counter_inc,
                                   o_counter => w_error_counter);
                         
    DECODER_CHECK_ADDER_INST: rs_adder 
                              generic map (WORD_LENGTH => WORD_LENGTH)
                              port map (i1 => i_o_decoder_symbol,
                                        i2 => w_symbol_fifo_output,
                                        o => w_decoder_check_adder);

    o_i_decoder_valid <= r_o_encoder_valid;
    o_enable_encoder_valid <= w_symbol_fifo_empty or (r_enable_error_insertion and not i_o_encoder_end_codeword);
    o_fifo_empty <= w_symbol_fifo_empty;
    o_fifo_xor_decoder_symbol <= or w_decoder_check_adder;
    o_error_counter <= w_error_counter;
    o_i_decoder_symbol <= w_decoder_symbol;
end behavioral;
