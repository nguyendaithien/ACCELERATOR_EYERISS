module TOP #(parameter DATA_WIDTH = 16, WEIGHT_WIDTH = 8, IFM_DATA_WIDTH = 8, FIFO_SIZE = 7, INDEX_WIDTH = 4, KERNEL_SIZE = 3, FIFO_SIZE_PSUM = 100, INDEX_WIDTH_PSUM = 10, IFM_WIDTH = 9, IFM_HEIGHT = 9, OFM_SIZE = 7, NUM_CHANNEL = 3)(
	input clk1,
	input clk2,
	input rst_n,
	input set_reg,
	input set_wgt,
	input set_ifm,
	input wr_en_0,
	input rd_en_0,
	input wr_en_1,
	input rd_en_1,
	input wr_en_2,
	input rd_en_2,
	input rd_clr,
	input wr_clr,
	input sel_mux_0,
	input [IFM_DATA_WIDTH-1:0] ifm,
	input [KERNEL_SIZE*KERNEL_SIZE*WEIGHT_WIDTH-1:0] wgt,

	input start_conv,
	input start_again,

	output[DATA_WIDTH-1:0] data_output
	);

	wire [DATA_WIDTH-1:0] psum_00_01;
	wire [DATA_WIDTH-1:0] psum_01_02;
	wire [DATA_WIDTH-1:0] psum_10_11;
	wire [DATA_WIDTH-1:0] psum_11_12;
	wire [DATA_WIDTH-1:0] psum_20_21;
	wire [DATA_WIDTH-1:0] psum_21_22;

	wire [DATA_WIDTH-1:0] data_to_fifo_0;
	wire [DATA_WIDTH-1:0] data_to_fifo_1;
	wire [DATA_WIDTH-1:0] data_to_fifo_2;

	reg  [WEIGHT_WIDTH-1:0] weight [KERNEL_SIZE*KERNEL_SIZE-1:0];
	wire [WEIGHT_WIDTH-1:0] wgt_wire_0;
	wire [WEIGHT_WIDTH-1:0] wgt_wire_1;
	wire [WEIGHT_WIDTH-1:0] wgt_wire_2;
	wire [WEIGHT_WIDTH-1:0] wgt_wire_3;
	wire [WEIGHT_WIDTH-1:0] wgt_wire_4;
	wire [WEIGHT_WIDTH-1:0] wgt_wire_5;
	wire [WEIGHT_WIDTH-1:0] wgt_wire_6;
	wire [WEIGHT_WIDTH-1:0] wgt_wire_7;
	wire [WEIGHT_WIDTH-1:0] wgt_wire_8;

	wire [IFM_WIDTH-1:0]  ifm_wire;
	wire [DATA_WIDTH-1:0] data_fifo_wire_0;
	wire [DATA_WIDTH-1:0] data_fifo_wire_1;
	wire [DATA_WIDTH-1:0] data_to_fifo_psum;


	wire [DATA_WIDTH-1:0] mux_to_fifo_psum;
	wire [DATA_WIDTH-1:0] psum_add;

  wire ifm_read    ;
  wire wgt_read    ;
  wire p_valid_out ;
  wire last_channel;
  wire end_conv    ;
  wire wr_en_1_wire     ;
  wire wr_en_2_wire     ;
  wire wr_en_3_wire     ;
  wire wr_clr_wire      ;
  wire rd_en_1_wire     ;
  wire rd_en_2_wire     ;
  wire rd_en_3_wire     ;
  wire rd_clr_wire      ;
  wire sel_mux_0   ;

  wire [3:0] channel_num;
  wire [9:0] collum_num;
  wire [9:0] cnt_pixel;
  wire wr_en_psum;
  wire rd_en_psum;
  wire rd_clr_psum;
  wire wr_clr_psum;







	always @(*) begin
		weight[0] = wgt[71:64];
		weight[1] = wgt[63:56];
		weight[2] = wgt[55:48];
		weight[3] = wgt[47:40];
		weight[4] = wgt[39:32];
		weight[5] = wgt[31:24];
		weight[6] = wgt[23:16];
		weight[7] = wgt[15:8] ;
		weight[8] = wgt[7:0]  ;
	end
 assign test_wgt = weight[0]; 


