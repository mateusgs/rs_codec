library IEEE;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.GENERIC_COMPONENTS.async_dff;
use work.RS_COMPONENTS.rs_adder;
use work.RS_COMPONENTS.rs_multiplier;
use work.RS_FUNCTIONS.get_pow;

entity rs_syndrome_subunit is
    generic (
        WORD_LENGTH : natural range 2 to 10;
        I : natural range 0 to 1021;
        TEST_MODE : boolean := false
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        i_select_feedback : in std_logic;
        i_stall : in std_logic;
        i_symbol : in std_logic_vector(WORD_LENGTH-1 downto 0);
        o_syndrome : out std_logic_vector(WORD_LENGTH-1 downto 0)
    );
end rs_syndrome_subunit;

architecture behavioral of rs_syndrome_subunit is

    signal w_end_adder_selector : std_logic_vector(WORD_LENGTH-1 downto 0);
    --output END_ADDER signals
    signal w_feedback : std_logic_vector(WORD_LENGTH-1 downto 0);

    --output MULTIPLIER signals
    signal w_multiplier : std_logic_vector(WORD_LENGTH-1 downto 0);

    signal w_d_flop_loop_selector : std_logic_vector(WORD_LENGTH-1 downto 0);
    --output LOOP_ASYNC_DFF signals
    signal r_dff : std_logic_vector(WORD_LENGTH-1 downto 0);

    signal w_d_flop_output_selector : std_logic_vector(WORD_LENGTH-1 downto 0);
    --output OUTPUT_ASYNC_DFF signals
    signal r_syndrome : std_logic_vector(WORD_LENGTH-1 downto 0);
begin
	 assert (I <= 2**WORD_LENGTH-3) 
		  report "ASSERT FAILURE - I <= 2**WORD_LENGTH-3 is not valid" 
		  severity failure;
		  
    w_end_adder_selector <=  r_dff when (i_select_feedback = '1') 
                             else (others => '0');
    END_ADDER: rs_adder 
               generic map (WORD_LENGTH => WORD_LENGTH,
                            TEST_MODE => TEST_MODE)
               port map (i1 => w_end_adder_selector,
                         i2 => i_symbol,
                         o => w_feedback);
    MULTIPLIER: rs_multiplier
                generic map (WORD_LENGTH => WORD_LENGTH, 
                             MULT_CONSTANT => get_pow(WORD_LENGTH, I),
                             TEST_MODE => TEST_MODE)
                port map (i => w_feedback, 
                          o => w_multiplier);
    w_d_flop_loop_selector <=  r_dff when (i_stall = '1') 
                                     else w_multiplier;
    LOOP_ASYNC_DFF: async_dff
                    generic map (WORD_LENGTH => WORD_LENGTH) 
                    port map (clk => clk,
                              rst => rst,
                              d => w_d_flop_loop_selector,
                              q => r_dff);
    w_d_flop_output_selector <= r_syndrome when (i_stall = '1')
                                           else w_feedback; 
    OUTPUT_ASYNC_DFF: async_dff
                      generic map (WORD_LENGTH => WORD_LENGTH) 
                      port map (clk => clk,
                                rst => rst,
                                d => w_d_flop_output_selector,
                                q => r_syndrome);
    o_syndrome <= r_syndrome;
end behavioral;
