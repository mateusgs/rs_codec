library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.MATH_REAL.ceil;
use IEEE.MATH_REAL.log2;
library work;
use work.GENERIC_COMPONENTS.async_dff;
--Quartus does not support it;
--use work.RS_TYPES.RSGFSize;
use work.RS_TYPES.all;
use work.RS_FUNCTIONS.get_word_length_from_rs_gf;

entity rs_encoder is
        generic (
            N : natural range 2 to 1023;
				K : natural range 1 to 1022;
				RS_GF : RSGFSize := RS_GF_NONE
   	  );
        port (
            clk : in std_logic;
            rst : in std_logic;
            i_end_codeword : in std_logic;
            i_start_codeword : in std_logic;
            i_valid : in std_logic;
				i_symbol : in std_logic_vector(get_word_length_from_rs_gf(N, RS_GF)-1 downto 0);          
            o_end_codeword : out std_logic;
            o_error : out std_logic;
            o_in_ready : out std_logic;
            o_start_codeword : out std_logic;
            o_valid : out std_logic;
				o_symbol : out std_logic_vector(get_word_length_from_rs_gf(N, RS_GF)-1 downto 0)
        );
end entity;

architecture behavior of rs_encoder is
	--Quartus does not support it
	constant WORD_LENGTH : natural := get_word_length_from_rs_gf(N, RS_GF);
	constant TWO_TIMES_T : natural := N - K;
	----Total number of symbols is 2^WORD_LENGTH - 1
	----Number of data symbols is 2^WORD_LENGTH - 1 - TWO_TIMES_T
	----Since "0" is considered in the range it is decremented 1
	----Then,
	constant DATA_LIMIT_INDEX : natural := N - 1 - TWO_TIMES_T;
	constant END_INDEX : natural := N - 1;
	
    --output INPUT_D_FLOP signals
	signal r_symbol : std_logic_vector(WORD_LENGTH-1 downto 0);

	--output rs_CONTROL signals
	signal w_end_codeword : std_logic;
	signal w_error : std_logic;
	signal w_in_ready : std_logic;
	signal w_select_parity_symbols : std_logic;
	signal w_stall : std_logic;
	signal w_start_codeword : std_logic;
	signal w_valid : std_logic;

	--output rs_PROCESS_UNIT signals
	signal w_symbol : std_logic_vector(WORD_LENGTH-1 downto 0);

	--output OUTPUT_D_FLOP signals
	constant OUTPUT_SIZE : natural := 5+WORD_LENGTH-1;
	signal r_output : std_logic_vector(OUTPUT_SIZE-1 downto 0);
	
	component rs_encoder_control is
		generic (
			N : natural range 2 to 1023;
			WORD_LENGTH : natural range 2 to 10;
			TWO_TIMES_T : natural
			--Quartus does not support it
			--TWO_TIMES_T : natural range 1 to (2**WORD_LENGTH - 2);
			----Total number of symbols is 2^WORD_LENGTH - 1
			----Number of data symbols is 2^WORD_LENGTH - 1 - TWO_TIMES_T
			----Since "0" is considered in the range it is decremented 1
			----Then,
			--DATA_LIMIT_INDEX : natural := N - 1 - TWO_TIMES_T;
			--END_INDEX : natural := N - 1
		);
		port (
			clk : in std_logic;
			rst : in std_logic;
			i_end_codeword : in std_logic;
			i_start_codeword : in std_logic;
			i_valid : in std_logic;
			o_end_codeword : out std_logic;
			o_error : out std_logic;
			o_in_ready : out std_logic;
			o_select_parity_symbols : out std_logic;
			o_stall : out std_logic;
			o_start_codeword : out std_logic;
			o_valid : out std_logic
		);
	end component;

	component rs_encoder_unit is
		generic (
			WORD_LENGTH : natural range 2 to 10;
			TWO_TIMES_T : natural
			--Quartus does not support it
			--TWO_TIMES_T : natural range 1 to (2**WORD_LENGTH - 2)
			);
		port (
			clk : in std_logic;
			rst : in std_logic;
			i_select_parity_symbols : in std_logic;
			i_stall : in std_logic;
			i_symbol : in std_logic_vector(WORD_LENGTH-1 downto 0);
			o_symbol : out std_logic_vector(WORD_LENGTH-1 downto 0)
		);
	end component;
