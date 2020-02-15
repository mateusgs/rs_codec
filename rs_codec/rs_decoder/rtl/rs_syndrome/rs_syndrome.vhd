library IEEE;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.GENERIC_TYPES.std_logic_vector_array;

entity rs_syndrome is
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
end rs_syndrome;

architecture behavioral of rs_syndrome is
    signal w_select_feedback : std_logic;
    signal w_stall : std_logic;

    component rs_syndrome_control is
        generic (
            N : natural range 2 to 1023;
            K : natural range 1 to 1022;
            WORD_LENGTH : natural range 2 to 10
        );
        port (
            clk : in std_logic;
            rst : in std_logic;
            i_end_codeword : in std_logic;
            i_number_of_symbols_fifo_full : in std_logic;
            i_syndrome_fifo_full : in std_logic;
            i_start_codeword : in std_logic;
            i_symbol_fifo_full : in std_logic;
            i_valid : in std_logic;
            o_in_ready : out std_logic;
            o_error : out std_logic;
            o_select_feedback : out std_logic;
            o_stall : out std_logic;
            o_valid : out std_logic;
            o_wr_number_of_symbols : out std_logic;
            o_wr_symbol : out std_logic;
            o_number_of_symbols : out std_logic_vector(WORD_LENGTH-1 downto 0)
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
begin

	 assert (K < N) 
		  report "ASSERT FAILURE - K cannot be >= N" 
		  severity failure;

	 assert (TWO_TIMES_T <= 2**WORD_LENGTH-2) 
		  report "ASSERT FAILURE - TWO_TIMES_T <= 2**WORD_LENGTH-2" 
		  severity failure;
		  
    RS_SYNDROME_CONTROL_INST: rs_syndrome_control
                              generic map (N => N,
                                           K => K,
                                           WORD_LENGTH => WORD_LENGTH)
                              port map(clk => clk,
                                       rst => rst,
                                       i_end_codeword => i_end_codeword,
                                       i_number_of_symbols_fifo_full => i_number_of_symbols_fifo_full,
                                       i_syndrome_fifo_full => i_syndrome_fifo_full,
                                       i_start_codeword => i_start_codeword,
                                       i_symbol_fifo_full => i_symbol_fifo_full,
                                       i_valid => i_valid,
                                       o_in_ready => o_in_ready,
                                       o_error => o_error,
                                       o_select_feedback => w_select_feedback,
                                       o_stall => w_stall,
                                       o_valid => o_valid,
                                       o_wr_number_of_symbols => o_wr_number_of_symbols,
                                       o_wr_symbol => o_wr_symbol,
                                       o_number_of_symbols => o_number_of_symbols);

    RS_SYNDROME_UNIT_INST: rs_syndrome_unit
                           generic map(WORD_LENGTH => WORD_LENGTH, 
                                       TWO_TIMES_T => TWO_TIMES_T)
                           port map(clk => clk,
                                    rst => rst,
                                    i_select_feedback => w_select_feedback,
                                    i_stall => w_stall,
                                    i_symbol => i_symbol,
                                    o_syndrome => o_syndrome);                                      
end behavioral;

library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

entity rs_syndrome_control is
    generic (
        N : natural range 2 to 1023;
        K : natural range 1 to 1022;
        WORD_LENGTH : natural range 2 to 10
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        i_end_codeword : in std_logic;
        i_number_of_symbols_fifo_full : in std_logic;
        i_syndrome_fifo_full : in std_logic;
        i_start_codeword : in std_logic;
        i_symbol_fifo_full : in std_logic;
        i_valid : in std_logic;
        o_in_ready : out std_logic;
        o_error : out std_logic;
        o_select_feedback : out std_logic;
        o_stall : out std_logic;
        o_valid : out std_logic; 
        o_wr_number_of_symbols : out std_logic;    
        o_wr_symbol : out std_logic;
        o_number_of_symbols : out std_logic_vector(WORD_LENGTH-1 downto 0)
    );
end entity;

architecture behavioral of rs_syndrome_control is
    constant N_END_INDEX : natural := N - 1;
    constant N_MIN_OF_SYMBOLS : natural := N - K;
    type State is (WAIT_SYMBOL,
                   START_SYNDROME,
                   COMPUTE_SYNDROME,
                   END_SYNDROME,
                   REGISTER_RESULT,
                   STALL,
                   ERROR);
    signal r_state : State;
    signal r_counter : integer range 0 to N_END_INDEX;
begin
    process (clk, rst)
    begin
        if (rst = '1') then
            r_counter <= 0;
            r_state <= WAIT_SYMBOL;
        elsif rising_edge(clk) then
            case r_state is
                when WAIT_SYMBOL =>
                    r_counter <= 0;
                    if (i_valid = '1' and (i_end_codeword = '1' or i_symbol_fifo_full = '1')) then
                        r_state <= ERROR;
                    elsif (i_start_codeword = '1' and i_valid = '1') then
                        r_state <= START_SYNDROME;
                    else
                        r_state <= WAIT_SYMBOL;
                    end if;
                when START_SYNDROME | COMPUTE_SYNDROME | STALL =>
                    if (i_valid = '1' and (i_symbol_fifo_full = '1' or i_start_codeword = '1')) then
                        r_state <= ERROR;
                    else
                        if (i_valid = '0') then
                            r_state <= STALL;
                        else
                            if ((r_counter = N_END_INDEX-1 and i_end_codeword /= '1') or
                                (r_counter < N_MIN_OF_SYMBOLS-1 and i_end_codeword = '1')) then
                                r_state <= ERROR;
                            elsif (i_end_codeword = '1') then
                                r_counter <= r_counter + 1;
                                r_state <= END_SYNDROME;
                            else
                                r_counter <= r_counter + 1;
                                r_state <= COMPUTE_SYNDROME;
                            end if;
                        end if;
                    end if;
                when END_SYNDROME =>
                    if (i_end_codeword = '1' and i_valid = '1') then
                        r_state <= ERROR;
                    else
                        if (i_start_codeword = '1' and i_valid = '1' and o_in_ready = '1') then
                            r_counter <= 0;
                        end if;
                        r_state <= REGISTER_RESULT;
                    end if;
                when REGISTER_RESULT =>
                    if (i_syndrome_fifo_full = '1') then
                        r_state <= REGISTER_RESULT;
                    elsif (i_end_codeword = '1' and i_valid = '1') then
                        r_state <= ERROR;
                    elsif (i_start_codeword = '1' and i_valid = '1') then
                        if (r_counter = 0) then
                            r_state <= ERROR;
                        else
                            r_counter <= 0;
                            r_state <= START_SYNDROME;
                        end if;
                    elsif (r_counter = 0) then
                        if (i_valid = '1') then
                            r_counter <= r_counter + 1;
                            r_state <= COMPUTE_SYNDROME;
                        else
                            r_state <= STALL;
                        end if;
                    else
                        r_state <= WAIT_SYMBOL;                    
                    end if;
                when ERROR =>
                    r_counter <= 0;
                    r_state <= ERROR;
            end case;
        end if;
    end process;

    process (rst, 
             r_state,
             i_valid, 
             i_end_codeword, 
             i_start_codeword,
             i_syndrome_fifo_full, 
             r_counter)
    begin
        case r_state is
            when WAIT_SYMBOL =>
                o_error <= '0';
                o_in_ready <= '1';
                o_select_feedback <= '0';
                o_stall <= '1';
                o_valid <= '0';
                o_wr_number_of_symbols <= '0';
                o_wr_symbol <= '0';
            when START_SYNDROME =>
                o_error <= '0';
                o_in_ready <= '1';                
                o_select_feedback <= '0';
                o_stall <= '0';
                o_valid <= '0';
                o_wr_number_of_symbols <= '0';
                o_wr_symbol <= '1';
            when COMPUTE_SYNDROME =>
                o_error <= '0';
                o_in_ready <= '1'; 
                o_select_feedback <= '1';
                o_stall <= '0';
                o_valid <= '0';
                o_wr_number_of_symbols <= '0';
                o_wr_symbol <= '1';
            when END_SYNDROME =>
                o_error <= '0';
                o_in_ready <= not i_syndrome_fifo_full; 
                o_select_feedback <= '1';
                o_stall <= '0';
                o_valid <= '0';
                o_wr_number_of_symbols <= '1';
                o_wr_symbol <= '1';          
            when REGISTER_RESULT =>
                o_error <= '0';
                o_in_ready <= not i_syndrome_fifo_full; 
                o_select_feedback <= '0';
                o_stall <= i_syndrome_fifo_full;
                o_valid <= not i_syndrome_fifo_full;
                o_wr_number_of_symbols <= '0';
                if ((i_syndrome_fifo_full = '0') and (r_counter = 0)) then
                    o_wr_symbol <= '1';
                else
                    o_wr_symbol <= '0';
                end if;
            when STALL =>
                o_error <= '0';
                o_in_ready <= '1'; 
                o_select_feedback <= '1';
                o_stall <= '1';
                o_valid <= '0';
                o_wr_number_of_symbols <= '0';
                o_wr_symbol <= '0';
            when ERROR =>
                o_error <= '1';
                o_in_ready <= '0'; 
                o_select_feedback <= '0';
                o_stall <= '0';
                o_valid <= '0';
                o_wr_number_of_symbols <= '0';
                o_wr_symbol <= '0';
        end case;
    end process;
    o_number_of_symbols <= std_logic_vector(to_unsigned(r_counter, WORD_LENGTH));
end behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.GENERIC_TYPES.std_logic_vector_array;
use work.RS_COMPONENTS.rs_syndrome_subunit;

entity rs_syndrome_unit is
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
end rs_syndrome_unit;

architecture behavioral of rs_syndrome_unit is
begin
    GEN_RS_SYNDROME_UNIT: for I in 0 to TWO_TIMES_T-1 generate
        RS_SYNDROME_SUBUNIT_INST: rs_syndrome_subunit
                                  generic map(WORD_LENGTH => WORD_LENGTH, 
                                              I => I)
                                  port map(clk => clk,
                                           rst => rst,
                                           i_select_feedback => i_select_feedback,
                                           i_stall => i_stall,
                                           i_symbol => i_symbol,
                                           o_syndrome => o_syndrome(I));
    end generate GEN_RS_SYNDROME_UNIT;
end behavioral;
