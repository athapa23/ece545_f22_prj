onerror {resume}
add wave -divider -height 18;
add wave -position insertpoint CLK_PERIOD;
add wave -position insertpoint clk_100MHz;
add wave -position insertpoint error_count;
add wave -divider -height 18;
add wave -position insertpoint -expand -group {Testbench Input/Output} a_i_s;
add wave -position insertpoint -expand -group {Testbench Input/Output} x_i_s;
add wave -position insertpoint -expand -group {Testbench Input/Output} product_o_s;
add wave -divider -height 18;
add wave -position insertpoint -expand -group {Entity} duv/sg_ext_a;
add wave -position insertpoint -expand -group {Entity} duv/sg_ext_x;
add wave -position insertpoint -expand -group {Entity} duv/addra;
add wave -position insertpoint -expand -group {Entity} duv/addrb;
add wave -position insertpoint -expand -group {Entity} duv/douta;
add wave -position insertpoint -expand -group {Entity} duv/doutb;
add wave -position insertpoint -expand -group {Entity} duv/douta_b;
add wave -position insertpoint -expand -group {Entity} duv/div4;
add wave -divider -height 18;
add wave -position insertpoint -expand -group {ROM} duv/inst_square_block/*;
add wave -position insertpoint -expand -group {ROM} duv/inst_square_block/rom_array;

run -all;