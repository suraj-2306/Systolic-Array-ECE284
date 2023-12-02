module mac_row (clk, out_s, in_w, in_n, valid, inst_w, reset);

  parameter bw = 4;
  parameter instr_bw = 2;
  parameter psum_bw = 16;
  parameter col = 8;

  input  clk, reset;
  output [psum_bw*col-1:0] out_s;
  output [col-1:0] valid;
  input  [bw-1:0] in_w; // inst[1]:execute, inst[0]: kernel loading
  input  [instr_bw-1:0] inst_w;
  input  [psum_bw*col-1:0] in_n;

  wire  [(col+1)*bw-1:0] temp;
  reg [col-1:0] validTemp = 8'b0;
  wire  [(col+1)*instr_bw-1:0] instr_temp;

  assign temp[bw-1:0]   = in_w;
  assign instr_temp[instr_bw-1:0]   = inst_w;

  genvar i;

    generate
  for (i=1; i < col+1 ; i=i+1) begin : col_num
      mac_tile #(.bw(bw), .psum_bw(psum_bw)) mac_tile_instance (
         .clk(clk),
         .reset(reset),
	 .in_w(temp[bw*i-1:bw*(i-1)]),
	 .out_e(temp[bw*(i+1)-1:bw*i]),
	 .inst_w(instr_temp[2*i-1:2*(i-1)]),
	 .inst_e(instr_temp[2*(i+1)-1:2*i]),
	 .in_n(in_n[psum_bw*i-1:psum_bw*(i-1)]),
	 .out_s(out_s[psum_bw*i-1:psum_bw*(i-1)]));
   assign  valid[i-1] = instr_temp[(i+1)*instr_bw-1];
  end
endgenerate

endmodule
