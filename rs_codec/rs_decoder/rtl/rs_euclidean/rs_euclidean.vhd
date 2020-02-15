library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.MATH_REAL.ceil;
use IEEE.MATH_REAL.log2;
library work;
use work.RS_COMPONENTS.rs_euclidean_acc_unit;
use work.RS_COMPONENTS.rs_euclidean_division_unit;
use work.RS_FUNCTIONS.get_szs;

entity rs_euclidean_control is
    generic(
        WORD_LENGTH : natural range 2 to 10;
        TWO_TIMES_T : natural range 1 to 1022
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        i_fifo_chien_forney_full : in std_logic;
        i_syndrome_ready : in std_logic;
        i_div_shift_zeros : in integer range 0 to 2**get_szs(TWO_TIMES_T)-1;
        i_rem_shift_zeros : in integer range 0 to 2**get_szs(TWO_TIMES_T)-1;
        o_wr_euclidean : out std_logic;
        o_error : out std_logic;
        o_rst_euclidean_divisor : out std_logic;
        o_rd_syndrome : out std_logic;
        o_swap : out std_logic;
        o_num_shift : out integer range 0 to 2**TWO_TIMES_T - 1
    );
end rs_euclidean_control;

architecture behavioral of rs_euclidean_control is
    constant SHIFTED_ZEROS_SIZE : natural := get_szs(TWO_TIMES_T);
	type State is (WAIT_FOR_SYNDROME,
                   START_EUCLIDEAN,
                   COMPUTE_EUCLIDEAN,
                   SWAP_EUCLIDEAN,
                   PROPAGATE_OUTPUTS,
                   END_EUCLIDEAN,
                   ERROR);
    signal r_divisor_degree : integer range 0 to 2**SHIFTED_ZEROS_SIZE-1;
    signal r_num_shift : integer range 0 to 2**TWO_TIMES_T - 1;
    signal r_remainder_degree : integer range 0 to 2**SHIFTED_ZEROS_SIZE-1;
    signal r_state : State;
