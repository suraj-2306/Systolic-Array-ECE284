module sfu2 (
  input clk,
  input acc,
  input reset,
  input signed [15:0] psum_regA,
  input [3:0] selLine
);
// input signed psum_regA;
  parameter bw = 4;
  parameter psum_bw = 16;
  reg signed [psum_bw-1:0]sfuReg0;
  reg signed [psum_bw-1:0]sfuReg1;
  reg signed [psum_bw-1:0]sfuReg2;
  reg signed [psum_bw-1:0]sfuReg3;
  reg signed [psum_bw-1:0]sfuReg4;
  reg signed [psum_bw-1:0]sfuReg5;
  reg signed [psum_bw-1:0]sfuReg6;
  reg signed [psum_bw-1:0]sfuReg7;
  reg signed [psum_bw-1:0]sfuReg8;
  reg signed [psum_bw-1:0]sfuReg9;
  reg signed [psum_bw-1:0]sfuReg10;
  reg signed [psum_bw-1:0]sfuReg11;
  reg signed [psum_bw-1:0]sfuReg12;
  reg signed [psum_bw-1:0]sfuReg13;
  reg signed [psum_bw-1:0]sfuReg14;
  reg signed [psum_bw-1:0]sfuReg15;
  reg signed [psum_bw-1:0]psumTemp=0;
  reg signed [psum_bw-1:0]psum_q;

  initial begin
    sfuReg0 <=0;
    sfuReg1 <=0;
    sfuReg2 <=0;
    sfuReg3 <=0;
    sfuReg4 <=0;
    sfuReg5 <=0;
    sfuReg6 <=0;
    sfuReg7 <=0;
    sfuReg8 <=0;
    sfuReg9 <=0;
    sfuReg10<=0;
    sfuReg11<=0;
    sfuReg12<=0;
    sfuReg13<=0;
    sfuReg14<=0;
    sfuReg15<=0;
  end

wire [15:0]psumTempB;
assign psumTempB = psum_regB(selLine);

function [15:0] psum_regB(input [3:0] selLine);
case (selLine)
   'd0:  psum_regB = sfuReg0;
   'd1:  psum_regB = sfuReg1;
   'd2:  psum_regB = sfuReg2;
   'd3:  psum_regB = sfuReg3;
   'd4:  psum_regB = sfuReg4;
   'd5:  psum_regB = sfuReg5;
   'd6:  psum_regB = sfuReg6;
   'd7:  psum_regB = sfuReg7;
   'd8:  psum_regB = sfuReg8;
   'd9:  psum_regB = sfuReg9;
   'd10: psum_regB = sfuReg10;
   'd11: psum_regB = sfuReg11;
   'd12: psum_regB = sfuReg12;
   'd13: psum_regB = sfuReg13;
   'd14: psum_regB = sfuReg14;
   'd15: psum_regB = sfuReg15;
endcase
endfunction

  // initial begin
// end
 

  always @(posedge clk )
  begin
    if (reset) psum_q <= 0;
    else if (acc)
      begin
        psumTemp = psumTempB+ psum_regA;
    end
  end
  always@(posedge clk)
  begin
       case(selLine)
           'd0:  sfuReg0 =psumTemp;
           'd1:  sfuReg1 =psumTemp;
           'd2:  sfuReg2 =psumTemp;
           'd3:  sfuReg3 =psumTemp;
           'd4:  sfuReg4 =psumTemp;
           'd5:  sfuReg5 =psumTemp;
           'd6:  sfuReg6 =psumTemp;
           'd7:  sfuReg7 =psumTemp;
           'd8:  sfuReg8 =psumTemp;
           'd9:  sfuReg9 =psumTemp;
           'd10: sfuReg10=psumTemp;
           'd11: sfuReg11=psumTemp;
           'd12: sfuReg12=psumTemp;
           'd13: sfuReg13=psumTemp;
           'd14: sfuReg14=psumTemp;
           'd15: sfuReg15=psumTemp;
         endcase
       end
endmodule
