--TODO
--# ** Fatal: (vsim-3421) Value -1 for o_num_shift is out of range 0 to 15.
--#    Time: 320 ns  Iteration: 1  Process: /tb_rs_decoder/UUT/rs_EUCLIDEAN_INST/EUCLIDEAN_CONTROL/line__402 File: C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_encode_decoder/rs_decoder/rs_euclidean/rs_euclidean.vhd
--# Fatal error in Process line__402 at C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_encode_decoder/rs_decoder/rs_euclidean/rs_euclidean.vhd line 430
--# 
--# HDL call sequence:

library IEEE;
use IEEE.MATH_REAL.ceil;
use IEEE.MATH_REAL.log2;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
library WORK;
use work.GENERIC_TYPES.std_logic_vector_array;
use WORK.RS_COMPONENTS.rs_berlekamp_massey;

entity tb_rs_berlekamp_massey is
end tb_rs_berlekamp_massey;

architecture behavioral of tb_rs_berlekamp_massey is
    constant CLK_PERIOD : time := 10 ns;
    constant WORD_LENGTH : natural := 4;
    constant TWO_TIMES_T : natural := 4;
    --constant WORD_LENGTH : natural := 8;
    --constant TWO_TIMES_T : natural := 16;
    constant T : natural := integer(ceil(real(TWO_TIMES_T/2)));

    signal clk : std_logic;
    signal rst : std_logic;
    signal i_fifo_chien_forney_full : std_logic;
    signal i_syndrome_ready : std_logic;
    signal i_syndrome : std_logic_vector_array(TWO_TIMES_T-1 downto 0)(WORD_LENGTH-1 downto 0);
    signal o_rd_syndrome : std_logic;
    signal o_berlekamp_massey_ready : std_logic;
    signal o_locator_poly : std_logic_vector_array(T-1 downto 0)(WORD_LENGTH-1 downto 0);
    signal o_value_poly : std_logic_vector_array(T-1 downto 0)(WORD_LENGTH-1 downto 0);
begin
--Reproducing example in:
--Clarke, C. K. P. "Reed-Solomon error correction. White Paper WHP 031." 
--British Broadcasting Corporation Research and Development (2002).
--RS(15,11) WORD_LENGTH=15 and T=2

    UUT: rs_berlekamp_massey
         generic map(WORD_LENGTH => WORD_LENGTH, 
                     TWO_TIMES_T => TWO_TIMES_T,
                     T => T)
         port map(clk => clk,
                  rst => rst,
                  i_fifo_chien_forney_full => i_fifo_chien_forney_full,
                  i_syndrome_ready => i_syndrome_ready,
                  i_syndrome => i_syndrome,
                  o_rd_syndrome => o_rd_syndrome, 
                  o_berlekamp_massey_ready => o_berlekamp_massey_ready,
                  o_locator_poly => o_locator_poly,
                  o_value_poly => o_value_poly);

    CLK_PROCESS : process
    begin
        clk <= '1';
        wait for CLK_PERIOD/2;
        clk <= '0';
        wait for CLK_PERIOD/2;
    end process;

    STIM_PROCESS : process
    begin
        rst <= '0';
        i_fifo_chien_forney_full <= '0';
        i_syndrome_ready <= '0';
        --i_syndrome <=  (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00");
        i_syndrome <=  (x"0", x"0", x"0", x"0");
        wait for CLK_PERIOD*5;
        rst <= '1';
        wait for CLK_PERIOD*5;
        rst <= '0';
        i_syndrome_ready <= '1';
        --i_syndrome <=  (x"AA", x"76", x"92", x"08", x"D7", x"8C", x"20", x"8F", x"27", x"33", x"DE", x"A2", x"02", x"E7", x"3D", x"21");
        --i_syndrome <=  (x"C", x"4", x"3", x"F");
        --i_syndrome <=  (x"F", x"3", x"1", x"C");
        i_syndrome <=  (x"A", x"F", x"6", x"2");
        wait for CLK_PERIOD*40;
        --rst <= '0';
        --wait for CLK_PERIOD*5;
        --i_symbol <= "0001";
        --i_start_codeword <= '1';
        --i_valid <= '1';
        --wait for CLK_PERIOD;
        --i_symbol <= "0010";
        --i_start_codeword <= '0';
        
    end process;
end behavioral;