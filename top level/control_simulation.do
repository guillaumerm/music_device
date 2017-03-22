vlib work

vlog -timescale 1ns/1ns control.v

vsim control

log {/*}
add wave {/*}


force {clk} 0 0, 1 5 -repeat 10
force {reset} 0 0, 1 10
force {load_n} 1 0, 0 10 -repeat 20 -cancel 200
force {playback} 1 0, 0 20 -repeat 40 -cancel 200

run 200ns

force {load_n} 1
force {playback} 0

run 5000ns