begin
	INPUT_ASYNC_DFF: async_dff 
                  	 generic map (WORD_LENGTH => WORD_LENGTH) 
                  	 port map (clk => clk,
                     	       rst => rst,
							   d => i_symbol,
                           	   q => r_symbol);
							   
	rs_CONTROL: rs_encoder_control
                generic map (N => N,
							 WORD_LENGTH => WORD_LENGTH,
							 TWO_TIMES_T => TWO_TIMES_T)
                port map (clk => clk,
						  rst => rst,
						  i_end_codeword => i_end_codeword,
						  i_start_codeword => i_start_codeword,
						  i_valid => i_valid,
						  o_end_codeword => w_end_codeword,
						  o_error => w_error,
						  o_in_ready => w_in_ready,
						  o_select_parity_symbols => w_select_parity_symbols,
                          o_stall => w_stall,
						  o_start_codeword => w_start_codeword,
						  o_valid => w_valid);

	rs_PROCESS_UNIT: rs_encoder_unit
					 generic map (WORD_LENGTH => WORD_LENGTH,
					 			  TWO_TIMES_T => TWO_TIMES_T)
					 port map (clk => clk,
					 		   rst => rst,
							   i_select_parity_symbols => w_select_parity_symbols,
                               i_stall => w_stall,
							   i_symbol => r_symbol,
							   o_symbol => w_symbol);

	OUTPUT_ASYNC_DFF: async_dff 
					  generic map (WORD_LENGTH => 4+WORD_LENGTH) 
					  port map (clk => clk,
								rst => rst,
								d => w_end_codeword &
			  						 w_error &
									 w_start_codeword &
									 w_valid &
									 w_symbol,
								q => r_output);

	o_in_ready <= w_in_ready;
	o_end_codeword <= r_output(OUTPUT_SIZE-1);
	o_error <= r_output(OUTPUT_SIZE-2);
	o_start_codeword <= r_output(OUTPUT_SIZE-3);
	o_valid <= r_output(OUTPUT_SIZE-4);
	o_symbol <= r_output(OUTPUT_SIZE-5 downto 0);
end behavior;

library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity rs_encoder_control is
	generic (
		N : natural range 2 to 1023;
		WORD_LENGTH : natural range 2 to 10;
		TWO_TIMES_T : natural
		--Quartus
		--TWO_TIMES_T : natural range 1 to (2**WORD_LENGTH - 2);
		----Total number of symbols is 2^WORD_LENGTH - 1
		----Number of data symbols is 2^WORD_LENGTH - 1 - TWO_TIMES_T
		----Since "0" is considered in the range it is decremented 1
		----Then,
		--DATA_LIMIT_INDEX : natural := N - 1 - TWO_TIMES_T;
		--END_INDEX : natural := N - 1
   	);
	port (
		clk : in std_logic;
		rst : in std_logic;
		i_end_codeword : in std_logic;
		i_start_codeword : in std_logic;
		i_valid : in std_logic;
		o_end_codeword : out std_logic;
		o_error : out std_logic;
		o_in_ready : out std_logic;
		o_select_parity_symbols : out std_logic;
		o_stall : out std_logic;
		o_start_codeword : out std_logic;
		o_valid : out std_logic
	);
end rs_encoder_control;

