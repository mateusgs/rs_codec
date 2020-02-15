clear -all
analyze -vhdl08 async_dff.vhd
#-parameter assign values for generic
elaborate -vhdl -top dff -parameter N 3 
check_return {get_signal_info q -width} 4
