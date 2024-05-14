module PE_FSM #(parameter KERNEL_SIZE = 3, IFM_WIDTH = 64, IFM_HEIGHT = 64, DATA_WIDTH = 16, NUM_CHANNEL = 3) (
		 	 clk1
			,clk2
			,rst_n
			,start_conv
			,start_again
			,channel_num
			,kernel_num
			,ifm_read
			,wgt_read
			,p_valid_output
			,cnt_pixel
			,last_channel
			,end_conv
			,cnt_channel
			,set_wgt
			,set_ifm
			,set_reg
			,counter
			,end_channel
			,next_state
		);
   input clk1;
   input clk2;
	 input rst_n;
   input start_conv;
   input start_again;
   input kernel_num;
	 input end_channel;

   output [4:0] channel_num;
   output ifm_read;
   output wgt_read;
   output p_valid_output;
   output [6:0] cnt_pixel;
	 output last_channel;
	 output end_conv;
	 output [4:0] cnt_channel;
	 output set_wgt;
	 output set_ifm;
	 output set_reg;
	 output [15:0] counter;
	 output [2:0] next_state;

	 parameter IDLE = 3'b000;
	 parameter LOAD_PARAM = 3'b001;
	 parameter COMPUTE = 3'b010;
	 parameter END_CONV = 3'b011;
	 
	 reg ifm_read;
	 reg wgt_read;
	 reg set_ifm;
	 reg set_reg;
	 reg p_valid_output;
	 reg last_channel;
	 reg end_conv;
	 reg set_wgt;
	 reg p_valid_data;
	 reg [6:0]  cnt_pixel;
	 reg [15:0] counter;
	 reg [4:0]  cnt_channel;

	 reg [2:0] current_state;
	 reg [2:0] next_state;

	 always @(posedge clk1 or negedge rst_n) begin
	 		if(!rst_n) begin
				current_state <= IDLE;
			end
			else 
				current_state <= next_state;
		end

	 always @(current_state or cnt_channel or start_conv or start_again or cnt_pixel or counter) begin
	 		next_state = IDLE;
			case(current_state) 
				IDLE:begin
					if(start_again || start_conv)
							next_state = LOAD_PARAM;
					else if(start_again && (cnt_channel == NUM_CHANNEL) && (cnt_pixel == 0) && (counter == 0) ) 
							next_state = END_CONV;
					else 
					next_state = IDLE;
				end
				LOAD_PARAM:
					next_state = (counter == 2) ? COMPUTE : LOAD_PARAM;
				COMPUTE: begin
				  if(counter == IFM_WIDTH * IFM_HEIGHT + KERNEL_SIZE - 1)
						next_state = END_CONV;
				//	if(end_channel)
				//		next_state = IDLE;
					else 
						next_state = COMPUTE;
				end
				END_CONV:
					if(counter == 4) 
							next_state = IDLE;
				default:
					next_state = IDLE;
			endcase
		end
    

		always @(posedge clk1 or negedge rst_n) begin
			if(!rst_n) begin
				{ifm_read,wgt_read, p_valid_data, last_channel, end_conv} <= 5'b00000;
			end
			else begin
				{ifm_read,wgt_read, p_valid_data, last_channel, end_conv} <= 5'b00000;
				case(next_state)
					IDLE:
				    {ifm_read,wgt_read, p_valid_data, last_channel, end_conv, set_wgt, set_ifm, set_reg} <= 8'b00000000;
					LOAD_PARAM: begin
				    {ifm_read, p_valid_data, end_conv, set_wgt, set_ifm, set_reg} <= 6'b000110;
					   wgt_read <= (counter == 1) ? 1 : 0;
						 last_channel <= ((counter == 3) && (cnt_channel == 0)) ? 1: 0;
					end
					COMPUTE: begin
				    {ifm_read, wgt_read, p_valid_data, last_channel, end_conv, set_wgt, set_ifm, set_reg} <= 8'b10100011;
						// ifm_read <= (counter <= IFM_WIDTH * IFM_HEIGHT ) ? 1 : 0;
					end
					END_CONV:
				    {ifm_read,wgt_read, p_valid_data, last_channel, end_conv, set_reg} <= 6'b000011;
					default:
				    {ifm_read,wgt_read, p_valid_data, last_channel, end_conv, set_reg} <= 6'b000000;
				endcase
			end
		end

    always @(posedge clk1 or negedge rst_n) begin
			if(!rst_n) begin
				cnt_pixel <= 0;
				counter <= 0;
				cnt_channel <= 0;
			end
			else begin
				if(next_state == IDLE) begin
					cnt_pixel <= 0;
					counter <= 0;
				end
				else begin
					if(cnt_pixel == IFM_WIDTH) begin
						cnt_pixel <= 1;
						counter <= (current_state == COMPUTE) ? counter + 1 : 0;
					end
					else begin
						cnt_pixel <= (!wgt_read && !start_conv) ? cnt_pixel + 1 : cnt_pixel;
						counter <= (counter == IFM_WIDTH * IFM_HEIGHT + KERNEL_SIZE) ? 0 : counter + 1;
						if(counter == IFM_WIDTH*IFM_HEIGHT+ KERNEL_SIZE) begin
							counter <= 1;
							cnt_channel <= cnt_channel + 1;
							end
					end
				end
			end
		end

		assign channel_num = cnt_channel;
endmodule
