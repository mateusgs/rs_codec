proc get_parameters {} {
    set parameters [list]

    set iterators {{15 RS_GF_16} {31 RS_GF_32} {63 RS_GF_64} {127 RS_GF_128} {255 RS_GF_256}}
    puts "init"
    foreach it $iterators {
        set n [lindex $it 0]
        set init_k [expr {$n-2}]
        for {set k $init_k} {$k >= 1 && [expr {$n - $k}] <= 32} {incr k -2} {
            set N_arg [list N $n]
            set K_arg [list K $k]
            set RS_GF_arg [list RS_GF [lindex $it 1]]
            set param [list $N_arg $K_arg $RS_GF_arg]
            set parameters [linsert $parameters end $param]
        }
    }
    return $parameters
}