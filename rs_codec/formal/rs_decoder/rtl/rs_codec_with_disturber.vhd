library IEEE;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.RS_TYPES.RSGFSize;
use work.RS_FUNCTIONS.get_word_length_from_rs_gf;
use work.RS_COMPONENTS.rs_encoder;
use work.RS_COMPONENTS.rs_decoder;
use work.RS_COMPONENTS.rs_disturber;

entity rs_codec_with_disturber is
    generic (
        N : natural range 2 to 1023;
		K : natural range 1 to N-1;
        RS_GF : RSGFSize := RS_GF_NONE;
		WORD_LENGTH : natural := get_word_length_from_rs_gf(N, RS_GF)
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
	i_consume : in std_logic;
        --rs_encoder inputs
        i_encoder_end_codeword : in std_logic;
        i_encoder_start_codeword : in std_logic;
        i_encoder_valid : in std_logic;
        i_encoder_symbol : in std_logic_vector(WORD_LENGTH-1 downto 0);

        --rs_disturber inputs
        i_corrupt_symbol : in std_logic;
        i_error_symbol : in std_logic_vector(WORD_LENGTH-1 downto 0);

        --rs_disturber outputs
        o_fifo_empty : out std_logic;
        o_fifo_xor_decoder_symbol : out std_logic;
        o_error_counter : out std_logic_vector(WORD_LENGTH-1 downto 0);

        --rs_decoder outputs
        o_start_codeword : out std_logic;
        o_end_codeword : out std_logic;
        o_valid : out std_logic
    );
end rs_codec_with_disturber;

architecture behavioral of rs_codec_with_disturber is

    --RS_ENCODER_INST outputs
    signal w_encoder_start_codeword : std_logic;
    signal w_encoder_end_codeword : std_logic;
    signal w_encoder_valid : std_logic;
    signal w_encoder_symbol : std_logic_vector(WORD_LENGTH-1 downto 0);

    --RS_DISTURBER_INST outputs
    signal w_enable_encoder_valid : std_logic;
    signal w_i_decoder_valid : std_logic;
    signal w_i_decoder_start_codeword : std_logic;
    signal w_i_decoder_end_codeword : std_logic;
    signal w_i_decoder_symbol : std_logic_vector(WORD_LENGTH-1 downto 0);

    --DUT outputs
    signal w_decoder_symbol : std_logic_vector(WORD_LENGTH-1 downto 0);

begin
    RS_ENCODER_INST: rs_encoder
                     generic map(N => N, 
                                 K => K,
                                 RS_GF => RS_GF)
                     port map(clk => clk,
                              rst => rst,
                              i_end_codeword => i_encoder_end_codeword,
                              i_start_codeword => i_encoder_start_codeword,
                              i_valid => i_encoder_valid and w_enable_encoder_valid,
			      i_consume => i_consume,
                              i_symbol => i_encoder_symbol,
                              o_start_codeword => w_encoder_start_codeword,
                              o_end_codeword => w_encoder_end_codeword,
                              o_error => open,
                              o_in_ready => open,
                              o_valid => w_encoder_valid,
                              o_symbol => w_encoder_symbol);

    RS_DISTURBER_INST : rs_disturber
                        generic map(N => N,
                                    RS_GF => RS_GF)
                        port map(clk => clk,
                                 rst => rst,
                                 i_corrupt_symbol => i_corrupt_symbol,
                                 i_error_symbol => i_error_symbol,
                                 i_o_encoder_start_codeword => w_encoder_start_codeword,
                                 i_o_encoder_end_codeword => w_encoder_end_codeword,
                                 i_o_encoder_valid => w_encoder_valid,
                                 i_o_encoder_symbol => w_encoder_symbol,
                                 i_consume_fifo => o_valid,
                                 i_o_decoder_symbol => w_decoder_symbol,
                                 o_i_decoder_valid => w_i_decoder_valid,
                                 o_i_decoder_start_codeword => w_i_decoder_start_codeword,
                                 o_i_decoder_end_codeword => w_i_decoder_end_codeword,
                                 o_enable_encoder_valid => w_enable_encoder_valid,
                                 o_fifo_empty => o_fifo_empty,
                                 o_fifo_xor_decoder_symbol => o_fifo_xor_decoder_symbol,
                                 o_error_counter => o_error_counter,
                                 o_i_decoder_symbol => w_i_decoder_symbol);
    DUT: rs_decoder
         generic map(N => N, 
                     K => K,
                     RS_GF => RS_GF)
         port map(clk => clk,
                  rst => rst,
                  i_end_codeword => w_i_decoder_end_codeword,
                  i_start_codeword => w_i_decoder_start_codeword,
                  i_valid => w_i_decoder_valid,
		  i_consume => i_consume,
                  i_symbol => w_i_decoder_symbol,
                  o_in_ready => open,
                  o_end_codeword => o_end_codeword,
                  o_start_codeword => o_start_codeword,
                  o_valid => o_valid,
                  o_error => open,
                  o_symbol => w_decoder_symbol);
end behavioral;
