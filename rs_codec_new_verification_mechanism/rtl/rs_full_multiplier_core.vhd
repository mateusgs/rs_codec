---------------------------------------------------------------------------
-- Universidade Federal de Minas Gerais (UFMG)
---------------------------------------------------------------------------
-- Project: Reed-Solomon Encoder
-- Design: RS Multiplier
---------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity rs_full_multiplier_core is
    generic (
        WORD_LENGTH : natural range 2 to 10
    );
    port (
        i1 : in std_logic_vector(WORD_LENGTH-1 downto 0);
        i2 : in std_logic_vector(WORD_LENGTH-1 downto 0);
        o : out std_logic_vector(WORD_LENGTH-1 downto 0)
    );
end rs_full_multiplier_core;

architecture behavioral of rs_full_multiplier_core is
    type std_logic_vector_array is array (natural range <>) of std_logic_vector;
    signal w_and_out : std_logic_vector_array(0 to WORD_LENGTH-1)(WORD_LENGTH-1 downto 0);
    signal w_factors_overflow : std_logic_vector(WORD_LENGTH-2 downto 0);
begin
    --generate all combinations of AND operation
    process(i1,i2)
    begin
        for I in 0 to WORD_LENGTH-1 loop
            for J in 0 to WORD_LENGTH-1 loop
                w_and_out(I)(J) <= i1(I) and i2(J);
            end loop;
        end loop;
    end process;

    gen_word_length_2: if WORD_LENGTH = 2 generate
        --galois field conversion
        --x^2 = x^1 + 1
        --0   => 0
        --x^0 => 1
        --x^1 => x
        --x^2 => x + 1

        --calculation for x^2
        w_factors_overflow(0) <= w_and_out(1)(1); 

        o(0) <= w_and_out(0)(0) xor 
                w_factors_overflow(0);
        o(1) <= w_and_out(0)(1) xor 
                w_and_out(1)(0) xor
                w_factors_overflow(0);
    end generate;

    gen_word_length_3: if WORD_LENGTH = 3 generate
        --galois field conversion
        --x^3 = x^1 + 1
        --0   => 0
        --x^0 => 1
        --x^1 => x
        --x^2 => x^2
        --x^3 => x^1 + 1
        --x^4 => x^2 + x

        --calculation for x^3
        w_factors_overflow(0) <= w_and_out(2)(1) xor
                                 w_and_out(1)(2);
        --calculation for x^4
        w_factors_overflow(1) <= w_and_out(2)(2);

        o(0) <= w_and_out(0)(0) xor 
                w_factors_overflow(0);
        o(1) <= w_and_out(0)(1) xor 
                w_and_out(1)(0) xor
                w_factors_overflow(0) xor
                w_factors_overflow(1);
        o(2) <= w_and_out(2)(0) xor
                w_and_out(1)(1) xor
                w_and_out(0)(2) xor
                w_factors_overflow(1);
    end generate;

    gen_word_length_4: if WORD_LENGTH = 4 generate
        --galois field conversion
        --x^4 = x^1 + 1
        --0   => 0
        --x^0 => 1
        --x^1 => x
        --x^2 => x^2
        --x^3 => x^3
        --x^4 => x + 1
        --x^5 => x^2 + x
        --x^6 => x^3 + x^2

        --calculation for x^4
        w_factors_overflow(0) <= w_and_out(3)(1) xor 
                                 w_and_out(2)(2) xor
                                 w_and_out(1)(3);
        --calculation for x^5
        w_factors_overflow(1) <= w_and_out(3)(2) xor 
                                 w_and_out(2)(3);
        --calculation for x^6
        w_factors_overflow(2) <= w_and_out(3)(3);

        o(0) <= w_and_out(0)(0) xor 
                w_factors_overflow(0);
        o(1) <= w_and_out(0)(1) xor
                w_and_out(1)(0) xor 
                w_factors_overflow(0) xor
                w_factors_overflow(1);
        o(2) <= w_and_out(2)(0) xor
                w_and_out(1)(1) xor
                w_and_out(0)(2) xor
                w_factors_overflow(1) xor
                w_factors_overflow(2);
        o(3) <= w_and_out(3)(0) xor
                w_and_out(2)(1) xor
                w_and_out(1)(2) xor
                w_and_out(0)(3) xor
                w_factors_overflow(2);
    end generate;

    gen_word_length_5: if WORD_LENGTH = 5 generate
        --galois field conversion
        --x^5 = x^2 + 1
        --0   => 0
        --x^0 => 1
        --x^1 => x
        --x^2 => x^2
        --x^3 => x^3
        --x^4 => x^4
        --x^5 => x^2 + 1
        --x^6 => x^3 + x
        --x^7 => x^4 + x^2
        --x^8 => x^3 + x^2 + 1

        --calculation for x^5
        w_factors_overflow(0) <= w_and_out(4)(1) xor 
                                 w_and_out(3)(2) xor
                                 w_and_out(2)(3) xor
                                 w_and_out(1)(4);
        --calculation for x^6
        w_factors_overflow(1) <= w_and_out(4)(2) xor 
                                 w_and_out(3)(3) xor
                                 w_and_out(2)(4);
        --calculation for x^7
        w_factors_overflow(2) <= w_and_out(4)(3) xor
                                 w_and_out(3)(4);
        --calculation for x^8
        w_factors_overflow(3) <= w_and_out(4)(4);


        o(0) <= w_and_out(0)(0) xor 
                w_factors_overflow(0) xor
                w_factors_overflow(3);

        o(1) <= w_and_out(0)(1) xor
                w_and_out(1)(0) xor 
                w_factors_overflow(1);

        o(2) <= w_and_out(2)(0) xor
                w_and_out(1)(1) xor
                w_and_out(0)(2) xor
                w_factors_overflow(0) xor
                w_factors_overflow(2) xor
                w_factors_overflow(3);

        o(3) <= w_and_out(3)(0) xor
                w_and_out(2)(1) xor
                w_and_out(1)(2) xor
                w_and_out(0)(3) xor
                w_factors_overflow(1) xor
                w_factors_overflow(3);

        o(4) <= w_and_out(4)(0) xor
                w_and_out(3)(1) xor
                w_and_out(2)(2) xor
                w_and_out(1)(3) xor
                w_and_out(0)(4) xor
                w_factors_overflow(2);
    end generate;

    gen_word_length_6: if WORD_LENGTH = 6 generate
        --galois field conversion
        --x^6 = x + 1
        --0   => 0
        --x^0 => 1
        --x^1 => x
        --x^2 => x^2
        --x^3 => x^3
        --x^4 => x^4
        --x^5 => x^5
        --x^6 => x + 1
        --x^7 => x^2 + x^1
        --x^8 => x^3 + x^2
        --x^9 => x^4 + x^3
        --x^10 => x^5 + x^4

        --calculation for x^6
        w_factors_overflow(0) <= w_and_out(5)(1) xor 
                                 w_and_out(4)(2) xor
                                 w_and_out(3)(3) xor
                                 w_and_out(2)(4) xor
                                 w_and_out(1)(5);
        --calculation for x^7
        w_factors_overflow(1) <= w_and_out(5)(2) xor 
                                 w_and_out(4)(3) xor
                                 w_and_out(3)(4) xor
                                 w_and_out(2)(5);
        --calculation for x^8
        w_factors_overflow(2) <= w_and_out(5)(3) xor 
                                 w_and_out(4)(4) xor
                                 w_and_out(3)(5);
        --calculation for x^9
        w_factors_overflow(3) <= w_and_out(5)(4) xor
                                 w_and_out(4)(5);
        --calculation for x^10
        w_factors_overflow(4) <= w_and_out(5)(5);

        o(0) <= w_and_out(0)(0) xor 
                w_factors_overflow(0);

        o(1) <= w_and_out(0)(1) xor
                w_and_out(1)(0) xor 
                w_factors_overflow(0) xor
                w_factors_overflow(1);

        o(2) <= w_and_out(2)(0) xor
                w_and_out(1)(1) xor
                w_and_out(0)(2) xor
                w_factors_overflow(1) xor
                w_factors_overflow(2);

        o(3) <= w_and_out(3)(0) xor
                w_and_out(2)(1) xor
                w_and_out(1)(2) xor
                w_and_out(0)(3) xor
                w_factors_overflow(2) xor
                w_factors_overflow(3);

        o(4) <= w_and_out(4)(0) xor
                w_and_out(3)(1) xor
                w_and_out(2)(2) xor
                w_and_out(1)(3) xor
                w_and_out(0)(4) xor
                w_factors_overflow(3) xor
                w_factors_overflow(4);

        o(5) <= w_and_out(5)(0) xor
                w_and_out(4)(1) xor
                w_and_out(3)(2) xor
                w_and_out(2)(3) xor
                w_and_out(1)(4) xor
                w_and_out(0)(5) xor
                w_factors_overflow(4);
    end generate;

    gen_word_length_7: if WORD_LENGTH = 7 generate
        --galois field conversion
        --x^7 = x + 1
        --0   => 0
        --x^0 => 1
        --x^1 => x
        --x^2 => x^2
        --x^3 => x^3
        --x^4 => x^4
        --x^5 => x^5
        --x^6 => x^6
        --x^7 => x + 1
        --x^8 => x^2 + x
        --x^9 => x^3 + x^2
        --x^10 => x^4 + x^3
        --x^11 => x^5 + x^4
        --x^12 => x^6 + x^5

        --calculation for x^7
        w_factors_overflow(0) <= w_and_out(6)(1) xor 
                                 w_and_out(5)(2) xor
                                 w_and_out(4)(3) xor
                                 w_and_out(3)(4) xor
                                 w_and_out(2)(5) xor
                                 w_and_out(1)(6);
        --calculation for x^8
        w_factors_overflow(1) <= w_and_out(6)(2) xor 
                                 w_and_out(5)(3) xor
                                 w_and_out(4)(4) xor
                                 w_and_out(3)(5) xor
                                 w_and_out(2)(6);
        --calculation for x^9
        w_factors_overflow(2) <= w_and_out(6)(3) xor 
                                 w_and_out(5)(4) xor
                                 w_and_out(4)(5) xor
                                 w_and_out(3)(6);
        --calculation for x^10
        w_factors_overflow(3) <= w_and_out(6)(4) xor 
                                 w_and_out(5)(5) xor
                                 w_and_out(4)(6);
        --calculation for x^11
        w_factors_overflow(4) <= w_and_out(6)(5) xor
                                 w_and_out(5)(6);
        --calculation for x^12
        w_factors_overflow(5) <= w_and_out(6)(6);

        o(0) <= w_and_out(0)(0) xor 
                w_factors_overflow(0);

        o(1) <= w_and_out(0)(1) xor
                w_and_out(1)(0) xor 
                w_factors_overflow(0) xor
                w_factors_overflow(1);

        o(2) <= w_and_out(2)(0) xor
                w_and_out(1)(1) xor
                w_and_out(0)(2) xor
                w_factors_overflow(1) xor
                w_factors_overflow(2);

        o(3) <= w_and_out(3)(0) xor
                w_and_out(2)(1) xor
                w_and_out(1)(2) xor
                w_and_out(0)(3) xor
                w_factors_overflow(2) xor
                w_factors_overflow(3);

        o(4) <= w_and_out(4)(0) xor
                w_and_out(3)(1) xor
                w_and_out(2)(2) xor
                w_and_out(1)(3) xor
                w_and_out(0)(4) xor
                w_factors_overflow(3) xor
                w_factors_overflow(4);

        o(5) <= w_and_out(5)(0) xor
                w_and_out(4)(1) xor
                w_and_out(3)(2) xor
                w_and_out(2)(3) xor
                w_and_out(1)(4) xor
                w_and_out(0)(5) xor
                w_factors_overflow(4) xor
                w_factors_overflow(5);

        o(6) <= w_and_out(6)(0) xor
                w_and_out(5)(1) xor
                w_and_out(4)(2) xor
                w_and_out(3)(3) xor
                w_and_out(2)(4) xor
                w_and_out(1)(5) xor
                w_and_out(0)(6) xor
                w_factors_overflow(5);
    end generate;

    gen_word_length_8: if WORD_LENGTH = 8 generate
        --galois field conversion
        --x^8 = x^4 + x^3 + x^2 + 1
        --0   => 0
        --x^0 => 1
        --x^1 => x
        --x^2 => x^2
        --x^3 => x^3
        --x^4 => x^4
        --x^5 => x^5
        --x^6 => x^6
        --x^7 => x^7
        --x^8 => x^4 + x^3 + x^2 + 1
        --x^9 => x^5 + x^4 + x^3 + x
        --x^10 => x^6 + x^5 + x^4 + x^2
        --x^11 => x^7 + x^6 + x^5 + x^3
        --x^12 => x^7 + x^6 + x^3 + x^2 + 1
        --x^13 => x^7 + x^2 + x + 1
        --x^14 => x^4 + x + 1

        --calculation for x^8
        w_factors_overflow(0) <= w_and_out(7)(1) xor 
                                 w_and_out(6)(2) xor
                                 w_and_out(5)(3) xor
                                 w_and_out(4)(4) xor
                                 w_and_out(3)(5) xor
                                 w_and_out(2)(6) xor
                                 w_and_out(1)(7);
        --calculation for x^9
        w_factors_overflow(1) <= w_and_out(7)(2) xor 
                                 w_and_out(6)(3) xor
                                 w_and_out(5)(4) xor
                                 w_and_out(4)(5) xor
                                 w_and_out(3)(6) xor
                                 w_and_out(2)(7);
        --calculation for x^10
        w_factors_overflow(2) <= w_and_out(7)(3) xor 
                                 w_and_out(6)(4) xor
                                 w_and_out(5)(5) xor
                                 w_and_out(4)(6) xor
                                 w_and_out(3)(7);
        --calculation for x^11
        w_factors_overflow(3) <= w_and_out(7)(4) xor 
                                 w_and_out(6)(5) xor
                                 w_and_out(5)(6) xor
                                 w_and_out(4)(7);
        --calculation for x^12
        w_factors_overflow(4) <= w_and_out(7)(5) xor 
                                 w_and_out(6)(6) xor
                                 w_and_out(5)(7);
        --calculation for x^13
        w_factors_overflow(5) <= w_and_out(7)(6) xor
                                 w_and_out(6)(7);
        --calculation for x^14
        w_factors_overflow(6) <= w_and_out(7)(7);

        o(0) <= w_and_out(0)(0) xor 
                w_factors_overflow(0) xor
                w_factors_overflow(4) xor
                w_factors_overflow(5) xor
                w_factors_overflow(6);

        o(1) <= w_and_out(0)(1) xor
                w_and_out(1)(0) xor 
                w_factors_overflow(1) xor
                w_factors_overflow(5) xor
                w_factors_overflow(6);

        o(2) <= w_and_out(2)(0) xor
                w_and_out(1)(1) xor
                w_and_out(0)(2) xor
                w_factors_overflow(0) xor
                w_factors_overflow(2) xor
                w_factors_overflow(4) xor
                w_factors_overflow(5);

        o(3) <= w_and_out(3)(0) xor
                w_and_out(2)(1) xor
                w_and_out(1)(2) xor
                w_and_out(0)(3) xor
                w_factors_overflow(0) xor
                w_factors_overflow(1) xor
                w_factors_overflow(3) xor
                w_factors_overflow(4);

        o(4) <= w_and_out(4)(0) xor
                w_and_out(3)(1) xor
                w_and_out(2)(2) xor
                w_and_out(1)(3) xor
                w_and_out(0)(4) xor
                w_factors_overflow(0) xor
                w_factors_overflow(1) xor
                w_factors_overflow(2) xor
                w_factors_overflow(6);

        o(5) <= w_and_out(5)(0) xor
                w_and_out(4)(1) xor
                w_and_out(3)(2) xor
                w_and_out(2)(3) xor
                w_and_out(1)(4) xor
                w_and_out(0)(5) xor
                w_factors_overflow(1) xor
                w_factors_overflow(2) xor
                w_factors_overflow(3);

        o(6) <= w_and_out(6)(0) xor
                w_and_out(5)(1) xor
                w_and_out(4)(2) xor
                w_and_out(3)(3) xor
                w_and_out(2)(4) xor
                w_and_out(1)(5) xor
                w_and_out(0)(6) xor
                w_factors_overflow(2) xor
                w_factors_overflow(3) xor
                w_factors_overflow(4);

        o(7) <= w_and_out(7)(0) xor
                w_and_out(6)(1) xor
                w_and_out(5)(2) xor
                w_and_out(4)(3) xor
                w_and_out(3)(4) xor
                w_and_out(2)(5) xor
                w_and_out(1)(6) xor
                w_and_out(0)(7) xor
                w_factors_overflow(3) xor
                w_factors_overflow(4) xor
                w_factors_overflow(5);
    end generate;

    gen_word_length_9: if WORD_LENGTH = 9 generate
        --galois field conversion
        --x^9 = x^4 + 1
        --0   => 0
        --x^0 => 1
        --x^1 => x
        --x^2 => x^2
        --x^3 => x^3
        --x^4 => x^4
        --x^5 => x^5
        --x^6 => x^6
        --x^7 => x^7
        --x^8 => x^8
        --x^9 => x^4 + 1
        --x^10 => x^5 + x
        --x^11 => x^6 + x^2
        --x^12 => x^7 + x^3
        --x^12 => x^8 + x^4
        --x^13 => x^5 + x^4 + 1
        --x^14 => x^6 + x^5 + x
        --x^15 => x^7 + x^6 + x^2
        --x^16 => x^8 + x^7 + x^3

        --calculation for x^9
        w_factors_overflow(0) <= w_and_out(8)(1) xor 
                                 w_and_out(7)(2) xor
                                 w_and_out(6)(3) xor
                                 w_and_out(5)(4) xor
                                 w_and_out(4)(5) xor
                                 w_and_out(3)(6) xor
                                 w_and_out(2)(7) xor
                                 w_and_out(1)(8);
        --calculation for x^10
        w_factors_overflow(1) <= w_and_out(8)(2) xor 
                                 w_and_out(7)(3) xor
                                 w_and_out(4)(4) xor
                                 w_and_out(5)(5) xor
                                 w_and_out(4)(6) xor
                                 w_and_out(3)(7) xor
                                 w_and_out(2)(8);
        --calculation for x^11
        w_factors_overflow(2) <= w_and_out(8)(3) xor 
                                 w_and_out(7)(4) xor
                                 w_and_out(6)(5) xor
                                 w_and_out(5)(6) xor
                                 w_and_out(4)(7) xor
                                 w_and_out(3)(8);
        --calculation for x^12
        w_factors_overflow(3) <= w_and_out(8)(4) xor 
                                 w_and_out(7)(5) xor
                                 w_and_out(6)(6) xor
                                 w_and_out(5)(7) xor
                                 w_and_out(4)(8);
        --calculation for x^13
        w_factors_overflow(4) <= w_and_out(8)(5) xor 
                                 w_and_out(7)(6) xor
                                 w_and_out(6)(7) xor
                                 w_and_out(5)(8);
        --calculation for x^14
        w_factors_overflow(5) <= w_and_out(8)(6) xor
                                 w_and_out(7)(7) xor
                                 w_and_out(6)(8);
        --calculation for x^15
        w_factors_overflow(6) <= w_and_out(8)(7) xor
                                 w_and_out(7)(8);

        --calculation for x^16
        w_factors_overflow(7) <= w_and_out(8)(8);

        o(0) <= w_and_out(0)(0) xor 
                w_factors_overflow(0) xor
                w_factors_overflow(5);

        o(1) <= w_and_out(0)(1) xor
                w_and_out(1)(0) xor 
                w_factors_overflow(1) xor
                w_factors_overflow(6);

        o(2) <= w_and_out(2)(0) xor
                w_and_out(1)(1) xor
                w_and_out(0)(2) xor
                w_factors_overflow(2) xor
                w_factors_overflow(7);

        o(3) <= w_and_out(3)(0) xor
                w_and_out(2)(1) xor
                w_and_out(1)(2) xor
                w_and_out(0)(3) xor
                w_factors_overflow(3) xor
                w_factors_overflow(8);

        o(4) <= w_and_out(4)(0) xor
                w_and_out(3)(1) xor
                w_and_out(2)(2) xor
                w_and_out(1)(3) xor
                w_and_out(0)(4) xor
                w_factors_overflow(0) xor
                w_factors_overflow(4) xor
                w_factors_overflow(5);

        o(5) <= w_and_out(5)(0) xor
                w_and_out(4)(1) xor
                w_and_out(3)(2) xor
                w_and_out(2)(3) xor
                w_and_out(1)(4) xor
                w_and_out(0)(5) xor
                w_factors_overflow(1) xor
                w_factors_overflow(5) xor
                w_factors_overflow(6);

        o(6) <= w_and_out(6)(0) xor
                w_and_out(5)(1) xor
                w_and_out(4)(2) xor
                w_and_out(3)(3) xor
                w_and_out(2)(4) xor
                w_and_out(1)(5) xor
                w_and_out(0)(6) xor
                w_factors_overflow(2) xor
                w_factors_overflow(6) xor
                w_factors_overflow(7);

        o(7) <= w_and_out(7)(0) xor
                w_and_out(6)(1) xor
                w_and_out(5)(2) xor
                w_and_out(4)(3) xor
                w_and_out(3)(4) xor
                w_and_out(2)(5) xor
                w_and_out(1)(6) xor
                w_and_out(0)(7) xor
                w_factors_overflow(3) xor
                w_factors_overflow(7) xor
                w_factors_overflow(8);

        o(8) <= w_and_out(8)(0) xor
                w_and_out(7)(1) xor
                w_and_out(6)(2) xor
                w_and_out(5)(3) xor
                w_and_out(4)(4) xor
                w_and_out(3)(5) xor
                w_and_out(2)(6) xor
                w_and_out(1)(7) xor
                w_and_out(0)(8) xor
                w_factors_overflow(4) xor
                w_factors_overflow(8);
    end generate;

    gen_word_length_10: if WORD_LENGTH = 10 generate
        --galois field conversion
        --x^10 = x^3 + 1
        --0   => 0
        --x^0 => 1
        --x^1 => x
        --x^2 => x^2
        --x^3 => x^3
        --x^4 => x^4
        --x^5 => x^5
        --x^6 => x^6
        --x^7 => x^7
        --x^8 => x^8
        --x^9 => x^0
        --x^10 => x^3 + 1
        --x^11 => x^4 + x
        --x^12 => x^5 + x^2
        --x^12 => x^6 + x^3
        --x^13 => x^7 + x^4
        --x^14 => x^8 + x^5
        --x^15 => x^9 + x^6
        --x^16 => x^7 + x^3 + 1
        --x^17 => x^8 + x^4 + x
        --x^18 => x^9 + x^5 + x^2

        --calculation for x^10
        w_factors_overflow(0) <= w_and_out(9)(1) xor 
                                 w_and_out(8)(2) xor
                                 w_and_out(7)(3) xor
                                 w_and_out(6)(4) xor
                                 w_and_out(5)(5) xor
                                 w_and_out(4)(6) xor
                                 w_and_out(3)(7) xor
                                 w_and_out(2)(8) xor
                                 w_and_out(1)(9);
        --calculation for x^11
        w_factors_overflow(1) <= w_and_out(9)(2) xor 
                                 w_and_out(8)(3) xor
                                 w_and_out(7)(4) xor
                                 w_and_out(6)(5) xor
                                 w_and_out(5)(6) xor
                                 w_and_out(4)(7) xor
                                 w_and_out(3)(8) xor
                                 w_and_out(2)(9);
        --calculation for x^12
        w_factors_overflow(2) <= w_and_out(9)(3) xor 
                                 w_and_out(8)(4) xor
                                 w_and_out(7)(5) xor
                                 w_and_out(6)(6) xor
                                 w_and_out(5)(7) xor
                                 w_and_out(4)(8) xor
                                 w_and_out(3)(9);
        --calculation for x^13
        w_factors_overflow(3) <= w_and_out(9)(4) xor 
                                 w_and_out(8)(5) xor
                                 w_and_out(7)(6) xor
                                 w_and_out(6)(7) xor
                                 w_and_out(5)(8) xor
                                 w_and_out(4)(9);
        --calculation for x^14
        w_factors_overflow(4) <= w_and_out(9)(5) xor 
                                 w_and_out(8)(6) xor
                                 w_and_out(7)(7) xor
                                 w_and_out(6)(8) xor
                                 w_and_out(5)(9);
        --calculation for x^15
        w_factors_overflow(5) <= w_and_out(9)(6) xor
                                 w_and_out(8)(7) xor
                                 w_and_out(7)(8) xor
                                 w_and_out(6)(9);
        --calculation for x^16
        w_factors_overflow(6) <= w_and_out(9)(7) xor
                                 w_and_out(8)(8) xor
                                 w_and_out(7)(9);

        --calculation for x^17
        w_factors_overflow(7) <= w_and_out(9)(8) xor
                                 w_and_out(8)(9);

        --calculation for x^18
        w_factors_overflow(8) <= w_and_out(9)(9);
        
        o(0) <= w_and_out(0)(0) xor 
                w_factors_overflow(0) xor
                w_factors_overflow(7);

        o(1) <= w_and_out(0)(1) xor
                w_and_out(1)(0) xor 
                w_factors_overflow(1) xor
                w_factors_overflow(8);

        o(2) <= w_and_out(2)(0) xor
                w_and_out(1)(1) xor
                w_and_out(0)(2) xor
                w_factors_overflow(2) xor
                w_factors_overflow(9);

        o(3) <= w_and_out(3)(0) xor
                w_and_out(2)(1) xor
                w_and_out(1)(2) xor
                w_and_out(0)(3) xor
                w_factors_overflow(0) xor
                w_factors_overflow(3) xor
                w_factors_overflow(7);

        o(4) <= w_and_out(4)(0) xor
                w_and_out(3)(1) xor
                w_and_out(2)(2) xor
                w_and_out(1)(3) xor
                w_and_out(0)(4) xor
                w_factors_overflow(1) xor
                w_factors_overflow(4) xor
                w_factors_overflow(8);

        o(5) <= w_and_out(5)(0) xor
                w_and_out(4)(1) xor
                w_and_out(3)(2) xor
                w_and_out(2)(3) xor
                w_and_out(1)(4) xor
                w_and_out(0)(5) xor
                w_factors_overflow(2) xor
                w_factors_overflow(5) xor
                w_factors_overflow(9);

        o(6) <= w_and_out(6)(0) xor
                w_and_out(5)(1) xor
                w_and_out(4)(2) xor
                w_and_out(3)(3) xor
                w_and_out(2)(4) xor
                w_and_out(1)(5) xor
                w_and_out(0)(6) xor
                w_factors_overflow(3) xor
                w_factors_overflow(6);

        o(7) <= w_and_out(7)(0) xor
                w_and_out(6)(1) xor
                w_and_out(5)(2) xor
                w_and_out(4)(3) xor
                w_and_out(3)(4) xor
                w_and_out(2)(5) xor
                w_and_out(1)(6) xor
                w_and_out(0)(7) xor
                w_factors_overflow(4) xor
                w_factors_overflow(7);

        o(8) <= w_and_out(8)(0) xor
                w_and_out(7)(1) xor
                w_and_out(6)(2) xor
                w_and_out(5)(3) xor
                w_and_out(4)(4) xor
                w_and_out(3)(5) xor
                w_and_out(2)(6) xor
                w_and_out(1)(7) xor
                w_and_out(0)(8) xor
                w_factors_overflow(5) xor
                w_factors_overflow(8);

        o(9) <= w_and_out(9)(0) xor
                w_and_out(8)(1) xor
                w_and_out(7)(2) xor
                w_and_out(6)(3) xor
                w_and_out(5)(4) xor
                w_and_out(4)(5) xor
                w_and_out(3)(6) xor
                w_and_out(2)(7) xor
                w_and_out(1)(8) xor
                w_and_out(0)(9) xor
                w_factors_overflow(6) xor
                w_factors_overflow(9);
    end generate;
    --TODO: WORD_LENGTH 0 and 1 should be covered here as well.
    gen_not_supported: if WORD_LENGTH > 10 generate
        o <= (others => '0');
    end generate;
end behavioral;
