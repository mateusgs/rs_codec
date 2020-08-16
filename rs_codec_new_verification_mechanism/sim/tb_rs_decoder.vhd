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
use WORK.RS_COMPONENTS.rs_decoder;

entity tb_rs_decoder is
end tb_rs_decoder;

architecture behavioral of tb_rs_decoder is
    constant CLK_PERIOD : time := 10 ns;
    constant N : natural := 15;
    constant K : natural := 11;
    constant WORD_LENGTH : natural := integer(ceil(log2(real(N+ 1))));

    signal clk : std_logic;
    signal rst : std_logic;
    signal i_end_codeword : std_logic;
    signal i_start_codeword : std_logic;
    signal i_valid: std_logic;
    signal i_symbol : std_logic_vector(WORD_LENGTH-1 downto 0);
    signal o_in_ready : std_logic;
    signal o_end_codeword : std_logic;
    signal o_start_codeword : std_logic;
    signal o_valid : std_logic;
    signal o_error : std_logic;
    signal o_symbol : std_logic_vector(WORD_LENGTH-1 downto 0);
begin

--Reproducing example in:
--Clarke, C. K. P. "Reed-Solomon error correction. White Paper WHP 031." 
--British Broadcasting Corporation Research and Development (2002).
--RS(15,11) WORD_LENGTH=15 and T=2

    UUT: rs_decoder
         generic map(N => N, 
                     K => K)
         port map(clk => clk,
                  rst => rst,
                  i_end_codeword => i_end_codeword,
                  i_start_codeword => i_start_codeword,
                  i_valid => i_valid,
                  i_symbol => i_symbol,
                  o_in_ready => o_in_ready,
                  o_end_codeword => o_end_codeword,
                  o_start_codeword => o_start_codeword,
                  o_valid => o_valid,
                  o_error => o_error,
                  o_symbol => o_symbol);

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
        i_start_codeword <= '0';
        i_end_codeword <= '0';
        i_valid <= '0';
        i_symbol <= "0000";
        wait for CLK_PERIOD*5;
        rst <= '1';
        wait for CLK_PERIOD*5;
        rst <= '0';
        wait for CLK_PERIOD*5;
        i_symbol <= "0001";
        i_start_codeword <= '1';
        i_valid <= '1';
        wait for CLK_PERIOD;
        i_symbol <= "0010";
        i_start_codeword <= '0';
        wait for CLK_PERIOD;
        i_symbol <= "0011";
        wait for CLK_PERIOD;
        i_symbol <= "0100";
        wait for CLK_PERIOD;
        i_symbol <= "0101";
        wait for CLK_PERIOD;
        i_symbol <= "1011";
        wait for CLK_PERIOD;
        i_symbol <= "0111";
        wait for CLK_PERIOD;
        i_symbol <= "1000";
        wait for CLK_PERIOD;
        i_symbol <= "1001";
        wait for CLK_PERIOD;
        i_symbol <= "1010";
        wait for CLK_PERIOD;
        i_symbol <= "1011";
        wait for CLK_PERIOD;
        i_symbol <= "0011";
        wait for CLK_PERIOD;
        i_symbol <= "0001";
        wait for CLK_PERIOD;
        i_symbol <= "1100";
        wait for CLK_PERIOD;
        i_end_codeword <= '1';
        i_symbol <= "1100";
        wait for CLK_PERIOD;
        i_symbol <= "0001";
        i_end_codeword <= '0';
        i_start_codeword <= '1';
        wait for CLK_PERIOD;
        i_symbol <= "0010";
        i_start_codeword <= '0';
        wait for CLK_PERIOD;
        i_symbol <= "0011";
        wait for CLK_PERIOD;
        i_symbol <= "0100";
        wait for CLK_PERIOD;
        i_symbol <= "0101";
        wait for CLK_PERIOD;
        i_symbol <= "1011";
        wait for CLK_PERIOD;
        i_symbol <= "0111";
        wait for CLK_PERIOD;
        i_symbol <= "1000";
        wait for CLK_PERIOD;
        i_symbol <= "1001";
        wait for CLK_PERIOD;
        i_symbol <= "1010";
        wait for CLK_PERIOD;
        i_symbol <= "1011";
        wait for CLK_PERIOD;
        i_symbol <= "0011";
        wait for CLK_PERIOD;
        i_symbol <= "0001";
        wait for CLK_PERIOD;
        i_symbol <= "1100";
        wait for CLK_PERIOD;
        i_symbol <= "1100";
        i_end_codeword <= '1';
        wait for CLK_PERIOD;
        i_symbol <= "0001";
        i_end_codeword <= '0';
        wait for CLK_PERIOD*5;
        i_symbol <= "0001";
        i_end_codeword <= '0';
        i_start_codeword <= '1';
        wait for CLK_PERIOD;
        i_symbol <= "0010";
        i_start_codeword <= '0';
        i_valid <= '0';
        wait for 5*CLK_PERIOD;
        i_symbol <= "0010";
        i_valid <= '1';
        wait for CLK_PERIOD;
        i_symbol <= "0011";
        wait for CLK_PERIOD;
        i_symbol <= "0100";
        wait for CLK_PERIOD;
        i_symbol <= "0101";
        wait for CLK_PERIOD;
        i_symbol <= "1011";
        i_valid <= '0';
        wait for 5*CLK_PERIOD;
        i_symbol <= "1011";
        i_valid <= '1';
        wait for CLK_PERIOD;
        i_symbol <= "0111";
        wait for CLK_PERIOD;
        i_symbol <= "1000";
        wait for CLK_PERIOD;
        i_symbol <= "1001";
        wait for CLK_PERIOD;
        i_symbol <= "1010";
        wait for CLK_PERIOD;
        i_symbol <= "1011";
        wait for CLK_PERIOD;
        i_symbol <= "0011";
        wait for CLK_PERIOD;
        i_symbol <= "0001";
        wait for CLK_PERIOD;
        i_symbol <= "1100";
        wait for CLK_PERIOD;
        i_symbol <= "1100";
        i_end_codeword <= '1';
        i_valid <= '0';
        wait for 5*CLK_PERIOD;
        i_symbol <= "1100";
        i_end_codeword <= '1';
        i_valid <= '1';
        wait for CLK_PERIOD;
        i_symbol <= "1100";
        i_end_codeword <= '0';
        wait for CLK_PERIOD*5;
    end process;
end behavioral;
