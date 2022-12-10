# ****************************************************************************
#
# The XDC files sets the timing constraints for the XTEA
#
# ****************************************************************************

# ****************************************************************************
# Create Clocks
# ****************************************************************************

# Create Clocks for the reference clocks
create_clock -period 10 -waveform {0.0 5.0} [get_ports clk]

# ****************************************************************************
# Input and Output Delays
# ****************************************************************************

# -------------------------------------------------------------------
# Input Delays
# -------------------------------------------------------------------

set_input_delay  0 -clock [get_clocks clk] [get_ports reset]
set_input_delay  0 -clock [get_clocks clk] [get_ports M]
set_input_delay  0 -clock [get_clocks clk] [get_ports write_M]
set_input_delay  0 -clock [get_clocks clk] [get_ports Ki]
set_input_delay  0 -clock [get_clocks clk] [get_ports write_Ki]
set_input_delay  0 -clock [get_clocks clk] [get_ports i]

# -------------------------------------------------------------------
# Output Delays
# -------------------------------------------------------------------

set_output_delay 0 -clock [get_clocks clk] [get_ports done]
set_output_delay 0 -clock [get_clocks clk] [get_ports C]

