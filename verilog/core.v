
module core(input clk,
  input reset,
input start,
    input   [31:0]  TB_I_D,  
    input   [6:0]  TB_I_A,  
    input           TB_I_CEN,
    input           TB_I_WEN,
    output [31:0]  TB_I_Q
);

parameter bw = 4;
parameter col = 12;
parameter row = 48;
parameter psum_bw = 16;


sram_32b_w128 sram_instance (
	.CLK(clk), 
	.CEN(TB_I_CEN), 
	.WEN(TB_I_WEN),
        .A(TB_I_A), 
        .D(TB_I_D), 
        .Q(TB_I_Q));

corelet corelet_instance( .clk(clk),
    .start(start),
    .reset(reset),
    .l0rd(l0rd),
    .l0wr(l0wr),
    .l0in (TB_I_Q)
);
endmodule


