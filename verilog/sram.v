module sram(
  input   CLK,
  input   CEN,
  input   WEN,
  input   [bitwidth-1:0]  D,
  output  [bitwidth-1:0]  Q,
  input   [addr_bw-1:0]   A);

  parameter addr_bw = 7;
  parameter bitwidth = 32;
  parameter num_entries = 128;

  reg [bitwidth-1:0] memory [num_entries-1:0];
  reg [10:0] add_q;
  assign Q = memory[add_q];

  always @ (posedge CLK) begin

   if (!CEN && WEN) // read
      add_q <= A;
   if (!CEN && !WEN) // write
      memory[A] <= D;

  end

endmodule
