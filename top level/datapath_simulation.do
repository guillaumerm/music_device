vlib work

vlog -timescale 1ns/1ns datapath.v

vsim -L altera_mf_ver datapath

log {/*}
add wave {/*}

force {clk} 0 0, 1 5 -repeat 10
force {note_data[3:0]} 2#0001
force {octave_data[1:0]} 2#00 
force {ld_note} 0
force {ld_play} 0
force {note_counter[3:0]} 2#0000 
force {reset} 0

run 20ns

force {note_data[3:0]} 2#0001
force {octave_data[1:0]} 2#00 
force {ld_note} 0
force {ld_play} 0
force {note_counter[3:0]} 2#0000  
force {reset} 1

run 20ns

force {note_data[3:0]} 2#0001
force {octave_data[1:0]} 2#00 
force {ld_note} 1
force {ld_play} 0
force {note_counter[3:0]} 2#0000  
run 20ns

force {note_data[3:0]} 2#0001
force {octave_data[1:0]} 2#00 
force {ld_note} 0
force {ld_play} 0
force {note_counter[3:0]} 2#0000  
run 20ns

force {note_data[3:0]} 2#0011
force {octave_data[1:0]} 2#00 
force {ld_note} 1
force {ld_play} 0
force {note_counter[3:0]} 2#0000 
run 20ns

force {note_data[3:0]} 2#0011
force {octave_data[1:0]} 2#00 
force {ld_note} 0
force {ld_play} 0
force {note_counter[3:0]} 2#0000  
run 20ns
force {note_data[3:0]} 2#0011
force {octave_data[1:0]} 2#00 
force {ld_note} 0
force {ld_play} 1
force {note_counter[3:0]} 2#0000  
run 20ns

force {note_data[3:0]} 2#0011
force {octave_data[1:0]} 2#00 

force {note_counter[3:0]} 2#0001  
run 20ns