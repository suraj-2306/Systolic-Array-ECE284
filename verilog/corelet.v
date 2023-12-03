//On the other hand, a corelet.v includes all the other blocks (e.g., L0, 2d PE array, ofifo) other than SRAMs. module l0 (clk, in, out, rd, wr, o_full, reset, o_ready);
module corelet ( input wire clk,
    input wire start,
    input wire reset,
    input   [31:0]  I_Q,
    output  [6:0]   I_A,
    output          I_CEN,
    output          I_WEN
    // input wire l0rd, input wire l0wr,
    // input wire [row*bw-1:0] l0in 
);

  parameter col = 8;
  parameter row = 8;
  parameter bw = 4;
  parameter psum_bw = 16;
  // parameter total_cycle = 64;
  // parameter total_cycle_2nd = 8;


  wire [bw*row-1:0] l02ma;
  reg l0reset = 0;
  wire l0full;
  wire l0ready;
  logic [3:0] kij, kij_next;
  logic [3:0] lut_ptr;


  //l0 operations. Input can be the instructions or data
  //

    logic [6:0] ACT_ADDR;
    logic [6:0] WEIGHT_ADDR;
    logic [6:0] AW_ADDR_MUX;

    always @*
    begin
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
        ACT_ADDR = lut_ptr + counter + {counter[3:2],1'b0};
        WEIGHT_ADDR = {kij,3'b0} + counter;
        AW_ADDR_MUX = (state==ACT_SR_L0) ? ACT_ADDR + 72 : WEIGHT_ADDR;
    end
  //
  //
    assign I_A    = AW_ADDR_MUX;    //output  [6:0] 
    assign I_CEN     = !write_next;    //output        
    assign I_WEN     = 1'b1;           //output       

l0 #(
        .bw(bw)
    ) l0_instance(
        .clk(clk), 
        .in(I_Q), //Q_MUX),  
        .out(l02ma), 
        .reset(reset),
        .wr(write), 
        .rd(read), 
        .o_full(), 
        .o_ready()
            );

  reg [col*bw-1:0] ofwr;
  reg ofrd;
  reg    ofreset;
  wire [col*psum_bw-1:0] ofin;
  wire   [col*psum_bw-1:0] ofout;
  wire   ofo_full;
  wire   ofo_ready;
  wire   ofo_valid;

  ofifo #(
      .bw(bw)
  ) ofifo_instance (
      .clk(clk),
      .in(ma2of),
      .out(ofout),
      .rd(ofrd),
      .wr(ofwr),
      .o_full(ofo_full),
      .reset(ofreset),
      .o_ready(ofo_ready),
      .o_valid(ofo_valid)
  );


  wire [psum_bw*col-1:0] ma2of;
  wire [col-1:0] mavalid;

  mac_array mac_array_instance (
      .clk(clk),
      .reset(reset),
      .out_s(ma2of),
      .in_w(l02ma),
      .in_n(128'b0),
      .inst_w(in_instr),
      .valid(mavalid)
  );


  reg sfuacc;
  reg sfurelu;
  reg sfureset;
  wire [bw-1:0] sfuin;
  wire [psum_bw-1:0] sfuout;

  genvar i;

  generate
    for (i = 0; i < col; i = i + 1) begin : col_num
      sfu sfu_instance (
          .out(sfuout),
          .in(ma2of[psum_bw*(i+1)-1:psum_bw*i]),
          //TODO: Come back to this and change the ma2of if requied
          .acc(sfuacc),
          .relu(sfurelu),
          .clk(clk),
          .reset(sfureset)
      );
    end
  endgenerate

  //Controller state 
  localparam IDLE = 4'b0000;
  localparam WGT_SR_L0 = 4'b0001;
  localparam WGT_L0_MA = 4'b0010;
  localparam ACT_SR_L0= 4'b0011;
  localparam ACT_L0_MA= 4'b0100;

  reg [6:0] counter;
  reg [3:0] state;
  reg write;
  reg read;
  reg [1:0]in_instr;
  reg [6:0] counter_next;
  reg [3:0] state_next;
  reg write_next;
  reg read_next;
  reg [1:0]in_instr_next;

  always @(posedge clk or posedge reset)
    begin
        if(reset)
        begin
            counter <= 'd0;
            state   <= 'd0;
            write   <= 'd0;
            read    <= 'd0;
            in_instr<= 'd0;
            kij     <= 'd0;
        end
        else
        begin
            counter <= #1 counter_next ;
            state   <= #1 state_next   ;
            write   <= #1 write_next   ;
            read   <= #1 read_next   ;
            in_instr<= #1 in_instr_next;
            kij     <= #1 kij_next;
        end
    end 

  //Conventions
  // write_next is 1 for L0 write
  // write_next is 0 for L0 read
  always @* begin
    state_next   <= state;
    counter_next <= counter;
    in_instr_next   <= 2'd0;
    write_next   <= 'b0;
    read_next    <= 'b0;
    kij_next        <= kij;
    case (state)
      IDLE:
      if (start) begin
        state_next   <= WGT_SR_L0;
        counter_next <= 'd0;  //initialise to 0 when start
        kij_next    <= 'd0;      //initialise to 0 when start
      end else state_next <= IDLE;
      WGT_SR_L0:
      //Write the logic for next state
        if(counter>'d7)
        begin
          counter_next<=0;
          state_next<=WGT_L0_MA;
          write_next <= 1'b0;
        end
        //Need to cover CEN, WEN and Addr, for the SRAM
        //Also need to cover write, in for L0 
        else begin
          counter_next<=counter +1;
          state_next<=state;
          write_next<=1'b1;
      end
      WGT_L0_MA:
        if(counter>'d23)
        begin
          counter_next<=0;
          state_next<=ACT_SR_L0;
          write_next <= 1'b0;
        end
        else if(counter>'d7)
        begin
          state_next<=state;
          counter_next <= counter+1;
          in_instr_next <=2'b00;
          read_next<=1'b0;
        end
        else
        begin
          state_next <= state;
          counter_next <= counter+1;
          in_instr_next <= 2'b01;
          read_next <= 1'b1;
        end
      ACT_SR_L0:
        if(counter>'d15)
        begin
          counter_next<=0;
          state_next<=ACT_L0_MA;
          write_next <= 1'b0;
        end
        else 
        begin       
          counter_next<=counter +1;
          state_next<=state;
          write_next<=1'b1;
        end 
      ACT_L0_MA:
        if(counter>'d31)
        begin
          counter_next<=0;
          state_next<=ACT_SR_L0;
          write_next<= 1'b0;
          kij_next <= kij=='d8 ? 'd8 : kij+'d1;
        end
        else if(counter>'d15)
        begin
          state_next<=state;
          counter_next <= counter+1;
          in_instr_next<=2'b00;
          read_next<=1'b0;
        end
        else
        begin
          state_next<=state;
          counter_next <= counter+1;
          in_instr_next<=2'b10;
          read_next<=1'b1;
        end
      // PSUM

    endcase
  end
endmodule
