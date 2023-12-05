
  module core_tb;

  reg clk;
  reg reset;
  reg start;

  parameter bw = 4;
  parameter psum_bw = 16;
  parameter len_kij = 9;
  parameter len_onij = 16;
  parameter col = 8;
  parameter row = 8;
  parameter len_nij = 36;


  wire [31:0] I_Q;
  reg [6:0] I_A;
  logic [31:0] I_D;
  reg I_CEN;
  reg I_WEN;
  reg [31:0] inputSramData[108:0];

  wire [31:0] O_Q;
  reg [6:0] O_A;
  logic [31:0] O_D;
  reg O_CEN;
  reg O_WEN;
  reg [127:0] outputSramData[15:0];

  reg TB_CL_SELECT = 0;
  integer w_file, w_scan_file;  // file_handler
  integer a_file, a_scan_file;  // file_handler
  integer p_file, p_scan_file;  // file_handler
  integer i, j;
  integer captured_data;
  integer error = 0;

  core core_instance (
      .clk  (clk),
      .start(start),
      .reset(reset),
      .TB_CL_SELECT(TB_CL_SELECT),
      .TB_I_CEN(I_CEN),
      .TB_I_A(I_A),
      .TB_I_D(I_D),
      .TB_I_Q(I_Q),
      .TB_I_WEN(I_WEN),

      .TB_O_CEN(O_CEN),
      .TB_O_A(O_A),
      .TB_O_D(O_D),
      .TB_O_Q(O_Q),
      .TB_O_WEN(O_WEN)
  );

  initial begin

    $dumpfile("core_tb.vcd");
    $dumpvars(0, core_tb);

    clk = 0;
    reset = 1;
    start = 0;

    w_file = $fopen("./verilog/weight.txt", "r");

    // Following three lines are to remove the first three comment lines of the file
    w_scan_file = $fscanf(w_file, "%s", captured_data);
    w_scan_file = $fscanf(w_file, "%s", captured_data);
    w_scan_file = $fscanf(w_file, "%s", captured_data);

    #10 I_CEN = 0;
    I_WEN = 0;
    TB_CL_SELECT = 1;
    O_CEN = 1;
    O_WEN = 1;

    reset = 0;
    clk = 0;
    #1 reset = 1;
    #1 reset = 0;

    for (j = 0; j < 72; j = j + 1) begin
      #10 I_A = j;
      w_scan_file = $fscanf(w_file, "%32b", I_D);
      inputSramData[j][31:0] = I_D;
    end
    #10 I_CEN = 1;
    I_WEN = 1;
    TB_CL_SELECT = 1;
    // for (i = 0; i < 72; i = i + 1) begin
    //   #5 I_CEN = 0;
    //   I_WEN = 1;
    //   I_A   = i;
    //   #5
    //     if (inputSramData[i][31:0] == I_Q)
    //       $display("%2d-th read data is %h --- Data matched", i, I_Q);
    //     else begin
    //       $display("%2d-th read data is %h, expected data is %h --- Data ERROR !!!", i, I_Q,
    //                inputSramData[i]);
    //       error = error + 1;
    //     end
    //   $display("%0t : DOWN", $time);
    //   $display("%d", error);
    //   $display("%d", i);


    a_file = $fopen("verilog/activation.txt", "r");

    // Following three lines are to remove the first three comment lines of the file
    a_scan_file = $fscanf(a_file,"%s", captured_data);
    a_scan_file = $fscanf(a_file,"%s", captured_data);
    a_scan_file = $fscanf(a_file,"%s", captured_data);

    #101 reset= 0;
    #10
    I_CEN = 0;
    I_WEN = 0;
    TB_CL_SELECT = 1;

    for (i=0; i<36 ; i=i+1)
    begin
        #10
        I_A   = 72 + i;
        a_scan_file = $fscanf(a_file,"%32b", I_D);
        inputSramData[72+i][31:0] = I_D;
    end
    #10
    I_CEN = 1;
    I_WEN = 1;
    TB_CL_SELECT = 1;
    for (i=0; i<36 ; i=i+1)
    begin
        #5
        I_CEN = 0;
        I_WEN = 1;
        I_A = i+72;
        #5
        if (inputSramData[72+i][31:0] == I_Q)
            $display("%2d-th read data is %h --- Data matched", i, I_Q);
        else begin
            $display("%2d-th read data is %h, expected data is %h --- Data ERROR !!!", i, I_Q, inputSramData[72+i]);
            error = error+1;
        end
    end

    // end
      #150 start = 1;
      #10000 ;

      I_WEN = 1;
      I_CEN = 1;
      TB_CL_SELECT = 0;
    O_CEN = 0;
    O_WEN = 0;

    for (i=0; i<16 ; i=i+1)
    begin
        #10
        O_A   = i;
        a_scan_file = $fscanf(a_file,"%32b", O_D);
        outputSramData[i][127:0] = O_D;
    end
    #10
    TB_CL_SELECT = 1;
    O_CEN = 1;
    O_WEN = 1;
    for (i=0; i<16; i=i+1)
    begin
        #5
        O_CEN = 0;
        O_WEN = 1;
        O_A = i;
        #5
        if (outputSramData[i][127:0] == O_Q)
            $display("%2d-th read data is %h --- Data matched", i, O_Q);
        else begin
            $display("%2d-th read data is %h, expected data is %h --- Data ERROR !!!", i, O_Q, outputSramData[i]);
            error = error+1;
        end
    end

    #1000 $finish;
    end

  initial begin
    #2 forever #2 clk = ~clk;
  end

endmodule

