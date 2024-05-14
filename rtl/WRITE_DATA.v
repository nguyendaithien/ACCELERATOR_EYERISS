module WRITE_DATA #( parameter DATA_WIDTH = 16 ,NUM_CHANNEL = 3, IFM_WIDTH = 9, IFM_HEIGHT = 9, OFM_SIZE = 7, KERNEL_SIZE = 3) (
     clk1
    ,clk2
    ,rst_n
    ,start_init
    ,channel_num
    ,last_channel
    ,data_in
		,cnt_pixel
		,counter
    ,start_again
    ,odd_cnt
    ,p_write_zero
    ,p_init
    ,data_output
    ,data_output_valid
		,wr_en_psum
		,rd_en_psum
		,rd_psum_clr
		,wr_psum_clr
		,sel_mux
 );

input clk1; 
input clk2;
input rst_n;
input start_init;
input [6:0] cnt_pixel;
input [4:0] channel_num;
input last_channel;
input [DATA_WIDTH-1:0] data_in;
input [15:0] counter;

output [DATA_WIDTH-1:0] data_output;
output start_again;
output odd_cnt; 
output data_output_valid;
output p_init;
output p_write_zero;
output wr_en_psum;
output wr_psum_clr;
output rd_en_psum;
output rd_psum_clr;
output sel_mux;
reg wr_en_psum;
reg rd_en_psum;
reg rd_psum_clr;
reg wr_psum_clr;
reg sel_mux;
reg start_again;



parameter IDLE                = 4'b0000;
parameter INIT_BUFF           = 4'b0001;
parameter START_CONV          = 4'b0010;
parameter FIRST_ROWS          = 4'b0011;
parameter WRITE_FIRST_CHANNEL = 4'b0100;
parameter END_ROW             = 4'b0101;
parameter CLEAR_BUFF          = 4'b0110;
parameter ADD_PSUM            = 4'b0111;
parameter CLEAR_CNT           = 4'b1000;
parameter WRITE_DATA          = 4'b1001;
parameter DEPTH = IFM_WIDTH - KERNEL_SIZE + 1;

reg [3:0] current_state;
reg [3:0] next_state;
reg [7:0] cnt_row_write;
reg [7:0] cnt;

always @(posedge clk2 or negedge rst_n) begin
  	if(!rst_n) begin
  		current_state <= 0;
  	end
  	else begin
  		current_state <=  next_state;
  	end
  end
