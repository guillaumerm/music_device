vlib work

vlog -timescale 1ns/1ns keyboard.v

vsim convert_keyboard_input

log {/*}
add wave {/*}

#
force {makeBreak} 0

run 20ns

# Key A
force {keyboard_code[7:0]} 16#1c
force {makeBreak} 0

run 20ns



force {makeBreak} 1

run 20ns


# Key G#
force {keyboard_code[7:0]} 16#3c
force {makeBreak} 0

run 20ns



force {makeBreak} 1

run 20ns




# Key Octave 2
force {keyboard_code[7:0]} 16#1E
force {makeBreak} 0

run 20ns



force {makeBreak} 1

run 20ns


# Key SPACE
force {keyboard_code[7:0]} 16#29
force {makeBreak} 0

run 20ns

force {makeBreak} 1
run 20ns
