module vgatest(
input wire clk_50m,
input wire rst_n,
input wire [3:0] direction_ori,
input wire shoot,
output reg [7:0] red,
output reg [7:0] green,
output reg [7:0] blue,
output wire hsync,
output wire vsync,
output wire dac_clk,
output wire dac_sync,
output wire dac_blank,
output reg [3:0] direction_reg,//debug
output wire bullet_exit24,//debug
output wire bullet_exit24_reg,
output wire [5:0] random//debug
);
//-------------------------------------------------//
//          640*480 60Hz VGA
//-------------------------------------------------//
/*
back porch  48    33
sync pulse  96     2 
front porch 16    10
*/ 
assign random=rand_num[7:2];
assign bullet_exit24=bullet_exit[24];
assign bullet_exit24_reg=bullet_exit_reg[24];
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


wire clk_25m;
wire clk_100m;
wire clk_200m;
//reg [3:0] direction_reg;

 
//-----------------------tank_test-------------------------------------
reg [4:0] tank_exit; //5 tanks
reg [9:0] tank_direction;//2 bits per tank
reg [49:0] tank_x;//10 bits per tank 1~639
reg [49:0] tank_y;//10 bits per tank 0~479

//-----------------------bullet test-----------------------------------
reg [24:0] bullet_exit;
reg [24:0] bullet_exit_reg;
reg [49:0] bullet_direction;
reg [249:0] bullet_x;
reg [249:0] bullet_y;
reg [5:0] bullet_counter;//0~60


reg clk_f;
reg clk_slow;
reg [24:0] clk_slow_counter;//1 second one period
wire [7:0] rand_num;
 

