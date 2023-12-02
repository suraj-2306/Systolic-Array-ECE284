// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module sfu (
    out,
    in,
    acc,
    relu,
    clk,
    reset
);

  parameter bw = 4;
  parameter psum_bw = 16;

  input clk;
  input acc;
  input relu;
  input reset;

  input signed [psum_bw-1:0] in;

  output signed [psum_bw-1:0] out;

  reg signed [psum_bw-1:0] psum_q;

  always @(posedge clk) begin
    if (reset) psum_q <= 0;
    else if (acc) psum_q <= psum_q + in;
    else if (relu & 0 > psum_q) psum_q = 0;
  end

  assign out = psum_q;
  // Your code goes here

endmodule
