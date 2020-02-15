library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.GENERIC_COMPONENTS.no_rst_dff;
use work.GENERIC_TYPES.std_logic_vector_array;
use work.GENERIC_FUNCTIONS.get_odd_indexes;
use work.GENERIC_FUNCTIONS.get_even_indexes;
use work.RS_COMPONENTS.rs_adder;
use work.RS_COMPONENTS.rs_multiplier;
use work.RS_COMPONENTS.rs_reduce_adder;
use work.RS_FUNCTIONS.get_pow;

entity rs_chien is
        generic (
            WORD_LENGTH : natural range 2 to 10;
			T : natural range 1 to 1022
        );
        port (
            clk : in std_logic;
            i_select_input : in std_logic;
            i_terms : in std_logic_vector_array(T downto 0)(WORD_LENGTH-1 downto 0);         
            o_has_error : out std_logic;
            o_derivative : out std_logic_vector(WORD_LENGTH-1 downto 0)
        );
end rs_chien;

architecture behavioral of rs_chien is
    constant word_zero : std_logic_vector(WORD_LENGTH-1 downto 0) := (others => '0');
    signal w_selector : std_logic_vector_array(T downto 0)(WORD_LENGTH-1 downto 0);
    signal w_multiplier : std_logic_vector_array(T downto 0)(WORD_LENGTH-1 downto 0);
    signal r_flop : std_logic_vector_array(T downto 0)(WORD_LENGTH-1 downto 0);

    signal w_odd_sum : std_logic_vector(WORD_LENGTH-1 downto 0);
    signal w_even_sum : std_logic_vector(WORD_LENGTH-1 downto 0);
    signal w_sum :  std_logic_vector(WORD_LENGTH-1 downto 0) := (others => '0');
begin
	 assert (T <= 2**WORD_LENGTH-2) 
		  report "ASSERT FAILURE - T <= 2**WORD_LENGTH-2" 
		  severity failure;
    GEN_RS_CHIEN_UNIT: for I in 0 to T generate
    begin
        w_selector(I) <= i_terms(I) when i_select_input else r_flop(I);
        MULTIPLIER: rs_multiplier
                    generic map (WORD_LENGTH => WORD_LENGTH,
                                 MULT_CONSTANT => get_pow(WORD_LENGTH, I))
                    port map (i => w_selector(I), 
                              o => w_multiplier(I));
        D_FLOP: no_rst_dff 
                generic map (WORD_LENGTH => WORD_LENGTH) 
                port map (clk => clk,
                          d => w_multiplier(I),
                          q => r_flop(I));
    end generate;

    GEN_EVEN_INDEX_SUM: if T = 1 generate
        w_even_sum <= r_flop(0);
    else generate
        REDUCE_ADDER_EVEN: rs_reduce_adder
        generic map(NUM_OF_ELEMENTS => (T+2)/2,
                    WORD_LENGTH => WORD_LENGTH)
        port map(i => get_even_indexes(r_flop, WORD_LENGTH),
                 o => w_even_sum);
    end generate;

    GEN_ODD_INDEX_SUM: if T = 1 generate
        w_odd_sum <= r_flop(1);
    else generate
        REDUCE_ADDER_ODD: rs_reduce_adder
        generic map(NUM_OF_ELEMENTS => (T+1)/2,
                    WORD_LENGTH => WORD_LENGTH)
        port map(i => get_odd_indexes(r_flop, WORD_LENGTH),
                 o => w_odd_sum);
    end generate;
        
    ADDER: rs_adder 
    generic map (WORD_LENGTH => WORD_LENGTH)
    port map (i1 => w_even_sum,
              i2 => w_odd_sum,
              o => w_sum);

    o_derivative <= w_odd_sum;

    process(all)
    begin
		if (w_sum = word_zero) then
		    o_has_error <= '1';
		else
			o_has_error <= '0';
		end if;	
    end process;
end behavioral;
