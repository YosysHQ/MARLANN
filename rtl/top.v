module top (
	input  clock,

	output reg led1,
	output reg led2,
	output reg led3,
	output reg led4,
	output reg led5,

	input  ml_clk,
	input  ml_csb,
	inout  ml_io0,
	inout  ml_io1,
	inout  ml_io2,
	inout  ml_io3,
	output ml_rdy,
	output ml_err
);
	wire [3:0] ml_io_oe = 0;
	wire [3:0] ml_io_do = 0;
	wire [3:0] ml_io_di;

	SB_IO #(
		.PIN_TYPE(6'b 1010_01),
		.PULLUP(1'b 0)
	) ml_io_buf [3:0] (
		.PACKAGE_PIN({ml_io3, ml_io2, ml_io1, ml_io0}),
		.OUTPUT_ENABLE(ml_io_oe),
		.D_OUT_0(ml_io_do),
		.D_IN_0(ml_io_di)
	);

	assign ml_rdy = 0;
	assign ml_err = 0;

	reg [7:0] din_data;
	reg din_valid;

	reg ml_clk_q1, ml_clk_q2, ml_clk_q3;
	reg ml_csb_q1, ml_csb_q2, ml_csb_q3;
	reg ml_di_q1, ml_di_q2;
	reg phase;

	always @(negedge clock) begin
		ml_di_q1 <= ml_io_di;
	end

	always @(posedge clock) begin
		din_valid <= 0;

		ml_clk_q1 <= ml_clk;
		ml_clk_q2 <= ml_clk_q1;
		ml_clk_q3 <= ml_clk_q2;

		ml_csb_q1 <= ml_csb;
		ml_csb_q2 <= ml_csb_q1;
		ml_csb_q3 <= ml_csb_q2;

		ml_di_q2 <= ml_di_q1;

		if (ml_csb_q3) begin
			phase <= 0;
		end else
		if (!phase && ml_clk_q2 && !ml_clk_q3) begin
			din_data[7:4] <= ml_di_q2;
			phase <= 1;
		end else
		if (phase && !ml_clk_q2 && ml_clk_q3) begin
			din_data[3:0] <= ml_di_q2;
			din_valid <= 1;
			phase <= 0;
		end
	end

	always @(posedge clock) begin
		if (din_valid)
			{led5, led4, led3, led2, led1} <= din_data;
	end
endmodule
