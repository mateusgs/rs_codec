library IEEE;
use IEEE.STD_LOGIC_1164.all;

package RS_TYPES is
    type RSGFSize is (RS_GF_4,
                      RS_GF_8,
                      RS_GF_16,
                      RS_GF_32,
                      RS_GF_64,
                      RS_GF_128,
                      RS_GF_256,
                      RS_GF_512,
                      RS_GF_1024,
                      RS_GF_NONE);
end package RS_TYPES;
