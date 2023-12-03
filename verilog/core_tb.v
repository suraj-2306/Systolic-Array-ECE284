// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
`timescale 1ns/1ps

module core_tb;

parameter bw = 4;
parameter psum_bw = 16;
parameter len_kij = 9;
parameter len_onij = 16;
parameter col = 8;
parameter row = 8;
parameter len_nij = 36;

logic clk;
logic reset;
logic start;

wire[31:0]  I_Q;
reg [6:0]   I_A;
reg [31:0]   I_D;
reg I_CEN;
reg I_WEN;
reg [31:0] inputSramData [108:0];

integer w_file, w_scan_file ; // file_handler
integer a_file, a_scan_file ; // file_handler
integer p_file, p_scan_file ; // file_handler
integer i;
integer captured_data;
integer error;


core  #(.bw(bw), .col(col), .row(row)) core_instance (
	.clk(clk), 
        .start(start),
    	.reset(reset) ,
    .TB_I_CEN(I_CEN),
    .TB_I_A(I_A),
    .TB_I_D(I_D),
    .TB_I_Q(I_Q),
    .TB_I_WEN(I_WEN)
  );

initial 
begin

    $dumpfile("core_tb.vcd");
    $dumpvars(0,core_tb);
 
    clk= 0;
    reset= 1;
    start= 0;
  
    w_file = $fopen("weight.txt", "r");

    // Following three lines are to remove the first three comment lines of the file
    w_scan_file = $fscanf(w_file,"%s", captured_data);
    w_scan_file = $fscanf(w_file,"%s", captured_data);
    w_scan_file = $fscanf(w_file,"%s", captured_data);

    #101 reset  = 0;
    #10
    I_CEN= 0;
    I_WEN= 0;
    // TB_CL_SELECT = 1;
    // TB_O_WEN = 1;
    // TB_O_CEN = 1;

    for (i=0; i<72 ; i=i+1)
    begin
        #10
       I_A= i;
        w_scan_file = $fscanf(w_file,"%32b", I_Q);
        inputSramData[i][31:0] = I_Q;
    end
    // #10
    // TB_I_CEN = 1;
    // TB_I_WEN = 1;
    // TB_CL_SELECT = 1;
    // TB_O_WEN = 1;
    // TB_O_CEN = 1;
    // for (i=0; i<72 ; i=i+1)
    // begin
    //     #5
    //     TB_I_CEN = 0;
    //     TB_I_WEN = 1;
    //     TB_I_ADDR   = i;
    //     #5
    //     if (D_2D[i][31:0] == TB_I_Q)
    //         $display("%2d-th read data is %h --- Data matched", i, TB_I_Q);
    //     else begin
    //         $display("%2d-th read data is %h, expected data is %h --- Data ERROR !!!", i, TB_I_Q, D_2D[i]);
    //         error = error+1;
    //     end
    // end
    //Weight Load and Check ends

    //Activation Load and check begins

 //    a_file = $fopen("activation.txt", "r");

 //    // Following three lines are to remove the first three comment lines of the file
 //    a_scan_file = $fscanf(a_file,"%s", captured_data);
 //    a_scan_file = $fscanf(a_file,"%s", captured_data);
 //    a_scan_file = $fscanf(a_file,"%s", captured_data);

 //    #101 RESET = 0;
 //    #10
 //    TB_I_CEN = 0;
 //    TB_I_WEN = 0;
 //    TB_CL_SELECT = 1;
 //    TB_O_WEN = 1;
 //    TB_O_CEN = 1;

 //    for (i=0; i<36 ; i=i+1)
 //    begin
 //        #10
 //        TB_I_ADDR   = 72 + i;
 //        a_scan_file = $fscanf(a_file,"%32b", TB_I_D);
 //        D_2D[72+i][31:0] = TB_I_D;
 //    end
 //    #10
 //    TB_I_CEN = 1;
 //    TB_I_WEN = 1;
 //    TB_CL_SELECT = 1;
 //    TB_O_WEN = 1;
 //    TB_O_CEN = 1;
 //    for (i=0; i<36 ; i=i+1)
 //    begin
 //        #5
 //        TB_I_CEN = 0;
 //        TB_I_WEN = 1;
 //        TB_I_ADDR   = i+72;
 //        #5
 //        if (D_2D[72+i][31:0] == TB_I_Q)
 //            $display("%2d-th read data is %h --- Data matched", i, TB_I_Q);
 //        else begin
 //            $display("%2d-th read data is %h, expected data is %h --- Data ERROR !!!", i, TB_I_Q, D_2D[72+i]);
 //            error = error+1;
 //        end
 //    end
	// 
 //    
 //    TB_CL_SELECT = 0;
 //    TB_I_WEN = 1;
 //    TB_I_CEN = 1;
 //    
    #100 start = 1; 
    #100 start= 0;

    #12500
 //    //Activation Load and check begins

 //    p_file = $fopen("output.txt", "r");

 //    // Following three lines are to remove the first three comment lines of the file
 //    p_scan_file = $fscanf(p_file,"%s", captured_data);
 //    p_scan_file = $fscanf(p_file,"%s", captured_data);
 //    p_scan_file = $fscanf(p_file,"%s", captured_data);

 //    #101 RESET = 0;
 //    #10
 //    TB_I_CEN = 1;
 //    TB_I_WEN = 1;
 //    TB_CL_SELECT = 1;
 //    TB_O_WEN = 1;
 //    TB_O_CEN = 1;

 //    for (i=0; i<16 ; i=i+1)
 //    begin
 //        #10
 //        p_scan_file = $fscanf(p_file,"%128b", TB_O_D);
 //        D_2D_128[i][127:0] = TB_O_D;
 //    end
 //    #10
 //    TB_I_CEN = 1;
 //    TB_I_WEN = 1;
 //    TB_CL_SELECT = 1;
 //    TB_O_WEN = 1;
 //    TB_O_CEN = 1;
 //    for (i=0; i<16 ; i=i+1)
 //    begin
 //        #5
 //        TB_O_CEN = 0;
 //        TB_O_WEN = 1;
 //        TB_O_ADDR   = i;
 //        #5
 //        if (D_2D_128[i][127:0] == TB_O_Q)
 //            $display("%2d-th read data is %h --- Data matched", i, TB_O_Q);
 //        else begin
 //            $display("%2d-th read data is %h, expected data is %h --- Data ERROR !!!", i, TB_O_Q, D_2D_128[i]);
 //            error = error+1;
 //        end
 //    end
 //    

 //    #500

     $finish;
end

initial
begin
#2
forever
    #2 clk= ~clk;
end

endmodule
