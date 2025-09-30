############################################################
# RS Codec Synthesis Sweep (Synopsys Design Compiler)
#
# - Reads sweep configurations from a text file
# - For each config: sets libraries, generates generic types,
#   analyzes/elaborates VHDL, compiles, and writes reports
# - Produces power, area, and timing reports per run
#
# Usage:
#   dc_shell -f scripts/run_sweep_asap7.tcl \
#     -x "set CONFIG_FILE sweep_configs_asap7.txt" \
#     -x "set OUT_ROOT data/asap7_sweep"
# Or, for Nangate45, use the convenience wrapper:
#   dc_shell -f scripts/run_nangate45.tcl
#
# Config file format (whitespace separated; # for comments):
#   N K GF_WIDTH clock_ps [library_dir] [top]
#
# Examples:
#   15 11 4 2000.0 /path/to/asap7/.../LIB/CCS/TT             rs_encoder_wrapper
#   15 11 4 8000.0 /path/to/NanGate45-Synopsys.../NanGate45/db rs_decoder_plus_syndrome
#
############################################################

# --------- User/Env overrides ---------
if {![info exists CONFIG_FILE]} {
  set CONFIG_FILE "sweep_configs_asap7.txt"
}
if {![info exists OUT_ROOT]} {
  set OUT_ROOT "data/asap7_sweep"
}
if {![info exists SUMMARY_FILE]} {
  set SUMMARY_FILE "$OUT_ROOT/summary.csv"
}
if {![info exists DEFAULT_LIB_DIR]} {
  # Optional: falls back when a config line omits the lib dir
  set DEFAULT_LIB_DIR ""
}
# Clock must be specified per config; no default

# --------- Paths ---------
set REPO_ROOT [pwd]
set RTL_ROOT  $REPO_ROOT
set GEN_TYPES_TEMPLATE "$RTL_ROOT/generic_components/rtl/generic_types_basic.vhd"
set WRAPPER_TEMPLATE   "$RTL_ROOT/rs_codec/rtl/rs_encoder_wrapper.vhd"

# Curated VHDL source list (order matters for packages/components)
proc get_vhdl_files {rtl_root generated_generic_types generated_wrapper_path top maybe_gen_encoder maybe_gen_decoder} {
  set files [list]
  # Generated generic_types must precede users of the package
  lappend files $generated_generic_types
  lappend files \
    "$rtl_root/generic_components/rtl/generic_functions.vhd" \
    "$rtl_root/generic_components/rtl/generic_components.vhd" \
    "$rtl_root/generic_components/rtl/async_dff.vhd" \
    "$rtl_root/generic_components/rtl/d_sync_flop.vhd" \
    "$rtl_root/generic_components/rtl/no_rst_dff.vhd" \
    "$rtl_root/generic_components/rtl/config_dff_array.vhd" \
    "$rtl_root/generic_components/rtl/sync_dff_array.vhd" \
    "$rtl_root/generic_components/rtl/reg_fifo_array.vhd" \
    "$rtl_root/generic_components/rtl/reg_fifo.vhd" \
    "$rtl_root/rs_codec/rtl/rs_types.vhd" \
    "$rtl_root/rs_codec/rtl/rs_constants.vhd" \
    "$rtl_root/rs_codec/rtl/rs_functions.vhd" \
    "$rtl_root/rs_codec/rtl/rs_components.vhd" \
    "$rtl_root/rs_codec/rtl/rs_adder.vhd" \
    "$rtl_root/rs_codec/rtl/rs_inverse.vhd" \
    "$rtl_root/rs_codec/rtl/rs_full_multiplier_core.vhd" \
    "$rtl_root/rs_codec/rtl/rs_full_multiplier.vhd" \
    "$rtl_root/rs_codec/rtl/rs_multiplier_lut.vhd" \
    "$rtl_root/rs_codec/rtl/rs_multiplier.vhd" \
    "$rtl_root/rs_codec/rtl/rs_reduce_adder.vhd" \
    "$rtl_root/rs_codec/rtl/rs_remainder_unit.vhd" \
    "$rtl_root/rs_codec/rtl/rs_syndrome_subunit.vhd" \
    "$rtl_root/rs_codec/rtl/rs_syndrome.vhd" \
    "$rtl_root/rs_codec/rtl/rs_berlekamp_massey.vhd" \
    "$rtl_root/rs_codec/rtl/rs_chien.vhd" \
    "$rtl_root/rs_codec/rtl/rs_forney.vhd" \
    "$rtl_root/rs_codec/rtl/rs_chien_forney.vhd" \
    "$rtl_root/rs_codec/rtl/rs_codec.vhd"

  # Include generated wrapper only when targeting the wrapper top
  if {$top eq "rs_encoder_wrapper" && [file exists $generated_wrapper_path]} {
    lappend files $generated_wrapper_path
  }

  # Always include encoder and decoder entities (prefer generated variants)
  if {$maybe_gen_encoder ne "" && [file exists $maybe_gen_encoder]} {
    lappend files $maybe_gen_encoder
  } else {
    lappend files "$rtl_root/rs_codec/rtl/rs_encoder.vhd"
  }
  if {$maybe_gen_decoder ne "" && [file exists $maybe_gen_decoder]} {
    lappend files $maybe_gen_decoder
  } else {
    lappend files "$rtl_root/rs_codec/rtl/rs_decoder.vhd"
  }
  return $files
}

