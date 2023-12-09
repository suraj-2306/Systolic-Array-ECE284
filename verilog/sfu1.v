
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
      reg_bank[0] = 0;
      reg_bank[1] = 0;
      reg_bank[2] = 0;
      reg_bank[3] = 0;
      reg_bank[4] = 0;
      reg_bank[5] = 0;
      reg_bank[6] = 0;
      reg_bank[7] = 0;
      reg_bank[8] = 0;
      reg_bank[9] = 0;
      reg_bank[10] = 0;
      reg_bank[11] = 0;
      reg_bank[12] = 0;
      reg_bank[13] = 0;
      reg_bank[14] = 0;
      reg_bank[15] = 0;
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
      psums_out_reg[psum_bw*0 +: psum_bw] = reg_bank[0] ;
      psums_out_reg[psum_bw*1 +: psum_bw] = reg_bank[1] ;
      psums_out_reg[psum_bw*2 +: psum_bw] = reg_bank[2] ;
      psums_out_reg[psum_bw*3 +: psum_bw] = reg_bank[3] ;
      psums_out_reg[psum_bw*4 +: psum_bw] = reg_bank[4] ;
      psums_out_reg[psum_bw*5 +: psum_bw] = reg_bank[5] ;
      psums_out_reg[psum_bw*6 +: psum_bw] = reg_bank[6] ;
      psums_out_reg[psum_bw*7 +: psum_bw] = reg_bank[7] ;
      psums_out_reg[psum_bw*8 +: psum_bw] = reg_bank[8] ;
      psums_out_reg[psum_bw*9 +: psum_bw] = reg_bank[9] ;
      psums_out_reg[psum_bw*10 +: psum_bw] = reg_bank[10] ;
      psums_out_reg[psum_bw*11 +: psum_bw] = reg_bank[11] ;
      psums_out_reg[psum_bw*12 +: psum_bw] = reg_bank[12] ;
      psums_out_reg[psum_bw*13 +: psum_bw] = reg_bank[13] ;
      psums_out_reg[psum_bw*14 +: psum_bw] = reg_bank[14] ;
      psums_out_reg[psum_bw*15 +: psum_bw] = reg_bank[15] ;
    end
  end
endmodule

