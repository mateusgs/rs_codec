library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.MATH_REAL.ceil;
use IEEE.MATH_REAL.log2;
library work;
use work.GENERIC_COMPONENTS.async_dff_gen_rst;
use work.GENERIC_FUNCTIONS.init_flop_value;
use work.GENERIC_TYPES.std_logic_vector_array;
use work.RS_COMPONENTS.rs_adder;
use work.RS_COMPONENTS.rs_full_multiplier;
use work.RS_COMPONENTS.rs_shifter_acc;

entity rs_euclidean_acc_unit is
    generic (
    	WORD_LENGTH : natural range 2 to 10;
        TWO_TIMES_T : natural range 1 to 1022;
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        i_sync_rst : in std_logic;
        i_swap : in std_logic;
        i_num_shift : integer range 0 to TWO_TIMES_T;
        i_quocient : in std_logic_vector(WORD_LENGTH-1 downto 0);
        o_chien : out std_logic_vector_array(TWO_TIMES_T-2 downto 0)(WORD_LENGTH-1 downto 0)
    );
end rs_euclidean_acc_unit;

architecture behavioral of rs_euclidean_acc_unit is
    --output GEN_rs_QUOCIENT_MULT signals
    signal w_mult : std_logic_vector_array(TWO_TIMES_T-3 downto 0)(WORD_LENGTH-1 downto 0);
    signal r_mult : std_logic_vector_array(TWO_TIMES_T-3 downto 0)(WORD_LENGTH-1 downto 0);

    --output GEN_rs_QUOCIENT_MULT signals (original code)
    signal w_selector_mult : std_logic_vector_array(TWO_TIMES_T-3 downto 0)(WORD_LENGTH-1 downto 0);

    --output GEN_rs_ACC_MUX signals
    signal w_selector_acc : std_logic_vector_array(TWO_TIMES_T-2 downto 0)(WORD_LENGTH-1 downto 0);

    --output D_FLOP_ACC signals
    signal r_acc : std_logic_vector_array(TWO_TIMES_T-2 downto 0)(WORD_LENGTH-1 downto 0);
    
    --output ADDER signals
    signal w_adder : std_logic_vector_array(TWO_TIMES_T-2 downto 0)(WORD_LENGTH-1 downto 0);
    
    --output SHIFTER signals
    signal w_shifter : std_logic_vector_array(TWO_TIMES_T-2 downto 0)(WORD_LENGTH-1 downto 0);
    
    
begin
    assert (TWO_TIMES_T <= 2**WORD_LENGTH-2) 
		report "ASSERT FAILURE - T <= 2**WORD_LENGTH-2" 
		severity failure;

    GEN_rs_ACC_UNIT: for I in 0 to TWO_TIMES_T-2 generate
    begin
        GEN_rs_QUOCIENT_MULT: if I /= TWO_TIMES_T-2 generate
            w_selector_mult(I) <= init_flop_value(I, WORD_LENGTH, 0) when i_sync_rst else w_adder(I) when i_swap else r_mult(I); 
            D_FLOP_MULT_TERM: async_dff_gen_rst 
                              generic map (WORD_LENGTH => WORD_LENGTH, 
	                	                   RESET_VALUE => init_flop_value(I, WORD_LENGTH, 0)) 
                              port map (clk => clk,
                                        rst => rst,
                                        d => w_selector_mult(I),
                                        q => r_mult(I));
            FULL_MULT: rs_full_multiplier
                       generic map(WORD_LENGTH => WORD_LENGTH)
                       port map(i1 => r_mult(I),
                                i2 => i_quocient,
                                o => w_mult(I));
       end generate;

        GEN_rs_ACC_MUX: if I = TWO_TIMES_T-2 generate
            w_selector_acc(I) <= (others => '0') when i_swap or i_sync_rst else w_adder(I); 
        else generate
            w_selector_acc(I) <= (others => '0') when i_sync_rst else r_mult(I) when i_swap else w_adder(I); 
        end generate;

        D_FLOP_ACC: async_dff_gen_rst 
                    generic map (WORD_LENGTH => WORD_LENGTH, 
				                 RESET_VALUE => std_logic_vector(to_unsigned(0, WORD_LENGTH))) 
                    port map (clk => clk,
                              rst => rst,
                              d => w_selector_acc(I),
                              q => r_acc(I));
        ADDER: rs_adder
               generic map(WORD_LENGTH => WORD_LENGTH)
               port map(i1 => r_acc(I),
                        i2 => w_shifter(I),
                        o => w_adder(I));
    end generate GEN_rs_ACC_UNIT;

    SHIFTER: rs_shifter_acc
             generic map(WORD_LENGTH => WORD_LENGTH, 
                         TWO_TIMES_T => TWO_TIMES_T)
             port map(i_shifter => w_mult, 
                      i_num_shift => i_num_shift, 
                      o_shifter => w_shifter);
    o_chien <= w_adder;
end behavioral;