begin
	process (clk, rst)
	begin
		if (rst = '1') then
			r_state <= WAIT_FOR_SYNDROME;
        elsif rising_edge(clk) then
            case r_state is
                when WAIT_FOR_SYNDROME =>
                    if (i_syndrome_ready = '1') then
                        r_divisor_degree <= TWO_TIMES_T - 1 - i_div_shift_zeros;
                        r_num_shift <= 1 - i_div_shift_zeros + i_rem_shift_zeros;
                        r_remainder_degree <= TWO_TIMES_T - 1 + i_rem_shift_zeros;
                        r_state <= START_EUCLIDEAN;
                    else
                        r_divisor_degree <= 0;
                        r_num_shift <= 0;
                        r_remainder_degree <= 0;
                        r_state <= WAIT_FOR_SYNDROME;
                    end if;
                when START_EUCLIDEAN=>
                    r_num_shift <= r_num_shift - 1 - i_div_shift_zeros + i_rem_shift_zeros;
                    r_remainder_degree <= r_remainder_degree - 1 - i_rem_shift_zeros;
                    if (r_remainder_degree - 1 - i_rem_shift_zeros < r_divisor_degree) then  
                        if (2*(r_remainder_degree - 1 - i_rem_shift_zeros) < TWO_TIMES_T) then
                            if (i_fifo_chien_forney_full = '1') then
                                r_state <= ERROR;
                            else
                                r_num_shift <= o_num_shift - 1 - i_div_shift_zeros + i_rem_shift_zeros;
                                r_remainder_degree <= r_remainder_degree - 1 - i_rem_shift_zeros;
                                r_state <= PROPAGATE_OUTPUTS;
                            end if;
                        else
                            r_divisor_degree <= r_remainder_degree;
                            r_num_shift <= r_num_shift - 1 - i_div_shift_zeros + i_rem_shift_zeros;
                            r_remainder_degree <= r_divisor_degree - 1 - i_rem_shift_zeros;
                            r_state <= SWAP_EUCLIDEAN;
                        end if;
                    else
                        r_state <= COMPUTE_EUCLIDEAN;
                    end if;
                when COMPUTE_EUCLIDEAN =>
                    if (r_remainder_degree - 1 - i_rem_shift_zeros < r_divisor_degree) then
                        if (2*(r_remainder_degree - 1 - i_rem_shift_zeros) < TWO_TIMES_T) then
                            if (i_fifo_chien_forney_full = '1') then
                                r_state <= ERROR;
                            else
                                r_num_shift <= o_num_shift - 1 - i_div_shift_zeros + i_rem_shift_zeros;
                                r_remainder_degree <= r_remainder_degree - 1 - i_rem_shift_zeros;
                                r_state <= PROPAGATE_OUTPUTS;
                            end if;
                        else
                            r_divisor_degree <= r_remainder_degree;
                            r_num_shift <= r_num_shift - 1 - i_div_shift_zeros + i_rem_shift_zeros;
                            r_remainder_degree <= r_divisor_degree - 1 - i_rem_shift_zeros;
                            r_state <= SWAP_EUCLIDEAN;
                        end if;
                    else
                        r_num_shift <= o_num_shift - 1 - i_div_shift_zeros + i_rem_shift_zeros;
                        r_remainder_degree <= r_remainder_degree - 1 - i_rem_shift_zeros;
                        r_state <= COMPUTE_EUCLIDEAN;
                    end if;
                when PROPAGATE_OUTPUTS =>
                    --one cycle delay to propagate outputs
                    r_divisor_degree <= 0;
                    r_num_shift <= 0;
                    r_remainder_degree <= 0;
                    r_state <= END_EUCLIDEAN;
                when END_EUCLIDEAN =>
                    if (i_syndrome_ready = '1' and i_fifo_chien_forney_full = '0') then
                        r_divisor_degree <= TWO_TIMES_T - 1 - i_div_shift_zeros;
                        r_num_shift <= 1 - i_div_shift_zeros + i_rem_shift_zeros;
                        r_remainder_degree <= TWO_TIMES_T - 1 + i_rem_shift_zeros;
                        r_state <= START_EUCLIDEAN;
                    else
                        r_divisor_degree <= 0;
                        r_num_shift <= 0;
                        r_remainder_degree <= 0;
                        if (i_fifo_chien_forney_full = '1') then
                            r_state <= END_EUCLIDEAN;
                        else
                            r_state <= WAIT_FOR_SYNDROME;
                        end if;
                    end if;
                when SWAP_EUCLIDEAN =>
                    r_num_shift <= 1 - i_div_shift_zeros + i_rem_shift_zeros;
                    r_remainder_degree <= r_remainder_degree - 1 - i_rem_shift_zeros;
                    r_state <= COMPUTE_EUCLIDEAN;
                when ERROR =>
                    r_divisor_degree <= 0;
                    r_num_shift <= 0;
                    r_remainder_degree <= 0;
                    r_state <= ERROR;
            end case;
        end if;
    end process;

    process (rst, r_state)
    begin 
        case r_state is
            when WAIT_FOR_SYNDROME =>
                o_error <= '0';
                o_rd_syndrome <= '0';
                o_rst_euclidean_divisor <= '1';
                o_swap <= '0';
                o_wr_euclidean <= '0';
            when START_EUCLIDEAN =>
                o_error <= '0';
                o_rd_syndrome <= '1';
                o_rst_euclidean_divisor <= '0';
                o_swap <= '0';
                o_wr_euclidean <= '0';
            when COMPUTE_EUCLIDEAN =>
                 o_error <= '0';
                 o_rd_syndrome <= '0';
                 o_rst_euclidean_divisor <= '0';
                 o_swap <= '0';
                 o_wr_euclidean <= '0';
            when SWAP_EUCLIDEAN =>
                 o_error <= '0';
                 o_rd_syndrome <= '0';
                 o_rst_euclidean_divisor <= '0';
                 o_swap <= '1';
                 o_wr_euclidean <= '0'; 
            when PROPAGATE_OUTPUTS =>
                 o_error <= '0';
                 o_rd_syndrome <= '0';
                 o_rst_euclidean_divisor <= '0';
                 o_swap <= '0';
                 o_wr_euclidean <= '0';            
            when END_EUCLIDEAN =>
                o_error <= '0';
                o_rd_syndrome <= '0';
                o_rst_euclidean_divisor <= '1';
                o_swap <= '0';
                o_wr_euclidean <= not i_fifo_chien_forney_full;
            when ERROR =>
                o_error <= '1';
                o_rd_syndrome <= '0';
                o_rst_euclidean_divisor <= '0';
                o_swap <= '0';
                o_wr_euclidean <= '0';
        end case;
    end process;
    o_num_shift <= r_num_shift;
end behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.MATH_REAL.ceil;
use IEEE.MATH_REAL.log2;
library work;
use work.GENERIC_COMPONENTS.config_dff_array;
use work.GENERIC_TYPES.all;
use work.RS_COMPONENTS.all;
use work.RS_FUNCTIONS.get_szs;

entity rs_euclidean_unit is
    generic (
    	WORD_LENGTH : natural range 2 to 10;
        TWO_TIMES_T : natural range 1 to 1022
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        i_sync_rst : in std_logic;
        i_swap : in std_logic;
        i_num_shift : in integer range 0 to TWO_TIMES_T;
        i_syndrome : in std_logic_vector_array(TWO_TIMES_T-1 downto 0)(WORD_LENGTH-1 downto 0);
        o_div_shift_zeros : out integer range 0 to 2**get_szs(TWO_TIMES_T)-1;
        o_rem_shift_zeros : out integer range 0 to 2**get_szs(TWO_TIMES_T)-1;
        o_chien : out std_logic_vector_array(TWO_TIMES_T-2 downto 0)(WORD_LENGTH-1 downto 0);
        o_forney : out std_logic_vector_array(TWO_TIMES_T-3 downto 0)(WORD_LENGTH-1 downto 0)
    );
end rs_euclidean_unit;

architecture behavioral of rs_euclidean_unit is
    constant SHIFTED_ZEROS_SIZE : natural := get_szs(TWO_TIMES_T);
    signal w_quocient : std_logic_vector(WORD_LENGTH-1 downto 0);
    signal w_num_shift : std_logic_vector(TWO_TIMES_T-1 downto 0);
    signal w_chien : std_logic_vector_array(TWO_TIMES_T-2 downto 0)(WORD_LENGTH-1 downto 0);
    signal w_forney : std_logic_vector_array(TWO_TIMES_T-3 downto 0)(WORD_LENGTH-1 downto 0);
begin
    ACC_UNIT: rs_euclidean_acc_unit
              generic map(WORD_LENGTH => WORD_LENGTH, 
                          TWO_TIMES_T => TWO_TIMES_T)
              port map(clk => clk,
                       rst => rst,
                       i_sync_rst => i_sync_rst,
                       i_swap => i_swap,
                       i_num_shift => i_num_shift,
                       i_quocient => w_quocient,
                       o_chien => w_chien);
    DIVISIION_UNIT: rs_euclidean_division_unit
                    generic map(WORD_LENGTH => WORD_LENGTH, 
                                TWO_TIMES_T => TWO_TIMES_T)
                    port map(clk => clk,
                             rst => rst,
                             i_sync_rst => i_sync_rst,
                             i_swap => i_swap,
                             i_syndrome => i_syndrome,
                             o_div_shift_zeros => o_div_shift_zeros,
                             o_rem_shift_zeros => o_rem_shift_zeros,
                             o_quocient => w_quocient,
                             o_forney => w_forney);
    CHIEN_REG: config_dff_array
               generic map(TWO_TIMES_T-1,
                           WORD_LENGTH)
               port map(clk => clk,
                        en => not (rst or i_sync_rst),
                        d => w_chien,
                        q => o_chien);
    FORNEY_REG: config_dff_array
                generic map(TWO_TIMES_T-2,
                            WORD_LENGTH)
                port map(clk => clk,
                         en => not (rst or i_sync_rst),
                         d => w_forney,
                         q => o_forney);
end behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.all;
use IEEE.MATH_REAL.ceil;
use IEEE.MATH_REAL.log2;
library work;
use work.GENERIC_COMPONENTS.all;
use work.GENERIC_TYPES.std_logic_vector_array;
use work.RS_COMPONENTS.all;

entity rs_euclidean is
    generic (
        WORD_LENGTH : natural range 2 to 10;
        TWO_TIMES_T : natural range 1 to 1022
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        i_fifo_chien_forney_full : in std_logic;
        i_syndrome_ready : in std_logic;
        i_syndrome : in std_logic_vector_array(TWO_TIMES_T-1 downto 0)(WORD_LENGTH-1 downto 0);
        o_error : out std_logic;
        o_rd_syndrome : out std_logic;
        o_wr_euclidean : out std_logic;
        o_chien : out std_logic_vector_array(TWO_TIMES_T-2 downto 0)(WORD_LENGTH-1 downto 0);
        o_forney : out std_logic_vector_array(TWO_TIMES_T-3 downto 0)(WORD_LENGTH-1 downto 0)
    );
