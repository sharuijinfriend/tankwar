module vgatest(
input wire clk_50m,
input wire rst_n,
input wire [3:0] direction_ori,
output reg [7:0] red,
output reg [7:0] green,
output reg [7:0] blue,
output wire hsync,
output wire vsync,
output wire dac_clk,
output wire dac_sync,
output wire dac_blank,
output reg [3:0] direction_reg
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

wire [3:0] direction;
assign direction=~direction_ori;

reg [9:0] x_cnt;//0~800，96+48=144~640~16
reg [9:0] y_cnt;//0~525，2+33=35~480~10

wire [9:0] x_pos;
wire [9:0] y_pos;

// wire [5:0] x_mo;
// wire [5:0] y_mo;
// wire [3:0] x_remainder;
// wire [3:0] y_remainder;
wire clk_25m;
wire clk_100m;
wire clk_200m;
//reg [3:0] direction_reg;
reg [7:0] red_reg;
reg [7:0] green_reg;
reg [7:0] blue_reg;
wire valid;
wire valid_tank_0;
wire valid_tank_0_up;
wire valid_tank_0_down;
wire valid_tank_0_left;
wire valid_tank_0_right;

//-----------------------tank_test-------------------------------------
reg [4:0] tank_exit; //5 tanks
reg [9:0] tank_direction;//2 bits per tank
reg [49:0] tank_x;//10 bits per tank 1~639
reg [49:0] tank_y;//10 bits per tank 0~479
reg [4:0] shoot;//
reg clk_f;

assign x_pos =(x_cnt <=10'd783 && x_cnt>=H_SHOW_START)?(x_cnt - H_SHOW_START) :10'd0 ;////0~639 
assign y_pos =(y_cnt <=10'd514 && y_cnt>=V_SHOW_START)?(y_cnt - V_SHOW_START):9'd0;////0~479
// assign x_mo=x_pos/10;//0~63
// assign y_mo=y_pos/10;//0~47
// assign x_remainder=x_pos%10;//0~9
// assign y_remainder=y_pos%10;//0~9

assign valid=(x_cnt <=10'd783 && x_cnt>=H_SHOW_START && y_cnt <=10'd514 && y_cnt>=V_SHOW_START)?1'b1:1'b0;
assign valid_tank_0=((x_pos-tank_x[49:40])<=10'd29 && (x_pos-tank_x[49:40])>=10'd0 && (y_pos-tank_y[49:40])<=10'd29 && (y_pos-tank_y[49:40])>=10'd0)?1'b1:1'b0;
assign valid_tank_0_up=(((x_pos-tank_x[49:40])>=10'd12 && (x_pos-tank_x[49:40])<=10'd17 && (y_pos-tank_y[49:40])>=10'd0 &&(y_pos-tank_y[49:40])<=10'd11) || 
						((x_pos-tank_x[49:40])>=10'd5 && (x_pos-tank_x[49:40])<=10'd24 && (y_pos-tank_y[49:40])>=10'd12 &&(y_pos-tank_y[49:40])<=10'd29) )?1'b1:1'b0;
assign valid_tank_0_down=(((x_pos-tank_x[49:40])>=10'd12 && (x_pos-tank_x[49:40])<=10'd17 && (y_pos-tank_y[49:40])>=10'd18 &&(y_pos-tank_y[49:40])<=10'd29) || 
						((x_pos-tank_x[49:40])>=10'd5 && (x_pos-tank_x[49:40])<=10'd24 && (y_pos-tank_y[49:40])>=10'd0 &&(y_pos-tank_y[49:40])<=10'd17) )?1'b1:1'b0;
assign valid_tank_0_left=(((x_pos-tank_x[49:40])>=10'd0 && (x_pos-tank_x[49:40])<=10'd11 && (y_pos-tank_y[49:40])>=10'd12 &&(y_pos-tank_y[49:40])<=10'd17) || 
						((x_pos-tank_x[49:40])>=10'd12 && (x_pos-tank_x[49:40])<=10'd29 && (y_pos-tank_y[49:40])>=10'd5 &&(y_pos-tank_y[49:40])<=10'd24) )?1'b1:1'b0;
assign valid_tank_0_right=(((x_pos-tank_x[49:40])>=10'd18 && (x_pos-tank_x[49:40])<=10'd29 && (y_pos-tank_y[49:40])>=10'd12 &&(y_pos-tank_y[49:40])<=10'd17) || 
						((x_pos-tank_x[49:40])>=10'd0 && (x_pos-tank_x[49:40])<=10'd17 && (y_pos-tank_y[49:40])>=10'd5 &&(y_pos-tank_y[49:40])<=10'd24) )?1'b1:1'b0;					




always@(posedge clk_25m,negedge rst_n)
	begin
		if(~rst_n)
			direction_reg<=0;
		else if(y_cnt<10'd34 && direction !=4'b0000)
			direction_reg<= direction;
		else if(y_cnt ==10'd515)
			direction_reg<=10'd0;
	end
	
	
	
	
always@(posedge clk_25m,negedge rst_n)//暂时是5辆坦克
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
				
								
				case(direction_reg)
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
	else if (y_cnt == 10'd5) clk_f<=1;
	else if (y_cnt == 10'd524) clk_f <= 0;  //V_SYNC_TOTAL-1
	
always@(posedge clk_f,negedge rst_n)
	begin
		if(~rst_n)
			tank_x<= {5{10'd3}};
		else
			begin
				case(direction_reg)
				4'b1000: tank_x<={tank_x[49:40],40'b111111101110010110101011};
				4'b0100: tank_x<={tank_x[49:40],40'b111111101110010110101011};
				4'b0010: begin
							if(tank_x[49:40]==10'd3)
								tank_x<=tank_x;
							else
								tank_x<={tank_x[49:40]-10'd1,40'b111111101110010110101011};
						end
						
				4'b0001: begin
							if(tank_x[49:40] == 10'd609)//10'd639-10'd29-1
								tank_x<=tank_x;
							else
								tank_x<={tank_x[49:40]+10'd1,40'b111111101110010110101011};
						end
				
				endcase
			end	
	end	

always@(posedge clk_f,negedge rst_n)
	begin
		if(~rst_n)
			tank_y<= {8{10'd1}};
		else
			begin
				case(direction_reg)
				4'b1000: begin
							if(tank_y[49:40] == 10'd1)
								tank_y<=tank_y;
							else
								tank_y<={tank_y[49:40]-10'd1,40'b100110000100011100101101};
						end
				4'b0100: begin
							if(tank_y[49:40]==10'd449)//10'd479-10'd29-1
								tank_y<=tank_y;
							else
								tank_y<={tank_y[49:40]+10'd1,40'b100110000100011100101101};
						end
				4'b0010: tank_y<={tank_y[49:40],40'b100110000100011100101101};
						
				4'b0001: tank_y<={tank_y[49:40],40'b100110000100011100101101};
				
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
				red<=8'b0;
				green<=8'b0;
				blue<=8'b0;
			end

		else if(x_pos==10'd1 || x_pos==10'd639 || y_pos==10'd0 || y_pos==10'd479)//边框
			begin
				red<={8{1'b1}};
				green<=8'b0;
				blue<=8'b0;
			end
		else if(valid_tank_0)
				begin
					case(tank_direction[8+:2])
						2'b00:	begin //up
									if(valid_tank_0_up)
										begin
											red=8'b0;
											green={8{1'b1}};
											blue={8{1'b1}};
										end
								end
								
						2'b01:	begin //down
									if(valid_tank_0_down)
										begin
											red=8'b0;
											green=8'b0;
											blue={8{1'b1}};
										end
								end
						2'b10:	begin //left
									if(valid_tank_0_left)
										begin
											red={8{1'b1}};
											green=8'b0;
											blue={8{1'b1}};
										end
								end
						2'b11:	begin //right
									if(valid_tank_0_right)
										begin
											red=8'b0;
											green={8{1'b1}};
											blue=8'b0;
										end
								end
						default: begin
										// red={8{1'b1}};
										red=8'b0;
										green=8'b0;
										blue=8'b0;
									end			
					endcase
					
				end
		else
			begin
				red<=8'b0;
				green<=8'b0;
				blue<=8'b0;
			end
	end


endmodule 