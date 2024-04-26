module TOP #(parameter DATA_WIDTH = 16, WEIGHT_WIDTH = 8, IFM_WIDTH = 8, FIFO_SIZE = 10, INDEX_WIDTH = 4, KERNEL_SIZE = 3)(
	input clk1,
	input clk2,
	input rst_n,
	input set_reg,
	input set_wgt,
	input set_ifm,
	input wr_en,
	input rd_en,
	input [IFM_WIDTH-1:0] ifm,
	input [KERNEL_SIZE*WEIGHT_WIDTH-1:0] wgt,
	output[DATA_WIDTH-1:0] data_output
	);

	wire [DATA_WIDTH-1:0] psum_0_1;
	wire [DATA_WIDTH-1:0] psum_1_2;
	wire [DATA_WIDTH-1:0] data_to_fifo;
	reg  [WEIGHT_WIDTH-1:0] weight [KERNEL_SIZE-1:0];
	wire [KERNEL_SIZE*WEIGHT_WIDTH-1:0] wgt_wire;
	wire [IFM_WIDTH-1:0] ifm_wire;
	wire [7:0] test_wgt;

	always @(*) begin
		weight[0] = wgt_wire[23:16];
		weight[1] = wgt_wire[15:8];
		weight[2] = wgt_wire[7:0];
	end
 assign test_wgt = weight[0]; 

	PE #(.PSUM_WIDTH(DATA_WIDTH), .WEIGHT_WIDTH(WEIGHT_WIDTH), .DATA_OUT_WIDTH(DATA_WIDTH), .IFM_WIDTH(IFM_WIDTH))  pe0 (
			.clk(clk1)
		 ,.rst_n(rst_n)
		 ,.set_reg(set_reg)
		 ,.ifm(ifm_wire)
		 ,.wgt(weight[0])
		 ,.psum_in(16'd5)
		 ,.psum_out(psum_0_1)
		 );
	PE #(.PSUM_WIDTH(DATA_WIDTH), .WEIGHT_WIDTH(WEIGHT_WIDTH), .DATA_OUT_WIDTH(DATA_WIDTH), .IFM_WIDTH(IFM_WIDTH))  pe1 (
			.clk(clk1)
		 ,.rst_n(rst_n)
		 ,.set_reg(set_reg)
		 ,.ifm(ifm_wire)
		 ,.wgt(weight[1])
		 ,.psum_in(psum_0_1)
		 ,.psum_out(psum_1_2)
		 );
	PE #(.PSUM_WIDTH(DATA_WIDTH), .WEIGHT_WIDTH(WEIGHT_WIDTH), .DATA_OUT_WIDTH(DATA_WIDTH), .IFM_WIDTH(IFM_WIDTH))  pe2 (
			.clk(clk1)
		 ,.rst_n(rst_n)
		 ,.set_reg(set_reg)
		 ,.ifm(ifm_wire)
		 ,.wgt(weight[2])
		 ,.psum_in(psum_1_2)
		 ,.psum_out(data_to_fifo)
		 );

  FIFO_ASYNCH #(.DATA_WIDTH(DATA_WIDTH), .FIFO_SIZE(FIFO_SIZE), .ADD_WIDTH(INDEX_WIDTH)) fifo_0(
		 .clk1  (clk1)
		,.clk2  (clk2)
		,.rd_clr(1'b0)
		,.wr_clr(1'b0)
		,.rd_inc(1'b1)
		,.wr_inc(1'b1)
		,.wr_en (wr_en)
		,.rd_en (rd_en)
		,.data_in_fifo (data_to_fifo)
		,.data_out_fifo(data_output)
		);
	WEIGHT_BUFF #(.DATA_WIDTH(KERNEL_SIZE*WEIGHT_WIDTH)) wgt_buf (
      .clk(clk1)
     ,.rst_n(rst_n)
     ,.set_wgt(set_wgt)
     ,.wgt_in(wgt)
     ,.wgt_out(wgt_wire)
		 );
  IFM_BUFF #(.DATA_WIDTH(IFM_WIDTH)) ifm_buf (
       .clk(clk1)
      ,.rst_n(rst_n)
      ,.set_ifm(set_ifm)
      ,.ifm_in(ifm)
      ,.ifm_out(ifm_wire)
			);
endmodule