always @(current_state or channel_num or last_channel  or counter or cnt or cnt_row_write) begin
		next_state = 3'bxxx;
		case (current_state)
			IDLE: 
				if(start_init) 
						next_state = INIT_BUFF;
				else
						next_state = IDLE;
			INIT_BUFF:
				if(cnt == DEPTH - 1)
						next_state = START_CONV;
				else 
						next_state = INIT_BUFF;
			START_CONV:
				if(cnt >= DEPTH+2)
					next_state = FIRST_ROWS;
				else 
					next_state = START_CONV;
			FIRST_ROWS:
					if(counter == KERNEL_SIZE*IFM_WIDTH + 1) 
						next_state = WRITE_FIRST_CHANNEL;
					else 
						next_state = FIRST_ROWS;
			WRITE_FIRST_CHANNEL:
					if(cnt_pixel == IFM_WIDTH - KERNEL_SIZE + 1)
						next_state = END_ROW;
					else 
						next_state = WRITE_FIRST_CHANNEL;
			END_ROW:
					if((cnt_pixel == IFM_WIDTH - KERNEL_SIZE + 1) && (cnt_row_write == IFM_HEIGHT - KERNEL_SIZE +1))
	          next_state = CLEAR_BUFF;
					else if(cnt_pixel == IFM_WIDTH)
						next_state = (channel_num > 0) ? ADD_PSUM : WRITE_FIRST_CHANNEL;
					else 
						next_state = END_ROW;
      ADD_PSUM:
					if(cnt_pixel == IFM_WIDTH - KERNEL_SIZE + 1)
						next_state = END_ROW;
					else 
						next_state = ADD_PSUM;
			CLEAR_BUFF:
						next_state = CLEAR_CNT;
      CLEAR_CNT:
			 			next_state = START_CONV;
      endcase
		end
							
		reg start_conv_r;
		always @(posedge clk1 or negedge rst_n) begin
			if(!rst_n) begin
				start_conv_r <= 0;
			end
			else if(current_state == START_CONV || current_state == CLEAR_CNT)
				start_conv_r <= 1;
			else 
				start_conv_r <= 0;
			end
			assign start_conv = start_conv_r;


	 always @(posedge clk1 or negedge rst_n) begin
	 		if(!rst_n) begin
				start_again <= 0;
			end
			else begin
				start_again <= (start_count == 1) ? 1 : 0;
			end
		end
		always @(posedge clk1 or negedge rst_n) begin
			if(!rst_n)
				p_init_r <= 0;
      else if(current_state == INIT_BUFF)
				p_init_r <= 0;
			end
		assign p_init = p_init_r;

    reg p_init_r;
		always @(posedge clk1 or negedge rst_n) begin
			if(!rst_n)
				cnt <= 0;
			else if(current_state == IDLE || current_state == CLEAR_CNT || current_state == CLEAR_BUFF ) 
				cnt <= 0;
			else 
				cnt <= cnt + 1;
		end

		always @(posedge wr_en_psum or negedge rst_n) begin
			if(!rst_n)	
				cnt_row_write <= 0;
			else if(current_state == WRITE_FIRST_CHANNEL || current_state == ADD_PSUM)
				cnt_row_write <= (IFM_HEIGHT - KERNEL_SIZE + 1) ? 0 : cnt_row_write + 1;
			else 
				cnt_row_write <= cnt_row_write;
		end
 
    always @(*) begin
			if(rst_n) 
					{rd_en_psum, wr_en_psum, rd_psum_clr, wr_psum_clr, sel_mux} <= 5'b00000;
			else 
			case(next_state)
				IDLE: 
					{rd_en_psum, wr_en_psum, rd_psum_clr, wr_psum_clr, sel_mux} <= 5'b00000;
				INIT_BUFF:
					{rd_en_psum, wr_en_psum, rd_psum_clr, wr_psum_clr, sel_mux} <= 5'b00000;
				FIRST_ROWS:
					{rd_en_psum, wr_en_psum, rd_psum_clr, wr_psum_clr, sel_mux} <= 5'b00000;
				WRITE_FIRST_CHANNEL:
					{rd_en_psum, wr_en_psum, rd_psum_clr, wr_psum_clr, sel_mux} <= 5'b01000;
				END_ROW:
					{rd_en_psum, wr_en_psum, rd_psum_clr, wr_psum_clr, sel_mux} <= 5'b00000;
				CLEAR_BUFF:
					{rd_en_psum, wr_en_psum, rd_psum_clr, wr_psum_clr, sel_mux} <= 5'b00110;
				ADD_PSUM:
					{rd_en_psum, wr_en_psum, rd_psum_clr, wr_psum_clr, sel_mux} <= 5'b11001;
				CLEAR_CNT:
					{rd_en_psum, wr_en_psum, rd_psum_clr, wr_psum_clr, sel_mux} <= 5'b00000;
				default:
					{rd_en_psum, wr_en_psum, rd_psum_clr, wr_psum_clr, sel_mux} <= 5'b00000;
			endcase
		end

		reg [3:0] start_count;
		reg start;
		reg [3:0] cnt_1;

		always @(posedge clk1 or negedge rst_n) begin
		  if(!rst_n) begin
			  start <= 0;
				cnt_1 <= 0;
			end
			else if(counter == IFM_WIDTH * IFM_HEIGHT) begin
			  start <= 1;
				cnt_1 <= 5;
			end
			else begin
				start <= 0;
				cnt_1 <= cnt_1;
			end
		end
				
		always @(posedge clk1 or negedge rst_n) begin
		  if(!rst_n) begin
				start_count <= 0;
			end
      else if(cnt_1 != 0) begin
				start_count <= (cnt_1 == 0) ? 0 : cnt_1 - 1;
				cnt_1 <= cnt_1 -1 ;
			end
		end

		endmodule

