vlib work

vlog -timescale 1ns/1ns freq_select.v

vsim freq_select

log {/*}
add wave {/*}


#HAPPY BIRTHDAY
# A second octave

force {note[3:0]} 0
force {octave[1]} 0
force {octave[0]} 1

run 10ns

# B second octave

force {note[3:0]} 2#0010

run 10ns

# A second octave

force {note[3:0]} 0


run 10ns

# D third octave

force {note[3:0]} 2#0101
force {octave[1]} 1
force {octave[0]} 0

run 10ns

# C# second octave

force {note[3:0]} 2#0100
force {octave[1]} 0
force {octave[0]} 1

run 10ns

#Rest/blank note

force {note[3:0]} 2#1111
force {octave[1]} 0
force {octave[0]} 1

run 10ns


