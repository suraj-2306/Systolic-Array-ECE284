
module core(
  input clk,
    input reset,
    input start,
    input TB_CL_SELECT,
    input   [31:0] TB_I_D,  
    input   [6:0]  TB_I_A,  
    input          TB_I_CEN,
    input          TB_I_WEN,
    output [31:0]  TB_I_Q,

    input   [31:0] TB_O_D,  
    input   [6:0]  TB_O_A,  
    input          TB_O_CEN,
    input          TB_O_WEN,
    output [31:0]  TB_O_Q
);

parameter bw = 4;
parameter col = 12;
parameter row = 48;
parameter psum_bw = 16;

sram_32b_w128 sram_ininstance (
	.CLK(clk), 
	.WEN(MUX_I_WEN), 
	.CEN(MUX_I_CEN),
  .A(MUX_I_A), 
  .D(MUX_I_D), 
  .Q(I_Q)
);

sram_128b_w16 sram_outinstance (
	.CLK(clk), 
	.WEN(MUX_O_WEN), 
	.CEN(MUX_O_CEN),
  .A(MUX_O_A), 
  .D(MUX_O_D), 
  .Q(O_Q)
);

assign TB_I_Q       =   I_Q;
assign TB_O_Q       =   O_Q;

corelet corelet_instance( .clk(clk),
    .start(start),
    .reset(reset),
    .I_A(CL_I_A), 
    .I_CEN(CL_I_CEN), 
    .I_Q(I_Q),
    .I_WEN(CL_I_WEN),

    .O_A(CL_O_A), 
    .O_CEN(CL_O_CEN), 
    .O_Q(O_Q),
    .O_WEN(CL_O_WEN)
);

    wire    [31:0]  I_Q;
    wire    [6:0]   CL_I_A;
    wire            CL_I_CEN;
    wire            CL_I_WEN;

    wire    [31:0]  MUX_I_D;  
    wire    [6:0]   MUX_I_A;
    wire            MUX_I_CEN;
    wire            MUX_I_WEN;

    wire    [127:0]  O_Q;
    wire    [3:0]   CL_O_A;
    wire            CL_O_CEN;
    wire            CL_O_WEN;

    wire    [127:0]  MUX_O_D;  
    wire    [3:0]   MUX_O_A;
    wire            MUX_O_CEN;
    wire            MUX_O_WEN;
    
  //assign MUX_I_Q      =   TB_CL_SELECT    ?   TB_I_Q      :   CL_I_Q      ;
    assign MUX_I_D      =   TB_I_D ; 
    assign MUX_I_A      =   TB_CL_SELECT    ?   TB_I_A   :   CL_I_A   ;
    assign MUX_I_CEN    =   TB_CL_SELECT    ?   TB_I_CEN    :   CL_I_CEN    ;
    assign MUX_I_WEN    =   TB_CL_SELECT    ?   TB_I_WEN    :   CL_I_WEN    ;

  //assign MUX_O_Q      =   TB_CL_SELECT    ?   TB_O_Q      :   CL_O_Q      ;
    assign MUX_O_D      =   TB_O_D ; 
    assign MUX_O_A      =   TB_CL_SELECT    ?   TB_O_A   :   CL_O_A   ;
    assign MUX_O_CEN    =   TB_CL_SELECT    ?   TB_O_CEN    :   CL_O_CEN    ;
    assign MUX_O_WEN    =   TB_CL_SELECT    ?   TB_O_WEN    :   CL_O_WEN    ;
endmodule


