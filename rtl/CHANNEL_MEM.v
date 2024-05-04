module CHANNEL_MEM #( parameter DATA_WIDTH = 16, MEM_SIZE = 1024, ADD_WIDTH = 10) (
		clk
	 ,wr_en
	 ,rd_en
	 ,rd_inc
	 ,wr_inc
	 ,wr_clr
	 ,rd_clr
	 ,data_in
	 ,data_out
	 );
   input clk; 
   input wr_en;
   input rd_en;
   input rd_inc; 
   input wr_inc;
   input wr_clr;
   input rd_clr;
   
   input  [DATA_WIDTH-1:0] data_in;
   output [DATA_WIDTH-1:0] data_out;

	 reg [DATA_WIDTH-1:0] ram_array [0:MEM_SIZE-1];
	 reg [ADD_WIDTH-1:0] wr_ptr;
	 reg [ADD_WIDTH-1:0] rd_ptr;
	 reg [DATA_WIDTH-1:0] data_read_mem;

	 always @(posedge clk) begin
	 		if(wr_clr) begin
				wr_ptr <= 0;
			end
			else if(wr_en) begin
				ram_array[wr_ptr] <= data_in;
				wr_ptr <= wr_ptr + wr_inc;
			end
		end
		always @(posedge clk) begin
			if(rd_clr) begin
				rd_ptr <= 0;
			end
			else if(rd_en) begin
				data_read_mem <= ram_array[rd_ptr];
				rd_ptr <= rd_ptr + rd_inc;
			end
			else begin
				data_read_mem <= 0;
			end
		end

		assign data_out = (rd_en) ? data_read_mem : 0;
endmodule
