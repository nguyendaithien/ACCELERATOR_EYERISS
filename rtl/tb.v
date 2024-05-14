`timescale 1 ns/10 ps
module tb();
parameter  DATA_WIDTH = 16;
parameter  WEIGHT_WIDTH = 8;
parameter  IFM_DATA_WIDTH = 8;
parameter  IFM_HEIGHT = 64;
parameter  IFM_WIDTH  = 64;
parameter  KERNEL_SIZE = 3;
parameter  KERNEL_NUM = 8;
parameter  FIFO_SIZE_PSUM = 62*62*3;
parameter  ADD_WIDTH = 10;
parameter  ADD_WIDTH_PSUM = 16;
parameter  FIFO_SIZE = 62;
parameter  OFM_SIZE = 62;
parameter  NUM_CHANNEL = 3;
localparam IFM_LENGTH = (IFM_HEIGHT) * (IFM_WIDTH) * (NUM_CHANNEL);
localparam WGT_LENGTH = (NUM_CHANNEL*KERNEL_NUM);

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
	wire ifm_read;
	wire wgt_read;

	reg start_conv;
	reg start_again;

	reg [WEIGHT_WIDTH*KERNEL_SIZE*KERNEL_SIZE-1:0] wgt;
	reg [IFM_WIDTH-1:0] ifm;
	wire [DATA_WIDTH-1:0] data_out;
	reg [2:0] set_reg;
	reg [8:0] cnt;
  reg [7:0] ifm_in [0:IFM_LENGTH-1];
	reg [71:0] wgt_in [0:WGT_LENGTH-1];
	reg [7:0] ifm_r;
	wire [7:0] ifm_file;
	wire [71:0] wgt_file;
	reg [31:0] ifm_cnt;
	reg [31:0] wgt_cnt;
	reg [71:0] wgt_r;

	initial begin
		$dumpfile("CONV_ACC.vcd");
		$dumpvars(0,tb);
	end
	initial begin
		$readmemb("./ifm.txt", ifm_in);
	end
	initial begin
		$readmemb("./weight.txt",wgt_in);
	end
    always @(*) begin
        if (!rst_n) begin
            wgt_r = 0;
        end else if (wgt_read) begin
            wgt_r   = wgt_in[wgt_cnt];
        end else
            wgt_r = 0;
    end 
    always @(posedge clk1 or negedge rst_n) begin
        if (!rst_n)
            wgt_cnt <= 0;
        else if (wgt_cnt == WGT_LENGTH && !wgt_read)
            wgt_cnt <= 0;
        else if (wgt_read)
            wgt_cnt <= wgt_cnt + 1;
        else
            wgt_cnt <= wgt_cnt;
    end 
    assign wgt_file = wgt_r;
    always @(*) begin
        if (!rst_n) begin
            ifm_r = 0;
        end else if (ifm_read) begin
            ifm_r = ifm_in[ifm_cnt];
        end else
            ifm_r = 0;
    end 

    always @(posedge clk1 or negedge rst_n) begin
        if (!rst_n)
            ifm_cnt <= 0;
        else if (ifm_cnt == IFM_LENGTH && !ifm_read)
            ifm_cnt <= 0;
        else if (ifm_read)
            ifm_cnt <= ifm_cnt + 1;
        else
            ifm_cnt <= ifm_cnt;
    end 
    assign ifm_file = ifm_r;

  TOP #(.DATA_WIDTH(DATA_WIDTH), .WEIGHT_WIDTH(WEIGHT_WIDTH), .IFM_WIDTH(IFM_WIDTH), .IFM_HEIGHT(IFM_HEIGHT), .FIFO_SIZE(FIFO_SIZE), .INDEX_WIDTH(ADD_WIDTH), .KERNEL_SIZE(KERNEL_SIZE), .FIFO_SIZE_PSUM(FIFO_SIZE_PSUM), .INDEX_WIDTH_PSUM(ADD_WIDTH_PSUM), .IFM_DATA_WIDTH(IFM_DATA_WIDTH)) top_module(
      .clk1(clk1)
     ,.clk2(clk2)
     ,.rst_n(rst_n)                    	
     //,.set_reg(set_reg_pe)
     //,.set_wgt(set_wgt)
     //,.set_ifm(set_ifm)
     //,.wr_en_0(wr_en_0)                        		
     //,.rd_en_0(rd_en_0)
     //,.wr_en_1(wr_en_1)                        		
     //,.rd_en_1(rd_en_1)
     //,.wr_en_2(wr_en_2)                        		
     //,.rd_en_2(rd_en_2)
		 //,.rd_clr(rd_clr)
		 //,.wr_clr(wr_clr)
		 ,.ifm_read(ifm_read)
		 ,.wgt_read(wgt_read)
     ,.ifm(ifm_file)
		 ,.wgt(wgt_file)
		 ,.start_conv(start_conv)
		 //,.start_again(start_again)
     //,.data_output(data_out)
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
		set_wgt =0;
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
		set_ifm = 1;
   	wr_en_0 =0;
		rd_en_0 =0;
   	wr_en_1 =0;
		rd_en_1 =0;
		start_conv = 1;
		set_wgt = 1;
#10 ifm = 2;
		set_ifm = 1;
		start_conv = 0;
		set_wgt = 0;
#10 ifm = 3;
		set_ifm = 1;
#10 ifm = 4;
		set_ifm = 1;
		wr_en_0 = 1;
		rd_en_0 = 0;
#10 ifm = 5;
		set_ifm = 1;
#10 ifm = 6;
		set_ifm = 1;
#10 ifm = 7;
		set_ifm = 1;
#10 ifm = 8;
		set_ifm = 1;
#10 ifm = 9;
		set_ifm = 1;

		// =======LINE 2============================
#10 
		wgt = 72'h010203010203010203;
#10 ifm = 2;
		wgt = 72'h010203010203010203;
		set_ifm = 1;
		wr_en_0 = 0;
		wr_clr = 1;
		rd_en_0 = 1;
#10 ifm = 3;
		set_ifm = 1;
		wr_en_0 = 0;
		rd_en_0 = 1;
		wr_en_2 = 0;
		rd_en_2 = 0;
		wr_clr = 0;
#10 ifm = 4;
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
		
#2000000 $finish; 
		end
endmodule
