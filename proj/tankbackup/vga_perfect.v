module vgatest(
input wire clk_50m,
input wire rst_n,

output reg [7:0] red,
output reg [7:0] green,
output reg [7:0] blue,
output wire hsync,
output wire vsync,
output wire dac_clk,
output wire dac_sync,
output wire dac_blank
);
//-------------------------------------------------//
//          640*480 60Hz VGA
//-------------------------------------------------//
/*
back porch  48    33
sync pulse  96     2
front porch 16    10
*/
parameter H_SYNC_END   = 10'd96;     //行同步脉冲结束时间
parameter V_SYNC_END   = 10'd2;      //列同步脉冲结束时间
parameter H_SYNC_TOTAL = 10'd800;    //行扫描总像素单位
parameter V_SYNC_TOTAL = 10'd525;    //列扫描总像素单位
parameter H_SHOW_START = 10'd144;    //显示区行开始像素点
parameter V_SHOW_START = 10'd35;     //显示区列开始像素点

integer i,j;

reg [9:0] x_cnt;//0~800，96+48=144~640~16
reg [9:0] y_cnt;//0~525，2+33=35~480~10

wire [9:0] x_pos;
wire [9:0] y_pos;

wire [5:0] x_mo;
wire [5:0] y_mo;
wire [3:0] x_remainder;
wire [3:0] y_remainder;
wire clk_25m;
wire clk_100m;
wire clk_200m;
reg [3:0] direction_reg;
reg [7:0] red_reg;
reg [7:0] green_reg;
reg [7:0] blue_reg;
wire valid;

assign x_pos =(x_cnt <=10'd783 && x_cnt>=H_SHOW_START)?(x_cnt - H_SHOW_START) :10'd0 ;////0~639 
assign y_pos =(y_cnt <=10'd514 && y_cnt>=V_SHOW_START)?(y_cnt - V_SHOW_START):9'd0;////0~399 
assign x_mo=x_pos%10;//0~63
assign y_mo=y_pos%10;//0~39
assign x_remainder=x_pos/10;//0~9
assign y_remainder=y_pos/10;//0~9

assign valid=(x_cnt <=10'd783 && x_cnt>=H_SHOW_START && y_cnt <=10'd514 && y_cnt>=V_SHOW_START)?1'b1:1'b0;
	

pll_clock M1(
		.refclk(clk_50m),   //  refclk.clk
		.rst(~rst_n),      //   reset.reset
		.outclk_0(clk_25m), // outclk0.clk
		.outclk_1(clk_100m),  // outclk1.clk
		.outclk_2(clk_200m)
);

assign dac_clk=clk_100m;
assign dac_sync=	1'b0;
assign dac_blank	= 1'b1;

//horizontal scan
always@(posedge clk_25m or negedge rst_n)    
	if(~rst_n) x_cnt <= 10'd0;
//	else if (x_cnt == (H_SYNC_TOTAL-1)) x_cnt <= 10'd0;
	else if (x_cnt == 10'd799) x_cnt <= 10'd0;
	else  x_cnt <= x_cnt + 1'b1;

//vertical scan
always@(posedge clk_25m or negedge rst_n)    
	if(~rst_n) y_cnt <= 10'd0;
//	else if (y_cnt == (V_SYNC_TOTAL-1)) y_cnt <= 10'd0;
//	else if (x_cnt == (H_SYNC_TOTAL-1)) y_cnt <= y_cnt + 1'b1;
	else if (y_cnt == 10'd524 && x_cnt == 10'd799 ) y_cnt <= 10'd0;
	else if (x_cnt == 10'd799) y_cnt <= y_cnt + 1'b1;
	
//H_SYNC signal
assign hsync=(x_cnt<H_SYNC_END)?1'b0:1'b1;
//V_SYNC signal
assign vsync=(y_cnt<V_SYNC_END)?1'b0:1'b1;

always@(posedge clk_25m, negedge rst_n)
	begin
//		red={8{1'b1}};
		if(~rst_n)
			begin
				red=8'b0;
				green=8'b0;
				blue=8'b0;
			end

		else if (valid && x_pos>=10'd0 && x_pos<=10'd10)
			begin
				red<= 8'b11111111;
				green<= 8'b0;
				blue<= 8'b0;
			end
		else if (valid && x_pos>10'd10 && x_pos<=10'd40)
			begin
				red<= 8'b0;
				green<= {8{1'b1}};
				blue<= 8'b0;
			end
		else if (valid && x_pos>10'd40 && x_pos<=10'd635)
			begin
				red<= 8'b0;
				green<= 8'b0;
				blue<= {8{1'b1}};
			end
		else if (valid && x_pos>10'd635 && x_pos<=10'd639)
			begin
				red<= 8'b11111111;
				green<= 8'b0;
				blue<= 8'b0;
			end

		else
			begin
				red=8'b0;
				green=8'b0;
				blue=8'b0;
			end
	end
endmodule 