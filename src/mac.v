// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac (out, a, b, c);

parameter bw = 4;
parameter psum_bw = 16;
parameter num_ch = 2;

output signed [psum_bw-1:0] out;
input signed  [bw-1:0] a;  // activation
input signed  [bw-1:0] b;  // weight
input signed  [psum_bw-1:0] c;


wire signed [2*bw:0] product;
wire signed [psum_bw-1:0] psum;
// wire signed [bw:0]   a_pad;

wire signed [(bw/num_ch):0] a_reg[num_ch-1:0];
wire signed [(bw/num_ch)-1:0] b_reg[num_ch-1:0];

assign a_reg[0] = {1'b0, a[3:0]};   // force to be unsigned number
assign a_reg[1] = {1'b0, a[7:4]};   // force to be unsigned number
assign b_reg[0] = b[3:0];
assign b_reg[1] = b[7:4];

assign product = a_reg[0]*b_reg[0] + a_reg[1]*b_reg[1];

// assign a_pad = {1'b0, a}; // force to be unsigned number
// assign product = a_pad * b;

assign psum = product + c;
assign out = psum;

endmodule
