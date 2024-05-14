module WRITE_READ_FIFO_FSM #(parameter KERNEL_SIZE = 3, IFM_WIDTH = 64, IFM_HEIGHT = 64, DATA_WIDTH = 16, NUM_CHANNEL = 3) (
		 	 clk1
			,clk2
			,rst_n
			,start_conv
			,start_again
			,channel_num
      ,counter
			,cnt_pixel

			,wr_en_0
			,wr_en_1
			,wr_en_2
			,rd_en_0
			,rd_en_1
			,rd_en_2
			,rd_clr
			,wr_clr
);


  input clk1; 
  input clk2;
  input rst_n;
  input start_conv;
  input start_again; 
  input [4:0] channel_num;
  input [15:0] counter;
  input [6:0] cnt_pixel;
   
	output wr_en_0;
  output wr_en_1; 
  output wr_en_2; 
  output wr_clr;
  output rd_en_0; 
  output rd_en_1; 
  output rd_en_2; 
  output rd_clr;
  wire wr_en_0;
  wire wr_en_1;
  wire wr_en_2;
  reg  wr_clr;
  wire rd_en_0;
  wire rd_en_1;
  wire rd_en_2;
  reg rd_clr;
	reg wr_en_prev;
	reg rd_en_prev;

  reg [7:0] collum_num_wr_en   ;
	reg [7:0] collum_num_read_en;
  reg [2:0] current_state;
  reg [2:0] next_state   ;
	reg [7:0] wr_cnt;
	reg [7:0] rd_cnt;

   always @(posedge clk1 or negedge rst_n) begin
   	if(!rst_n)begin
			collum_num_wr_en <= 0;
		end
		else begin
   		collum_num_wr_en = ( wr_cnt == IFM_WIDTH - KERNEL_SIZE + 1) ? ( collum_num_wr_en == IFM_HEIGHT - 1) ? 0 :   collum_num_wr_en + 1 : collum_num_wr_en;
   end
	 end
   always @(posedge clk2 or negedge rst_n) begin
   	if(!rst_n)begin
			collum_num_read_en <= 0;
		end
		else begin
   		collum_num_read_en = ( cnt_pixel == IFM_WIDTH ) ? (collum_num_read_en == IFM_HEIGHT - 1) ? 0 : collum_num_read_en + 1 : collum_num_read_en;
   end
	 end

	 always @(posedge clk1 or rst_n) begin
	 		if(!rst_n) begin
				wr_cnt <= 0;
			end
			else if((counter > KERNEL_SIZE) || ((wr_cnt <= IFM_WIDTH - KERNEL_SIZE + 1) && (collum_num_wr_en > 0) ) || (collum_num_wr_en == 0 && channel_num > 0 ) || ((wr_cnt == IFM_WIDTH - 1) && (collum_num_wr_en == 0)))  begin
				wr_cnt <= ((wr_cnt > (IFM_WIDTH - KERNEL_SIZE + 1)) || ((wr_cnt == IFM_WIDTH - 1) && (collum_num_wr_en == 0))) ? 0 : wr_cnt + 1;
			end
		end
   
	 always @(posedge clk2 or rst_n) begin
	 		if(!rst_n) begin
				rd_cnt <= 0;
			end
			else 
				rd_cnt <= cnt_pixel;
		end
		always @(posedge clk1) begin
			if(counter == 0) begin
				rd_clr <= 1;
				wr_clr <= 1;
			end
		end

   	always @(posedge clk1) begin
   		if(!wr_en_0 && wr_en_prev) begin
   			wr_clr <= 1;
   		end
   		else begin
   			wr_clr <= 0;
   		end
   		wr_en_prev <= wr_en_0;
   	end
   	always @(posedge clk2) begin
   	  if(!rd_en_0 && rd_en_prev) begin
   	  		rd_clr <= 1;
   	  end
   	  else begin
   	  		rd_clr <= 0;
   	  end
   	  	rd_en_prev <= rd_en_0;
   	  end

     assign rd_en_0 =  ( (collum_num_read_en >= 1) && ( cnt_pixel <= (IFM_WIDTH-KERNEL_SIZE+1)) && (cnt_pixel > 0)) ? 1 : 0;
     assign rd_en_1 =  ( (collum_num_read_en >= 2) && ( cnt_pixel <= (IFM_WIDTH-KERNEL_SIZE+1)) && (cnt_pixel > 0)) ? 1 : 0;
     assign rd_en_2 =  ( (collum_num_read_en >= 3) && ( cnt_pixel <= (IFM_WIDTH-KERNEL_SIZE+1)) && (cnt_pixel > 0)) ? 1 : 0;
   
   
     assign wr_en_0 =  ( (collum_num_wr_en >= 0)    && ( wr_cnt <= (IFM_WIDTH-KERNEL_SIZE+1)) && (wr_cnt > 0)) ? 1 : 0;
     assign wr_en_1 =  ( (collum_num_wr_en >= 1)    && ( wr_cnt <= (IFM_WIDTH-KERNEL_SIZE+1)) && (wr_cnt > 0)) ? 1 : 0;
     assign wr_en_2 =  ( (collum_num_wr_en >= 2)    && ( wr_cnt <= (IFM_WIDTH-KERNEL_SIZE+1)) && (wr_cnt > 0)) ? 1 : 0;

endmodule

