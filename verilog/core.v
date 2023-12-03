module core(input clk,
    input reset,
    input start,
    input TB_CL_SELECT,
    input   [31:0] TB_I_D,  
    input   [6:0]  TB_I_A,  
    input          TB_I_CEN,
    input          TB_I_WEN,
    output [31:0]  TB_I_Q
);

parameter bw = 4;
parameter col = 12;
parameter row = 48;
parameter psum_bw = 16;

sram_32b_w128 sram_instance (
	.CLK(clk), 
	.CEN(MUX_I_WEN), 
	.WEN(MUX_I_CEN),
  .A(MUX_I_A), 
  .D(MUX_I_D), 
  .Q(I_Q)
);

assign TB_I_Q       =   I_Q;

corelet corelet_instance( .clk(clk),
    .start(start),
    .reset(reset),
    .I_A(CL_I_A), 
    .I_CEN(CL_I_CEN), 
    .I_Q(I_Q),
    .I_WEN(CL_I_WEN)
);

    wire    [31:0]  I_Q;
    wire    [6:0]   CL_I_A;
    wire            CL_I_CEN;
    wire            CL_I_WEN;

    wire    [31:0]  MUX_I_D;  
    wire    [6:0]   MUX_I_A;
    wire            MUX_I_CEN;
    wire            MUX_I_WEN;
    
  //assign MUX_I_Q      =   TB_CL_SELECT    ?   TB_I_Q      :   CL_I_Q      ;
    assign MUX_I_D      =   TB_I_D ; 
    assign MUX_I_A      =   TB_CL_SELECT    ?   TB_I_A   :   CL_I_A   ;
    assign MUX_I_CEN    =   TB_CL_SELECT    ?   TB_I_CEN    :   CL_I_CEN    ;
    assign MUX_I_WEN    =   TB_CL_SELECT    ?   TB_I_WEN    :   CL_I_WEN    ;
endmodule


