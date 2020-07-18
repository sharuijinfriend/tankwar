module vgatest(
input wire clk_50m,
input wire rst_n,
//input wire [3:0] direction,
output reg [7:0] red,
output reg [7:0] green,
output reg [7:0] blue,
output reg hsync,
output reg vsync,
output wire dac_clk,
output wire dac_sync,
output wire dac_blank
);
//-------------------------------------------------//
//          扫描参数的设定 640*480 60Hz VGA
//-------------------------------------------------//
/*
back porch  48    33
sync pulse  96     2
front porch 16    10
*/
reg [9:0] x_cnt;
reg [9:0] y_cnt;

wire [9:0] x_pos;
wire [8:0] y_pos;


wire clk_100m;

pll_clock M1(
		.refclk(clk_50m),   //  refclk.clk
		.rst(~rst_n),      //   reset.reset
		.outclk_0(clk_25m), // outclk0.clk
		.outclk_1(clk_100m)  // outclk1.clk
);

//always@(posedge clk_50m,negedge rst_n)
//begin
//	if(~rst_n) 
//		clk_25m<=0;
//	else:
//		clk_25m<= ~clk_25m;
//end
assign dac_clk=~clk_25m;
assign dac_sync=	1'b1;
assign dac_blank	= (((x_cnt>=H_SHOW_START) &&(x_cnt<=10'd784))||((y_cnt>=V_SHOW_START)&&(y_cnt<=10'd515)))?1'b1:1'b0;



	

parameter H_SYNC_END   = 96;     //行同步脉冲结束时间
parameter V_SYNC_END   = 2;      //列同步脉冲结束时间
parameter H_SYNC_TOTAL = 800;    //行扫描总像素单位
parameter V_SYNC_TOTAL = 525;    //列扫描总像素单位
parameter H_SHOW_START = 144;    //显示区行开始像素点
parameter V_SHOW_START = 35;     //显示区列开始像素点
	
//水平扫描
always@(posedge clk_25m or negedge rst_n)    
	if(~rst_n) x_cnt <= 'd0;
	else if (x_cnt == H_SYNC_TOTAL) x_cnt <= 'd0;
	else  x_cnt <= x_cnt + 1'b1;

//垂直扫描
always@(posedge clk_25m or negedge rst_n)    
	if(~rst_n) y_cnt <= 'd0;
	else if (y_cnt == V_SYNC_TOTAL) y_cnt <= 'd0;
	else if (x_cnt == H_SYNC_TOTAL) y_cnt <= y_cnt + 1'b1;
	else y_cnt <= y_cnt;

