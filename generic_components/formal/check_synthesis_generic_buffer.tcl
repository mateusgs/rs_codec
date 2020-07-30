clear -all
analyze -vhdl08 generic_buffer.vhd
elaborate -vhdl -top generic_buffer -parameter INPUT_LENGTH 8 -parameter OUTPUT_LENGTH 8 -parameter MEMORY_BIT_SIZE 80
get_design_info
