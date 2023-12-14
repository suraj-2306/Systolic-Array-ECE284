
module sfu (
  output  [psum_bw-1:0] psum_out,
  input signed  [psum_bw-1:0] psum_in,
  input   valid,
  input   enable,
  input   out_en,
  input   clk,
  input   reset,
  input   reset_ptr
  );

  parameter bw = 4;
  parameter psum_bw = 16;
  parameter input_ch = 16;

  // Define reg bank for 16 input channels
  reg signed [psum_bw-1:0] psum_out_reg;
  reg signed [psum_bw-1:0] reg_bank [input_ch-1:0];
  reg [psum_bw-1:0] relu_out;

  wire [psum_bw-1:0] reg0;
  wire [psum_bw-1:0] reg1;
  wire [psum_bw-1:0] reg2;
  wire [psum_bw-1:0] reg3;
  wire [psum_bw-1:0] reg4;
  wire [psum_bw-1:0] reg5;
  wire [psum_bw-1:0] reg6;
  wire [psum_bw-1:0] reg7;
  wire [psum_bw-1:0] reg8;
  wire [psum_bw-1:0] reg9;
  wire [psum_bw-1:0] reg10;
  wire [psum_bw-1:0] reg11;
  wire [psum_bw-1:0] reg12;
  wire [psum_bw-1:0] reg13;
  wire [psum_bw-1:0] reg14;
  wire [psum_bw-1:0] reg15;

  assign reg0 = reg_bank[0];
  assign reg1 = reg_bank[1];
  assign reg2 = reg_bank[2];
  assign reg3 = reg_bank[3];
  assign reg4 = reg_bank[4];
  assign reg5 = reg_bank[5];
  assign reg6 = reg_bank[6];
  assign reg7 = reg_bank[7];
  assign reg8 = reg_bank[8];
  assign reg9 = reg_bank[9];
  assign reg10 = reg_bank[10];
  assign reg11 = reg_bank[11];
  assign reg12 = reg_bank[12];
  assign reg13 = reg_bank[13];
  assign reg14 = reg_bank[14];
  assign reg15 = reg_bank[15];

  integer in_ptr, out_ptr, j;
  assign psum_out = psum_out_reg;

  initial begin
    in_ptr  <= 'd0;
    out_ptr <= 'd0;
  end

  always @(posedge clk or posedge reset or posedge reset_ptr) begin
    if (reset) begin
      in_ptr  <= 'd0;
      out_ptr <= 'd0;
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
      psum_out_reg = 0;
    end

    else if (reset_ptr) begin
      in_ptr  <= 'd0;
      out_ptr <= 'd0;
    end

    else if (valid & enable) begin
      reg_bank[in_ptr] <=  reg_bank[in_ptr] + psum_in;
      if(in_ptr == (input_ch - 1))
        in_ptr <= 0;
      else
        in_ptr <= in_ptr + 1;
    end

    if (out_en) begin
      psum_out_reg = (reg_bank[out_ptr] > 0) ? reg_bank[out_ptr] : 0;
      if(out_ptr == (input_ch - 1))
        out_ptr <= 0;
      else
        out_ptr <= out_ptr + 1;
      end
  end
endmodule

