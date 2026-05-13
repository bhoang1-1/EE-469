# Create work library
vlib work

# Compile Verilog
#     All Verilog files that are part of this design should have
#     their own "vlog" line below.
vlog "./D_FF.sv"
vlog "./mux2_1.sv"
vlog "./mux2_1_5.sv"
vlog "./mux2_1_64.sv"
vlog "./mux32_1.sv"
vlog "./decoder5_32.sv"
vlog "./full_adder.sv"
vlog "./adder.sv"
vlog "./alu_bitslice.sv"
vlog "./alu.sv"
vlog "./register_32.sv"
vlog "./regfile.sv"
vlog "./flags.sv"
vlog "./math.sv"
vlog "./pc.sv"
vlog "./signextend.sv"
vlog "./instructmem.sv"
vlog "./datamem.sv"
vlog "./control.sv"
vlog "./cpu.sv"
vlog "./testbench.sv"


# Call vsim to invoke simulator
#     Make sure the last item on the line is the name of the
#     testbench module you want to execute.
vsim -voptargs="+acc" -t 1ps -lib work testbench

# Source the wave do file
#     This should be the file that sets up the signal window for
#     the module you are testing.
do testbench_wave.do

# Set the window types
view wave
view structure
view signals

# Run the simulation
run -all

# End