# Interpret GF value from config as BIT WIDTH (e.g., 4 -> 4-bit symbols)
# Clamp to supported range [2..10]. Return width-1 for generic_types generation.
proc gf_width_to_word_width_minus1 {width_bits} {
  if {$width_bits < 2} { set width_bits 2 }
  if {$width_bits > 10} { set width_bits 10 }
  return [expr {$width_bits - 1}]
}

# Map bit width to RS_GF literal name
proc gf_width_to_literal {width_bits} {
  if {$width_bits < 2} { set width_bits 2 }
  if {$width_bits > 10} { set width_bits 10 }
  switch -- $width_bits \
    2  { return RS_GF_4 } \
    3  { return RS_GF_8 } \
    4  { return RS_GF_16 } \
    5  { return RS_GF_32 } \
    6  { return RS_GF_64 } \
    7  { return RS_GF_128 } \
    8  { return RS_GF_256 } \
    9  { return RS_GF_512 } \
    10 { return RS_GF_1024 } \
    default { return RS_GF_1024 }
}

proc mkdir_p {path} {
  if {![file isdirectory $path]} {
    file mkdir $path
  }
}

proc basename {path} {
  return [file tail $path]
}

proc sanitize {s} {
  regsub -all {[^A-Za-z0-9_.-]} $s _ s2
  return $s2
}

# Configure link/target libraries given a directory of compiled .db files (no .lib)
proc setup_libs {lib_dir} {
  upvar 1 link_library link_library target_library target_library

  # Reset
  set link_library [list *]
  set target_library [list]

  if {$lib_dir eq ""} { return }
  if {![file exists $lib_dir]} {
    puts "[format {WARN: Library dir not found: %s} $lib_dir]"
    return
  }

  # Recursively collect .db files only
  proc __collect_libs {dirVar path} {
    upvar 1 $dirVar libs
    foreach f [glob -nocomplain -directory $path *] {
      if {[file isdirectory $f]} {
        __collect_libs libs $f
      } else {
        set ext [file extension $f]
        if {$ext eq ".db"} {
          lappend libs $f
        }
      }
    }
  }

  set libs [list]
  __collect_libs libs $lib_dir

  if {[llength $libs] == 0} {
    puts "[format {WARN: No compiled .db found under: %s} $lib_dir]"
    return
  }

  # De-duplicate and sort for stability
  set uniq {}
  foreach f $libs {
    if {[lsearch -exact $uniq $f] < 0} { lappend uniq $f }
  }
  set libs $uniq

  # Append to link and target, and set DC app vars
  foreach f $libs {
    lappend link_library $f
    lappend target_library $f
  }

  # Ensure DC sees these values
  set_app_var link_library $link_library
  set_app_var target_library $target_library

  # Help DC find includes by adding directory to search_path
  set cur_sp [get_app_var search_path]
  set_app_var search_path [concat $cur_sp [list $lib_dir]]

  puts "[format {INFO: Loaded %d .db libraries from %s} [llength $libs] $lib_dir]"
}

