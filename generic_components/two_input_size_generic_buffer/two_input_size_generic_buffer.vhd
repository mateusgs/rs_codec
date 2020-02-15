library IEEE;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.GENERIC_FUNCTIONS.max;

entity two_input_size_generic_buffer is
  generic (
    INPUT_1_LENGTH : natural;
    INPUT_2_LENGTH : natural;
    OUTPUT_LENGTH : natural;
    NUM_OF_OUTPUT_ELEMENTS : natural
  );
  port (
    clk : in std_logic;
    rst : in std_logic;
    i_data_length_selector : in std_logic;
    i_rd_en : in  std_logic;
    i_wr_en : in std_logic;
    i_wr_data : in std_logic_vector(max(INPUT_1_LENGTH, INPUT_2_LENGTH)-1 downto 0);
    o_full_buffer : out std_logic;
    o_empty_buffer : out std_logic;
    o_rd_data : out std_logic_vector(OUTPUT_LENGTH-1 downto 0)
  );
end two_input_size_generic_buffer;
 
architecture behavioral of two_input_size_generic_buffer is
begin
end behavioral;
