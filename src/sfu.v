
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

  integer in_ptr, out_ptr;

  assign psum_out = psum_out_reg;

  always @(posedge clk or posedge reset )begin
    if (reset) begin
      in_ptr  <= 'd0;
      out_ptr <= 'd0;
      // Reset all the psum regs to zero
      reg_bank[0] <= 0;
      reg_bank[1] <= 0;
      reg_bank[2] <= 0;
      reg_bank[3] <= 0;
      reg_bank[4] <= 0;
      reg_bank[5] <= 0;
      reg_bank[6] <= 0;
      reg_bank[7] <= 0;
      reg_bank[8] <= 0;
      reg_bank[9] <= 0;
      reg_bank[10] <= 0;
      reg_bank[11] <= 0;
      reg_bank[12] <= 0;
      reg_bank[13] <= 0;
      reg_bank[14] <= 0;
      reg_bank[15] <= 0;
    end

    else if (valid && enable) begin
      reg_bank[in_ptr] <=  reg_bank[in_ptr] + psum_in;
      if(in_ptr == (input_ch - 1))
        in_ptr <= 0;
      else
        in_ptr <= in_ptr + 1;
    end

    else if (out_en) begin
      psum_out_reg <= (reg_bank[out_ptr] > 0) ? reg_bank[out_ptr] : 0;
      if(out_ptr == (input_ch - 1))
        out_ptr <= 0;
      else
        out_ptr <= out_ptr + 1;
      end

  end

  // always@(posedge clk) begin
  //   if (out_en) begin
  //     psum_out_reg <= (reg_bank[out_ptr] > 0) ? reg_bank[out_ptr] : 0;
  //     if(out_ptr == (input_ch - 1))
  //       out_ptr <= 0;
  //     else
  //       out_ptr <= out_ptr + 1;
  //     end
  //   end
endmodule


