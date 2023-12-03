module sfuTB;
 reg clk;
 reg acc;
 // reg relu ;
 reg reset;
reg signed [15:0]psum_regA;
reg [3:0] selLine=0;
integer i;
reg signed [15:0]temp_val='d5;
sfu2 sfu_instance(.clk(clk),.reset(reset),.psum_regA(psum_regA),.selLine(selLine),.acc(acc));

initial begin

  $dumpfile("sfuTB.vcd");
  $dumpvars(-1,sfuTB);
  selLine=0;


  reset=0;
  clk=0;
  #10;
  #1  reset=1;
  #1  reset=0;
  acc=1;
  #100 $finish ;
end


initial begin
  #10;
#5 forever #5 clk = ~clk;
end

always@(posedge clk)  begin
selLine= selLine+1;
  
end


always@(posedge clk)
begin
  temp_val=temp_val+1;
  psum_regA=temp_val;
end
endmodule