end rs_euclidean;

architecture behavioral of rs_euclidean is
    component rs_euclidean_unit is
        generic (
            WORD_LENGTH : natural range 2 to 10;
            TWO_TIMES_T : natural range 1 to 1022
        );
        port (
            clk : in std_logic;
            rst : in std_logic;
            i_sync_rst : in std_logic;
            i_swap : in std_logic;
            i_num_shift : in integer range 0 to TWO_TIMES_T;
            i_syndrome : in std_logic_vector_array(TWO_TIMES_T-1 downto 0)(WORD_LENGTH-1 downto 0);
            o_div_shift_zeros : out integer range 0 to 2**get_szs(TWO_TIMES_T)-1;
            o_rem_shift_zeros : out integer range 0 to 2**get_szs(TWO_TIMES_T)-1;
            o_chien : out std_logic_vector_array(TWO_TIMES_T-2 downto 0)(WORD_LENGTH-1 downto 0);
            o_forney : out std_logic_vector_array(TWO_TIMES_T-3 downto 0)(WORD_LENGTH-1 downto 0)
        );
    end component;

    component rs_euclidean_control is
        generic(
            WORD_LENGTH : natural range 2 to 10;
            TWO_TIMES_T : natural range 1 to 1022
        );
        port (
            clk : in std_logic;
            rst : in std_logic;
            i_fifo_chien_forney_full : in std_logic;
            i_syndrome_ready : in std_logic;
            i_div_shift_zeros : in integer range 0 to 2**get_szs(TWO_TIMES_T)-1;
            i_rem_shift_zeros : in integer range 0 to 2**get_szs(TWO_TIMES_T)-1;
            o_wr_euclidean : out std_logic;
            o_error : out std_logic;
            o_rst_euclidean_divisor : out std_logic;
            o_rd_syndrome : out std_logic;
            o_swap : out std_logic;
            o_num_shift : out integer range 0 to 2**TWO_TIMES_T - 1
        );
    end component;
    constant SHIFTED_ZEROS_SIZE : natural := get_szs(TWO_TIMES_T);
    signal w_rst_euclidean_divisor : std_logic;
    signal w_swap : std_logic;
    signal w_num_shift : integer range 0 to TWO_TIMES_T;
    signal w_div_shift_zeros : integer range 0 to 2**SHIFTED_ZEROS_SIZE-1;
    signal w_rem_shift_zeros : integer range 0 to 2**SHIFTED_ZEROS_SIZE-1;
begin
	assert (TWO_TIMES_T <= 2**WORD_LENGTH-2) 
		  report "ASSERT FAILURE - T <= 2**WORD_LENGTH-2" 
		  severity failure;

    EUCLIDEAN_UNIT: rs_euclidean_unit
                       generic map(WORD_LENGTH => WORD_LENGTH, 
                                   TWO_TIMES_T => TWO_TIMES_T)
                       port map(clk => clk,
                                rst => rst,
                                i_sync_rst => w_rst_euclidean_divisor,
                                i_swap => w_swap,
                                i_num_shift => w_num_shift,
                                i_syndrome => i_syndrome,
                                o_div_shift_zeros => w_div_shift_zeros,
                                o_rem_shift_zeros => w_rem_shift_zeros,
                                o_chien => o_chien,
                                o_forney => o_forney);

    EUCLIDEAN_CONTROL: rs_euclidean_control
                       generic map(WORD_LENGTH => WORD_LENGTH, 
                                   TWO_TIMES_T => TWO_TIMES_T)
                       port map(clk => clk,
                                rst => rst,
                                i_fifo_chien_forney_full => i_fifo_chien_forney_full,
                                i_syndrome_ready => i_syndrome_ready,
                                i_div_shift_zeros => w_div_shift_zeros,
                                i_rem_shift_zeros => w_rem_shift_zeros,
                                o_wr_euclidean => o_wr_euclidean,
                                o_error => o_error,
                                o_rst_euclidean_divisor => w_rst_euclidean_divisor,
                                o_rd_syndrome => o_rd_syndrome,
                                o_swap => w_swap,
                                o_num_shift => w_num_shift);
end behavioral;
