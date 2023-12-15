
module core(
  input   clk,
  input   reset,
  input   start,
  input   TB_CL_SELECT,       // Controller operation select (who is controlling the SRAM busses)
  output  ready,              // Controller ready out signal (Core operation complete; Data is ready in OSRAM)

  input   [31:0]  TB_I_D,     // ISRAM Data input (to write into ISRAM)
  input   [6:0]   TB_I_A,     // ISRAM Address
  input           TB_I_CEN,   // ISRAM Chip-enable
  input           TB_I_WEN,   // ISRAM Write-enable (to select betweek Read/Write)
  output  [31:0]  TB_I_Q,     // ISRAM Data output (read from ISRAM)

  input   [127:0]  TB_O_D,     // OSRAM Data input (to write into OSRAM)
  input   [6:0]   TB_O_A,     // OSRAM Address
  input           TB_O_CEN,   // OSRAM Chip-enable
  input           TB_O_WEN,   // OSRAM Write-enable (to select betweek Read/Write)
  output  [127:0]  TB_O_Q      // OSRAM Data output (read from OSRAM)
);

  // ---------- Parameters definition ----------

  parameter bw = 4;
  parameter col = 12;
  parameter row = 48;
  parameter psum_bw = 16;


  // ---------- Variables/Wires/Regs definition ----------

  wire    [31:0]  I_Q;          // ISRAM Read Data
  wire    [127:0] O_Q;          // OSRAM Read Data

  wire    [6:0]   CL_I_A;       // Controller ISRAM Address
  wire            CL_I_CEN;     // Controller ISRAM Chip-enable
  wire            CL_I_WEN;     // Controller ISRAM Write-enable
  wire    [127:0] CL_O_D;       // Controller OSRAM Write Data
  wire    [3:0]   CL_O_A;       // Controller OSRAM Address
  wire            CL_O_CEN;     // Controller OSRAM Chip-enable
  wire            CL_O_WEN;     // Controller OSRAM Write-enable

  wire    [31:0]  MUX_I_D;      // Multiplexed ISRAM Write Data (connected directly)
  wire    [6:0]   MUX_I_A;      // Multiplexed ISRAM Address
  wire            MUX_I_CEN;    // Multiplexed ISRAM Chip-enable
  wire            MUX_I_WEN;    // Multiplexed ISRAM Write-enable (to select betweek Read/Write)
  wire    [127:0] MUX_O_D;      // Multiplexed OSRAM Write Data
  wire    [3:0]   MUX_O_A;      // Multiplexed OSRAM Address
  wire            MUX_O_CEN;    // Multiplexed OSRAM Chip-enable
  wire            MUX_O_WEN;    // Multiplexed OSRAM Write-enable (to select betweek Read/Write)


  // ---------- Module(s) instantiation ----------

  sram_32b_w128 sram_ininstance (
    .CLK(clk),
    .WEN(MUX_I_WEN),
    .CEN(MUX_I_CEN),
    .A(MUX_I_A),
    .D(MUX_I_D),
    .Q(I_Q)
  );

  sram_128b_w16 sram_outinstance (
    .CLK(clk),
    .WEN(MUX_O_WEN),
    .CEN(MUX_O_CEN),
    .A(MUX_O_A),
    .D(MUX_O_D),
    .Q(O_Q)
  );

  corelet corelet_instance( .clk(clk),
    .start(start),
    .reset(reset),
    .ready(ready),
    .I_A(CL_I_A),
    .I_CEN(CL_I_CEN),
    .I_Q(I_Q),
    .I_WEN(CL_I_WEN),

    .O_A(CL_O_A), 
    .O_CEN(CL_O_CEN), 
    .O_Q(O_Q),
    .O_WEN(CL_O_WEN)
);

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


