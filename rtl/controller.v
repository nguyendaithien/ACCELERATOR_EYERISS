module CONTROLLER #( parameter DATA_WIDTH = 16 ,NUM_CHANNEL = 3, IFM_WIDTH = 9, IFM_HEIGHT = 9, OFM_SIZE = 7, KERNEL_SIZE = 3) (
   clk1
	,clk2
	,rst_n
	,start_conv
	,start_again
	,ifm_read
	,wgt_read
	,p_valid_output
	,last_channel
	,end_conv
	,wr_en_1
	,wr_en_2
	,wr_en_3
	,wr_clr
	,rd_en_1
	,rd_en_2
	,rd_en_3
	,rd_clr
	,wr_en_psum
  ,wr_psum_clr
	,rd_en_psum
	,rd_psum_clr
	,sel_mux_0
	,channel_num
	,collum_num
	,cnt_pixel
	);

  input clk1;
  input clk2; 
	input rst_n;
  input start_conv;
  input start_again;
  output ifm_read; 
  output wgt_read;
  output p_valid_output;
  output last_channel;
  output end_conv;
  output wr_en_1;
  output wr_en_2;
  output wr_en_3;
  output wr_clr;
  output rd_en_1;
  output rd_en_2;
  output rd_en_3;
  output rd_clr;
  output wr_en_psum;
  output wr_psum_clr;
  output rd_en_psum;
  output rd_psum_clr;
	output sel_mux_0;
	output [3:0] channel_num;
	output [9:0] collum_num;
	output [9:0] cnt_pixel;

  reg wr_en_1;
  reg wr_en_2;
  reg wr_en_3;
  reg wr_clr;
  reg rd_en_1;
  reg rd_en_2;
  reg rd_en_3;
  reg rd_clr;
  reg wr_en_psum;
  reg wr_psum_clr;
  reg rd_en_psum;
  reg rd_psum_clr;
  reg sel_mux_0;
	reg ifm_read;
	reg wgt_read;

	reg [2:0] current_state;
	reg [2:0] next_state   ;

	reg [9:0] cnt_pixel; // counting [0:input_size-kernel_size+1]
  reg [9:0] collum_num; // counting collum

	reg [3:0] channel_num;
  reg [2:0] cnt_rd_en;
  reg [2:0] cnt_wr_en;

  parameter IDLE          = 4'd0;
	parameter END_ROW       = 4'd1;
	parameter COMPUTE       = 4'd2;
	parameter WR_CLEAR      = 4'd3;
	parameter RD_CLEAR      = 4'd4;
	parameter RD_CLEAR_PSUM = 4'd5;
	parameter WR_CLEAR_PSUM = 4'd6;
  parameter WRITE_DATA    = 4'd7;
	parameter FINISH        = 4'd8;

  always @(posedge clk1 or negedge rst_n) begin
  	if(!rst_n) begin
  		current_state <= 0;
  	end
  	else begin
  		current_state <=  next_state;
  	end
  end

	always @(current_state or start_conv or cnt_pixel) begin
	next_state = 4'bx;
	case(current_state)
		IDLE: 
			if(start_conv)
	      next_state = COMPUTE;
			else 
				next_state = IDLE;
		COMPUTE: 
			next_state = (cnt_pixel == IFM_WIDTH+1) ? END_ROW : COMPUTE; 
		END_ROW: 
			next_state = COMPUTE;
		FINISH:
			next_state = FINISH;
	default: next_state = IDLE;
  endcase
	end
  always @(posedge clk1 or negedge rst_n) begin
		if(!rst_n) begin
			channel_num     <= 0;	
    	cnt_pixel       <= 0; 
    	collum_num      <= 0;
    	cnt_rd_en       <= 0;
    	cnt_wr_en       <= 0;
		end
		else begin
		case(next_state)
			IDLE: begin
				channel_num     <= 0;	
				cnt_pixel       <= 0; 
				collum_num      <= 0; 				
				cnt_rd_en       <= 0;
				cnt_wr_en       <= 0;
			end
			COMPUTE : begin
			  if(cnt_pixel == KERNEL_SIZE + 1) begin
					cnt_wr_en  = cnt_wr_en + 1; 
				  cnt_pixel = cnt_pixel + 1;
					end
        else if(cnt_pixel == IFM_WIDTH + 1) 
					begin
						cnt_pixel = 0;
						collum_num = collum_num + 1;
					end
			  else if((cnt_pixel == 0) && (collum_num == IFM_HEIGHT-1)) begin
						channel_num = channel_num + 1;
						end
				else cnt_pixel = cnt_pixel + 1;
				end
			END_ROW: 
				cnt_pixel = 0;
				endcase
			end
	 end
 reg wr_en;
 reg rd_en;
	 always @(posedge clk1 or negedge rst_n) begin
	 		if(!rst_n) begin
				{wr_en_1,wr_en_2,wr_en_3,wr_clr,rd_en_1,rd_en_2,rd_en_3,rd_clr,wr_en_psum,wr_psum_clr,rd_en_psum,rd_psum_clr,sel_mux_0,wr_en_psum,rd_en_psum} <= 15'd0;
			end
			else begin 
				case(next_state)
					IDLE:
			      	{wr_en_1,wr_en_2,wr_en_3,wr_clr,rd_en_1,rd_en_2,rd_en_3,rd_clr,wr_en_psum,wr_psum_clr,rd_en_psum,rd_psum_clr,sel_mux_0,ifm_read} <= 14'd0;
				  COMPUTE: 
						if(cnt_pixel == 0) begin
					      {rd_en_1,rd_en_2,rd_en_3,wr_en_1,wr_en_2,wr_en_3,wr_en_psum,wr_psum_clr,rd_en_psum,rd_psum_clr,sel_mux_0,ifm_read} <= 12'b111000000001;
						end
						else if(cnt_pixel == OFM_SIZE + 1) begin
					      {rd_en_1,rd_en_2,rd_en_3,wr_en_psum,wr_psum_clr,rd_en_psum,rd_psum_clr,sel_mux_0} <= 8'b00000000;
								end
						else if(cnt_pixel == KERNEL_SIZE + 1) begin 
					      {wr_en_1,wr_en_2,wr_en_3,wr_en_psum,wr_psum_clr,rd_en_psum,rd_psum_clr,sel_mux_0} <= 8'b11100000;
						end
					END_ROW: 
					      {rd_en,wr_en_psum,wr_psum_clr,rd_en_psum,rd_psum_clr,sel_mux_0} <= 8'b100000;
			endcase
		end
	end
	reg wr_en_prev;
	reg rd_en_prev;
	always @(posedge clk1) begin
	  if(!wr_en_1 && wr_en_prev) begin
			wr_clr <= 1;
		end
		else begin
			wr_clr <= 0;
		end
		wr_en_prev <= wr_en_1;
	end
	always @(posedge clk1) begin
	  if(!rd_en_1 && rd_en_prev) begin
			rd_clr <= 1;
		end
		else begin
			rd_clr <= 0;
		end
		rd_en_prev <= rd_en_1;
	end














	endmodule


			
			







