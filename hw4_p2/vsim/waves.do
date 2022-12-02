onerror {resume}
add wave -divider -height 18;
add wave -position insertpoint CLK_PRD;
add wave -position insertpoint clk_100MHz;
add wave -position insertpoint error_count;
add wave -position insertpoint test_running;
add wave -divider -height 18;
add wave -position insertpoint -expand -group {Testbench Input/Output} init_i_s;
add wave -position insertpoint -expand -group {Testbench Input/Output} run_i_s;
add wave -position insertpoint -expand -group {Testbench Input/Output} z_i_s;
add wave -position insertpoint -expand -group {Testbench Input/Output} d_i_s;
add wave -position insertpoint -expand -group {Testbench Input/Output} r_o_s;
add wave -position insertpoint -expand -group {Testbench Input/Output} q_o_s;
add wave -divider -height 18;
add wave -position insertpoint -expand -group {Entity} duv/din;
add wave -position insertpoint -expand -group {Entity} duv/shift_msb;
add wave -position insertpoint -expand -group {Entity} duv/shift_lsb;
add wave -position insertpoint -expand -group {Entity} duv/shift_reg;
add wave -position insertpoint -expand -group {Entity} duv/div_reg;
add wave -position insertpoint -expand -group {Entity} duv/sum;
add wave -position insertpoint -expand -group {Entity} duv/load;
add wave -divider -height 18;
run -all;