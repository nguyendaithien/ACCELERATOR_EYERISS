module CONTROL_CHANNEL #( parameter DATA_WIDTH = 16 ,NUM_CHANNEL = 3, IFM_WIDTH = 9, IFM_HEIGHT = 9, OFM_SIZE = 7, KERNEL_SIZE = 3) (
		clk1
	 ,rst_n
	 ,clk2
	 ,ifm_read
	 ,start_init
	 ,end_channel
	 ,next_state
	 ,counter
);
input clk1;
input clk2;
input start_init;
input rst_n;
input ifm_read;
input [2:0] next_state;
output [15:0] counter;

output end_channel;
reg end_channel;
reg [15:0] counter ;

always @(posedge clk1 or negedge rst_n) begin
	if(!rst_n) begin
		end_channel <= 0;
		counter <= 0;
	end
	else begin
	  counter <= ( counter <= IFM_WIDTH * IFM_HEIGHT + KERNEL_SIZE && next_state == 2) ? counter + 1 : 0;
		end_channel <= (counter == IFM_WIDTH * IFM_HEIGHT + KERNEL_SIZE) ? 1 : 0; 
	end
end

endmodule

	 