# Generate a run-specific generic_types.vhd and an optional wrapper with RS_GF literal substituted
proc generate_supporting_sources {gf_width out_dir types_template wrapper_template} {
  # RS GF bit-width for entity generics
  set word_width_m1 [gf_width_to_word_width_minus1 $gf_width]
  set gf_literal   [gf_width_to_literal $gf_width]

  # IMPORTANT: generic_types.vhd must use a max width wide enough for all designs
  # in this repo because some code zeroes slices up to bit 9 regardless of GF.
  # Keep max_word as 10 bits (9 downto 0) to avoid out-of-range errors.
  set max_word_upper 9

  set gen_types "$out_dir/generic_types.vhd"
  set gen_wrap  "$out_dir/rs_encoder_wrapper_gen.vhd"
  set gen_enc   "$out_dir/rs_encoder_gen.vhd"
  set gen_dec   "$out_dir/rs_decoder_gen.vhd"

  mkdir_p $out_dir
  # Generate generic_types.vhd with a fixed max_word width (9 downto 0)
  set sed_ok 0
  if {[file exists $types_template]} {
    catch {exec sed "s/WORD_WIDTH_PLACEHOLDER/$max_word_upper/g" $types_template > $gen_types} sed_rc
    if {[file exists $gen_types]} { set sed_ok 1 }
  }
  if {!$sed_ok} {
    # Fallback to Tcl-generation if sed is not available
    set fin  [open $types_template r]
    set data [read $fin]
    close $fin
    set data [string map [list WORD_WIDTH_PLACEHOLDER $max_word_upper] $data]
    set fout [open $gen_types w]
    puts $fout $data
    close $fout
  }

  # Optionally generate a wrapper where default RS_GF is replaced
  if {[file exists $wrapper_template]} {
    set fin  [open $wrapper_template r]
    set data [read $fin]
    close $fin
    set data [string map [list RS_GF_NONE $gf_literal] $data]
    set fout [open $gen_wrap w]
    puts $fout $data
    close $fout
  }

  # Generate encoder/decoder variants with RS_GF default substituted
  set enc_src "$::RTL_ROOT/rs_codec/rtl/rs_encoder.vhd"
  if {[file exists $enc_src]} {
    set fin  [open $enc_src r]
    set data [read $fin]
    close $fin
    set data [string map [list RS_GF_NONE $gf_literal] $data]
    set fout [open $gen_enc w]
    puts $fout $data
    close $fout
  }

  set dec_src "$::RTL_ROOT/rs_codec/rtl/rs_decoder.vhd"
  if {[file exists $dec_src]} {
    set fin  [open $dec_src r]
    set data [read $fin]
    close $fin
    set data [string map [list RS_GF_NONE $gf_literal] $data]
    set fout [open $gen_dec w]
    puts $fout $data
    close $fout
  }

  return [list $gen_types $gen_wrap $gen_enc $gen_dec]
}

proc elaborate_with_generics {top n k gf_width clk_ns} {
  # Elaborate different tops with appropriate generics
  set two_t [expr {$n - $k}]
  set word_width [expr {[gf_width_to_word_width_minus1 $gf_width] + 1}]
  set gf_literal [gf_width_to_literal $gf_width]

  switch -- $top \
    rs_encoder_wrapper {
      # Wrapper default RS_GF already substituted in generated copy; pass N/K only
      elaborate rs_encoder_wrapper -parameters "N=$n,K=$k"
    } \
    rs_encoder {
      # Use generated encoder copy with RS_GF substituted, pass N/K only
      elaborate rs_encoder -parameters "N=$n,K=$k"
    } \
    rs_decoder {
      # Use generated decoder copy with RS_GF substituted, pass N/K only
      elaborate rs_decoder -parameters "N=$n,K=$k"
    } \
    rs_syndrome {
      # Requires concrete WORD_LENGTH and TWO_TIMES_T. Use 1 for boolean true in DC parameter list.
      elaborate rs_syndrome -parameters "N=$n,K=$k,WORD_LENGTH=$word_width,TWO_TIMES_T=$two_t,OUTPUT_PARITY_SYMBOLS=1"
    } \
    rs_syndrome_unit {
      elaborate rs_syndrome_unit -parameters "WORD_LENGTH=$word_width,TWO_TIMES_T=$two_t"
    } \
    default {
      # Attempt to elaborate arbitrary entity name with N/K if it accepts them
      catch { elaborate $top -parameters "N=$n,K=$k" } rc
    }
}

