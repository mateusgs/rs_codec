library IEEE;
use IEEE.MATH_REAL.ceil;
use IEEE.MATH_REAL.log2;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
library WORK;
use WORK.RS_COMPONENTS.rs_encoder;

entity tb_rs_encoder is
end tb_rs_encoder;

architecture behavioral of tb_rs_encoder is
    constant N : Integer := 15;
    constant K : Integer := 11;
    constant WORD_LENGTH : natural := integer(ceil(log2(real(N+ 1))));
    constant CLK_PERIOD : time := 10 ns;

    signal clk : std_logic;
    signal rst : std_logic;
    signal i_start_codeword : std_logic;
    signal i_end_codeword : std_logic;
    signal i_valid : std_logic;
    signal i_symbol : std_logic_vector(WORD_LENGTH-1 downto 0);
    signal o_start_codeword : std_logic;
    signal o_end_codeword : std_logic;
    signal o_error : std_logic;
    signal o_in_ready : std_logic;
    signal o_valid : std_logic;
    signal o_symbol : std_logic_vector(WORD_LENGTH-1 downto 0);
begin
    UUT: rs_encoder
         generic map(N => N, 
                     K => K)
         port map(clk => clk,
                  rst => rst,
                  i_end_codeword => i_end_codeword,
                  i_start_codeword => i_start_codeword,
                  i_valid => i_valid,
                  i_consume => '1',
                  i_symbol => i_symbol,
                  o_start_codeword => o_start_codeword,
                  o_end_codeword => o_end_codeword,
                  o_error => o_error,
                  o_in_ready => o_in_ready,
                  o_valid => o_valid,
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
        i_start_codeword <= '1';
        i_valid <= '1';
        i_symbol <= "0001";
        wait for CLK_PERIOD;
        i_start_codeword <= '0';
        i_symbol <= "0010";
        wait for CLK_PERIOD;
        i_symbol <= "0011";
        wait for CLK_PERIOD;
        i_symbol <= "0100";
        wait for CLK_PERIOD;
        i_symbol <= "0101";
        wait for CLK_PERIOD;
        i_symbol <= "0110";
        wait for CLK_PERIOD;
        i_symbol <= "0111";
        wait for CLK_PERIOD;
        i_symbol <= "1000";
        wait for CLK_PERIOD;
        i_symbol <= "1001";
        wait for CLK_PERIOD;
        i_symbol <= "1010";
        wait for CLK_PERIOD;
        i_end_codeword <= '1';
        i_symbol <= "1011";
        wait for CLK_PERIOD;
        i_end_codeword <= '0';
        i_valid <= '0';
        i_symbol <= "1011";
        wait for CLK_PERIOD*4;
        i_start_codeword <= '1';
        i_valid <= '1';
        i_symbol <= "0001";
        wait for CLK_PERIOD;
        i_valid <= '0';
        i_symbol <= "0001";
        wait for CLK_PERIOD*5;
        i_valid <= '1';
        i_start_codeword <= '0';
        i_symbol <= "0010";
        wait for CLK_PERIOD;
        i_symbol <= "0011";
        wait for CLK_PERIOD;
        i_symbol <= "0100";
        wait for CLK_PERIOD;
        i_symbol <= "0101";
        wait for CLK_PERIOD;
        i_valid <= '0';
        i_symbol <= "0101";
        wait for CLK_PERIOD;
        i_valid <= '1';
        i_symbol <= "0110";
        wait for CLK_PERIOD;
        i_symbol <= "0111";
        wait for CLK_PERIOD;
        i_symbol <= "1000";
        wait for CLK_PERIOD;
        i_symbol <= "1001";
        wait for CLK_PERIOD;
        i_symbol <= "1010";
        wait for CLK_PERIOD;
        i_end_codeword <= '1';
        i_valid <= '0';
        i_symbol <= "1011";
        wait for CLK_PERIOD;
        i_end_codeword <= '0';
        wait for CLK_PERIOD*5;
        i_end_codeword <= '1';
        i_valid <= '1';
        i_symbol <= "1011";
        wait for CLK_PERIOD;
        i_valid <= '1';
        i_end_codeword <= '0';
        wait for 6*CLK_PERIOD;
    end process;
end behavioral;