module customTB;

reg clk;
reg reset;
reg start;


initial begin

  $dumpfile("customTB.vcd");
  $dumpvars(0,customTB);

  reset =0;
  clk=0;
  #1reset =1;

  #1 reset =0;
  start =1;

 #200 $finish; // You can put the delay as per your requirement.
end

initial
begin
#1
forever
    #1 clk = ~clk;
end


corelet coreletInst(
  .clk(clk),
  .reset(reset),
  .start(start)
);

endmodule