proc run_one_config {idx n k gf_width clock_ps lib_dir top} {
  global REPO_ROOT RTL_ROOT OUT_ROOT GEN_TYPES_TEMPLATE WRAPPER_TEMPLATE

  set two_t       [expr {$n - $k}]
  set word_width  [expr {[gf_width_to_word_width_minus1 $gf_width] + 1}]
  set clk_ns      [expr {$clock_ps / 1000.0}]

  set corner      [basename $lib_dir]
  if {$corner eq ""} { set corner "lib" }

  set label [format "N%02d_K%02d_GF%d_TT2T%03d_CLK%.3fns_%s_%s" \
                 $n $k $gf_width $two_t $clk_ns [sanitize $corner] [sanitize $top]]

  set run_root "$OUT_ROOT/$label"

  # Dry-run mode for environments without DC (e.g., to validate parsing)
  if {[info exists ::DRY_RUN] && $::DRY_RUN} {
    puts "DRY_RUN: idx=$idx label=$label N=$n K=$k GF=$gf_width clk_ns=$clk_ns lib=[expr {$lib_dir eq "" ? "(none)" : $lib_dir}] top=$top"
    return
  }
  set work_dir "$run_root/.WORK"
  set gen_dir  "$run_root/generated"
  set rpt_dir  "$run_root/reports"

  mkdir_p $run_root
  mkdir_p $gen_dir
  mkdir_p $rpt_dir
  # Clean and recreate WORK to avoid re-analysis warnings across reruns
  if {[file exists $work_dir]} { file delete -force $work_dir }
  file mkdir $work_dir

  # Setup libraries
  set link_library [list *]
  set target_library [list]
  setup_libs $lib_dir

  # Fresh WORK library per run
  define_design_lib WORK -path $work_dir

  # Clean out any previously elaborated designs from this DC session
  catch { remove_design -all }

  # HDL language settings
  set_app_var hdlin_vhdl_std 2008

  # Generate supporting sources for this GF setting
  foreach {generated_types generated_wrapper generated_encoder generated_decoder} \
          [generate_supporting_sources $gf_width $gen_dir $GEN_TYPES_TEMPLATE $WRAPPER_TEMPLATE] { break }

  # Determine elaboration top early (for source list selection)
  set elab_top [map_top_alias $top]

  # Source list
  set vhdl_sources [get_vhdl_files $RTL_ROOT $generated_types $generated_wrapper $elab_top $generated_encoder $generated_decoder]

  # Analyze
  analyze -f vhd -library WORK $vhdl_sources

  # Elaborate chosen top
  if {[catch {elaborate_with_generics $elab_top $n $k $gf_width $clk_ns} elab_err]} {
    puts "[format {ERROR: Elaborate failed for top '%s' (N=%d K=%d GF=%d): %s} $top $n $k $gf_width $elab_err]"
    return
  }
  # Ensure current_design is set explicitly and stays on target top
  catch { current_design $elab_top }
  set cur_top [get_object_name [current_design]]
  puts "[format {INFO: Elaborated top: %s (current_design=%s)} $elab_top $cur_top]"
  # Guard: if requested top didn't elaborate, abort this run (prevents mis-attributed reports)
  if {![string match ${elab_top}* $cur_top]} {
    puts "[format {ERROR: Requested top '%s' did not elaborate; current_design=%s. Check missing RTL (e.g., rs_euclidean.vhd for decoder).} $elab_top $cur_top]"
    return
  }

  # Link
  link

  # Basic constraints (clk/rst)
  set CLK_PIN clk
  set RST_PIN rst
  create_clock -name clk -period $clk_ns [get_ports $CLK_PIN]
  set_dont_touch [get_ports $RST_PIN]
  set_ideal_network [get_ports $RST_PIN]
  set_false_path -from [get_ports $RST_PIN]
  set_max_fanout 20 [current_design]

  # Power: assume random data on data inputs only and standard clock switching
  # - Data ports (e.g., i_symbol*): P=0.5, toggle_rate=0.5 toggles/cycle
  # - Other primary inputs (control/handshake): no switching
  # - Reset: no switching
  # Use toggle rate per-ns to match typical DC expectations.
  set trand_toggle_rate [expr {0.5 / $clk_ns}]
  catch {
    set all_in   [all_inputs]
    set clk_port [get_ports $CLK_PIN]
    set rst_port [get_ports $RST_PIN]
    set data_ports [get_ports -quiet {i_symbol*}]
    if {[sizeof_collection $data_ports] > 0} {
      set_switching_activity -static_probability 0.5 -toggle_rate $trand_toggle_rate $data_ports
    }
    set non_data [remove_from_collection $all_in [list $clk_port $rst_port $data_ports]]
    if {[sizeof_collection $non_data] > 0} {
      set_switching_activity -static_probability 0.0 -toggle_rate 0.0 $non_data
    }
    if {[sizeof_collection $rst_port] > 0} {
      set_switching_activity -static_probability 0.0 -toggle_rate 0.0 $rst_port
    }
    # Drive common handshake ports to active/non-stalling states
    foreach patt {i_consume* i_valid*} {
      set p [get_ports -quiet $patt]
      if {[sizeof_collection $p] > 0} {
        set_switching_activity -static_probability 1.0 -toggle_rate 0.0 $p
      }
    }
    foreach patt {i_start_codeword* i_end_codeword* i_symbol_fifo_full* i_syndrome_fifo_full* i_number_of_symbols_fifo_full*} {
      set p [get_ports -quiet $patt]
      if {[sizeof_collection $p] > 0} {
        set_switching_activity -static_probability 0.0 -toggle_rate 0.0 $p
      }
    }
  }
  # Increase power analysis effort
  catch { set_power_analysis_options -analysis_effort medium }

  # Optional user constraints in CWD
  if {[file exists "constraints.tcl"]} {
    source constraints.tcl
  }

  # Compile
  uniquify
  compile_ultra -no_autoungroup -no_boundary_optimization
  # Reassert current_design in case compile changes focus
  catch { current_design $elab_top }

  # Reports and outputs
  set topModule [get_object_name [current_design]]
  # Preserve label using requested top name; topModule may differ if alias is used
  write -f ddc -o "$run_root/$topModule.compile.ddc" -hierarchy
  report_qor                      > "$rpt_dir/${topModule}_qor.rep"
  report_timing -significant_digits 6 > "$rpt_dir/${topModule}_timing.rep"
  report_clock                   > "$rpt_dir/${topModule}_clock.rep"
  report_power -analysis_effort medium -significant_digits 6 > "$rpt_dir/${topModule}_power.rep"
  report_area -hierarchy             > "$rpt_dir/${topModule}_area.rep"
  report_path_group                 > "$rpt_dir/${topModule}_pathgroup.rep"

  # Export constraints and netlist
  set_app_var verilogout_no_tri true
  remove_ideal_network [all_clocks]
  set_propagated_clock [all_clocks]
  write_sdc -version 1.9 "$run_root/${topModule}.sdc"
  write -hierarchy -format verilog -output "$run_root/${topModule}.netlist.v"

  puts "[format {INFO: Completed run %d: %s} $idx $label]"

  # Summarize results into OUT_ROOT/summary.csv
  set summary $SUMMARY_FILE
  set summary_dir [file dirname $summary]
  if {$summary_dir ne ""} {
    mkdir_p $summary_dir
  }
  set area ""
  set wns  ""
  set pwr_mw ""

  # Parse area
  set fpath "$rpt_dir/${topModule}_area.rep"
  if {[file exists $fpath]} {
    set fin [open $fpath r]
    set txt [read $fin]
    close $fin
    if {[regexp {Total cell area:\s*([0-9.eE+\-]+)} $txt -> area_val]} {
      set area $area_val
    }
  }
  # Parse timing (first slack value)
  set fpath "$rpt_dir/${topModule}_timing.rep"
  if {[file exists $fpath]} {
    set fin [open $fpath r]
    set found 0
    while {[gets $fin line] >= 0} {
      if {$found} { break }
      if {[regexp {slack \([^)]*\)\s*(-?[0-9.eE+\-]+)} $line -> wns_val]} {
        set wns $wns_val
        set found 1
      }
    }
    close $fin
  }
  # Parse power (Total Dynamic Power)
  set fpath "$rpt_dir/${topModule}_power.rep"
  if {[file exists $fpath]} {
    set fin [open $fpath r]
    set txt [read $fin]
    close $fin
    if {[regexp {Total Dynamic Power\s*=\s*([0-9.eE+\-]+)\s*([kKmMuUnNpP]?W)} $txt -> pwr_val pwr_unit]} {
      set val $pwr_val
      switch -- $pwr_unit {
        W     { set pwr_mw [format %.6f [expr {$val * 1000.0}]] }
        kW    { set pwr_mw [format %.6f [expr {$val * 1000000.0}]] }
        KW    { set pwr_mw [format %.6f [expr {$val * 1000000.0}]] }
        mW    { set pwr_mw $val }
        uW    { set pwr_mw [format %.6f [expr {$val / 1000.0}]] }
        nW    { set pwr_mw [format %.9f [expr {$val / 1000000.0}]] }
        default { set pwr_mw $val }
      }
    }
  }

  # Append CSV line
  set need_header [expr {![file exists $summary]}]
  set fout [open $summary a]
  if {$need_header} {
    puts $fout "label,top,N,K,GF_WIDTH,CLK_NS,area,wns,total_dyn_mw"
  }
  puts $fout [format "%s,%s,%d,%d,%d,%.6f,%s,%s,%s" \
                     $label $top $n $k $gf_width $clk_ns \
                     [expr {$area eq "" ? "NA" : $area}] \
                     [expr {$wns  eq "" ? "NA" : $wns}] \
                     [expr {$pwr_mw eq "" ? "NA" : $pwr_mw}]]
  close $fout
}

