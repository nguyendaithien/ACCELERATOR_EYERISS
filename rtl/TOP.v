module TOP #(parameter DATA_WIDTH = 16, WEIGHT_WIDTH = 8, IFM_WIDTH = 8, FIFO_SIZE = 7, INDEX_WIDTH = 4, KERNEL_SIZE = 3)(
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
	input [IFM_WIDTH-1:0] ifm,
	input [KERNEL_SIZE*KERNEL_SIZE*WEIGHT_WIDTH-1:0] wgt,
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
endmodule

