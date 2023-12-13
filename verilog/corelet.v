
module corelet ( input wire clk,
    input wire start,
    input wire reset,
    input   [31:0]  I_Q,      // ISRAM Data Output
    output  [6:0]   I_A,      // ISRAM Address
    output          I_CEN,    // ISRAM Chip-enable
    output          I_WEN,    // ISRAM Write-enable (to select betweek Read/Write)

    output  [127:0] O_D,      // OSRAM Data Input
    output  [3:0]   O_A,      // OSRAM Address
    output          O_CEN,    // OSRAM Chip-enable
    output          O_WEN,    // OSRAM Write-enable (to select betweek Read/Write)

    output  ready             // Core operation complete. Data is ready in OSRAM.

    // YJ // Add a connection from SFU to OSRAM
    // Add an output to signal computation complete

    // input wire l0rd, input wire l0wr,
    // input wire [row*bw-1:0] l0in
);

  // ---------- Parameters definition ----------

  parameter col = 8;
  parameter row = 8;
  parameter bw = 4;
  parameter psum_bw = 16;
  // parameter total_cycle = 64;
  // parameter total_cycle_2nd = 8;


  // ---------- Variables/Wires/Regs definition ----------

  //Controller state
  localparam IDLE = 4'b0000;
  localparam WT_LD = 4'b0001;
  localparam WT_ACT_INTER = 4'b0010;
  localparam ACT_LD= 4'b0011;
  localparam PSUMS_OSRAM_WR= 4'b0100;
  localparam WAIT_FOR_NEXT= 4'b0101;

  // State machine
  reg cascade;                      // Cascade operation mode toggle
  reg SM_ready;                     // State Machine oujtput ready signal
  reg SM_reset_ma;                  // State machine reset Mac Array signal
  reg SM_reset_ma_next;             // Value weitten into state machine reset mac array in next clk cycle
  reg [6:0] SM_counter;             // State machine internal counter
  reg [6:0] SM_counter_next;        // Value written into state machine internal counter in next clk cycle
  reg [3:0] SM_state;               // State machine 'State'
  reg [3:0] SM_state_next;          // State machine next 'State'
  reg L0_write_next;                // Value written into L0 Write signal in next clk cycle
  reg L0_read_next;                 // Value written into L0 Write signal in next clk cycle
  reg [1:0] MA_instr_in_next;       // Value written into MAC Array Instruction In (W) in next cycle
  reg SFU_enable_next;              // Value written into SFU Enable in next cycle
  reg SFU_out_en_next;              // Value written into SFU Output Enable in next cycle

  // L0 Reg/Wires
  reg L0_WRITE;                     // L0 Write signal
  reg L0_READ;                      // L0 Read signal
  wire [bw*row-1:0] L0_MA;          // Wire connection between L0 Data out and MAC Array
  wire L0_FULL;                     // Wire out for L0 Full signal
  wire L0_READY;                    // Wire out for L0 Ready signal

  logic [3:0] kij, kij_next;
  logic [3:0] lut_ptr;


  //l0 operations. Input can be the instructions or data

  logic [6:0] ACT_ADDR;             // Address for the next activation line in ISRAM
  logic [6:0] WEIGHT_ADDR;          // Kernel element address (to be loaded next)
  logic [6:0] AW_ADDR_MUX;          // Multiplexed ISRAM Address

  logic [3:0] O_ADDR_MUX;          // Multiplexed OSRAM Address

  reg [1:0] MA_INSTR_IN;            // MAC Array Instruction In (West)
  wire [psum_bw*col-1:0] MA_OUT_S;  // MAC Array South output
  wire [col-1:0] MA_VALID;          // MAC Array Valid output

  reg SFU_EN;                       // Enable SFU
  reg SFU_OUT_EN;                   // SFU output enable
  wire [127:0] SFU_PSUMS_OUT;       // SFU partial sums output

  reg O_write;

  genvar i;


  // ---------- Module(s) instantiation ----------

  l0 #(.bw(bw)) l0_instance(
    .clk(clk),
    .reset(reset),
    .in(I_Q),
    .out(L0_MA),
    .wr(L0_WRITE),
    .rd(L0_READ),
    .o_full(L0_FULL),
    .o_ready(L0_READY),
    .cascade(cascade)
  );

  mac_array mac_array_instance (
      .clk(clk),
      .reset(SM_reset_ma),
      .out_s(MA_OUT_S),
      .in_w(L0_MA),
      .in_n(128'b0),
      .inst_w(MA_INSTR_IN),
      .valid(MA_VALID),
      .cascade(cascade)
  );

  generate
    for (i=0; i<8; i=i+1) begin
      sfu sfu_instance(
        .psum_out(SFU_PSUMS_OUT[psum_bw*i +: psum_bw]),
        .psum_in(MA_OUT_S[psum_bw*i +:psum_bw]),
        .valid(MA_VALID[i]),
        .enable(SFU_EN),
        .out_en(SFU_OUT_EN),
        .clk(clk),
        .reset(reset));
    end
  endgenerate

  // ---------- Corelet logic ----------

  // YJ // This section is used to generate the addresses for fetching data from ISRAM.
  // Review the logic here.
  always @* begin
    case(kij)
      'd0: lut_ptr = 'd0;
      'd1: lut_ptr = 'd1;
      'd2: lut_ptr = 'd2;
      'd3: lut_ptr = 'd6;
      'd4: lut_ptr = 'd7;
      'd5: lut_ptr = 'd8;
      'd6: lut_ptr = 'd12;
      'd7: lut_ptr = 'd13;
      'd8: lut_ptr = 'd14;
    endcase
    ACT_ADDR = lut_ptr + SM_counter + {SM_counter[3:2],1'b0};
    WEIGHT_ADDR = {kij,3'b0} + SM_counter;
    // YJ // Need to review this logic
    AW_ADDR_MUX = (SM_state==ACT_LD) ? ACT_ADDR + 72 : WEIGHT_ADDR;
  end

  assign I_A = AW_ADDR_MUX;
  assign I_CEN = !L0_write_next;  // Enable ISRAM only when we are reading in next cycle
  assign I_WEN = 1'b1;            // Hardcode ISRAM to Read-only

  assign O_A = O_ADDR_MUX;
  assign O_D = SFU_PSUMS_OUT;     // PSum output from SFUs routed to OSRAM Data In
  assign O_CEN = !O_write;        // OSRAM enable signal (active low)
  assign O_WEN = 1'b0;            // Hardcode OSRAM to Write-only

  assign ready = SM_ready;        

  always @(posedge clk or posedge reset) begin
    if(reset) begin
      SM_counter  <= 'd0;
      SM_state    <= 'd0;
      L0_WRITE    <= 'd0;
      L0_READ     <= 'd0;
      kij         <= 'd0;
      MA_INSTR_IN <= 'd0;
      SFU_EN      <= 'd0;
      SFU_OUT_EN  <= 'd0;
      O_write     <= 'd0;
      SM_ready    <= 'd0;
      SM_reset_ma <= 'd1;
      SM_reset_ma_next <= 'd0;
    end
    else begin
      // YJ // Do we need these delayed signals?
      // SM_counter  <= #1 SM_counter_next;
      // SM_state    <= #1 SM_state_next;
      // L0_WRITE    <= #1 L0_write_next;
      // L0_READ     <= #1 L0_read_next;
      // MA_INSTR_IN <= #1 MA_instr_in_next;
      // kij         <= #1 kij_next;

      SM_counter  <= SM_counter_next;
      SM_state    <= SM_state_next;
      kij         <= kij_next;

      SM_state_next   <= SM_state;
      SM_counter_next <= SM_counter;

      L0_WRITE    <= L0_write_next;

      SFU_EN      <= SFU_enable_next;
      SFU_OUT_EN  <= SFU_out_en_next;

      SM_reset_ma <= SM_reset_ma_next;

    end
  end

  always @(negedge clk) begin
    if (!reset) begin
      L0_READ     <= L0_read_next;
      MA_INSTR_IN <= MA_instr_in_next;

      if (SFU_OUT_EN)
        O_write <= 'b1;   // Copy accumulated PSUMS into OSRAM
      else
        O_write <= 'b0;
    end
  end

  // ---------- State Machine logic ----------

  //Conventions
  // write_next is 1 for L0 write
  // write_next is 0 for L0 read
  always @* begin
    // These value copies can be done on clk rising edge
    // SM_state_next   <= SM_state;
    // SM_counter_next <= SM_counter;
    // MA_instr_in_next<= 2'd0;
    // L0_write_next   <= 'b0;
    // L0_read_next    <= 'b0;
    kij_next        <= kij;
    case (SM_state)
      IDLE:
        if (start) begin
          SM_state_next   <= WT_LD;
          SM_counter_next <= 'd0;   // Initialise to 0 when start
          kij_next    <= 'd0;       // Initialise to 0 when start
          SFU_enable_next <= 'd0;
          SM_reset_ma_next  <= 'd1; // Keep MAC Array reset till we begin operation
        end
        else SM_state_next <= IDLE;

      // [WEIGHT] Read 1 line from SRAM and write into L0 (write_next = 1)
      // cascade_L0 = 0
      // cascade_sysarr = 0
      // instr_w = 0x01
      // l0rd = 1 (read_next = 1)
      // [WEIGHT] Read 1 line from SRAM and write into L0 [Done automatically by l0wr signal]
      // Pop 1 line from L0 FIFOs into SysArr [Done automatically by l0rd signal]
      // Repeat prev 2 steps 5 times
      // Pop 1 line from L0 FIFOs into SysArr
      // l0rd = 0
      WT_LD:
        if (SM_counter > 'd8) begin
          // All weights have been provided to the SysArr.
          // Set instr to 0x00 (NOP)
          L0_read_next     <=  1'b0;
          SM_state_next    <=  WT_ACT_INTER;
          SM_counter_next  <=  'd0;
          MA_instr_in_next <=  2'b00;
        end else if (SM_counter > 'd7) begin
          // All weights have been loaded into L0 already
          // Disable writing into L0
          L0_write_next    <=  1'b0;
          SM_counter_next  <=  SM_counter + 1;
        end else if (SM_counter > 'd0) begin
          // First weight has been loaded into L0.
          // Enable reading from L0
          // Set instr to 0x01 (load)
          L0_read_next     <=  1'b1;
          MA_instr_in_next <= 2'b01;
          SM_counter_next  <=  SM_counter + 1;
        end else begin
          // Initialize state
          // Enable writing to L0
          // Disable cascade and reading from L0
          L0_write_next    <= 1'b1;
          L0_read_next     <= 1'b0;
          cascade          <= 1'b0;
          SM_reset_ma_next <= 'd0;  // Enable MAC Array before we begin loading weights
          SM_counter_next  <= SM_counter + 1;
          SM_state_next    <= SM_state;
        end

      // instr_w = 0x00
      // Wait 8 cycles.
      // [OPTIONAL] During this weight, we can prefetch the first line for activations.
      WT_ACT_INTER:
        if (SM_counter > 'd6) begin
          // Weights have been loaded into the SysArr PEs
          // Move on to supplying the activations in the next state
          SM_state_next    <=  ACT_LD;
          SM_counter_next  <=  'd0;
        end else begin
          // Initialize state
          // Wait for a total of 8 cycles
          SM_counter_next  <=  SM_counter + 1;
          SM_state_next    <= SM_state;
        end

      // [ACT] Read 1 line from SRAM and write into L0
      // cascade_L0 = 1
      // cascade_sysarr = 1
      // instr_w = 0x10
      // l0rd = 1
      // [ACT] Read 1 line from SRAM and write into L0
      // Pop 1 line from L0 FIFOs into SysArr [Done automatically by l0rd signal]
      // Repeat prev 2 steps 14 times
      // Pop 1 line from L0 FIFOs into SysArr [Done automatically by l0rd signal]
      // l0rd = 0
      // If kij index < 8, repeat from the top (kernel loading state)
      ACT_LD: //YJ // Add inter-cycle buffers (between activation input end and weight load beginning)
        if (SM_counter > 'd30) begin
          // Activations/PSums have been calculated
          // YJ // Disable SFU to avoid any accidental overwrites. Here or 1 cycle later?
          // YJ // Reset MAC Array to clear all weights?
          // Move to next step
          SFU_enable_next  <= 'd0;
          SM_counter_next  <=  'd0;
          SM_state_next    <=  (kij < 'd7) ? WT_LD : PSUMS_OSRAM_WR;
          kij_next <= kij=='d8 ? 'd8 : kij+'d1;
          SM_reset_ma_next <= 'd1;
        end else if (SM_counter > 'd22) begin
          // All activations have been provided to the SysArr.
          // Wait for execution to complete.
          L0_read_next     <=  1'b0;
          SM_counter_next  <=  SM_counter + 1;
        end else if (SM_counter > 'd15) begin
          // Set instr to 0x00 (NOP, will be cascaded as required)
          // Delayed by 1 cycle because this is propagated at falling edge
          MA_instr_in_next <=  2'b00;
          SM_counter_next  <=  SM_counter + 1;
        end else if (SM_counter > 'd14) begin
          // All activations have been loaded into L0 already
          // Disable writing into L0
          L0_write_next    <=  1'b0;
          SM_counter_next  <=  SM_counter + 1;
        end else if (SM_counter > 'd0) begin
          // First activation has been loaded into L0.
          // Enable reading from L0
          // Set instr to 0x10 (execute)
          L0_read_next     <=  1'b1;
          MA_instr_in_next <=  2'b10;
          SM_counter_next  <=  SM_counter + 1;
        end else begin
          // Initialise state.
          // Enable cascade and writing to L0
          // Enable SFU. Will be active only when it gets an active signal from MAC Array
          L0_write_next    <=  1'b1;
          cascade          <=  1'b1;
          SFU_enable_next  <= 'd1;
          SM_counter_next  <=  SM_counter + 1;
          SM_state_next    <= SM_state;
        end

      PSUMS_OSRAM_WR:
        if (SM_counter > 'd15) begin
          SFU_out_en_next <= 'b0;
          SM_counter_next <= 'd0;
          SM_state_next   <= WAIT_FOR_NEXT;
        end
        else begin
          O_ADDR_MUX = SM_counter;
          SFU_out_en_next <= 'b1;
          SM_state_next   <= SM_state;
          SM_counter_next <= SM_counter + 1;
        end

      WAIT_FOR_NEXT:
        begin
          SM_ready <= 1;
          SM_counter_next  <=  SM_counter + 1;
          SM_state_next   <= SM_state;
        end
        // SM_state_next    <= SM_state;

        // Owrite <= 0;
    endcase
  end

endmodule
