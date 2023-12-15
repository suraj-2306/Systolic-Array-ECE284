
module core(
  input   clk,
  input   reset,
  input   start,
  input   TB_CL_SELECT,       // Controller operation select (who is controlling the SRAM busses)
  output  ready,              // Controller ready out signal (Core operation complete; Data is ready in OSRAM)

  input   TB_I_CEN,                       // ISRAM Chip-enable
  input   TB_I_WEN,                       // ISRAM Write-enable (to select betweek Read/Write)
  input   [isram_bw-1:0]      TB_I_D,     // ISRAM Data input (to write into ISRAM)
  input   [isram_addr_bw-1:0] TB_I_A,     // ISRAM Address
  output  [isram_bw-1:0]      TB_I_Q,     // ISRAM Data output (read from ISRAM)

  input   TB_O_CEN,                       // OSRAM Chip-enable
  input   TB_O_WEN,                       // OSRAM Write-enable (to select betweek Read/Write)
  input   [osram_bw-1:0]      TB_O_D,     // OSRAM Data input (to write into OSRAM)
  input   [osram_addr_bw-1:0] TB_O_A,     // OSRAM Address
  output  [osram_bw-1:0]      TB_O_Q      // OSRAM Data output (read from OSRAM)
);

  // ---------- Parameters definition ----------

  parameter bw = 4;
  parameter col = 8;
  parameter row = 8;
  parameter psum_bw = 16;

  parameter isram_bw = bw * row;      // Bit-width of Input SRAM
  parameter osram_bw = psum_bw * row; // Bit-width of Output SRAM
  parameter isram_addr_bw = 7;        // Bit-width of ISRAM Address bus
  parameter osram_addr_bw = 4;        // Bit-width of OSRAM Address bus
  parameter isram_num_entries = 128;  // Number of entries in ISRAM
  parameter osram_num_entries = 16;   // Number of entries in OSRAM


  // ---------- Variables/Wires/Regs definition ----------

  wire    [isram_bw-1:0] I_Q;          // ISRAM Read Data
  wire    [osram_bw-1:0] O_Q;          // OSRAM Read Data

  wire    [isram_addr_bw-1:0]   CL_I_A;       // Controller ISRAM Address
  wire            CL_I_CEN;     // Controller ISRAM Chip-enable
  wire            CL_I_WEN;     // Controller ISRAM Write-enable
  wire    [osram_bw-1:0] CL_O_D;       // Controller OSRAM Write Data
  wire    [osram_addr_bw-1:0]   CL_O_A;       // Controller OSRAM Address
  wire            CL_O_CEN;     // Controller OSRAM Chip-enable
  wire            CL_O_WEN;     // Controller OSRAM Write-enable

  wire    [isram_bw-1:0]  MUX_I_D;      // Multiplexed ISRAM Write Data (connected directly)
  wire    [isram_addr_bw-1:0]   MUX_I_A;      // Multiplexed ISRAM Address
  wire            MUX_I_CEN;    // Multiplexed ISRAM Chip-enable
  wire            MUX_I_WEN;    // Multiplexed ISRAM Write-enable (to select betweek Read/Write)
  wire    [osram_bw-1:0] MUX_O_D;      // Multiplexed OSRAM Write Data
  wire    [osram_addr_bw-1:0]   MUX_O_A;      // Multiplexed OSRAM Address
  wire            MUX_O_CEN;    // Multiplexed OSRAM Chip-enable
  wire            MUX_O_WEN;    // Multiplexed OSRAM Write-enable (to select betweek Read/Write)


  // ---------- Module(s) instantiation ----------

  // sram_32b_w128 sram_ininstance (
  //   .CLK(clk),
  //   .WEN(MUX_I_WEN),
  //   .CEN(MUX_I_CEN),
  //   .A(MUX_I_A),
  //   .D(MUX_I_D),
  //   .Q(I_Q)
  // );

  sram #(.bitwidth(isram_bw),
    .addr_bw(isram_addr_bw),
    .num_entries(isram_num_entries)) isram_instance (
    .CLK(clk),
    .WEN(MUX_I_WEN),
    .CEN(MUX_I_CEN),
    .A(MUX_I_A),
    .D(MUX_I_D),
    .Q(I_Q)
  );

  // sram_128b_w16 sram_outinstance (
  //   .CLK(clk),
  //   .WEN(MUX_O_WEN),
  //   .CEN(MUX_O_CEN),
  //   .A(MUX_O_A),
  //   .D(MUX_O_D),
  //   .Q(O_Q)
  // );

  sram #(.bitwidth(osram_bw),
    .addr_bw(osram_addr_bw),
    .num_entries(osram_num_entries)) osram_instance (
    .CLK(clk),
    .WEN(MUX_O_WEN),
    .CEN(MUX_O_CEN),
    .A(MUX_O_A),
    .D(MUX_O_D),
    .Q(O_Q)
  );

  corelet #(.bw(bw)) corelet_instance( .clk(clk),
    .start(start),
    .reset(reset),
    .ready(ready),
    .I_A(CL_I_A),
    .I_CEN(CL_I_CEN),
    .I_Q(I_Q),
    .I_WEN(CL_I_WEN),

    .O_A(CL_O_A),
    .O_CEN(CL_O_CEN),
    .O_D(CL_O_D),
    .O_WEN(CL_O_WEN)
  );


  // ---------- Wire assignments ----------

  assign TB_I_Q       =   I_Q;
  assign TB_O_Q       =   O_Q;

  assign MUX_I_D      =   TB_I_D ;
  assign MUX_O_D      =   TB_CL_SELECT    ?   TB_O_D    :   CL_O_D;

  assign MUX_I_A      =   TB_CL_SELECT    ?   TB_I_A    :   CL_I_A   ;
  assign MUX_I_CEN    =   TB_CL_SELECT    ?   TB_I_CEN  :   CL_I_CEN    ;
  assign MUX_I_WEN    =   TB_CL_SELECT    ?   TB_I_WEN  :   CL_I_WEN    ;

  assign MUX_O_A      =   TB_CL_SELECT    ?   TB_O_A    :   CL_O_A   ;
  assign MUX_O_CEN    =   TB_CL_SELECT    ?   TB_O_CEN  :   CL_O_CEN    ;
  assign MUX_O_WEN    =   TB_CL_SELECT    ?   TB_O_WEN  :   CL_O_WEN    ;
endmodule


