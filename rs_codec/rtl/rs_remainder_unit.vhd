library IEEE;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.GENERIC_COMPONENTS.async_dff;
use work.RS_COMPONENTS.rs_adder;
use work.RS_COMPONENTS.rs_multiplier;

entity rs_remainder_unit is
	generic (
        WORD_LENGTH : natural range 2 to 10;
        MULT_CONSTANT : natural range 0 to 1023;
        TEST_MODE : boolean := false
    );
	port (
        clk : in std_logic;
        rst : in std_logic;
        i_stall : in std_logic;
    	i_symbol : in std_logic_vector(WORD_LENGTH-1 downto 0);
        i_upper_lv : in std_logic_vector(WORD_LENGTH-1 downto 0);
        o : out std_logic_vector(WORD_LENGTH-1 downto 0)
    );
end rs_remainder_unit;

architecture behavioral of rs_remainder_unit is
    --output MULTIPLIER signals
    signal w_multiplier : std_logic_vector(WORD_LENGTH-1 downto 0);
    --output ADDER signals
    signal w_adder : std_logic_vector(WORD_LENGTH-1 downto 0);

    signal w_dff_selector : std_logic_vector(WORD_LENGTH-1 downto 0);
	 
	 signal w_o : std_logic_vector(WORD_LENGTH-1 downto 0);
begin
	 assert (MULT_CONSTANT <= 2**WORD_LENGTH-1) 
		  report "ASSERT FAILURE - T <= 2**WORD_LENGTH-1" 
		  severity failure;
		  
    MULTIPLIER: rs_multiplier
                generic map (WORD_LENGTH => WORD_LENGTH,
                             MULT_CONSTANT => MULT_CONSTANT,
                             TEST_MODE => TEST_MODE)
                port map (i => i_symbol, 
                          o => w_multiplier);
    ADDER: rs_adder 
           generic map (WORD_LENGTH => WORD_LENGTH,
                        TEST_MODE => TEST_MODE)
           port map (i1 => w_multiplier,
                     i2 => i_upper_lv,
                     o => w_adder);	

    w_dff_selector <= w_o when (i_stall = '1') else w_adder;
    
    OUTPUT_ASYNC_DFF: async_dff
                      generic map (WORD_LENGTH => WORD_LENGTH) 
                      port map (clk => clk,
                                rst => rst,
                                d => w_dff_selector,
                                q => w_o);
	
	o <= w_o;
	
end behavioral;
