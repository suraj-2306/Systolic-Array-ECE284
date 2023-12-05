module sfu_tb;

  parameter bw = 4;
  parameter psum_bw = 16;
  parameter input_ch = 16;
  parameter num_iters = 4;

  reg [psum_bw-1:0] psum_in;
  wire [psum_bw*input_ch-1:0] psums_out;
  reg valid;
  reg reset;

  integer psum_in_val = 0;
  integer i = 0;
  integer j = 0;
  integer validate[input_ch-1:0];
  reg send_out=0;
  reg clk=0;


  sfu #(.bw(bw), .psum_bw(psum_bw), .input_ch(input_ch)) sfu_instance(
    .psums_out(psums_out),
    .psum_in(psum_in),
    .valid(valid),
    .send_out(send_out),
    .clk(clk),
    .reset(reset)
  );

  initial begin
    $dumpfile("sfu_tb.vcd");
    $dumpvars(0, sfu_tb);
    $display("Entered the program!");

    // Init
    reset = 0;
    clk = 0;
    #10 reset = 1'b1;
    #3 reset = 0; valid = 1'b0;
    #1 valid = 1'b1;

    for (i=0; i<input_ch*num_iters; i=i+1) begin
      validate[i] = 0;
    end

    for (i=0; i<input_ch*num_iters; i=i+1) begin
      if (i > 60)
        psum_in_val = -100;
      else
        psum_in_val = i;

      psum_in = psum_in_val;
      validate[j] = validate[j] + psum_in_val;
      #4 j = j+1;
      if (j == input_ch) begin
        j = 0;
      end
    end
    send_out = 1'b1;
    valid = 1'b0;

    // Perform Relu operation on validate
    // NOTE: Disable for checking negative values.
    for (i=0; i<input_ch; i=i+1) begin
      if (validate[i] < 0)
        validate[i] = 0;
    end

    #4
    for (i=0; i<input_ch; i=i+1) begin
      if (validate[i] == psums_out[psum_bw*i +: psum_bw]) begin
        $display("Partial Sum output validated for reg %d: psum_out = %d", i, psums_out[psum_bw*i +: psum_bw]);
      end
      else begin
        $display("Partial Sum output NOT MATCHED for reg %d: psum_out = %d, validate = %d", i, psums_out[psum_bw*i +: psum_bw], validate[i]);
      end
    end
    #10 $finish;
  end

  initial begin #2
    forever #2 clk= ~clk;
  end

endmodule