//===================================================================================================================
//                    CONTROLLER PE
//===================================================================================================================
  CONTROLLER #(.DATA_WIDTH(DATA_WIDTH) ,.NUM_CHANNEL(NUM_CHANNEL), .IFM_WIDTH(IFM_WIDTH), .IFM_HEIGHT(IFM_HEIGHT), .OFM_SIZE(OFM_SIZE), .KERNEL_SIZE(KERNEL_SIZE)) controller (
	  .clk1(clk1)       	
   ,.clk2(clk2)
   ,.rst_n(rst_n)
   ,.start_conv(start_conv)
   ,.start_again(start_again)
   ,.channel_num(channel_num)
	 ,.collum_num(collum_num)
	 ,.cnt_pixel(cnt_pixel)
   ,.ifm_read(ifm_rd)
   ,.wgt_read(wgt_rd)
   ,.p_valid_output()
   ,.last_channel()
   ,.end_conv(end_conv)
   ,.wr_en_1(wr_en_1_wire)
   ,.wr_en_2(wr_en_2_wire)
   ,.wr_en_3(wr_en_3_wire)
   ,.wr_clr(wr_clr_wire)
   ,.rd_en_1(rd_en_1_wire)
   ,.rd_en_2(rd_en_2_wire)
   ,.rd_en_3(rd_en_3_wire)
   ,.rd_clr(rd_clr_wire)
   ,.wr_en_psum(wr_en_psum)
   ,.wr_psum_clr(wr_psum_clr)
   ,.rd_en_psum(rd_en_psum)
   ,.rd_psum_clr(rd_psum_clr)
   ,.sel_mux_0(sel_mux_0)
	);

//===================================================================================================================
//                    CONTROLLER WRITE_DATA
//===================================================================================================================
WRITE_DATA #(.DATA_WIDTH(DATA_WIDTH),.NUM_CHANNEL(NUM_CHANNEL), .IFM_WIDTH(IFM_WIDTH), .IFM_HEIGHT(IFM_HEIGHT), .OFM_SIZE(OFM_SIZE), .KERNEL_SIZE(KERNEL_SIZE))  write_data(
  .clk1(clk1)
 ,.clk2(clk2)
 ,.rst_n(rst_n)
 ,.start_conv(start_conv)
 ,.start_again()
 ,.channel_num(channel_num)
 ,.collum_num(collum_num)
 ,.last_channel(last_channel)
 ,.wr_en_psum(wr_en_psum)
 ,.rd_en_psum(rd_en_psum)
 ,.wr_clr(wr_clr_psum)
 ,.rd_clr(rd_clr_psum)
 ,.cnt_pixel(cnt_pixel)
 );
