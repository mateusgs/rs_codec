library IEEE;
use IEEE.STD_LOGIC_1164.all;
 
entity dual_clock_generic_buffer is
  generic (
    INPUT_LENGTH : natural;
    OUTPUT_LENGTH : natural
  );
  port (
    clk_rd : in std_logic;
    clk_wr : in std_logic;
    rst : in std_logic;
    i_rd_en : in  std_logic;
    i_wr_en : in std_logic;
    i_wr_data : in std_logic_vector(INPUT_LENGTH-1 downto 0);
    o_full_buffer : out std_logic;
    o_empty_buffer : out std_logic;
    o_rd_data : out std_logic_vector(OUTPUT_LENGTH-1 downto 0)
  );
end dual_clock_generic_buffer;
 
architecture behavioral of dual_clock_generic_buffer is
    constant MEMORY_BIT_SIZE : natural range maximum(INPUT_LENGTH, OUTPUT_LENGTH) 
                                       to 10000*maximum(INPUT_LENGTH, OUTPUT_LENGTH)
begin
end behavioral;