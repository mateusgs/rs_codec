library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.MATH_REAL.ceil;
use IEEE.MATH_REAL.log2;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.GENERIC_COMPONENTS.no_rst_dff;
use work.GENERIC_COMPONENTS.async_dff_gen_rst;
use work.GENERIC_FUNCTIONS.init_flop_value;
use work.GENERIC_TYPES.std_logic_vector_array;
use work.RS_COMPONENTS.rs_adder;
use work.RS_COMPONENTS.rs_inverse;
use work.RS_COMPONENTS.rs_full_multiplier;
use work.RS_COMPONENTS.rs_shitfer_zero_significant_positions;
use work.RS_FUNCTIONS.get_szs;

entity rs_euclidean_division_unit is
    generic (
	    WORD_LENGTH : natural range 2 to 10;
        TWO_TIMES_T : natural range 1 to 1022
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        i_sync_rst : in std_logic;
        i_swap : in std_logic;
        i_syndrome : in std_logic_vector_array(TWO_TIMES_T-1 downto 0)(WORD_LENGTH-1 downto 0);
        o_div_shift_zeros : out integer range 0 to 2**get_szs(TWO_TIMES_T)-1;
        o_rem_shift_zeros : out integer range 0 to 2**get_szs(TWO_TIMES_T)-1;
        o_quocient : out std_logic_vector(WORD_LENGTH-1 downto 0);
        o_forney : out std_logic_vector_array(TWO_TIMES_T-3 downto 0)(WORD_LENGTH-1 downto 0)
    );
end rs_euclidean_division_unit;

architecture behavior of rs_euclidean_division_unit is
    constant SHIFTED_ZEROS_SIZE : natural := get_szs(TWO_TIMES_T);
    --output ZERO_DIV_SHIFTER signals
    signal w_zero_div_shifter : std_logic_vector_array(TWO_TIMES_T-1 downto 0)(WORD_LENGTH-1 downto 0);

    --output ZERO_REM_SHIFTER signals
    signal w_zero_rem_shifter : std_logic_vector_array(TWO_TIMES_T-1 downto 0)(WORD_LENGTH-1 downto 0);
    signal w_flop_dividend_input : std_logic_vector_array(TWO_TIMES_T-1 downto 0)(WORD_LENGTH-1 downto 0);        

    --output GEN_rs_DIV_UNIT signals
    signal w_selector_divisor : std_logic_vector_array(TWO_TIMES_T-1 downto 0)(WORD_LENGTH-1 downto 0);        

    --output D_FLOP_DIVISOR signals
    signal r_divisor : std_logic_vector_array(TWO_TIMES_T-1 downto 0)(WORD_LENGTH-1 downto 0);

    --output GEN_rs_MULT signals
    signal w_inverter : std_logic_vector(WORD_LENGTH-1 downto 0);

    --output FULL_MULT signals
    signal w_mult : std_logic_vector_array(TWO_TIMES_T-2 downto 0)(WORD_LENGTH-1 downto 0);

    --output GEN_rs_DIVIDEND_MUX signals
    signal w_selector_dividend : std_logic_vector_array(TWO_TIMES_T-1 downto 0)(WORD_LENGTH-1 downto 0);    
            
    --output GEN_rs_DIVIDEND_MUX signals
    signal r_dividend : std_logic_vector_array(TWO_TIMES_T-1 downto 0)(WORD_LENGTH-1 downto 0);

    --output ADDER signals
    signal w_adder : std_logic_vector_array(TWO_TIMES_T-2 downto 0)(WORD_LENGTH-1 downto 0);       
    
begin
    assert (TWO_TIMES_T <= 2**WORD_LENGTH-2) 
		report "ASSERT FAILURE - T <= 2**WORD_LENGTH-2" 
		severity failure;

    ZERO_DIV_SHIFTER: rs_shitfer_zero_significant_positions
                      generic map (WORD_LENGTH => WORD_LENGTH, 
                                   TWO_TIMES_T => TWO_TIMES_T)
                      port map (i_shifter => w_selector_divisor,
                                o_num_shift_zeros => o_div_shift_zeros,
                                o_shifter => w_zero_div_shifter);

    ZERO_REM_SHIFTER: rs_shitfer_zero_significant_positions
                      generic map (WORD_LENGTH => WORD_LENGTH, 
                                   TWO_TIMES_T => TWO_TIMES_T)
                      port map (i_shifter => w_selector_dividend,
                                o_num_shift_zeros => o_rem_shift_zeros,
                                o_shifter => w_zero_rem_shifter);

    GEN_rs_DIV_UNIT: for I in 0 to TWO_TIMES_T-1 generate
    begin
	    GEN_rs_DIVISOR_MUX: if I = 0 generate
            w_selector_divisor(I) <= i_syndrome(I) when rst or i_sync_rst 
                                                   else (others=>'0') 
                                                   when i_swap 
                                                   else r_divisor(I); 
        else generate
             w_selector_divisor(I) <= i_syndrome(I) when rst or i_sync_rst 
                                                    else w_adder(I-1) 
                                                    when i_swap 
                                                    else r_divisor(I); 
        end generate;

	    D_FLOP_DIVISOR: no_rst_dff
                        generic map (WORD_LENGTH => WORD_LENGTH) 
                        port map (clk => clk,
                                  d => w_zero_div_shifter(I),
                                  q => r_divisor(I));

	    GEN_rs_MULT: if I = TWO_TIMES_T-1 generate
            INVERTER: rs_inverse
                      generic map(WORD_LENGTH)
                      port map(i => r_divisor(I),
                               o => w_inverter);
            FULL_MULT: rs_full_multiplier
                       generic map(WORD_LENGTH)
                       port map(i1 => w_inverter,
                                i2 => r_dividend(I),
                                o => o_quocient);
	    else generate
            FULL_MULT: rs_full_multiplier
                       generic map(WORD_LENGTH => WORD_LENGTH)
                       port map(i1 => o_quocient,
                                i2 => r_divisor(I),
                                o => w_mult(I));
	    end generate;

	    GEN_rs_DIVIDEND_MUX: if I = 0 generate
            w_selector_dividend(I) <= r_dividend(I) when rst or i_sync_rst 
                                                    else r_divisor(I) 
                                                    when i_swap 
                                                    else (others=>'0'); 
        else generate
            w_selector_dividend(I) <= r_dividend(I) when rst or i_sync_rst 
                                                    else r_divisor(I) 
                                                    when i_swap 
                                                    else w_adder(I-1);
        end generate;

        w_flop_dividend_input(I) <=  init_flop_value(I, WORD_LENGTH, TWO_TIMES_T-1) when i_sync_rst else w_zero_rem_shifter(I);
        D_FLOP_DIVIDEND: async_dff_gen_rst 
                         generic map (WORD_LENGTH => WORD_LENGTH, 
                                      RESET_VALUE => init_flop_value(I, WORD_LENGTH, TWO_TIMES_T-1)) 
                         port map (clk => clk,
                                   rst => rst,
                                   d => w_flop_dividend_input(I),
                                   q => r_dividend(I));

	    GEN_rs_ADDER: if I /= TWO_TIMES_T-1 generate
	        ADDER: rs_adder
                   generic map(WORD_LENGTH => WORD_LENGTH)
                   port map(i1 => r_dividend(I),
                            i2 => w_mult(I),
                            o => w_adder(I));
	    end generate;
    end generate GEN_rs_DIV_UNIT;
    o_forney <= w_adder(TWO_TIMES_T-2 downto 1);
end behavior;