//===================================================================================================================
//                    ROW 1 OF PE ARRAY
//===================================================================================================================
	PE #(.PSUM_WIDTH(DATA_WIDTH), .WEIGHT_WIDTH(WEIGHT_WIDTH), .DATA_OUT_WIDTH(DATA_WIDTH), .IFM_WIDTH(IFM_WIDTH))  pe00 (
			.clk(clk1)
		 ,.rst_n(rst_n)
		 ,.set_reg(set_reg)
		 ,.ifm(ifm_wire)
		 ,.wgt(wgt_wire_0)
		 ,.psum_in(16'd0)
		 ,.psum_out(psum_00_01)
		 );
	PE #(.PSUM_WIDTH(DATA_WIDTH), .WEIGHT_WIDTH(WEIGHT_WIDTH), .DATA_OUT_WIDTH(DATA_WIDTH), .IFM_WIDTH(IFM_WIDTH))  pe01 (
			.clk(clk1)
		 ,.rst_n(rst_n)
		 ,.set_reg(set_reg)
		 ,.ifm(ifm_wire)
		 ,.wgt(wgt_wire_1)
		 ,.psum_in(psum_00_01)
		 ,.psum_out(psum_01_02)
		 );
	PE #(.PSUM_WIDTH(DATA_WIDTH), .WEIGHT_WIDTH(WEIGHT_WIDTH), .DATA_OUT_WIDTH(DATA_WIDTH), .IFM_WIDTH(IFM_WIDTH))  pe02 (
			.clk(clk1)
		 ,.rst_n(rst_n)
		 ,.set_reg(set_reg)
		 ,.ifm(ifm_wire)
		 ,.wgt(wgt_wire_2)
		 ,.psum_in(psum_01_02)
		 ,.psum_out(data_to_fifo_0)
		 );

  FIFO_ASYNCH #(.DATA_WIDTH(DATA_WIDTH), .FIFO_SIZE(FIFO_SIZE), .ADD_WIDTH(INDEX_WIDTH)) fifo_0(
		 .clk1  (clk1)
		,.clk2  (clk2)
		,.rd_clr(rd_clr)
		,.wr_clr(wr_clr)
		,.rd_inc(1'b1)
		,.wr_inc(1'b1)
		,.wr_en (wr_en_0)
		,.rd_en (rd_en_0)
		,.data_in_fifo (data_to_fifo_0)
		,.data_out_fifo(data_fifo_wire_0)
		);
//===================================================================================================================
//                    ROW 2 OF PE ARRAY
//===================================================================================================================
	PE #(.PSUM_WIDTH(DATA_WIDTH), .WEIGHT_WIDTH(WEIGHT_WIDTH), .DATA_OUT_WIDTH(DATA_WIDTH), .IFM_WIDTH(IFM_WIDTH))  pe10 (
			.clk(clk1)
		 ,.rst_n(rst_n)
		 ,.set_reg(set_reg)
		 ,.ifm(ifm_wire)
		 ,.wgt(wgt_wire_3)
		 ,.psum_in(data_fifo_wire_0)
		 ,.psum_out(psum_10_11)
		 );
	PE #(.PSUM_WIDTH(DATA_WIDTH), .WEIGHT_WIDTH(WEIGHT_WIDTH), .DATA_OUT_WIDTH(DATA_WIDTH), .IFM_WIDTH(IFM_WIDTH))  pe11 (
			.clk(clk1)
		 ,.rst_n(rst_n)
		 ,.set_reg(set_reg)
		 ,.ifm(ifm_wire)
		 ,.wgt(wgt_wire_4)
		 ,.psum_in(psum_10_11)
		 ,.psum_out(psum_11_12)
		 );
	PE #(.PSUM_WIDTH(DATA_WIDTH), .WEIGHT_WIDTH(WEIGHT_WIDTH), .DATA_OUT_WIDTH(DATA_WIDTH), .IFM_WIDTH(IFM_WIDTH))  pe12 (
			.clk(clk1)
		 ,.rst_n(rst_n)
		 ,.set_reg(set_reg)
		 ,.ifm(ifm_wire)
		 ,.wgt(wgt_wire_5)
		 ,.psum_in(psum_11_12)
		 ,.psum_out(data_to_fifo_1)
		 );

  FIFO_ASYNCH #(.DATA_WIDTH(DATA_WIDTH), .FIFO_SIZE(FIFO_SIZE), .ADD_WIDTH(INDEX_WIDTH)) fifo_1(
		 .clk1  (clk1)
		,.clk2  (clk2)
		,.rd_clr(rd_clr)
		,.wr_clr(wr_clr)
		,.rd_inc(1'b1)
		,.wr_inc(1'b1)
		,.wr_en (wr_en_1)
		,.rd_en (rd_en_1)
		,.data_in_fifo (data_to_fifo_1)
		,.data_out_fifo(data_fifo_wire_1)
		);
//===================================================================================================================
//                    ROW 3 OF PE ARRAY 
//===================================================================================================================
	PE #(.PSUM_WIDTH(DATA_WIDTH), .WEIGHT_WIDTH(WEIGHT_WIDTH), .DATA_OUT_WIDTH(DATA_WIDTH), .IFM_WIDTH(IFM_WIDTH))  pe20 (
			.clk(clk1)
		 ,.rst_n(rst_n)
		 ,.set_reg(set_reg)
		 ,.ifm(ifm_wire)
		 ,.wgt(wgt_wire_6)
		 ,.psum_in(data_fifo_wire_1)
		 ,.psum_out(psum_20_21)
		 );
	PE #(.PSUM_WIDTH(DATA_WIDTH), .WEIGHT_WIDTH(WEIGHT_WIDTH), .DATA_OUT_WIDTH(DATA_WIDTH), .IFM_WIDTH(IFM_WIDTH))  pe21 (
			.clk(clk1)
		 ,.rst_n(rst_n)  
		 ,.set_reg(set_reg)
		 ,.ifm(ifm_wire)
		 ,.wgt(wgt_wire_7)
		 ,.psum_in(psum_20_21)
		 ,.psum_out(psum_21_22)
		 );
	PE #(.PSUM_WIDTH(DATA_WIDTH), .WEIGHT_WIDTH(WEIGHT_WIDTH), .DATA_OUT_WIDTH(DATA_WIDTH), .IFM_WIDTH(IFM_WIDTH))  pe22 (
			.clk(clk1)
		 ,.rst_n(rst_n)
		 ,.set_reg (set_reg)
		 ,.ifm(ifm_wire)
		 ,.wgt(wgt_wire_8)
		 ,.psum_in (psum_21_22)
		 ,.psum_out(data_to_fifo_2)
		 );

  FIFO_ASYNCH #(.DATA_WIDTH(DATA_WIDTH), .FIFO_SIZE(FIFO_SIZE), .ADD_WIDTH(INDEX_WIDTH)) fifo_2(
		 .clk1(clk1)
		,.clk2(clk2)
		,.rd_clr(rd_clr)
		,.wr_clr(wr_clr)
		,.rd_inc(1'b1)
		,.wr_inc(1'b1)
		,.wr_en(wr_en_2)
		,.rd_en(rd_en_2)
		,.data_in_fifo (data_to_fifo_2)
		,.data_out_fifo(data_to_fifo_psum)
		);
//===================================================================================================================
//                    PSUM BUFFER 
//===================================================================================================================
FIFO_ASYNCH #(.DATA_WIDTH(DATA_WIDTH), .FIFO_SIZE(FIFO_SIZE_PSUM), .ADD_WIDTH(INDEX_WIDTH_PSUM)) fifo_psum(
		 .clk1(clk1)
		,.clk2(clk2)
		,.rd_clr(rd_clr_psum)
		,.wr_clr(wr_clr_psum)
		,.rd_inc(1'b1)
		,.wr_inc(1'b1)
		,.wr_en(wr_en_psum)
		,.rd_en(rd_en_psum)
		,.data_in_fifo (data_to_fifo_psum)
		,.data_out_fifo(data_output)
		);

//===================================================================================================================
//                    WEIGHT BUFFER 
//===================================================================================================================
	WEIGHT_BUFF #(.DATA_WIDTH(WEIGHT_WIDTH)) wgt_buf_0 (
      .clk(clk1)
     ,.rst_n(rst_n)
     ,.set_wgt(set_wgt)
     ,.wgt_in(weight[0])
     ,.wgt_out(wgt_wire_0)
		 );
	WEIGHT_BUFF #(.DATA_WIDTH(WEIGHT_WIDTH)) wgt_buf_1 (
      .clk(clk1)
     ,.rst_n(rst_n)
     ,.set_wgt(set_wgt)
     ,.wgt_in(weight[1])
     ,.wgt_out(wgt_wire_1)
		 );
	WEIGHT_BUFF #(.DATA_WIDTH(WEIGHT_WIDTH)) wgt_buf_2 (
      .clk(clk1)
     ,.rst_n(rst_n)
     ,.set_wgt(set_wgt)
     ,.wgt_in(weight[2])
     ,.wgt_out(wgt_wire_2)
		 );
	WEIGHT_BUFF #(.DATA_WIDTH(WEIGHT_WIDTH)) wgt_buf_3 (
      .clk(clk1)
     ,.rst_n(rst_n)
     ,.set_wgt(set_wgt)
     ,.wgt_in(weight[3])
     ,.wgt_out(wgt_wire_3)
		 );
	WEIGHT_BUFF #(.DATA_WIDTH(WEIGHT_WIDTH)) wgt_buf_4 (
      .clk(clk1)
     ,.rst_n(rst_n)
     ,.set_wgt(set_wgt)
     ,.wgt_in(weight[4])
     ,.wgt_out(wgt_wire_4)
		 );
	WEIGHT_BUFF #(.DATA_WIDTH(WEIGHT_WIDTH)) wgt_buf_5 (
      .clk(clk1)
     ,.rst_n(rst_n)
     ,.set_wgt(set_wgt)
     ,.wgt_in(weight[5])
     ,.wgt_out(wgt_wire_5)
		 );
	WEIGHT_BUFF #(.DATA_WIDTH(WEIGHT_WIDTH)) wgt_buf_6 (
      .clk(clk1)
     ,.rst_n(rst_n)
     ,.set_wgt(set_wgt)
     ,.wgt_in(weight[6])
     ,.wgt_out(wgt_wire_6)
		 );
	WEIGHT_BUFF #(.DATA_WIDTH(WEIGHT_WIDTH)) wgt_buf_7 (
      .clk(clk1)
     ,.rst_n(rst_n)
     ,.set_wgt(set_wgt)
     ,.wgt_in(weight[7])
     ,.wgt_out(wgt_wire_7)
		 );
	WEIGHT_BUFF #(.DATA_WIDTH(WEIGHT_WIDTH)) wgt_buf_8 (
      .clk(clk1)
     ,.rst_n(rst_n)
     ,.set_wgt(set_wgt)
     ,.wgt_in(weight[8])
     ,.wgt_out(wgt_wire_8)
		 );
//===================================================================================================================
//                    INPUT FEATURE MAP BUFFER 
//===================================================================================================================
  IFM_BUFF #(.DATA_WIDTH(IFM_WIDTH)) ifm_buf (
       .clk(clk1)
      ,.rst_n(rst_n)
      ,.set_ifm(set_ifm)
      ,.ifm_in(ifm)
      ,.ifm_out(ifm_wire)
			);
//===================================================================================================================
//                    ADDER MULTIL CHANNEL 
//===================================================================================================================
	ADDER #(.DATA_WIDTH(DATA_WIDTH) ) add_0(
       .a(data_output)
			,.b(data_to_fifo_psum)
			,.sum(psum_add)
      );
  MUX_2x1 #(.DATA_WIDTH(DATA_WIDTH)) mux_0 (
			.a(data_to_fifo_psum)
		 ,.b(psum_add)
		 ,.sel(sel_mux_0)
		 );






endmodule

