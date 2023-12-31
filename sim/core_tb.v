
module core_tb;

  // ---------- Parameters definition ----------

  parameter bw = 8;           // Bit-width of kernel and activation elements
  parameter psum_bw = 16;     // Bit-width of Partial Sum

  parameter len_kij = 9;      // Length of kernel map (single layer)
  parameter len_nij = 36;     // Length of input map (single input layer)
  parameter len_onij = 16;    // Length of output map (single input layer)
  parameter num_ip_ch = 8;    // Number of Input channels (for conv layer)

  parameter col = 8;          // Number of columns in Systolic Array
  parameter row = 8;          // Number of rows in Systolic Array

  parameter isram_bw = bw * row;      // Bit-width of Input SRAM
  parameter osram_bw = psum_bw * row; // Bit-width of Output SRAM
  parameter isram_addr_bw = 7;        // Bit-width of ISRAM Address bus
  parameter osram_addr_bw = 4;        // Bit-width of OSRAM Address bus
  parameter isram_num_entries = 128;  // Number of entries in ISRAM
  parameter osram_num_entries = 16;   // Number of entries in OSRAM

  // ---------- Variables/Wires/Regs definition ----------

  reg clk;
  reg reset;
  reg start;

  wire output_ready;

  wire [isram_bw-1:0] I_Q;    // Input sent to ISRAM (Input SRAM)
  reg [isram_addr_bw-1:0] I_A;              // Address of input sent to SRAM
  logic [isram_bw-1:0] I_D;   // Input value read from txt file (activation and weight)

  wire [osram_bw-1:0] O_Q;            // Output read from OSRAM (Output SRAM)
  reg [osram_addr_bw-1:0] O_A;              // Address of output val read from txt file
  logic [osram_bw-1:0] O_D;           // Output value read from txt file
  logic [osram_bw-1:0] tempVar;

  reg I_CEN;                  // ISRAM Chip-enable
  reg I_WEN;                  // ISRAM Write-enable
  reg O_CEN;                  // OSRAM Chip-enable
  reg O_WEN;                  // OSRAM Write-enable
  reg TB_CL_SELECT = 0;       // Controller select (who controls the SRAM)

  // Validation registers (for comparing hardware values with txt files)
  reg [isram_bw-1:0] inputSramData[(num_ip_ch*len_kij) + len_nij:0];
  reg [osram_bw-1:0] outputSramData[len_onij-1:0];

  integer w_file, w_scan_file;  // file_handler
  integer a_file, a_scan_file;  // file_handler
  integer p_file, p_scan_file;  // file_handler
  integer i, j;
  integer captured_data;
  integer error = 0;


  // ---------- Module(s) instantiation ----------

  core #(.bw(bw)) core_instance (
    .clk  (clk),
    .start(start),
    .reset(reset),
    .ready(output_ready),
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

  // ---------- Testbench operation ----------

  initial begin
    $dumpfile("core_tb.vcd");
    $dumpvars(0, core_tb);

    clk = 0;
    reset = 0;
    start = 0;

    // Perform global reset
    #4 reset = 1;
    #4 reset = 0;

    // ---------- Open weight.txt file for reading ----------
    // w_file = $fopen("./verilog/weight_project.txt", "r");
    w_file = $fopen("sim/weight_16.txt", "r");

    // Following three lines are to remove the first three comment lines of the file
    w_scan_file = $fscanf(w_file, "%s", captured_data);
    w_scan_file = $fscanf(w_file, "%s", captured_data);
    w_scan_file = $fscanf(w_file, "%s", captured_data);

    #12
    // Give SRAM control to testbench. reset reset and clk.
    TB_CL_SELECT = 1; reset = 0;  clk = 0;


    // Enable ISRAM for writing
    I_CEN = 0;  I_WEN = 0;
    // Disable OSRAM
    O_CEN = 1;  O_WEN = 1;
    for (j = 0; j < (num_ip_ch*len_kij); j = j + 1) begin
      // Give ISRAM address to write to
      #10 I_A = j;
      w_scan_file = $fscanf(w_file, "%64b", I_D);
      inputSramData[j][isram_bw-1:0] = I_D;
    end
    // Disable ISRAM
    #10 I_CEN = 1; I_WEN = 1;

    // ---------- Verify weights read into SRAM ----------
    $display("Verify weights read into SRAM");
    // Enable ISRAM for reading
    #11 I_CEN = 0; I_WEN = 1;
    error = 0;
    for (i = 0; i < (num_ip_ch*len_kij); i = i + 1) begin
      // Give ISRAM address to read from
      #5 I_A = i;
      #5
      // $display("%2d-th read wt is %h", i, I_Q);
      if (inputSramData[i][isram_bw-1:0] != I_Q) begin
        $display("%2d-th read data is %h, expected data is %h --- Data ERROR !!!", i, I_Q,
                  inputSramData[i]);
        error = error + 1;
      end
      // if (inputSramData[i][isram_bw-1:0] == I_Q)
      //   $display("%2d-th read data is %h --- Data matched", i, I_Q);
      // else begin
      //   $display("%2d-th read data is %h, expected data is %h --- Data ERROR !!!", i, I_Q,
      //            inputSramData[i]);
      //   error = error + 1;
      // end
      // $display("%0t : DOWN", $time);
      // $display("%d", error);
      // $display("%d", i);
    end
    $display("Encountered %d error(s)", error);


    // ---------- Open activation.txt file for reading ----------
    // a_file = $fopen("verilog/activation_project.txt", "r");
    a_file = $fopen("./sim/activation_16.txt", "r");

    // Following three lines are to remove the first three comment lines of the file
    a_scan_file = $fscanf(a_file,"%s", captured_data);
    a_scan_file = $fscanf(a_file,"%s", captured_data);
    a_scan_file = $fscanf(a_file,"%s", captured_data);

    #101 reset= 0;

    // Enable ISRAM for Writing
    #10 I_CEN = 0; I_WEN = 0;
    for (i=0; i<len_nij ; i=i+1) begin
      // Give ISRAM address to write to (offset by number of kernel elements)
      #10 I_A = (num_ip_ch*len_kij) + i;
      a_scan_file = $fscanf(a_file,"%64b", I_D);
      inputSramData[(num_ip_ch*len_kij)+i][isram_bw-1:0] = I_D;
    end
    // Disable ISRAM
    #10 I_CEN = 1; I_WEN = 1;

    // ---------- Verify activations read into SRAM ----------
    $display("Verify activations read into SRAM");
    // Enable ISRAM for reading
    #10 I_CEN = 0; I_WEN = 1;
    // Disable OSRAM
    O_CEN = 1;  O_WEN = 1;
    TB_CL_SELECT = 1;
    error = 0;
    for (i=0; i<len_nij ; i=i+1) begin
      // Give ISRAM address to read from (offset by number of kernel elements)
      #5 I_A = (num_ip_ch*len_kij) + i;
      #5
      // $display("%2d-th read act is %h", i, I_Q);
      if (inputSramData[(num_ip_ch*len_kij)+i][isram_bw-1:0] != I_Q) begin
        $display("%2d-th read data is %h, expected data is %h --- Data ERROR !!!", i, I_Q, inputSramData[72+i]);
        error = error + 1;
      end
      // if (inputSramData[(num_ip_ch*len_kij)+i][isram_bw-1:0] == I_Q)
      //     $display("%2d-th read data is %h --- Data matched", i, I_Q);
      // else begin
      //     $display("%2d-th read data is %h, expected data is %h --- Data ERROR !!!", i, I_Q, inputSramData[72+i]);
      //     error = error+1;
      // end
    end
    $display("Encountered %d error(s)", error);

    // Disable ISRAM
    #10 I_CEN = 1; I_WEN = 1;

    // End testbench control. Let Corelet controller take over now.
    #150 start = 1;
    TB_CL_SELECT = 0;
    #10000 ;
  end

  initial begin
    #2 forever #2 clk = ~clk;
  end

  always@(posedge output_ready)
  begin
    // Stop Core operation.

    // ---------- Open output.txt for reading expected outputs ----------
    // a_file = $fopen("./verilog/output_project.txt", "r");
    a_file = $fopen("./sim/output_16.txt", "r");

    // Following three lines are to remove the first three comment lines of the file
    // a_scan_file = $fscanf(a_file,"%s", captured_data);
    // a_scan_file = $fscanf(a_file,"%s", captured_data);
    // a_scan_file = $fscanf(a_file,"%s", captured_data);

    // We do not need to control the OSRAM at this instant. Just read from the
    // file and store into our local var for comparision.
    // Disable ISRAM
    I_CEN = 1; I_WEN = 1;
    // Disable OSRAM
    O_CEN = 1;  O_WEN = 1;
    TB_CL_SELECT = 0;
    for (i=0; i<len_onij ; i=i+1) begin
      // #10 O_A   = i;
      a_scan_file = $fscanf(a_file,"%128b", tempVar);
      outputSramData[i][osram_bw-1:0] = tempVar;
      $display("%d iter : %h",i, tempVar);
    end

    start = 0;

    // ---------- Verify output generated by SysArr Core ----------
    $display("Verify output generated by SysArr Core");
    // Give SRAM control to testbench.
    #10 TB_CL_SELECT = 1;
    // Disable ISRAM
    I_CEN = 1; I_WEN = 1;
    // Enable OSRAM for reading
    O_CEN = 0; O_WEN = 1;
    for (i=0; i<len_onij; i=i+1) begin
      // Give OSRAM address to read from
      #5 O_A = i;
      #5
      // $display("%2d-th read data is %h, expected data is %h", i, O_Q, outputSramData[i]);
      if (outputSramData[i][osram_bw-1:0] != O_Q) begin
        $display("%2d-th read data is %h, expected data is %h --- Data ERROR !!!", i, O_Q, outputSramData[i]);
        error = error + 1;
      end
      // if (outputSramData[i][osram_bw-1:0] == O_Q)
      //     $display("%2d-th read data is %h --- Data matched", i, O_Q);
      // else begin
      //     $display("%2d-th read data is %h, expected data is %h --- Data ERROR !!!", i, O_Q, outputSramData[i]);
      //     error = error+1;
      // end
    end
    $display("Encountered %d error(s)", error);
    // Disable OSRAM
    #10 O_CEN = 1; O_WEN = 1;

    #10 $finish;
  end
endmodule

