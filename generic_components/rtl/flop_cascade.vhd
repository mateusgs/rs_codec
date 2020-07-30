library IEEE;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.GENERIC_TYPES.all;
use work.GENERIC_COMPONENTS.sync_ld_dff;

entity flop_cascade is 
    generic (
        WORD_LENGTH : integer;
        CASCADE_LENGTH : integer
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        i_valid : in std_logic;
        i_data : in std_logic_vector(WORD_LENGTH-1 downto 0);
        o_valid : out std_logic;
        o_data : out std_logic_vector(WORD_LENGTH-1 downto 0)
    );
end flop_cascade;

architecture behavioral of flop_cascade is

signal q_array : std_logic_vector_array(CASCADE_LENGTH-1 downto 0)(WORD_LENGTH downto 0);
	
begin
    GEN_CONVOLUTIONAL_PATH: for I in 0 to (CASCADE_LENGTH - 1) generate
        GEN_FIRST_TERM: if I = 0 generate
            SYNC_D_FLOP_INST: sync_ld_dff 
                generic map (WORD_LENGTH => WORD_LENGTH + 1) 
                port map (rst => rst,
                          clk => clk,
                          ld => i_valid,
                          i_data => i_data & i_valid,
                          o_data => q_array(I));
        end generate;
        GEN_NOT_FIRST_TERM: if I /= 0 generate
            SYNC_D_FLOP_INST: sync_ld_dff 
                generic map (WORD_LENGTH => WORD_LENGTH + 1) 
                port map (rst => rst,
                          clk => clk,
                          ld => i_valid,
                          i_data => q_array(I - 1),
                          o_data => q_array(I));
        end generate;   
    end generate;
    o_data <= q_array(CASCADE_LENGTH - 1)(WORD_LENGTH downto 1);
    o_valid <= q_array(CASCADE_LENGTH - 1)(0);
end behavioral;
