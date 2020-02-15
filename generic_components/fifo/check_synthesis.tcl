clear -all
analyze -vhdl08 reg_fifo.vhd
elaborate -vhdl -top reg_fifo -parameter WORD_LENGTH 8 -parameter NUM_OF_ELEMENTS 10
get_design_info
#check_return {get_signal_info o_rd_data -width} 4
