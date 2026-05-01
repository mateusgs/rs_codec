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
        procedure send_symbol(symbol_value : natural;
                              start_codeword : std_logic;
                              end_codeword : std_logic) is
        begin
            wait until falling_edge(clk);

            i_symbol <= std_logic_vector(to_unsigned(symbol_value, WORD_LENGTH));
            i_start_codeword <= start_codeword;
            i_end_codeword <= end_codeword;
            i_valid <= '1';

            wait until rising_edge(clk);

            i_start_codeword <= '0';
            i_end_codeword <= '0';
            i_valid <= '0';
        end procedure;

        procedure idle_cycles(cycles : natural) is
        begin
            for I in 1 to cycles loop
                wait until falling_edge(clk);
                i_start_codeword <= '0';
                i_end_codeword <= '0';
                i_valid <= '0';
                wait until rising_edge(clk);
            end loop;
        end procedure;
    begin
        rst <= '1';
        i_start_codeword <= '0';
        i_end_codeword <= '0';
        i_valid <= '0';
        i_symbol <= "0000";
        wait for CLK_PERIOD*5;
        wait until falling_edge(clk);
        rst <= '0';

        send_symbol(1, '1', '0');
        send_symbol(2, '0', '0');
        send_symbol(3, '0', '0');
        send_symbol(4, '0', '0');
        send_symbol(5, '0', '0');
        send_symbol(6, '0', '0');
        send_symbol(7, '0', '0');
        send_symbol(8, '0', '0');
        send_symbol(9, '0', '0');
        send_symbol(10, '0', '0');
        send_symbol(11, '0', '1');

        idle_cycles(4);

        send_symbol(1, '1', '0');
        idle_cycles(5);
        send_symbol(2, '0', '0');
        send_symbol(3, '0', '0');
        send_symbol(4, '0', '0');
        send_symbol(5, '0', '0');
        idle_cycles(1);
        send_symbol(6, '0', '0');
        send_symbol(7, '0', '0');
        send_symbol(8, '0', '0');
        send_symbol(9, '0', '0');
        send_symbol(10, '0', '0');
        idle_cycles(6);
        send_symbol(11, '0', '1');

        idle_cycles(6);
        wait;
    end process;
end behavioral;
