   54 endmodule 

  parameter row  = 8;
  parameter bw = 4;

  input  clk;
  input  wr;
  input  rd;
  input  reset;
  input  [row*bw-1:0] in;
  output [row*bw-1:0] out;
  output o_full;
  output o_ready;

  wire [row-1:0] empty;
  wire [row-1:0] full;
  reg [row-1:0] rd_en;
  
  genvar i;

  assign o_full  = full[row-1] ;
  assign o_ready = !o_full;


  generate
  for (i=0; i<row ; i=i+1) begin : row_num
      fifo_depth64 #(.bw(bw)) fifo_instance (
	    .rd_clk(clk),
	    .wr_clk(clk),
	    .rd(rd_en[i]),
	    .wr(wr),
      .o_empty(empty[i]),
      .o_full(full[i]),
	    .in(in[bw*(i+1)-1:i*bw]),
	    .out(out[(i+1)*bw-1:i*bw]),
      .reset(reset));
  end
endgenerate


  always @ (posedge clk) begin
   if (reset) begin
      rd_en <= 8'b00000000;
   end
   else

      /////////////// version1: read all row at a time ////////////////
        // rd_en<={row{rd}};
        
      ///////////////////////////////////////////////////////

      //////////////// version2: read 1 row at a time /////////////////
      ///////////////////////////////////////////////////////
      rd_en<={rd_en[row-2:0],rd};
    end

endmodule
