`timescale 1 ns/1 ps

module core(input clk, input reset,input [36:0] inst, output ofifo_valid,
input [row*bw-1:0]D_xmem,
// input [row*psum_bw-1:0]D_pmem,
input start,
output wire [psum_bw*col-1:0] sfu_out
)
parameter bw = 4;
parameter col = 12;
parameter row = 48;
parameter psum_bw = 16;

reg clk = 0;
reg Icen_Q ; reg Iwen_Q ;
reg [36:0] inst,
wire [31:0] IQ;
wire ofifo_valid;
wire [6:0] addr_w_a;
wire CEN_w_a;
wire WEN_w_a;

assign CEN_w_a = inst[19];
assign WEN_w_a = inst[18];
assign addr_w_a = inst[17:7];

sram_32b_w128 sram_instance (
	.CLK(clk), 
	.CEN(CEN_w_a), 
	.WEN(WEN_w_a),
        .A(addr_w_a), 
        .D(D_xmem), 
        .Q(IQ));

corelet corelet_instance( .clk(clk),
    .start(start),
    .reset(reset),
    .l0rd(l0rd),
    .l0wr(l0wr),
    .l0in (IQ)
);
endmodule


// wire [bw*row-1:0] in_lo;
// wire CEN_psum;
// wire WEN_psum;
// wire [191:0] D_psum_1;
// wire [191:0] D_psum_2;
// wire [191:0] Q_psum;
// wire [191:0] Q;
// wire wr_lo;
// wire rd_lo;
// wire [psum_bw*col-1:0] psum_valid_vector;
// wire [10:0] addr_w_a;
// wire [10:0] addr_psum;
// wire ofifo_rd;
// wire acc;
// wire relu;
// wire residual;
// wire pmem_load;
// reg cap;

// assign ofifo_rd = inst[6];
// assign in_lo = Q;
// assign wr_lo = inst[2];
// assign rd_lo = inst[3];
// assign addr_w_a = inst[17:7];
// assign CEN_w_a = inst[19];
// assign WEN_w_a = inst[18];
// assign addr_psum = inst[30:20];
// assign CEN_psum = inst[32];
// assign WEN_psum = inst[31];
// //assign D_psum = relu ? sfp_out:psum_valid_vector;
// assign D_psum_1 = pmem_load? D_pmem : cap? sfp_out:psum_valid_vector;
// assign acc = inst[33];
// assign relu = inst[34];
// assign residual = inst[35];
// assign pmem_load = inst[36];

// always @(posedge clk)
//   cap = relu;
// corelet i_corelet
// (
// .clk(clk),
// .reset (reset),
// .in_lo (in_lo),
// .inst_w (inst[1:0]),
// .wr_lo (wr_lo),
// .rd_lo (rd_lo),
// .ofifo_rd(ofifo_rd),
// .psum_valid_vector(psum_valid_vector),
// .sfp_out(sfp_out),
// .psum_mem_q(Q_psum),
// //.residual_in(residual_in),
// .acc(acc),
// .residual(residual),
// .relu(relu)
// );


// sram_32b_w2048 i_sram_w_a 
// (
// .CLK	(clk), 
// .D	(D_xmem), 
// .Q	(Q), 
// .CEN	(CEN_w_a), 
// .WEN	(WEN_w_a), 
// .A	(addr_w_a)
// );
// sram_32b_w2048 #(.DATA_WIDTH(192)) i_sram_psum 
// (
// .CLK	(clk), 
// .D	(D_psum_1), 
// .Q	(Q_psum), 
// .CEN	(CEN_psum), 
// .WEN	(WEN_psum), 
// .A	(addr_psum)
// );



// endmodule
