library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity up_counter is
    generic(
        WORD_LENGTH : natural
    );
    port ( 
        clk : in std_logic; -- clock input
        rst : in std_logic; -- reset input
        i_inc : in std_logic;
        o_counter : out std_logic_vector(WORD_LENGTH-1 downto 0) -- output 4-bit counter
     );
end up_counter;

architecture behavioral of up_counter is
constant c_ones : std_logic_vector(WORD_LENGTH-1 downto 0) := (others => '1');
signal w_counter_up : std_logic_vector(WORD_LENGTH-1 downto 0);
begin
-- up counter
    process(clk, rst)
    begin
        if(rising_edge(clk)) then
            if (rst = '1') then
                 w_counter_up <= (others => '0');
            elsif ((i_inc = '1') and (w_counter_up /= c_ones)) then
                w_counter_up <= w_counter_up + 1;
            end if;
         end if;
    end process;
    o_counter <= w_counter_up;
end behavioral;
