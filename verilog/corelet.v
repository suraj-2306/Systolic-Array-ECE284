//We need add the 
//On the other hand, a corelet.v includes all the other blocks (e.g., L0, 2d PE array, ofifo) other than SRAMs.
// module l0 (clk, in, out, rd, wr, o_full, reset, o_ready);
module corelet (
    input clk
);

  parameter col = 8;
  parameter row = 8;
  parameter bw = 4;
  parameter psum_bw = 16;
  parameter total_cycle = 64;
  parameter total_cycle_2nd = 8;


  reg [bw*row-1:0] w_vector_bin;
  wire [bw*row-1:0] l0out;
  reg l0rd = 0;
  reg l0wr = 0;
  reg l0reset = 0;
  wire l0full;
  wire l0ready;


  //l0 operations. Input can be the instructions or data
  l0 #(
      .bw(bw)
  ) l0_instance (
      .clk(clk),
      .in(w_vector_bin),
      .out(l0out),
      .rd(l0rd),
      .wr(l0wr),
      .o_full(l0full),
      .reset(l0reset),
      .o_ready(l0ready)
  );


  reg [col*bw-1:0] ofwr;
  reg ofrd;
  reg    ofreset;
  wire [col*psum_bw-1:0] ofin;
  wire   [col*psum_bw-1:0] ofout;
  wire   ofo_full;
  wire   ofo_ready;
  wire   ofo_valid;

  ofifo #(
      .bw(bw)
  ) ofifo_instance (
      .clk(clk),
      .in(ofin),
      .out(ofout),
      .rd(ofrd),
      .wr(ofwr),
      .o_full(ofo_full),
      .reset(ofreset),
      .o_ready(ofo_ready),
      .o_valid(ofo_valid)
  );


  reg macreset;
  wire [psum_bw*col-1:0] macout_s;
  reg [row*bw-1:0] macin_w;  // inst[1]:execute, inst[0]: kernel loading
  reg [1:0] macinst_w;
  reg [psum_bw*col-1:0] macin_n;
  wire [col-1:0] macvalid;

  mac_array mac_array_instance (
      .clk(clk),
      .reset(macreset),
      .out_s(macout_s),
      .in_w(macin_w),
      .in_n(macin_n),
      .inst_w(macinst_w),
      .valid(macvalid)
  );

endmodule