# Map user-friendly top aliases to actual entities present in the RTL
proc map_top_alias {top} {
  switch -- $top \
    rs_decoder_plus_syndrome { return rs_decoder } \
    default { return $top }
}

# --------- Parse config file and run sweep ---------
if {![file exists $CONFIG_FILE]} {
  puts "[format {ERROR: Config file not found: %s} $CONFIG_FILE]"
  exit 1
}

set fh [open $CONFIG_FILE r]
set idx 0
while {[gets $fh line] >= 0} {
  # Strip comments and trim
  regsub {#.*$} $line "" line
  set line [string trim $line]
  if {$line eq ""} { continue }

  set toks [split $line]
  if {[llength $toks] < 4} {
    puts "[format {WARN: Skipping malformed line: '%s'} $line]"
    continue
  }

  set N        [lindex $toks 0]
  set K        [lindex $toks 1]
  set GF_WIDTH [lindex $toks 2]

  # Required clock value as 4th token
  set CLK_PS [lindex $toks 3]
  if {![string is double -strict $CLK_PS]} {
    puts "[format {WARN: Expected numeric clock_ps at token 4, got '%s' in line: %s} $CLK_PS $line]"
    continue
  }

  set LIB_DIR    ""
  set TOP_ENTITY "rs_encoder_wrapper"
  if {[llength $toks] >= 5} { set LIB_DIR   [lindex $toks 4] }
  if {[llength $toks] >= 6} { set TOP_ENTITY [lindex $toks 5] }
  if {$LIB_DIR eq "" && $DEFAULT_LIB_DIR ne ""} { set LIB_DIR $DEFAULT_LIB_DIR }

  incr idx
  catch {
    run_one_config $idx $N $K $GF_WIDTH $CLK_PS $LIB_DIR $TOP_ENTITY
  } err
  if {[info exists err] && $err ne ""} {
    puts "[format {ERROR: Run %d failed: %s} $idx $err]"
  }
}
close $fh

puts "[format {INFO: Sweep complete. Outputs under: %s} $OUT_ROOT]"