assign x_pos =(x_cnt <=10'd783 && x_cnt>=H_SHOW_START)?(x_cnt - H_SHOW_START) :10'd0 ;////0~639 
assign y_pos =(y_cnt <=10'd514 && y_cnt>=V_SHOW_START)?(y_cnt - V_SHOW_START):9'd0;////0~479
			


RanGen rangen0(
.clk(clk_slow),
.rst_n(rst_n),
.rand_num(rand_num)
);

always@(posedge clk_25m,negedge rst_n)
	begin
		if(~rst_n)
			direction_reg<=4'd0;
		else if(y_cnt<10'd34 && direction !=4'b0000)
			direction_reg<= direction;
		else if(y_cnt ==10'd515)
			direction_reg<=4'd0;
	end
	
	
	
	
always@(posedge clk_25m,negedge rst_n)//暂时是5辆坦克
begin
	if(~rst_n)
		tank_exit<=5'b11111;
	else
		tank_exit<=5'b11111;
end

//-------------------------------------------------------------BULLET_0~4 EXIT

/* always@(posedge clk_slow,negedge rst_n)//每秒采样一次，检测是不是可以产生新的子弹
//还需要做碰撞后消失
	begin
		if(~rst_n)
			bullet_exit[20+:5]<=5'b0;
		else if(shoot)
			begin
				if(~bullet_exit[24])
					bullet_exit[24]<=1'b1;
				else if(~bullet_exit[23])
					bullet_exit[23]<=1'b1;
				else if(~bullet_exit[22])
					bullet_exit[22]<=1'b1;
				else if(~bullet_exit[21])
					bullet_exit[21]<=1'b1;
				else if(~bullet_exit[20])
					bullet_exit[20]<=1'b1;
			end
		if(bullet_x[240+:10]==10'd3 || bullet_x[240+:10]==10'd636 || bullet_y[240+:10] == 10'd1 || bullet_y[240+:10] == 10'd476 || 
		(bullet_x[240+:10]== tank_x[39:30] && bullet_y[240+:10]== tank_y[39:30])||
		(bullet_x[240+:10]== tank_x[29:20] && bullet_y[240+:10]== tank_y[29:20]))
			bullet_exit[24]<=1'b0;
	end */

always @(posedge clk_f,negedge rst_n)
	begin
		if(~rst_n)
			bullet_counter<=6'b0;
		else if(bullet_counter==6'd60)
			bullet_counter<=6'd0;
		else
			bullet_counter<=bullet_counter+1;
	end
	
always@(posedge clk_f,negedge rst_n)//每秒采样一次，检测是不是可以产生新的子弹
//还需要做碰撞后消失
	begin
		if(~rst_n)
			bullet_exit[24]<=1'b0;
		else if(bullet_exit_reg[24] && (bullet_x[240+:10]==10'd3 || bullet_x[240+:10]==10'd636 || bullet_y[240+:10] == 10'd1 || bullet_y[240+:10] == 10'd476 || 
		(((bullet_x[240+:10]-tank_x[39:30])<=10'd30 )&& ((bullet_y[240+:10]-tank_y[39:30])<=10'd30 ))||
		(((bullet_x[240+:10]-tank_x[29:20])<=10'd30 )&& ((bullet_y[240+:10]-tank_y[29:20])<=10'd30 ))))
			bullet_exit[24]<=1'b0;
		else if(shoot && ~bullet_exit[24] &&bullet_counter==6'd60)
			bullet_exit[24]<=1'b1;
		//else if(shoot && bullet_exit[24] && ~bullet_exit[23])
		//	bullet_exit[23]<=1'b1;
	end
	

always@(posedge clk_f,negedge rst_n)//用来判断是不是有新子弹的产生
begin
	if(~rst_n)
		bullet_exit_reg<=25'b0;
	else
		bullet_exit_reg<= bullet_exit;			
end
//----------------------------------------------------------------------BULLET_0~4 direction------------------
always@(posedge clk_f, negedge rst_n)
	if(~rst_n)
		bullet_direction[20+:5]<=5'b0;
	else if(bullet_exit[24] && !bullet_exit_reg[24])
		bullet_direction[48+:2]<= tank_direction[8+:2];
	else if(bullet_exit[23] && !bullet_exit_reg[23])
		bullet_direction[46+:2]<= tank_direction[8+:2];
	else if(bullet_exit[22] && !bullet_exit_reg[22])
		bullet_direction[44+:2]<= tank_direction[8+:2];
	else if(bullet_exit[21] && !bullet_exit_reg[21])
		bullet_direction[42+:2]<= tank_direction[8+:2];
	else if(bullet_exit[20] && !bullet_exit_reg[20])
		bullet_direction[40+:2]<= tank_direction[8+:2];

//----------------------------------------------------------------------BULLET_0 X
always@(posedge clk_f,negedge rst_n)
	if(~rst_n)
		bullet_x[240+:10]<=10'd30;
	else if(bullet_exit[24] && !bullet_exit_reg[24])
		begin
			case(tank_direction[9:8])
				2'b00:	bullet_x[240+:10]<=tank_x[49:40]+10'd14;
				2'b01:	bullet_x[240+:10]<=tank_x[49:40]+10'd14;
				2'b10:	bullet_x[240+:10]<=tank_x[49:40]-10'd3;
				2'b11:	bullet_x[240+:10]<=tank_x[49:40]+10'd30;
			endcase
		end	
	else if(bullet_exit[24] && bullet_exit_reg[24])
		begin
			case(bullet_direction[48+:2])
				2'b00: bullet_x[240+:10]<=bullet_x[240+:10];
				2'b01: bullet_x[240+:10]<=bullet_x[240+:10];
				2'b10: begin
					if(bullet_x[240+:10]>10'd6)
						bullet_x[240+:10]<=bullet_x[240+:10]-10'd3;
					else
						bullet_x[240+:10]<=10'd3;
					end
				
				2'b11: begin
							if(bullet_x[240+:10] < 10'd633)//10'd639-10'd2-1
								bullet_x[240+:10]<=bullet_x[240+:10]+10'd3;
							else
								bullet_x[240+:10]<=10'd636;
						end
				
				endcase
		end
//----------------------------------------------------------------------BULLET_0 Y
always@(posedge clk_f,negedge rst_n)
	if(~rst_n)
		bullet_y[240+:10]<=10'd30;
	else if(bullet_exit[24] && !bullet_exit_reg[24])
			case(tank_direction[9:8])
				2'b00:	bullet_y[240+:10]<=tank_y[49:40]-10'd3;
				2'b01:	bullet_y[240+:10]<=tank_y[49:40]+10'd30;
				2'b10:	bullet_y[240+:10]<=tank_y[49:40]+10'd14;
				2'b11:	bullet_y[240+:10]<=tank_y[49:40]+10'd14;
			endcase
		
	else if(bullet_exit[24] && bullet_exit_reg[24])
		begin
			case(bullet_direction[48+:2])
				2'b00: begin
							if(bullet_y[240+:10] >10'd4)//10'd479-10'd2-1
								bullet_y[240+:10]<=bullet_y[240+:10]-10'd3;
							else
								bullet_y[240+:10]<=10'd1;
						end
				2'b01: begin
							if(bullet_y[240+:10]<10'd473)
								bullet_y[240+:10]<=bullet_y[240+:10]+10'd3;
							else
								bullet_y[240+:10]<=10'd476;
						end
				2'b10: bullet_y[240+:10]<=bullet_y[240+:10];
				2'b11: bullet_y[240+:10]<=bullet_y[240+:10];
				endcase
		end
	


always@(posedge clk_f, negedge rst_n)//一帧采集一次，能保证一帧中的坦克的方向不会发生变化，其实也没用，因为XY坐标的采样一帧只进行一次，所以一帧中其余时刻坦克方向的改变对XY事没有影响的
	begin
		if(~rst_n)
		begin
			tank_direction[9:8]<=2'b0;
		end
			
		else
			begin							
				case(direction_reg)
				4'b1000: tank_direction[9:8]<=2'd0;//up  
				4'b0100: tank_direction[9:8]<=2'd1;//down
				4'b0010: tank_direction[9:8]<=2'd2;//left
				4'b0001: tank_direction[9:8]<=2'd3;//right
				//default
				endcase
			end
	end

always@(posedge clk_slow, negedge rst_n)
	begin
		if(~rst_n)
		begin
			tank_direction[7:0]<=8'd200;
		end
			
		else
			begin
				tank_direction[7:0]<=rand_num;
				//tank_direction[7:0]<=8'd200;
			end
	end

always@(posedge clk_25m or negedge rst_n)    
	if(~rst_n) clk_f<= 0;
	else if (y_cnt == 10'd5) clk_f<=1;
	else if (y_cnt == 10'd524) clk_f <= 0;  //V_SYNC_TOTAL-1
	
always@(posedge clk_25m or negedge rst_n)    
	if(~rst_n) clk_slow_counter<=25'b1;
	else if (clk_slow_counter == 25'd25000000) clk_slow_counter<=25'd1;
	else clk_slow_counter<=clk_slow_counter+1;

always@(posedge clk_25m or negedge rst_n)    
	if(~rst_n) clk_slow<= 0;
	else if (clk_slow_counter == 25'd12500000) clk_slow<=25'd1;
	else if (clk_slow_counter == 25'd25000000) clk_slow<=25'd0;	
	
//----------------------------------------------------------------------TANK_0 X
always@(posedge clk_f,negedge rst_n)
	begin
		if(~rst_n)
			tank_x[49:40]<= 10'd6;
		else
			begin
				case(direction_reg)
				4'b1000: tank_x[49:40]<=tank_x[49:40];
				4'b0100: tank_x[49:40]<=tank_x[49:40];
				4'b0010: begin
							if(tank_x[49:40]==10'd6)
								tank_x[49:40]<=tank_x[49:40];
							else
								tank_x[49:40]<=tank_x[49:40]-10'd1;
						end
						
				4'b0001: begin
							if(tank_x[49:40] == 10'd606)//10'd639-10'd29-1-3
								tank_x[49:40]<=tank_x[49:40];
							else
								tank_x[49:40]<=tank_x[49:40]+10'd1;
						end
				
				endcase
			end	
	end	
//----------------------------------------------------------------------TANK_0 Y
always@(posedge clk_f,negedge rst_n)
	begin
		if(~rst_n)
			tank_y[49:40]<= 10'd446;
		else
			begin
				case(direction_reg)
				4'b1000: begin
							if(tank_y[49:40] == 10'd4)
								tank_y[49:40]<=tank_y[49:40];
							else
								tank_y[49:40]<=tank_y[49:40]-10'd1;
						end
				4'b0100: begin
							if(tank_y[49:40]==10'd446)//10'd479-10'd29-1-3
								tank_y[49:40]<=tank_y[49:40];
							else
								tank_y[49:40]<=tank_y[49:40]+10'd1;
						end
				4'b0010: tank_y[49:40]<=tank_y[49:40];
						
				4'b0001: tank_y[49:40]<=tank_y[49:40];
				
				endcase
			end	
	end	

	
//----------------------------------------------------------------------TANK_1 X
always@(posedge clk_f,negedge rst_n)
	begin
		if(~rst_n)
			tank_x[39:30]<= 10'd23;
		else
			begin
				case(tank_direction[7:6])
				2'b00: tank_x[39:30]<=tank_x[39:30];
				2'b01: tank_x[39:30]<=tank_x[39:30];
				2'b10: begin
							if(tank_x[39:30]==10'd6)
								tank_x[39:30]<=tank_x[39:30];
							else
								tank_x[39:30]<=tank_x[39:30]-10'd1;
						end
						
				2'b11: begin
							if(tank_x[39:30] == 10'd606)//10'd639-10'd29-1-3
								tank_x[39:30]<=tank_x[39:30];
							else
								tank_x[39:30]<=tank_x[39:30]+10'd1;
						end
				
				endcase
			end	
	end	
//----------------------------------------------------------------------TANK_1 Y
always@(posedge clk_f,negedge rst_n)
	begin
		if(~rst_n)
			tank_y[39:30]<= 10'd4;
		else
			begin
				case(tank_direction[7:6])
				2'b00: begin
							if(tank_y[39:30] == 10'd4)
								tank_y[39:30]<=tank_y[39:30];
							else
								tank_y[39:30]<=tank_y[39:30]-10'd1;
						end
				2'b01: begin
							if(tank_y[39:30]==10'd446)//10'd479-10'd29-1-3
								tank_y[39:30]<=tank_y[39:30];
							else
								tank_y[39:30]<=tank_y[39:30]+10'd1;
						end
				2'b10: tank_y[39:30]<=tank_y[39:30];
						
				2'b11: tank_y[39:30]<=tank_y[39:30];
				
				endcase
			end	
	end	 

//----------------------------------------------------------------------TANK_2 X
always@(posedge clk_f,negedge rst_n)
	begin
		if(~rst_n)
			tank_x[29:20]<= 10'd400;
		else
			begin
				case(tank_direction[5:4])
				2'b00: tank_x[29:20]<=tank_x[29:20];
				2'b01: tank_x[29:20]<=tank_x[29:20];
				2'b10: begin
							if(tank_x[29:20]==10'd6)
								tank_x[29:20]<=tank_x[29:20];
							else
								tank_x[29:20]<=tank_x[29:20]-10'd1;
						end
						
				2'b11: begin
							if(tank_x[29:20] == 10'd606)//10'd639-10'd29-1-3
								tank_x[29:20]<=tank_x[29:20];
							else
								tank_x[29:20]<=tank_x[29:20]+10'd1;
						end
				
				endcase
			end	
	end	
//----------------------------------------------------------------------TANK_2 Y
always@(posedge clk_f,negedge rst_n)
	begin
		if(~rst_n)
			tank_y[29:20]<= 10'd4;
		else
			begin
				case(tank_direction[5:4])
				2'b00: begin
							if(tank_y[29:20] == 10'd4)
								tank_y[29:20]<=tank_y[29:20];
							else
								tank_y[29:20]<=tank_y[29:20]-10'd1;
						end
				2'b01: begin
							if(tank_y[29:20]==10'd446)//10'd479-10'd29-1-3
								tank_y[29:20]<=tank_y[29:20];
							else
								tank_y[29:20]<=tank_y[29:20]+10'd1;
						end
				2'b10: tank_y[29:20]<=tank_y[29:20];
						
				2'b11: tank_y[29:20]<=tank_y[29:20];
				
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
assign dac_sync=1'b0;
assign dac_blank= 1'b1;

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
		else if(tank_exit[4] && tank_direction[8+:2]==2'b00 &&(((x_pos-tank_x[49:40])>=10'd12 && (x_pos-tank_x[49:40])<=10'd17 && (y_pos-tank_y[49:40])>=10'd0 &&(y_pos-tank_y[49:40])<=10'd11) || 
						((x_pos-tank_x[49:40])>=10'd5 && (x_pos-tank_x[49:40])<=10'd24 && (y_pos-tank_y[49:40])>=10'd12 &&(y_pos-tank_y[49:40])<=10'd29) ))//up0
			begin
				red=8'b0;
				green={8{1'b1}};
				blue={8{1'b1}};
			end
		else if(tank_exit[4] && tank_direction[8+:2]==2'b01 && (((x_pos-tank_x[49:40])>=10'd12 && (x_pos-tank_x[49:40])<=10'd17 && (y_pos-tank_y[49:40])>=10'd18 &&(y_pos-tank_y[49:40])<=10'd29) || 
						((x_pos-tank_x[49:40])>=10'd5 && (x_pos-tank_x[49:40])<=10'd24 && (y_pos-tank_y[49:40])>=10'd0 &&(y_pos-tank_y[49:40])<=10'd17) ))//down0
			begin
				red=8'b0;
				green=8'b0;
				blue={8{1'b1}};
			end
		else if(tank_exit[4] && tank_direction[8+:2]==2'b10 && (((x_pos-tank_x[49:40])>=10'd0 && (x_pos-tank_x[49:40])<=10'd11 && (y_pos-tank_y[49:40])>=10'd12 &&(y_pos-tank_y[49:40])<=10'd17) || 
						((x_pos-tank_x[49:40])>=10'd12 && (x_pos-tank_x[49:40])<=10'd29 && (y_pos-tank_y[49:40])>=10'd5 &&(y_pos-tank_y[49:40])<=10'd24) ))//left0
			begin
				red={8{1'b1}};
				green=8'b0;
				blue={8{1'b1}};
			end
		else if(tank_exit[4] && tank_direction[8+:2]==2'b11 &&(((x_pos-tank_x[49:40])>=10'd18 && (x_pos-tank_x[49:40])<=10'd29 && (y_pos-tank_y[49:40])>=10'd12 &&(y_pos-tank_y[49:40])<=10'd17) || 
						((x_pos-tank_x[49:40])>=10'd0 && (x_pos-tank_x[49:40])<=10'd17 && (y_pos-tank_y[49:40])>=10'd5 &&(y_pos-tank_y[49:40])<=10'd24) ) )//right0
			begin
				red=8'b0;
				green={8{1'b1}};
				blue=8'b0;
			end
		//else if(tank_direction[8+:2]==2'b01 && )
		//tank_1
		else if(tank_exit[3] && tank_direction[6+:2]==2'b00 &&(((x_pos-tank_x[39:30])>=10'd12 && (x_pos-tank_x[39:30])<=10'd17 && (y_pos-tank_y[39:30])>=10'd0 &&(y_pos-tank_y[39:30])<=10'd11) || 
						((x_pos-tank_x[39:30])>=10'd5 && (x_pos-tank_x[39:30])<=10'd24 && (y_pos-tank_y[39:30])>=10'd12 &&(y_pos-tank_y[39:30])<=10'd29) ))//up1
			begin
				red=8'b0;
				green={8{1'b1}};
				blue={8{1'b1}};
			end
		else if(tank_exit[3] && tank_direction[6+:2]==2'b01 && (((x_pos-tank_x[39:30])>=10'd12 && (x_pos-tank_x[39:30])<=10'd17 && (y_pos-tank_y[39:30])>=10'd18 &&(y_pos-tank_y[39:30])<=10'd29) || 
						((x_pos-tank_x[39:30])>=10'd5 && (x_pos-tank_x[39:30])<=10'd24 && (y_pos-tank_y[39:30])>=10'd0 &&(y_pos-tank_y[39:30])<=10'd17) ))//down1
			begin
				red=8'b0;
				green={8{1'b1}};
				blue={8{1'b1}};
			end
		else if(tank_exit[3] && tank_direction[6+:2]==2'b10 && (((x_pos-tank_x[39:30])>=10'd0 && (x_pos-tank_x[39:30])<=10'd11 && (y_pos-tank_y[39:30])>=10'd12 &&(y_pos-tank_y[39:30])<=10'd17) || 
						((x_pos-tank_x[39:30])>=10'd12 && (x_pos-tank_x[39:30])<=10'd29 && (y_pos-tank_y[39:30])>=10'd5 &&(y_pos-tank_y[39:30])<=10'd24) ))//left1
			begin
				red=8'b0;
				green={8{1'b1}};
				blue={8{1'b1}};
			end
		else if(tank_exit[3] && tank_direction[6+:2]==2'b11 &&(((x_pos-tank_x[39:30])>=10'd18 && (x_pos-tank_x[39:30])<=10'd29 && (y_pos-tank_y[39:30])>=10'd12 &&(y_pos-tank_y[39:30])<=10'd17) || 
						((x_pos-tank_x[39:30])>=10'd0 && (x_pos-tank_x[39:30])<=10'd17 && (y_pos-tank_y[39:30])>=10'd5 &&(y_pos-tank_y[39:30])<=10'd24) ) )//right1
			begin
				red=8'b0;
				green={8{1'b1}};
				blue={8{1'b1}};
			end
		//tank2
		else if(tank_exit[2] && tank_direction[4+:2]==2'b00 &&(((x_pos-tank_x[29:20])>=10'd12 && (x_pos-tank_x[29:20])<=10'd17 && (y_pos-tank_y[29:20])>=10'd0 &&(y_pos-tank_y[29:20])<=10'd11) || 
						((x_pos-tank_x[29:20])>=10'd5 && (x_pos-tank_x[29:20])<=10'd24 && (y_pos-tank_y[29:20])>=10'd12 &&(y_pos-tank_y[29:20])<=10'd29) ))//up1
			begin
				red={8{1'b1}};
				green=8'b0;
				blue={8{1'b1}};
			end
		else if(tank_exit[2] && tank_direction[4+:2]==2'b01 && (((x_pos-tank_x[29:20])>=10'd12 && (x_pos-tank_x[29:20])<=10'd17 && (y_pos-tank_y[29:20])>=10'd18 &&(y_pos-tank_y[29:20])<=10'd29) || 
						((x_pos-tank_x[29:20])>=10'd5 && (x_pos-tank_x[29:20])<=10'd24 && (y_pos-tank_y[29:20])>=10'd0 &&(y_pos-tank_y[29:20])<=10'd17) ))//down1
			begin
				red={8{1'b1}};
				green=8'b0;
				blue={8{1'b1}};
			end
		else if(tank_exit[2] && tank_direction[4+:2]==2'b10 && (((x_pos-tank_x[29:20])>=10'd0 && (x_pos-tank_x[29:20])<=10'd11 && (y_pos-tank_y[29:20])>=10'd12 &&(y_pos-tank_y[29:20])<=10'd17) || 
						((x_pos-tank_x[29:20])>=10'd12 && (x_pos-tank_x[29:20])<=10'd29 && (y_pos-tank_y[29:20])>=10'd5 &&(y_pos-tank_y[29:20])<=10'd24) ))//left1
			begin
				red={8{1'b1}};
				green=8'b0;
				blue={8{1'b1}};
			end
		else if(tank_exit[2] && tank_direction[4+:2]==2'b11 &&(((x_pos-tank_x[29:20])>=10'd18 && (x_pos-tank_x[29:20])<=10'd29 && (y_pos-tank_y[29:20])>=10'd12 &&(y_pos-tank_y[29:20])<=10'd17) || 
						((x_pos-tank_x[29:20])>=10'd0 && (x_pos-tank_x[29:20])<=10'd17 && (y_pos-tank_y[29:20])>=10'd5 &&(y_pos-tank_y[29:20])<=10'd24) ) )//right1
			begin
				red={8{1'b1}};
				green=8'b0;
				blue={8{1'b1}};
			end
		//bullet0
		else if(bullet_exit[24] && (x_pos-bullet_x[240+:10])>=10'd0 && (x_pos-bullet_x[240+:10])<=10'd2 && (y_pos-bullet_y[240+:10])>=10'd0 && (y_pos-bullet_y[240+:10])<=10'd2)//right1
			begin
				red={8{1'b1}};
				green=8'd0;
				blue=8'd0;
			end
		else
			begin
				red<=8'b0;
				green<=8'b0;
				blue<=8'b0;
			end
	end


endmodule 