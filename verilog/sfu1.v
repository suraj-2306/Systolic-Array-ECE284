
module sfu (
  output  [psum_bw*input_ch-1:0] psums_out,
  input signed  [psum_bw-1:0] psum_in,
  input   valid,
  input   send_out, // Rename as needed
  input   clk,
  input   reset
  );

  parameter bw = 4;
  parameter psum_bw = 16;
  parameter input_ch = 16;

  // Define reg bank for 16 input channels
  reg signed [psum_bw*input_ch-1:0] psums_out_reg;
  reg signed [psum_bw-1:0] reg_bank [input_ch-1:0];
  reg [psum_bw-1:0] relu_out;


  integer i,j;
  assign psums_out = psums_out_reg;

  initial begin
    i=0;
  end

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      // Reset all the psum regs to zero
      for (j=0; j < input_ch; j=j+1) begin
        reg_bank[j] = 0;
      end
      psums_out_reg = 0;
    end

    else if (valid) begin
      reg_bank[i] <=  reg_bank[i] + psum_in;
      if(i == (input_ch - 1))
        i <= 0;
      else
        i <= i + 1;
    end

    if (send_out) begin
      for (i=0; i<input_ch; i=i+1) begin
        psums_out_reg[psum_bw*i +: psum_bw] = reg_bank[i] ;
        // psums_out_reg[psum_bw*i +: psum_bw] = (reg_bank[i] > 0) ? reg_bank[i] : 0;
      end
    end
  end

endmodule

