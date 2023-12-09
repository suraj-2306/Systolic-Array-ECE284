module l0_tb_v2;

  reg clk;
  reg reset;
  reg rd;
  reg wr;
  reg cascade;
  wire [31:0] out;
  reg [31:0] in;

  parameter bw = 4;

  l0 #(.bw(bw)) l0_instance (
    .clk(clk),
    .in(in),
    .out(out),
    .rd(rd),
    .wr(wr),
    .o_full(),
    .reset(reset),
    .o_ready(),
    .cascade(cascade));

  initial begin
    $dumpfile("l0_tb_v2.vcd");
    $dumpvars(0, l0_tb_v2);


    reset = 0;
    clk = 0;
    cascade = 1;

    #4 reset = 1;
    #4 reset = 0;

    // Write into L0
    rd = 0; wr = 1;

    #4 in = 'hAAAAAAAA;
    #4 in = 'hBBBBBBBB;
    #4 in = 'hCCCCCCCC;
    #4 in = 'hDDDDDDDD;

    // Read from L0
    #4 rd = 1; wr = 0;

    #100 $finish;

  end

  initial begin
    #2 forever #2 clk = ~clk;
  end

endmodule