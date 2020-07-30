clear -all
analyze -vhdl08 reg_fifo.vhd
elaborate -vhdl -top module_fifo_regs_no_flags -parameter g_WIDTH 4 -parameter g_DEPTH 32
check_return {get_signal_info o_rd_data -width} 4
