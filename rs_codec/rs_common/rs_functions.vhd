library IEEE;
use IEEE.MATH_REAL.ceil;
use IEEE.MATH_REAL.log2;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.RS_CONSTANTS.gp_pow_2;
use work.RS_CONSTANTS.gp_pow_3;
use work.RS_CONSTANTS.gp_pow_4;
use work.RS_CONSTANTS.gp_pow_5;
use work.RS_CONSTANTS.gp_pow_6;
use work.RS_CONSTANTS.gp_pow_7;
use work.RS_CONSTANTS.gp_pow_8;
use work.RS_CONSTANTS.gp_pow_9;
use work.RS_CONSTANTS.gp_pow_10;
use work.RS_TYPES.all;

package RS_FUNCTIONS is
    function get_last_odd_array_index(t: natural) return natural;
	function get_t(two_times_t: natural) return natural;
	function get_szs(two_times_t: natural) return natural;
    function get_pow(size, n: natural) return integer;
    function get_word_length_from_rs_gf(n: natural; gf_type: RSGFSize) return natural;
end package RS_FUNCTIONS;

package body RS_FUNCTIONS is

    function get_last_odd_array_index(t: natural) return natural is
    begin
        if t = 0 or t = 1 then
            return 0;
        else
            return t/2 - 1 + (t mod 2);
        end if;
    end;

    function get_t(two_times_t: natural) return natural is
	begin
		  return integer(ceil(real(two_times_t/2)));
	end;
	 
	function get_szs(two_times_t: natural) return natural is
	begin
		  return integer(ceil(log2(real(TWO_TIMES_T+1))));
	end;
	 
    function get_word_length_from_rs_gf(n: natural; gf_type: RSGFSize) return natural is
        variable word_length : natural := 0;
    begin
        case gf_type is
            when RS_GF_4 =>
                word_length := 4;
            when RS_GF_8 =>
                word_length := 8;
            when RS_GF_16 =>
                word_length := 16;
            when RS_GF_32 =>
                word_length := 32;
            when RS_GF_64 =>
                word_length := 64;
            when RS_GF_128 =>
                word_length := 128;
            when RS_GF_256 =>
                word_length := 256;
            when RS_GF_512 =>
                word_length := 512;
            when RS_GF_1024 =>
                word_length := 1024;
            when RS_GF_NONE =>
                word_length := integer(ceil(log2(real(n + 1))));
                return word_length;
            when others =>
                report "ASSERTION FAILURE: Undefined RSGFSize." severity failure;
                return 0;
        end case;
        if (word_length <= n) then
            report "ASSERTION FAILURE: Galois field size does no support." severity failure;
        end if;
        return integer(log2(real(word_length)));
    end;

    function get_pow(size, n: natural) return integer is
    begin
        case size is
            when 2 =>
                return gp_pow_2(n);
            when 3 =>
                return gp_pow_3(n);
            when 4 =>
                return gp_pow_4(n);
            when 5 =>
                return gp_pow_5(n);
            when 6 =>
                return gp_pow_6(n);
            when 7 =>
                return gp_pow_7(n);
            when 8 =>
                return gp_pow_8(n);
            when 9 =>
                return gp_pow_9(n);
            when 10 =>
                return gp_pow_10(n);
            when others =>
                return 0;
        end case;
        return 0;
    end function;
end package body RS_FUNCTIONS;
