module WRITE_DATA #( parameter DATA_WIDTH = 16 ,NUM_CHANNEL = 3, IFM_WIDTH = 9, IFM_HEIGHT = 9, OFM_SIZE = 7, KERNEL_SIZE = 3) (
  clk1
 ,clk2
 ,rst_n
 ,start_conv
 ,start_again
 ,channel_num
 ,collum_num
 ,last_channel
 ,wr_en_psum
 ,rd_en_psum
 ,wr_clr
 ,rd_clr
 ,cnt_pixel
 );

input clk1; 
input clk2;
input rst_n;
input start_conv;
input [3:0] channel_num;
input [9:0] collum_num;
input last_channel;
input [9:0] cnt_pixel;
output start_again;
output wr_en_psum; 
output rd_en_psum;
output wr_clr;
output rd_clr;

reg start_again;
reg wr_en_psum ;
reg rd_en_psum ;
reg wr_clr;
reg rd_clr;

parameter IDLE    = 3'b000;
parameter FIRST_ROW = 3'b001;
parameter COMPUTE = 3'b010;
parameter END_CHANNEL =3'b011;
parameter FINISH      = 3'b100;
parameter END_ROW     = 3'b101;

reg [2:0] current_state;
reg [2:0] next_state;

always @(posedge clk2 or negedge rst_n) begin
  	if(!rst_n) begin
  		current_state <= 0;
  	end
  	else begin
  		current_state <=  next_state;
  	end
  end
always @(current_state or channel_num or collum_num or last_channel) begin
		next_state = 3'bxxx;
		case(current_state)
			IDLE: 
				if(start_conv) 
						next_state = FIRST_ROW;
				else
						next_state = IDLE;
			FIRST_ROW:
						if(collum_num == KERNEL_SIZE - 1) 
							next_state = COMPUTE;
						else 
							next_state = FIRST_ROW;
			COMPUTE: 
			      if(cnt_pixel == IFM_WIDTH)
							next_state = END_ROW;
						else 
						if((collum_num == IFM_HEIGHT) && (channel_num < NUM_CHANNEL)) 
							next_state = FIRST_ROW;
						else 
						if((collum_num == IFM_HEIGHT) && (channel_num == NUM_CHANNEL))
							next_state = FINISH;
						else 
							next_state = COMPUTE;
			END_ROW:
				next_state = COMPUTE;
			FINISH: 
			     next_state = FINISH;
			default: next_state = IDLE;
			endcase 
end

always @(posedge clk2 or negedge rst_n) begin
		if(!rst_n) begin
			start_again <= 0; 
			wr_en_psum  <= 0;
      rd_en_psum  <= 0;
			rd_clr      <= 0;
			wr_clr      <= 0;
		end
		else begin
			case(next_state) 
				IDLE: begin 
			    start_again <= 0; 
			    wr_en_psum  <= 0;
          rd_en_psum  <= 0;
			    rd_clr      <= 0;
			    wr_clr      <= 0;
				end
				FIRST_ROW: begin
			    start_again <= 0; 
			    wr_en_psum  <= 0;
          rd_en_psum  <= 0;
				end
				COMPUTE:begin
			    start_again <= 0; 
			    wr_en_psum  <= 1;
          rd_en_psum  <= 1;
				end
				END_ROW: begin
			    start_again <= 0; 
			    wr_en_psum  <= 0;
          rd_en_psum  <= 0;
				end
				FINISH: begin
			    start_again <= 1; 
			    wr_en_psum  <= 0;
          rd_en_psum  <= 0;
				end
			endcase
		end
	end
endmodule

					
					




