//H_SYNC信号
always@(posedge clk_25m or negedge rst_n)    
	if(~rst_n) hsync <= 'd0;
	else if (x_cnt == 'd0) hsync <= 1'b0;
	else if (x_cnt == H_SYNC_END) hsync <= 1'b1;
	else  hsync <= hsync;

//V_SYNC信号
always@(posedge clk_25m or negedge rst_n)    
	if(~rst_n) vsync <= 'd0;
	else if (y_cnt == 'd0) vsync <= 1'b0;
	else if (y_cnt == V_SYNC_END) vsync <= 1'b1;
	else  vsync <= vsync;   

assign x_pos = x_cnt - H_SHOW_START;
assign y_pos = y_cnt - V_SHOW_START;

always@(posedge clk_25m, negedge rst_n)
	begin
//		red={8{1'b1}};
		if(~rst_n)
			begin
				red=8'b0;
				green=8'b0;
				blue=8'b0;
			end
		else
			begin
				case(x_pos)
					9'd160 : begin
									red=8'b11111111;
									green=8'b0;
									blue=8'b11110000;
								end
					9'd320 : begin
									red=8'b0;
									green=8'b0;
									blue={8{1'b1}};
								end
					9'd480 : begin
									red=8'b0;
									green={8{1'b1}};
									blue=8'b0;
								end
					
				endcase
			end
	end

endmodule 
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
module vgatest(
input wire clk_50m,
input wire rst_n,
input wire [3:0] direction,
output reg [7:0] red,
output reg [7:0] green,
output reg [7:0] blue,
output reg hsync,
output reg vsync,
output wire dac_clk,
output wire dac_sync,
output wire dac_blank
);
//-------------------------------------------------//
//          扫描参数的设定 640*480 60Hz VGA
//-------------------------------------------------//
/*
back porch  48    33
sync pulse  96     2
front porch 16    10
*/
parameter H_SYNC_END   = 96;     //行同步脉冲结束时间
parameter V_SYNC_END   = 2;      //列同步脉冲结束时间
parameter H_SYNC_TOTAL = 800;    //行扫描总像素单位
parameter V_SYNC_TOTAL = 525;    //列扫描总像素单位
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

assign x_pos =(x_cnt <=10'd784 && x_cnt>H_SHOW_START)?(x_cnt - H_SHOW_START-1) :10'd0 ;//1~640 or 0 //0~639 or 0
assign y_pos =(y_cnt <=10'd515 && y_cnt>V_SHOW_START)?(y_cnt - V_SHOW_START-1):9'd0;//1~480 or 0 //0~399 or 0
assign x_mo=x_pos%10;//0~63
assign y_mo=y_pos%10;//0~39
assign x_remainder=x_pos/10;//0~9
assign y_remainder=y_pos/10;//0~9

//-----------------------tank_test-------------------------------------
reg [4:0] tank_exit; //5 tanks
reg [9:0] tank_direction;//2 bits per tank
reg [29:0] tank_x;//6 bits per tank
reg [29:0] tank_y;//6 bits per tank
reg [4:0] shoot;//
reg clk_f;


always@(posedge clk_200m,negedge rst_n)
	begin
		if(~rst_n)
			direction_reg<=0;
		else if(direction)
			direction_reg<=direction;
	end
	
always@(posedge clk_25m,negedge rst_n)
begin
	if(~rst_n)
		tank_exit<=5'b11111;
	else
		tank_exit<=5'b11111;
end

always@(posedge clk_f, negedge rst_n)
	begin
		if(~rst_n)
			tank_direction<=10'b0;
		else
			begin
				// tank_direction[7:0]<=8'b0;
				// case(direction)
				// 4'b1000: tank_direction[9:8]<=2'd0;//{2'd0,8'd0}
				// 4'b0100: tank_direction[9:8]<=2'd1;
				// 4'b0010: tank_direction[9:8]<=2'd2;
				// 4'b0001: tank_direction[9:8]<=2'd3;
				// //default
				// endcase
				
								
				case(direction)
				4'b1000: tank_direction<={2'd0,8'b11011000};//up  
				4'b0100: tank_direction<={2'd1,8'b11011000};//down
				4'b0010: tank_direction<={2'd2,8'b11011000};//left
				4'b0001: tank_direction<={2'd3,8'b11011000};//right
				//default
				endcase
			end
	end

always@(posedge clk_25m or negedge rst_n)    
	if(~rst_n) clk_f<= 0;
	else if (y_cnt == 10'd1) clk_f<=1;
	else if (y_cnt == V_SYNC_TOTAL) clk_f <= 0;  
	
always@(posedge clk_f,negedge rst_n)
	begin
		if(~rst_n)
			tank_x<= 30'b0;
		else
			begin
				case(direction_reg)
				4'b1000: tank_x<={6'b0,24'b111111101110010110101011};
				4'b0100: tank_x<={6'b0,24'b111111101110010110101011};
				4'b0010: begin
							if(tank_x[29:24]==0 || tank_x[29:24] == 6'd63)
								tank_x<=tank_x;
							else
								tank_x<={tank_x[29:24]-1,24'b111111101110010110101011};
						end
						
				4'b0001: begin
							if(tank_x[29:24]==0 || tank_x[29:24] == 6'd63)
								tank_x<=tank_x;
							else
								tank_x<={tank_x[29:24]+1,24'b111111101110010110101011};
						end
				
				endcase
			end	
	end	

always@(posedge clk_f,negedge rst_n)
	begin
		if(~rst_n)
			tank_y<= 30'b0;
		else
			begin
				case(direction_reg)
				4'b1000: begin
							if(tank_y[29:24]==0 || tank_y[29:24] == 6'd63)
								tank_y<=tank_y;
							else
								tank_y<={tank_y[29:24]+1,24'b100110000100011100101101};
						end
				4'b0100: begin
							if(tank_y[29:24]==0 || tank_y[29:24] == 6'd63)
								tank_y<=tank_y;
							else
								tank_y<={tank_y[29:24]-1,24'b100110000100011100101101};
						end
				4'b0010: tank_y<={tank_y[29:24],24'b100110000100011100101101};
						
				4'b0001: tank_y<={tank_y[29:24],24'b100110000100011100101101};
				
				endcase
			end	
	end	
	 

pll_clock M1(
		.refclk(clk_50m),   //  refclk.clk
		.rst(~rst_n),      //   reset.reset
		.outclk_0(clk_25m), // outclk0.clk
		.outclk_1(clk_100m),  // outclk1.clk
		.outclk_2(clk_200m)
);

//always@(posedge clk_50m,negedge rst_n)
//begin
//	if(~rst_n) 
//		clk_25m<=0;
//	else:
//		clk_25m<= ~clk_25m;
//end
assign dac_clk=clk_100m;
assign dac_sync=	1'b0;
//assign dac_blank	= (((x_cnt>=H_SHOW_START) &&(x_cnt<=10'd784))||((y_cnt>=V_SHOW_START)&&(y_cnt<=10'd515)))?1'b1:1'b0;
assign dac_blank	= 1'b1;



	


	
//水平扫描
always@(posedge clk_25m or negedge rst_n)    
	if(~rst_n) x_cnt <= 10'd0;
	else if (x_cnt == H_SYNC_TOTAL) x_cnt <= 10'd0;
	else  x_cnt <= x_cnt + 1'b1;

//垂直扫描
always@(posedge clk_25m or negedge rst_n)    
	if(~rst_n) y_cnt <= 10'd0;
	else if (y_cnt == V_SYNC_TOTAL) y_cnt <= 10'd0;
	else if (x_cnt == H_SYNC_TOTAL) y_cnt <= y_cnt + 1'b1;
	else y_cnt <= y_cnt;

//H_SYNC信号
always@(posedge clk_25m or negedge rst_n)    
	if(~rst_n) hsync <= 1'd0;
	else if (x_cnt == 'd0) hsync <= 1'b0;
	else if (x_cnt == H_SYNC_END) hsync <= 1'b1;
	else  hsync <= hsync;

//V_SYNC信号
always@(posedge clk_25m or negedge rst_n)    
	if(~rst_n) vsync <= 1'd0;
	else if (y_cnt == 'd0) vsync <= 1'b0;
	else if (y_cnt == V_SYNC_END) vsync <= 1'b1;
	else  vsync <= vsync;   

//输出rgb三色信号，首先要根据模确定是不是有坦克，再者根据坦克的方向，以余数描绘出坦克。


always@(posedge clk_25m, negedge rst_n)
	begin
//		red={8{1'b1}};
		if(~rst_n)
			begin
				red=8'b0;
				green=8'b0;
				blue=8'b0;
			end
		else 
			begin
//				if(x_pos==9'd160)
//				begin
//				red=8'b11111111;
//				green=8'b0;
//				blue=8'b0;
//				end
				case(x_pos)
					10'd1 : begin
									red=8'b0;
									green=8'b11111111;
									blue=8'b0;
								end
					10'd320 : begin
									red=8'b0;
									green=8'b0;
									blue={8{1'b1}};
								end
					10'd480 : begin
									red={8{1'b1}};
									green=8'b0;
									blue=8'b0;
								end
					10'd640 : begin
									red=8'b0;
									green=8'b0;
									blue=8'b0;
								end
								
					
				endcase
			end
	
				// case({x_mo,y_mo})
					// 9'd160 : begin
									// red=8'b11111111;
									// green=8'b0;
									// blue=8'b11110000;
								// end
					// 9'd320 : begin
									// red=8'b0;
									// green=8'b0;
									// blue={8{1'b1}};
								// end
					// 9'd480 : begin
									// red=8'b0;
									// //green={8{1'b1}};
									// green=8'b11111111;
									// blue=8'b0;
								// end
					
				// endcase
	end

endmodule 