architecture behavioral of rs_encoder_control is
	--Quartus
	--Total number of symbols is 2^WORD_LENGTH - 1
	--Number of data symbols is 2^WORD_LENGTH - 1 - TWO_TIMES_T
	--Since "0" is considered in the range it is decremented 1
	--Then,
	constant DATA_LIMIT_INDEX : natural := N - 1 - TWO_TIMES_T;
	constant END_INDEX : natural := N - 1;
	
	type State is  (WAIT_SYMBOL,
				    START_CODEWORD,
                    PROCESS_SYMBOLS,
                    GENERATE_PARITY,
				    END_CODEWORD,
				    STALL,
                    ERROR);
	signal r_state : State;
	signal r_counter : natural range 0 to END_INDEX;
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
					if (i_start_codeword = '1' and i_valid = '1') then
						if (i_end_codeword = '1') then 
							r_counter <= DATA_LIMIT_INDEX;
						end if;
						r_state <= START_CODEWORD;
					elsif (i_end_codeword = '1' and i_valid = '1') then
						r_state <= ERROR;
					else
						r_state <= WAIT_SYMBOL;
					end if;
				when START_CODEWORD | PROCESS_SYMBOLS | STALL =>					
					if (i_valid = '0' and r_counter /= DATA_LIMIT_INDEX) then
						r_state <= STALL;
					elsif (i_valid = '1' and i_start_codeword = '1') then
						r_state <= ERROR;
					elsif (r_counter = DATA_LIMIT_INDEX - 1 and i_end_codeword /= '1') then
                        r_state <= ERROR;
					elsif (r_counter = DATA_LIMIT_INDEX) then
                        if (i_end_codeword = '1' and i_valid = '1') then
                            r_state <= ERROR;
                        else
						    r_counter <= r_counter + 1;
						    r_state <= GENERATE_PARITY;
                        end if;
					elsif (i_end_codeword = '1') then
						r_counter <= DATA_LIMIT_INDEX;
						r_state <= PROCESS_SYMBOLS;
                    else
						r_counter <= r_counter + 1;
                        r_state <= PROCESS_SYMBOLS;
					end if;
                when GENERATE_PARITY =>
					r_counter <= r_counter + 1;
					if (i_start_codeword = '1' and i_valid = '1') then
						r_state <= ERROR;
					elsif (i_end_codeword = '1' and i_valid = '1') then
						r_state <= ERROR;
					elsif (r_counter = END_INDEX - 1) then
                        r_state <= END_CODEWORD;
					else
						r_state <= GENERATE_PARITY;
					end if;
				--TODO: END_CODEWORD should be equal to WAIT_SYMBOL
				when END_CODEWORD =>
					r_counter <= 0;
					--looks like you should not look at it.
					if (i_end_codeword = '1' and i_valid = '1') then
						r_state <= ERROR;
					elsif (i_start_codeword = '1' and i_valid = '1') then
						r_state <= START_CODEWORD;
					else
						r_state <= WAIT_SYMBOL;
					end if;
				when ERROR =>
					r_counter <= 0;
					r_state <= ERROR;
				when others =>
					r_state <= ERROR;
			end case;
		end if;
	end process;
	process (rst, r_state, r_counter)
    begin
        case r_state is
			when WAIT_SYMBOL =>
				o_end_codeword <= '0';
				o_error <= '0';
				o_in_ready <= '0';
				o_select_parity_symbols <= '1';
				o_stall <= '1';
				o_start_codeword <= '0';
				o_valid <= '0';
			when START_CODEWORD =>
				o_end_codeword <= '0';
				o_error <= '0';
				o_in_ready <= '1';
				o_select_parity_symbols <= '0';
				o_stall <= '0';
				o_start_codeword <= '1';
				o_valid <= '1'; 
			when PROCESS_SYMBOLS =>
				o_end_codeword <= '0';
				o_error <= '0';
				o_in_ready <= '1';
				o_select_parity_symbols <= '0';
				o_stall <= '0';
				o_start_codeword <= '0';
				o_valid <= '1'; 
			when GENERATE_PARITY =>
				o_end_codeword <= '0';
				o_error <= '0';
				o_in_ready <= '0';
				o_select_parity_symbols <= '1';
				o_stall <= '0';
				o_stall <= '0';
				o_start_codeword <= '0';
				o_valid <= '1';
			when END_CODEWORD => 
				o_end_codeword <= '1';
				o_error <= '0';
				o_in_ready <= '0';
				o_select_parity_symbols <= '1';
				o_stall <= '0';
				o_start_codeword <= '0';
				o_valid <= '1';	
			when STALL =>
				o_end_codeword <= '0';
				o_error <= '0';
				o_in_ready <= '1';
				o_select_parity_symbols <= '0';
				o_stall <= '1';
				o_start_codeword <= '0';
				o_valid <= '0';	
			when ERROR =>
				o_end_codeword <= '0';
				o_error <= '1';
				o_in_ready <= '0';
				o_select_parity_symbols <= '0';
				o_stall <= '0';
				o_start_codeword <= '0';
				o_valid <= '0';			
		end case;
	end process;

end behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.GENERIC_COMPONENTS.async_dff;
use work.GENERIC_TYPES.std_logic_vector_array;
use work.RS_COMPONENTS.rs_adder;
use work.RS_COMPONENTS.rs_multiplier;
use work.RS_COMPONENTS.rs_remainder_unit;
use work.RS_CONSTANTS.f_gp_factor;

entity rs_encoder_unit is
	generic (
    	WORD_LENGTH : natural range 2 to 10;
		TWO_TIMES_T : natural
		--Quartus
      --TWO_TIMES_T : natural range 1 to (2**WORD_LENGTH - 2)
    	);
	port (
		clk : in std_logic;
		rst : in std_logic;
		i_select_parity_symbols : in std_logic;
		i_stall : in std_logic;
		i_symbol : in std_logic_vector(WORD_LENGTH-1 downto 0);
		o_symbol : out std_logic_vector(WORD_LENGTH-1 downto 0)
    );
end rs_encoder_unit;

architecture behavioral of rs_encoder_unit is
	--output END_ADDER signals
	signal w_end_adder : std_logic_vector(WORD_LENGTH-1 downto 0);

	--output FST_MULTIPLIER signals
	signal w_fst_multiplier : std_logic_vector(WORD_LENGTH-1 downto 0);
	signal w_fst_multiplier_selector : std_logic_vector(WORD_LENGTH-1 downto 0);
    
	--output GEN_rs_REMAINDER signals
    signal w_feedback : std_logic_vector(WORD_LENGTH-1 downto 0);

	signal r_cascade_outputs : std_logic_vector_array(TWO_TIMES_T-1 downto 0)(WORD_LENGTH-1 downto 0);
begin
    END_ADDER: rs_adder 
               generic map (WORD_LENGTH => WORD_LENGTH)
               port map (i1 => r_cascade_outputs(TWO_TIMES_T-1),
                         i2 => i_symbol,
                         o => w_end_adder);

    w_feedback <= w_end_adder when (i_select_parity_symbols = '0') 
                              else (others => '0');

    FST_MULTIPLIER: rs_multiplier
                    generic map (WORD_LENGTH => WORD_LENGTH, 
								 MULT_CONSTANT => f_gp_factor(WORD_LENGTH,TWO_TIMES_T,0))
                    port map (i => w_feedback, 
                              o => w_fst_multiplier);

    w_fst_multiplier_selector <= r_cascade_outputs(0) when i_stall 
                                                      else w_fst_multiplier;

    FST_ASYCN_DFF: async_dff 
                   generic map (WORD_LENGTH => WORD_LENGTH) 
                   port map (clk => clk,
					     	 rst => rst,
						  	 d => w_fst_multiplier_selector,
                          	 q => r_cascade_outputs(0));

    GEN_RS_REMAINDER: for I in 0 to TWO_TIMES_T-2 generate
        RS_REMAINDER: rs_remainder_unit
                      generic map (WORD_LENGTH, f_gp_factor(WORD_LENGTH,TWO_TIMES_T,I+1))
                      port map (clk => clk,
					  			rst => rst,
                                i_stall => i_stall,
                                i_symbol => w_feedback,
                                i_upper_lv => r_cascade_outputs(I),
                                o => r_cascade_outputs(I+1));
    end generate GEN_RS_REMAINDER;

    o_symbol <= i_symbol when (i_select_parity_symbols = '0') 
					     else r_cascade_outputs(TWO_TIMES_T-1);
end behavioral;
