`timescale 1 ns/10 ps
module tb();
parameter DATA_WIDTH = 16;
parameter WEIGHT_WIDTH = 8;
parameter IFM_DATA_WIDTH = 8;
parameter IFM_DATA_HEIGHT = 9;
parameter IFM_WIDTH = 8;
parameter KERNEL_SIZE  = 3;
parameter FIFO_SIZE = 10;
parameter ADD_WIDTH = 4;
parameter ADD_WIDTH_PSUM = 10;
parameter FIFO_SIZE_PSUM = 100;
parameter OFM_SIZE = 7;
parameter NUM_CHANNEL = 3;

	reg clk1;
	reg clk2;
	reg rst_n;
	reg set_reg_pe;
	reg set_wgt;
	reg set_ifm;
	reg wr_en_0;
	reg rd_en_0;
	reg wr_en_1;
	reg rd_en_1;
	reg wr_en_2;
	reg rd_en_2;
	reg rd_clr;
	reg wr_clr;

	reg start_conv;
	reg start_again;

	reg [WEIGHT_WIDTH*KERNEL_SIZE*KERNEL_SIZE-1:0] wgt;
	reg [IFM_WIDTH-1:0] ifm;
	wire [DATA_WIDTH-1:0] data_out;
	reg [2:0] set_reg;
	reg [8:0] cnt;


	always @(posedge clk2 or negedge rst_n) begin
		if(!rst_n) begin
			cnt <= 0; 
		end
		else 
		if(set_reg_pe) begin
			cnt <= cnt + 1;
		end
	end
	initial begin
		$dumpfile("CONV_ACC.vcd");
		$dumpvars(0,tb);
	end

  TOP #(.DATA_WIDTH(DATA_WIDTH), .WEIGHT_WIDTH(WEIGHT_WIDTH), .IFM_WIDTH(IFM_WIDTH), .FIFO_SIZE(FIFO_SIZE), .INDEX_WIDTH(ADD_WIDTH), .KERNEL_SIZE(KERNEL_SIZE), .FIFO_SIZE_PSUM(FIFO_SIZE_PSUM), .INDEX_WIDTH_PSUM(ADD_WIDTH_PSUM), .IFM_DATA_WIDTH(IFM_DATA_WIDTH)) top_module(
      .clk1(clk1)
     ,.clk2(clk2)
     ,.rst_n(rst_n)                    	
     ,.set_reg(set_reg_pe)
     ,.set_wgt(set_wgt)
     ,.set_ifm(set_ifm)
     ,.wr_en_0(wr_en_0)                        		
     ,.rd_en_0(rd_en_0)
     ,.wr_en_1(wr_en_1)                        		
     ,.rd_en_1(rd_en_1)
     ,.wr_en_2(wr_en_2)                        		
     ,.rd_en_2(rd_en_2)
		 ,.rd_clr(rd_clr)
		 ,.wr_clr(wr_clr)
     ,.ifm(ifm)
		 ,.wgt(wgt)
		 ,.start_conv(start_conv)
		 ,.start_again(start_again)
     ,.data_output(data_out)
		 );
	always #5 clk1 = ~clk1;
	always @(clk1) begin
		clk2 = ~clk1;
	end
	always @(posedge clk2 or negedge rst_n) begin
		if(!rst_n) begin
			set_reg_pe = 0;
		end
		else begin
			set_reg_pe = 1'b1;
		end
	end
			
	initial begin
		rst_n = 1;
		clk1 = 1;
		clk2 = 0;
		rd_clr = 1;
		wr_clr = 1;
   	wr_en_0 =0;
		rd_en_0 =0;
   	wr_en_1 =0;
		rd_en_1 =0;
   	wr_en_2 =0;
		rd_en_2 =0;
		//rd_clr  = 0;
		//1wr_clr  = 0;
#10 rst_n = 0;
#10 rst_n = 1;
		rd_clr = 0;
		wr_clr = 0;
		start_conv = 0;
		start_again = 0;

#20 ifm = 1;
		wgt = 72'h010203010203010203;
		set_wgt =1;
		set_ifm = 1;
   	wr_en_0 =0;
		rd_en_0 =0;
   	wr_en_1 =0;
		rd_en_1 =0;
		start_conv = 1;
#10 ifm = 2;
		set_wgt =1;
		set_ifm = 1;
		start_conv = 0;
#10 ifm = 3;
		set_wgt =1;
		set_ifm = 1;
#10 ifm = 4;
		set_wgt =1;
		set_ifm = 1;
		wr_en_0 = 1;
		rd_en_0 = 0;
#10 ifm = 5;
		set_wgt =1;
		set_ifm = 1;
#10 ifm = 6;
		set_wgt =1;
		set_ifm = 1;
#10 ifm = 7;
		set_wgt =1;
		set_ifm = 1;
#10 ifm = 8;
		set_wgt =1;
		set_ifm = 1;
#10 ifm = 9;
		set_wgt =1;
		set_ifm = 1;

		// =======LINE 2============================
#10 
		wgt = 72'h010203010203010203;
#10 ifm = 2;
		wgt = 72'h010203010203010203;
		set_wgt =1;
		set_ifm = 1;
		wr_en_0 = 0;
		wr_clr = 1;
		rd_en_0 = 1;
#10 ifm = 3;
		set_wgt =1;
		set_ifm = 1;
		wr_en_0 = 0;
		rd_en_0 = 1;
		wr_en_2 = 0;
		rd_en_2 = 0;
		wr_clr = 0;
#10 ifm = 4;
		set_wgt =1;
		set_ifm = 1;
#10 ifm = 5;
		set_wgt =1;
		set_ifm = 1;
		wr_en_0 = 1;
		wr_en_1 = 1;
		rd_en_1 = 0;
#10 ifm = 6;
		set_wgt =1;
		set_ifm = 1;
#10 ifm = 7;
		set_wgt =1;
		set_ifm = 1;
#10 ifm = 8;
		set_wgt =1;
		set_ifm = 1;
#10 ifm = 9;
		set_wgt =1;
		set_ifm = 1;
		rd_en_0 = 0;
		rd_clr = 1;
#10 ifm = 10;
		set_wgt =1;
		set_ifm = 1;
		rd_clr = 0;
		
//=====================LINE 3==================================
#10 
		wgt = 72'h010203010203010203;
#10 ifm = 3;
		wgt = 72'h010203010203010203;
		set_wgt =1;
		set_ifm = 1;
		wr_en_0 = 0;
		rd_en_0 = 1;
		wr_en_1 = 0;
		rd_en_1 = 1;
		wr_clr  = 1;
#10 ifm = 4;
		wr_en_0 = 0;
		set_wgt =1;
		set_ifm = 1;
		wr_en_1 = 0;
		rd_en_1 = 1;
		wr_en_2 = 0;
		rd_en_2 = 0;
		wr_clr  = 0;
#10 ifm = 5;
		set_wgt =1;
		set_ifm = 1;
#10 ifm = 6;
		set_wgt =1;
		set_ifm = 1;
		wr_en_2 = 1;
		rd_en_2 = 0;
		wr_en_0 = 1;
		wr_en_1 = 1;
#10 ifm = 7;
		set_wgt =1;
		set_ifm = 1;
#10 ifm = 8;
		set_wgt =1;
		set_ifm = 1;
#10 ifm = 9;
		set_wgt =1;
		set_ifm = 1;
#10 ifm = 10;
		set_wgt =1;
		set_ifm = 1;
		rd_en_1 = 0;
		rd_en_0 = 0;
		rd_clr = 1;
#10 ifm = 11;
		set_wgt =1;
		set_ifm = 1;
		rd_clr = 0;
//=====================LINE 4==================================
#10 
		wgt = 72'h010203010203010203;
#10 ifm = 4;
		wgt = 72'h010203010203010203;
		set_wgt = 1;
		set_ifm = 1;
		wr_en_0 = 0;
		rd_en_0 = 1;
		wr_en_1 = 0;
		rd_en_1 = 1;
		wr_en_2 = 0;
	  rd_en_2 = 1;
		wr_en_1 = 0;
		wr_clr  = 1;

#10 ifm = 5;
		wr_en_0 = 0;
		set_wgt =1;
		set_ifm = 1;
		wr_clr  = 0;
#10 ifm = 6;
		set_wgt =1;
		set_ifm = 1;
#10 ifm = 7;
		set_wgt =1;
		set_ifm = 1;
		wr_en_0 = 1;
		rd_en_0 = 1;
		wr_en_1 = 1;
		rd_en_1 = 1;
		wr_en_2 = 1;
		rd_en_2 = 1;
#10 ifm = 8;
		set_wgt =1;
		set_ifm = 1;
#10 ifm = 9;
		set_wgt =1;
		set_ifm = 1;
#10 ifm = 10;
		set_wgt =1;
		set_ifm = 1;
#10 ifm = 11;
		set_wgt =1;
		set_ifm = 1;
		rd_en_1 = 0;
		rd_clr = 1;
		rd_en_2 = 0;
		rd_en_0 = 0;
#10 ifm = 12;
		set_wgt =1;
		set_ifm = 1;
		rd_clr = 0;
//=====================LINE 5==================================
#10 
		wgt = 72'h010203010203010203;
#10 ifm = 5;
		wgt = 72'h010203010203010203;
		set_wgt = 1;
		set_ifm = 1;
		wr_en_0 = 0;
		rd_en_0 = 1;
		wr_en_1 = 0;
		rd_en_1 = 1;
		wr_en_2 = 0;
	  rd_en_2 = 1;
		wr_en_1 = 0;
		wr_clr  = 1;

#10 ifm = 6;
		wr_en_0 = 0;
		set_wgt =1;
		set_ifm = 1;
		wr_clr  = 0;
#10 ifm = 7;
		set_wgt =1;
		set_ifm = 1;
#10 ifm = 8;
		set_wgt =1;
		set_ifm = 1;
		wr_en_0 = 1;
		rd_en_0 = 1;
		wr_en_1 = 1;
		rd_en_1 = 1;
		wr_en_2 = 1;
		rd_en_2 = 1;
#10 ifm = 9;
		set_wgt =1;
		set_ifm = 1;
#10 ifm = 10;
		set_wgt =1;
		set_ifm = 1;
#10 ifm = 11;
		set_wgt =1;
		set_ifm = 1;
#10 ifm = 12;
		set_wgt =1;
		set_ifm = 1;
		rd_en_1 = 0;
		rd_clr = 1;
		rd_en_2 = 0;
		rd_en_0 = 0;
#10 ifm = 13;
		set_wgt =1;
		set_ifm = 1;
		rd_clr = 0;
//=====================LINE 6==================================
#10 
		wgt = 72'h010203010203010203;
#10 ifm = 6;
		wgt = 72'h010203010203010203;
		set_wgt = 1;
		set_ifm = 1;
		wr_en_0 = 0;
		rd_en_0 = 1;
		wr_en_1 = 0;
		rd_en_1 = 1;
		wr_en_2 = 0;
	  rd_en_2 = 1;
		wr_en_1 = 0;
		wr_clr  = 1;

#10 ifm = 7;
		set_wgt =1;
		set_ifm = 1;
		wr_clr  = 0;
#10 ifm = 8;
		set_wgt =1;
		set_ifm = 1;
#10 ifm = 9;
		set_wgt =1;
		set_ifm = 1;
		wr_en_0 = 1;
		rd_en_0 = 1;
		wr_en_1 = 1;
		rd_en_1 = 1;
		wr_en_2 = 1;
		rd_en_2 = 1;
#10 ifm = 10;
		set_wgt =1;
		set_ifm = 1;
#10 ifm = 11;
		set_wgt =1;
		set_ifm = 1;
#10 ifm = 12;
		set_wgt =1;
		set_ifm = 1;
#10 ifm = 13;
		set_wgt =1;
		set_ifm = 1;
		rd_en_1 = 0;
		rd_clr = 1;
		rd_en_2 = 0;
		rd_en_0 = 0;
#10 ifm = 14;
		set_wgt =1;
		set_ifm = 1;
		rd_clr = 0;
//=====================LINE 7==================================
#10 
		wgt = 72'h010203010203010203;
#10 ifm = 7;
		wgt = 72'h010203010203010203;
		set_wgt = 1;
		set_ifm = 1;
		wr_en_0 = 0;
		rd_en_0 = 1;
		wr_en_1 = 0;
		rd_en_1 = 1;
		wr_en_2 = 0;
	  rd_en_2 = 1;
		wr_en_1 = 0;
		wr_clr  = 1;

#10 ifm = 8;
		wr_en_0 = 0;
		set_wgt =1;
		set_ifm = 1;
		wr_clr  = 0;
#10 ifm = 9;
		set_wgt =1;
		set_ifm = 1;
#10 ifm = 10;
		set_wgt =1;
		set_ifm = 1;
		wr_en_0 = 1;
		rd_en_0 = 1;
		wr_en_1 = 1;
		rd_en_1 = 1;
		wr_en_2 = 1;
		rd_en_2 = 1;
#10 ifm = 11;
		set_wgt =1;
		set_ifm = 1;
#10 ifm = 12;
		set_wgt =1;
		set_ifm = 1;
#10 ifm = 13;
		set_wgt =1;
		set_ifm = 1;
#10 ifm = 14;
		set_wgt =1;
		set_ifm = 1;
		rd_en_1 = 0;
		rd_clr = 1;
		rd_en_2 = 0;
		rd_en_0 = 0;
#10 ifm = 15;
		set_wgt =1;
		set_ifm = 1;
		rd_clr = 0;
#10 
#10		
		wr_en_0 = 0;
		rd_en_0 = 1;
		wr_en_2 = 0;
		rd_en_2 = 1;
		wr_clr =1;
#10 
		wr_clr  = 0;
#60 
		rd_en_2 = 0;
		
#300 $finish; 
		end
endmodule
