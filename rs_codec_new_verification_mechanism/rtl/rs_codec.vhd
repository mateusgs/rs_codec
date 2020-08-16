library IEEE;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.RS_TYPES.all;
use work.RS_FUNCTIONS.get_word_length_from_rs_gf;
use WORK.RS_COMPONENTS.rs_decoder;
use WORK.RS_COMPONENTS.rs_encoder;

entity rs_codec is
	  generic (
            N : natural range 2 to 1023;
		    K : natural range 1 to 1022;
            RS_GF : RSGFSize := RS_GF_NONE;
            MODE : boolean := false; -- ENCODER=false and DECODER=true
            TEST_MODE : boolean := false
	  );
	  port (
			clk : in std_logic;
			rst : in std_logic;
			i_end_codeword : in std_logic;
			i_start_codeword : in std_logic;
            i_valid : in std_logic;
            i_consume : in std_logic;
			i_symbol : in std_logic_vector(get_word_length_from_rs_gf(N, RS_GF)-1 downto 0);				
			o_in_ready : out std_logic;
			o_end_codeword : out std_logic;
			o_start_codeword : out std_logic;
			o_valid : out std_logic;
			o_error : out std_logic;
			o_symbol : out std_logic_vector(get_word_length_from_rs_gf(N, RS_GF)-1 downto 0)
	  );
end rs_codec;

architecture behavioral of rs_codec is
begin
    GEN_ENCODER: if MODE = false generate
        ENCODER_INST : rs_encoder
                       generic map(N => N, 
                                   K => K,
                                   RS_GF => RS_GF,
                                   TEST_MODE => TEST_MODE)
                       port map(clk => clk,
                                rst => rst,
                                i_end_codeword => i_end_codeword,
                                i_start_codeword => i_start_codeword,
                                i_valid => i_valid,
                                i_consume => i_consume,
                                i_symbol => i_symbol,
                                o_start_codeword => o_start_codeword,
                                o_end_codeword => o_end_codeword,
                                o_error => o_error,
                                o_in_ready => o_in_ready,
                                o_valid => o_valid,
                                o_symbol => o_symbol);
    end generate;
    GEN_DECODER: if MODE = true generate
        DECODER_INST : rs_decoder
                       generic map(N => N, 
                                   K => K,
                                   RS_GF => RS_GF,
                                   OUTPUT_PARITY_SYMBOLS => false,
                                   TEST_MODE => TEST_MODE)
                       port map(clk => clk,
                                rst => rst,
                                i_end_codeword => i_end_codeword,
                                i_start_codeword => i_start_codeword,
                                i_valid => i_valid,
                                i_symbol => i_symbol,
                                i_consume => i_consume,
                                o_start_codeword => o_start_codeword,
                                o_end_codeword => o_end_codeword,
                                o_error => o_error,
                                o_in_ready => o_in_ready,
                                o_valid => o_valid,
                                o_symbol => o_symbol);    
    end generate;
end behavioral;
