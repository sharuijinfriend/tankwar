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
output wire [6:0] seg0,
output wire [6:0] seg1,
output wire [6:0] seg2,
output wire [6:0] seg3,
output wire [6:0] seg4,
output wire [6:0] seg5,
output reg [3:0] direction_reg,//debug
output wire[3:0] bullet_exit24,//debug

output wire [5:0] random,//debug
output wire [9:0] live_debug,
output wire [7:0] bullet_exit_debug
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


reg [9:0] x_cnt;//0~800，96+48=144~640~16
reg [9:0] y_cnt;//0~525，2+33=35~480~10

wire [9:0] x_pos;
wire [9:0] y_pos;

wire [9:0] absx43;
wire [9:0] absx42;
wire [9:0] absx32;
wire [9:0] absy43;
wire [9:0] absy42;
wire [9:0] absy32;


wire clk_25m;
wire clk_100m;
wire clk_200m;
//reg [3:0] direction_reg;

 
//-----------------------tank_test-------------------------------------
reg [4:0] tank_exit; //5 tanks
reg [9:0] tank_direction;//2 bits per tank
reg [49:0] tank_x;//10 bits per tank 1~639
reg [49:0] tank_y;//10 bits per tank 0~479
reg [9:0] live;//my tank live =10
reg damage;
reg [19:0] score;
reg [3:0] seg0_ori;
reg [3:0] seg1_ori;
reg [3:0] seg2_ori;
reg [3:0] seg3_ori;
reg [3:0] seg4_ori;
reg [3:0] seg5_ori;


wire [0:6] seg0_tem;
wire [0:6] seg1_tem;
wire [0:6] seg2_tem;
wire [0:6] seg3_tem;
wire [0:6] seg4_tem;
wire [0:6] seg5_tem;

wire [23:0] rgb;
wire [14:0] addr;
assign addr=x_pos-10'd200+(y_pos-10'd200)*10'd200;
romtest rgbgenerate(
	.address(addr),
	.clock(clk_25m),
	.q(rgb));
 
//-----------------------bullet test-----------------------------------
wire [24:0] bullet_exit;
wire [24:0] bullet_exit_reg;
wire [49:0] bullet_direction;
wire [249:0] bullet_x;
wire [249:0] bullet_y;
reg [5:0] bullet_counter;//0~60
reg [7:0] enemy1_rebirth;
reg [7:0] enemy2_rebirth;

reg clk_f;
reg clk_slow;
reg [24:0] clk_slow_counter;//1 second one period
wire [7:0] rand_num;
 

assign x_pos =(x_cnt <=10'd783 && x_cnt>=H_SHOW_START)?(x_cnt - H_SHOW_START) :10'd0 ;////0~639 
assign y_pos =(y_cnt <=10'd514 && y_cnt>=V_SHOW_START)?(y_cnt - V_SHOW_START):9'd0;////0~479

assign random=rand_num[7:2];
assign bullet_exit24=bullet_exit[24:21];
assign live_debug=live;
assign bullet_exit_debug={bullet_exit[19:16],bullet_exit[14:11]};
			
assign direction=~direction_ori;

//-------------------------------------产生伪随机数----------------------------
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
	
	
	
	
//always@(posedge clk_25m,negedge rst_n)//暂时是5辆坦克
//begin
//	if(~rst_n)
//		tank_exit<=5'b11111;
//	else
//		tank_exit<=5'b11111;
//end
always@(posedge clk_25m,negedge rst_n)//暂时是3辆坦克
begin
	if(~rst_n)
		tank_exit[1:0]<=2'b0;
	else
		tank_exit[1:0]<=2'b0;
end

always@(posedge clk_f,negedge rst_n)//暂时是3辆坦克
begin
	if(~rst_n)
		live<={10{1'b1}};
	else if(live &&( 
( (bullet_x[190+:10]>=tank_x[40+:10])&&((bullet_x[190+:10])<tank_x[40+:10]+10'd30 )&& (bullet_y[190+:10]>=tank_y[40+:10])&&((bullet_y[190+:10])<tank_y[40+:10]+10'd30 ) && bullet_exit[19]) ||
( (bullet_x[180+:10]>=tank_x[40+:10])&&((bullet_x[180+:10])<tank_x[40+:10]+10'd30 )&& (bullet_y[180+:10]>=tank_y[40+:10])&&((bullet_y[180+:10])<tank_y[40+:10]+10'd30 ) && bullet_exit[18]) ||
( (bullet_x[170+:10]>=tank_x[40+:10])&&((bullet_x[170+:10])<tank_x[40+:10]+10'd30 )&& (bullet_y[170+:10]>=tank_y[40+:10])&&((bullet_y[170+:10])<tank_y[40+:10]+10'd30 ) && bullet_exit[17]) ||
( (bullet_x[160+:10]>=tank_x[40+:10])&&((bullet_x[160+:10])<tank_x[40+:10]+10'd30 )&& (bullet_y[160+:10]>=tank_y[40+:10])&&((bullet_y[160+:10])<tank_y[40+:10]+10'd30 ) && bullet_exit[16]) ||
( (bullet_x[140+:10]>=tank_x[40+:10])&&((bullet_x[140+:10])<tank_x[40+:10]+10'd30 )&& (bullet_y[140+:10]>=tank_y[40+:10])&&((bullet_y[140+:10])<tank_y[40+:10]+10'd30 ) && bullet_exit[14]) ||
( (bullet_x[130+:10]>=tank_x[40+:10])&&((bullet_x[130+:10])<tank_x[40+:10]+10'd30 )&& (bullet_y[130+:10]>=tank_y[40+:10])&&((bullet_y[130+:10])<tank_y[40+:10]+10'd30 ) && bullet_exit[13]) ||
( (bullet_x[120+:10]>=tank_x[40+:10])&&((bullet_x[120+:10])<tank_x[40+:10]+10'd30 )&& (bullet_y[120+:10]>=tank_y[40+:10])&&((bullet_y[120+:10])<tank_y[40+:10]+10'd30 ) && bullet_exit[12]) ||
( (bullet_x[110+:10]>=tank_x[40+:10])&&((bullet_x[110+:10])<tank_x[40+:10]+10'd30 )&& (bullet_y[110+:10]>=tank_y[40+:10])&&((bullet_y[110+:10])<tank_y[40+:10]+10'd30 ) && bullet_exit[11]) 

	))
		live<=live<<1;
	
end

always@(posedge clk_f,negedge rst_n)//暂时是3辆坦克
begin
	if(~rst_n)
		damage=1'b0;
	else if(live &&( 
( (bullet_x[190+:10]>=tank_x[40+:10])&&((bullet_x[190+:10])<tank_x[40+:10]+10'd30 )&& (bullet_y[190+:10]>=tank_y[40+:10])&&((bullet_y[190+:10])<tank_y[40+:10]+10'd30 ) && bullet_exit[19]) ||
( (bullet_x[180+:10]>=tank_x[40+:10])&&((bullet_x[180+:10])<tank_x[40+:10]+10'd30 )&& (bullet_y[180+:10]>=tank_y[40+:10])&&((bullet_y[180+:10])<tank_y[40+:10]+10'd30 ) && bullet_exit[18]) ||
( (bullet_x[170+:10]>=tank_x[40+:10])&&((bullet_x[170+:10])<tank_x[40+:10]+10'd30 )&& (bullet_y[170+:10]>=tank_y[40+:10])&&((bullet_y[170+:10])<tank_y[40+:10]+10'd30 ) && bullet_exit[17]) ||
( (bullet_x[160+:10]>=tank_x[40+:10])&&((bullet_x[160+:10])<tank_x[40+:10]+10'd30 )&& (bullet_y[160+:10]>=tank_y[40+:10])&&((bullet_y[160+:10])<tank_y[40+:10]+10'd30 ) && bullet_exit[16]) ||
( (bullet_x[140+:10]>=tank_x[40+:10])&&((bullet_x[140+:10])<tank_x[40+:10]+10'd30 )&& (bullet_y[140+:10]>=tank_y[40+:10])&&((bullet_y[140+:10])<tank_y[40+:10]+10'd30 ) && bullet_exit[14]) ||
( (bullet_x[130+:10]>=tank_x[40+:10])&&((bullet_x[130+:10])<tank_x[40+:10]+10'd30 )&& (bullet_y[130+:10]>=tank_y[40+:10])&&((bullet_y[130+:10])<tank_y[40+:10]+10'd30 ) && bullet_exit[13]) ||
( (bullet_x[120+:10]>=tank_x[40+:10])&&((bullet_x[120+:10])<tank_x[40+:10]+10'd30 )&& (bullet_y[120+:10]>=tank_y[40+:10])&&((bullet_y[120+:10])<tank_y[40+:10]+10'd30 ) && bullet_exit[12]) ||
( (bullet_x[110+:10]>=tank_x[40+:10])&&((bullet_x[110+:10])<tank_x[40+:10]+10'd30 )&& (bullet_y[110+:10]>=tank_y[40+:10])&&((bullet_y[110+:10])<tank_y[40+:10]+10'd30 ) && bullet_exit[11]) 

	))
		damage=1'b1;
	else
		damage=1'b0;
	
end

always@(posedge clk_25m,negedge rst_n)//暂时是3辆坦克
begin
	if(~rst_n)
		tank_exit[4]<=1'b1;
	else if(!live)
		tank_exit[4]<=1'b0;
end



//-------------------------------------------------------------enermy1 tank exist
always@(posedge clk_f,negedge rst_n)//暂时是3辆坦克
begin
	if(~rst_n)
		tank_exit[3]<=1'b1;
	else if(enemy1_rebirth==8'd255)
		tank_exit[3]<=1'b1;
	else if(( 
( (bullet_x[240+:10]>=tank_x[30+:10])&&((bullet_x[240+:10])<tank_x[30+:10]+10'd30 )&& (bullet_y[240+:10]>=tank_y[30+:10])&&((bullet_y[240+:10])<tank_y[30+:10]+10'd30 ) && bullet_exit[24]) ||
( (bullet_x[230+:10]>=tank_x[30+:10])&&((bullet_x[230+:10])<tank_x[30+:10]+10'd30 )&& (bullet_y[230+:10]>=tank_y[30+:10])&&((bullet_y[230+:10])<tank_y[30+:10]+10'd30 ) && bullet_exit[23]) ||
( (bullet_x[220+:10]>=tank_x[30+:10])&&((bullet_x[220+:10])<tank_x[30+:10]+10'd30 )&& (bullet_y[220+:10]>=tank_y[30+:10])&&((bullet_y[220+:10])<tank_y[30+:10]+10'd30 ) && bullet_exit[22]) ||
( (bullet_x[210+:10]>=tank_x[30+:10])&&((bullet_x[210+:10])<tank_x[30+:10]+10'd30 )&& (bullet_y[210+:10]>=tank_y[30+:10])&&((bullet_y[210+:10])<tank_y[30+:10]+10'd30 ) && bullet_exit[21]) 

	))
		tank_exit[3]<=1'b0;
end


//enemy1_rebirth counter
always@(posedge clk_f,negedge rst_n)
begin
	if(~rst_n)
		enemy1_rebirth<=8'b0;
	else if(enemy1_rebirth==8'd255)
		enemy1_rebirth<= 8'd0;
	else if(!tank_exit[3])
		enemy1_rebirth<= enemy1_rebirth+8'b1;
end


//-------------------------------------------------------------enermy2 tank exist
always@(posedge clk_f,negedge rst_n)//暂时是3辆坦克
begin
	if(~rst_n)
		tank_exit[2]<=1'b1;
	else if(enemy2_rebirth==8'd255)
		tank_exit[2]<=1'b1;
	else if(( 
( (bullet_x[240+:10]>=tank_x[20+:10])&&((bullet_x[240+:10])<tank_x[20+:10]+10'd30 )&& (bullet_y[240+:10]>=tank_y[20+:10])&&((bullet_y[240+:10])<tank_y[20+:10]+10'd30 ) && bullet_exit[24]) ||
( (bullet_x[230+:10]>=tank_x[20+:10])&&((bullet_x[230+:10])<tank_x[20+:10]+10'd30 )&& (bullet_y[230+:10]>=tank_y[20+:10])&&((bullet_y[230+:10])<tank_y[20+:10]+10'd30 ) && bullet_exit[23]) ||
( (bullet_x[220+:10]>=tank_x[20+:10])&&((bullet_x[220+:10])<tank_x[20+:10]+10'd30 )&& (bullet_y[220+:10]>=tank_y[20+:10])&&((bullet_y[220+:10])<tank_y[20+:10]+10'd30 ) && bullet_exit[22]) ||
( (bullet_x[210+:10]>=tank_x[20+:10])&&((bullet_x[210+:10])<tank_x[20+:10]+10'd30 )&& (bullet_y[210+:10]>=tank_y[20+:10])&&((bullet_y[210+:10])<tank_y[20+:10]+10'd30 ) && bullet_exit[21]) 
	))
		tank_exit[2]<=1'b0;
end

//enemy2_rebirth counter
always@(posedge clk_f,negedge rst_n)
begin
	if(~rst_n)
		enemy2_rebirth<=8'b0;
	else if(enemy2_rebirth==8'd255)
		enemy2_rebirth<= 8'd0;
	else if(!tank_exit[2])
		enemy2_rebirth<= enemy2_rebirth+8'b1;
end


always @(posedge clk_f,negedge rst_n)
	begin
		if(~rst_n)
			bullet_counter<=6'b0;
		else if(bullet_counter==6'd60)
			bullet_counter<=6'd0;
		else
			bullet_counter<=bullet_counter+6'd1;
	end

	
//----------------------------------------------------------score--------------------------------------

always@(posedge clk_f,negedge rst_n)//暂时是3辆坦克
begin
	if(~rst_n)
		score<= 20'b0;
	else if(score==20'd999999)
		score<=20'b0;
	else if(
	(tank_exit[3]&& (bullet_x[240+:10]>=tank_x[30+:10])&&((bullet_x[240+:10])<tank_x[30+:10]+10'd30 )&& (bullet_y[240+:10]>=tank_y[30+:10])&&((bullet_y[240+:10])<tank_y[30+:10]+10'd30 ) && bullet_exit[24]) ||
(tank_exit[3]&& (bullet_x[230+:10]>=tank_x[30+:10])&&((bullet_x[230+:10])<tank_x[30+:10]+10'd30 )&& (bullet_y[230+:10]>=tank_y[30+:10])&&((bullet_y[230+:10])<tank_y[30+:10]+10'd30 ) && bullet_exit[23]) ||
(tank_exit[3]&& (bullet_x[220+:10]>=tank_x[30+:10])&&((bullet_x[220+:10])<tank_x[30+:10]+10'd30 )&& (bullet_y[220+:10]>=tank_y[30+:10])&&((bullet_y[220+:10])<tank_y[30+:10]+10'd30 ) && bullet_exit[22]) ||
(tank_exit[3]&& (bullet_x[210+:10]>=tank_x[30+:10])&&((bullet_x[210+:10])<tank_x[30+:10]+10'd30 )&& (bullet_y[210+:10]>=tank_y[30+:10])&&((bullet_y[210+:10])<tank_y[30+:10]+10'd30 ) && bullet_exit[21]) ||
(tank_exit[2]&& (bullet_x[240+:10]>=tank_x[20+:10])&&((bullet_x[240+:10])<tank_x[20+:10]+10'd30 )&& (bullet_y[240+:10]>=tank_y[20+:10])&&((bullet_y[240+:10])<tank_y[20+:10]+10'd30 ) && bullet_exit[24]) ||
(tank_exit[2]&& (bullet_x[230+:10]>=tank_x[20+:10])&&((bullet_x[230+:10])<tank_x[20+:10]+10'd30 )&& (bullet_y[230+:10]>=tank_y[20+:10])&&((bullet_y[230+:10])<tank_y[20+:10]+10'd30 ) && bullet_exit[23]) ||
(tank_exit[2]&& (bullet_x[220+:10]>=tank_x[20+:10])&&((bullet_x[220+:10])<tank_x[20+:10]+10'd30 )&& (bullet_y[220+:10]>=tank_y[20+:10])&&((bullet_y[220+:10])<tank_y[20+:10]+10'd30 ) && bullet_exit[22]) ||
(tank_exit[2]&& (bullet_x[210+:10]>=tank_x[20+:10])&&((bullet_x[210+:10])<tank_x[20+:10]+10'd30 )&& (bullet_y[210+:10]>=tank_y[20+:10])&&((bullet_y[210+:10])<tank_y[20+:10]+10'd30 ) && bullet_exit[21]) 
	)
	score<= score+20'd1;
end

always @(*)
	begin
		seg5_ori=score/100000;
		seg4_ori=score/10000-seg5_ori*10;
		seg3_ori=score/1000-seg5_ori*100-seg4_ori*10;
		seg2_ori=score/100-seg5_ori*1000-seg4_ori*100-seg3_ori*10;
		seg1_ori=score/10-seg5_ori*10000-seg4_ori*1000-seg3_ori*100-seg2_ori*10;
		seg0_ori=score-seg5_ori*100000-seg4_ori*10000-seg3_ori*1000-seg2_ori*100-seg1_ori*10;
	end

segment i5(
.seg_ori(seg5_ori),
.seg(seg5_tem)
);
assign seg5=seg5_tem;
assign seg4=seg4_tem;
assign seg3=seg3_tem;
assign seg2=seg2_tem;
assign seg1=seg1_tem;
assign seg0=seg0_tem;
//genvar k;
//generate for (k=0;k<7;k=k+1)
//	begin :seg
//		assign seg5[k]=~seg5_tem[6-k];
//		assign seg4[k]=~seg4_tem[6-k];
//		assign seg3[k]=~seg3_tem[6-k];
//		assign seg2[k]=~seg2_tem[6-k];
//		assign seg1[k]=~seg1_tem[6-k];
////		assign seg0[k]=~seg0_tem[6-k];
//		
//	end
//endgenerate	
//
////assign seg0=~(7'b1011011);
//assign seg0=~seg0_tem;
segment i4(
.seg_ori(seg4_ori),
.seg(seg4_tem)
);


segment i3(
.seg_ori(seg3_ori),
.seg(seg3_tem)
);


segment i2(
.seg_ori(seg2_ori),
.seg(seg2_tem)
);


segment i1(
.seg_ori(seg1_ori),
.seg(seg1_tem)
);


segment i0(
.seg_ori(seg0_ori),
.seg(seg0_tem)
);

		



//-----------------------------tank0--------------bullet0---------------------------------------
mybullet t0b0(
.clk_f(clk_f),
.rst_n(rst_n),
.shoot(shoot),
.tank_exit(tank_exit),
.tank_direction(tank_direction[9:8]),
.tank_x(tank_x[49:0]),
.tank_y(tank_y[49:0]),
.bullet_counter(bullet_counter),
.other_bullet_x({bullet_x[199:160],bullet_x[149:110]}),
.other_bullet_y({bullet_y[199:160],bullet_y[149:110]}),
.otherbullet_exit({bullet_exit[16+:4],bullet_exit[11+:4]}),
.bullet_exit_front(1'b1),
.bullet_exit(bullet_exit[24]),
.bullet_exit_reg(bullet_exit_reg[24]),
.bullet_direction(bullet_direction[49:48]),
.bullet_x(bullet_x[249:240]),
.bullet_y(bullet_y[249:240])
);

//-----------------------------------------------------------------------------------------------

//-----------------------------tank0--------------bullet1---------------------------------------
mybullet t0b1(
.clk_f(clk_f),
.rst_n(rst_n),
.shoot(shoot),
.tank_exit(tank_exit),
.tank_direction(tank_direction[9:8]),
.tank_x(tank_x[49:0]),
.tank_y(tank_y[49:0]),
.bullet_counter(bullet_counter),
.other_bullet_x({bullet_x[199:160],bullet_x[149:110]}),
.other_bullet_y({bullet_y[199:160],bullet_y[149:110]}),
.otherbullet_exit({bullet_exit[16+:4],bullet_exit[11+:4]}),
.bullet_exit_front(bullet_exit[24]),
.bullet_exit(bullet_exit[23]),
.bullet_exit_reg(bullet_exit_reg[23]),
.bullet_direction(bullet_direction[47:46]),
.bullet_x(bullet_x[239:230]),
.bullet_y(bullet_y[239:230])
);

//-----------------------------------------------------------------------------------------------

//-----------------------------tank0--------------bullet2---------------------------------------
mybullet t0b2(
.clk_f(clk_f),
.rst_n(rst_n),
.shoot(shoot),
.tank_exit(tank_exit),
.tank_direction(tank_direction[9:8]),
.tank_x(tank_x[49:0]),
.tank_y(tank_y[49:0]),
.bullet_counter(bullet_counter),
.other_bullet_x({bullet_x[199:160],bullet_x[149:110]}),
.other_bullet_y({bullet_y[199:160],bullet_y[149:110]}),
.otherbullet_exit({bullet_exit[16+:4],bullet_exit[11+:4]}),
.bullet_exit_front(bullet_exit[23]),
.bullet_exit(bullet_exit[22]),
.bullet_exit_reg(bullet_exit_reg[22]),
.bullet_direction(bullet_direction[45:44]),
.bullet_x(bullet_x[229:220]),
.bullet_y(bullet_y[229:220])
);

//-----------------------------------------------------------------------------------------------

//-----------------------------tank0--------------bullet3---------------------------------------
mybullet t0b3(
.clk_f(clk_f),
.rst_n(rst_n),
.shoot(shoot),
.tank_exit(tank_exit),
.tank_direction(tank_direction[9:8]),
.tank_x(tank_x[49:0]),
.tank_y(tank_y[49:0]),
.bullet_counter(bullet_counter),
.other_bullet_x({bullet_x[199:160],bullet_x[149:110]}),
.other_bullet_y({bullet_y[199:160],bullet_y[149:110]}),
.otherbullet_exit({bullet_exit[16+:4],bullet_exit[11+:4]}),
.bullet_exit_front(bullet_exit[22]),
.bullet_exit(bullet_exit[21]),
.bullet_exit_reg(bullet_exit_reg[21]),
.bullet_direction(bullet_direction[43:42]),
.bullet_x(bullet_x[210+:10]),
.bullet_y(bullet_y[210+:10])
);

//-----------------------------------------------------------------------------------------------

//-----------------------------tank1 enermy1--------------bullet0---------------------------------------
enermy1bullet t1b0(
.clk_f(clk_f),
.rst_n(rst_n),
.shoot(1'b1),
.tank_exit(tank_exit),
.tank_direction(tank_direction[7:6]),
.tank_x(tank_x[49:0]),
.tank_y(tank_y[49:0]),
.bullet_counter(bullet_counter),
.other_bullet_x({bullet_x[249:210],bullet_x[149:110]}),
.other_bullet_y({bullet_y[249:210],bullet_y[149:110]}),
.otherbullet_exit({bullet_exit[21+:4],bullet_exit[11+:4]}),
.bullet_exit_front(1'b1),
.bullet_exit(bullet_exit[19]),
.bullet_exit_reg(bullet_exit_reg[19]),
.bullet_direction(bullet_direction[38+:2]),
.bullet_x(bullet_x[190+:10]),
.bullet_y(bullet_y[190+:10])
);

//-----------------------------------------------------------------------------------------------

//-----------------------------tank1 enermy1--------------bullet1---------------------------------------
enermy1bullet t1b1(
.clk_f(clk_f),
.rst_n(rst_n),
.shoot(1'b1),
.tank_exit(tank_exit),
.tank_direction(tank_direction[7:6]),
.tank_x(tank_x[49:0]),
.tank_y(tank_y[49:0]),
.bullet_counter(bullet_counter),
.other_bullet_x({bullet_x[249:210],bullet_x[149:110]}),
.other_bullet_y({bullet_y[249:210],bullet_y[149:110]}),
.otherbullet_exit({bullet_exit[21+:4],bullet_exit[11+:4]}),
.bullet_exit_front(bullet_exit[19]),
.bullet_exit(bullet_exit[18]),
.bullet_exit_reg(bullet_exit_reg[18]),
.bullet_direction(bullet_direction[36+:2]),
.bullet_x(bullet_x[180+:10]),
.bullet_y(bullet_y[180+:10])
);

//-----------------------------------------------------------------------------------------------

//-----------------------------tank1 enermy1--------------bullet2---------------------------------------
enermy1bullet t1b2(
.clk_f(clk_f),
.rst_n(rst_n),
.shoot(1'b1),
.tank_exit(tank_exit),
.tank_direction(tank_direction[7:6]),
.tank_x(tank_x[49:0]),
.tank_y(tank_y[49:0]),
.bullet_counter(bullet_counter),
.other_bullet_x({bullet_x[249:210],bullet_x[149:110]}),
.other_bullet_y({bullet_y[249:210],bullet_y[149:110]}),
.otherbullet_exit({bullet_exit[21+:4],bullet_exit[11+:4]}),
.bullet_exit_front(bullet_exit[18]),
.bullet_exit(bullet_exit[17]),
.bullet_exit_reg(bullet_exit_reg[17]),
.bullet_direction(bullet_direction[34+:2]),
.bullet_x(bullet_x[170+:10]),
.bullet_y(bullet_y[170+:10])
);

//-----------------------------------------------------------------------------------------------

//-----------------------------tank1 enermy1--------------bullet3---------------------------------------
enermy1bullet t1b3(
.clk_f(clk_f),
.rst_n(rst_n),
.shoot(1'b1),
.tank_exit(tank_exit),
.tank_direction(tank_direction[7:6]),
.tank_x(tank_x[49:0]),
.tank_y(tank_y[49:0]),
.bullet_counter(bullet_counter),
.other_bullet_x({bullet_x[249:210],bullet_x[149:110]}),
.other_bullet_y({bullet_y[249:210],bullet_y[149:110]}),
.otherbullet_exit({bullet_exit[21+:4],bullet_exit[11+:4]}),
.bullet_exit_front(bullet_exit[17]),
.bullet_exit(bullet_exit[16]),
.bullet_exit_reg(bullet_exit_reg[16]),
.bullet_direction(bullet_direction[32+:2]),
.bullet_x(bullet_x[160+:10]),
.bullet_y(bullet_y[160+:10])
);

//-----------------------------------------------------------------------------------------------

//-----------------------------tank2 enermy2--------------bullet0---------------------------------------
enermy2bullet t2b0(
.clk_f(clk_f),
.rst_n(rst_n),
//.shoot(rand_num[7]),
.shoot(1'b1),
.tank_exit(tank_exit),
.tank_direction(tank_direction[4+:2]),
.tank_x(tank_x[49:0]),
.tank_y(tank_y[49:0]),
.bullet_counter(bullet_counter),
.other_bullet_x({bullet_x[249:210],bullet_x[199:160]}),
.other_bullet_y({bullet_y[249:210],bullet_y[199:160]}),
.otherbullet_exit({bullet_exit[21+:4],bullet_exit[16+:4]}),
.bullet_exit_front(1'b1),
.bullet_exit(bullet_exit[14]),
.bullet_exit_reg(bullet_exit_reg[14]),
.bullet_direction(bullet_direction[28+:2]),
.bullet_x(bullet_x[140+:10]),
.bullet_y(bullet_y[140+:10])
);

//-----------------------------------------------------------------------------------------------

//-----------------------------tank2 enermy2--------------bullet1---------------------------------------
enermy2bullet t2b1(
.clk_f(clk_f),
.rst_n(rst_n),
.shoot(1'b1),
.tank_exit(tank_exit),
.tank_direction(tank_direction[4+:2]),
.tank_x(tank_x[49:0]),
.tank_y(tank_y[49:0]),
.bullet_counter(bullet_counter),
.other_bullet_x({bullet_x[249:210],bullet_x[199:160]}),
.other_bullet_y({bullet_y[249:210],bullet_y[199:160]}),
.otherbullet_exit({bullet_exit[21+:4],bullet_exit[16+:4]}),
.bullet_exit_front(bullet_exit[14]),
.bullet_exit(bullet_exit[13]),
.bullet_exit_reg(bullet_exit_reg[13]),
.bullet_direction(bullet_direction[26+:2]),
.bullet_x(bullet_x[130+:10]),
.bullet_y(bullet_y[130+:10])
);

//-----------------------------------------------------------------------------------------------

//-----------------------------tank2 enermy2--------------bullet2---------------------------------------
enermy2bullet t2b2(
.clk_f(clk_f),
.rst_n(rst_n),
.shoot(1'b1),
.tank_exit(tank_exit),
.tank_direction(tank_direction[4+:2]),
.tank_x(tank_x[49:0]),
.tank_y(tank_y[49:0]),
.bullet_counter(bullet_counter),
.other_bullet_x({bullet_x[249:210],bullet_x[199:160]}),
.other_bullet_y({bullet_y[249:210],bullet_y[199:160]}),
.otherbullet_exit({bullet_exit[21+:4],bullet_exit[16+:4]}),
.bullet_exit_front(bullet_exit[13]),
.bullet_exit(bullet_exit[12]),
.bullet_exit_reg(bullet_exit_reg[12]),
.bullet_direction(bullet_direction[24+:2]),
.bullet_x(bullet_x[120+:10]),
.bullet_y(bullet_y[120+:10])
);

//-----------------------------------------------------------------------------------------------

//-----------------------------tank2 enermy2--------------bullet3---------------------------------------
enermy2bullet t2b3(
.clk_f(clk_f),
.rst_n(rst_n),
.shoot(1'b1),
.tank_exit(tank_exit),
.tank_direction(tank_direction[4+:2]),
.tank_x(tank_x[49:0]),
.tank_y(tank_y[49:0]),
.bullet_counter(bullet_counter),
.other_bullet_x({bullet_x[249:210],bullet_x[199:160]}),
.other_bullet_y({bullet_y[249:210],bullet_y[199:160]}),
.otherbullet_exit({bullet_exit[21+:4],bullet_exit[16+:4]}),
.bullet_exit_front(bullet_exit[12]),
.bullet_exit(bullet_exit[11]),
.bullet_exit_reg(bullet_exit_reg[11]),
.bullet_direction(bullet_direction[22+:2]),
.bullet_x(bullet_x[110+:10]),
.bullet_y(bullet_y[110+:10])
);

//-----------------------------------------------------------------------------------------------

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

//always@(posedge clk_slow, negedge rst_n)
//	begin
//		if(~rst_n)
//		begin
//			tank_direction[7:0]<=8'd200;
//			//tank_direction[7:0]<=8'b01010000;
//		end
//			
//		else
//			begin
//				tank_direction[7:0]<=rand_num;
//				//tank_direction[7:0]<=8'b01010000;
//			end
//	end

always@(posedge clk_slow, negedge rst_n)
	begin
		if(~rst_n)
		begin
			tank_direction[7:6]<=2'b01;
			//tank_direction[7:0]<=8'b01010000;
		end
		else if(~tank_exit[3])
			tank_direction[7:6]<=2'b01;
		else
			begin
				tank_direction[7:6]<=rand_num[7:6];
				//tank_direction[7:0]<=8'b01010000;
			end
	end

always@(posedge clk_slow, negedge rst_n)
	begin
		if(~rst_n)
		begin
			tank_direction[5:4]<=2'b01;
			//tank_direction[7:0]<=8'b01010000;
		end
		else if(~tank_exit[2])
			tank_direction[5:4]<=2'b01;
		else
			begin
				tank_direction[5:4]<=rand_num[5:4];
				//tank_direction[7:0]<=8'b01010000;
			end
	end

always@(posedge clk_25m or negedge rst_n)    
	if(~rst_n) clk_f<= 0;
	else if (y_cnt == 10'd5) clk_f<=1;
	else if (y_cnt == 10'd524) clk_f <= 0;  //V_SYNC_TOTAL-1
	
always@(posedge clk_25m or negedge rst_n)    
	if(~rst_n) clk_slow_counter<=25'b1;
	else if (clk_slow_counter == 25'd25000000) clk_slow_counter<=25'd1;
	else clk_slow_counter<=clk_slow_counter+25'd1;

always@(posedge clk_25m or negedge rst_n)    
	if(~rst_n) clk_slow<= 0;
	else if (clk_slow_counter == 25'd12500000) clk_slow<=25'd1;
	else if (clk_slow_counter == 25'd25000000) clk_slow<=25'd0;	
	
	
assign absx43=(tank_x[40+:10]>tank_x[30+:10])?(tank_x[40+:10]-tank_x[30+:10]):(tank_x[30+:10]-tank_x[40+:10]);
assign absx42=(tank_x[40+:10]>tank_x[20+:10])?(tank_x[40+:10]-tank_x[20+:10]):(tank_x[20+:10]-tank_x[40+:10]);
assign absx32=(tank_x[30+:10]>tank_x[20+:10])?(tank_x[30+:10]-tank_x[20+:10]):(tank_x[20+:10]-tank_x[30+:10]);

assign absy43=(tank_y[40+:10]>tank_y[30+:10])?(tank_y[40+:10]-tank_y[30+:10]):(tank_y[30+:10]-tank_y[40+:10]);
assign absy42=(tank_y[40+:10]>tank_y[20+:10])?(tank_y[40+:10]-tank_y[20+:10]):(tank_y[20+:10]-tank_y[40+:10]);
assign absy32=(tank_y[30+:10]>tank_y[20+:10])?(tank_y[30+:10]-tank_y[20+:10]):(tank_y[20+:10]-tank_y[30+:10]);
	
//----------------------------------------------------------------------TANK_0 X
always@(posedge clk_f,negedge rst_n)
	begin
		if(~rst_n)
			tank_x[49:40]<= 10'd6;
		else if(~tank_exit[4])
			tank_x[49:40]<= 10'd6;
		else
			begin
				case(direction_reg)
				4'b1000: tank_x[49:40]<=tank_x[49:40];
				4'b0100: tank_x[49:40]<=tank_x[49:40];
				4'b0010: begin
							if(tank_x[49:40]==10'd6)
								tank_x[49:40]<=tank_x[49:40];
							else if( ( (tank_x[49:40]-10'd1-tank_x[30+:10])<10'd30 && absy43<10'd30 ) ||( (tank_x[49:40]-10'd1-tank_x[20+:10])<10'd30 && absy42<10'd30 ))
								tank_x[49:40]<=tank_x[49:40];
							else
								tank_x[49:40]<=tank_x[49:40]-10'd1;
						end
						
				4'b0001: begin
							if(tank_x[49:40] == 10'd606)//10'd639-10'd29-1-3
								tank_x[49:40]<=tank_x[49:40];
							else if( ( (tank_x[30+:10]-tank_x[49:40]-10'd1)<10'd30 && absy43<10'd30 ) ||( (tank_x[20+:10]-tank_x[49:40]-10'd1)<10'd30 && absy42<10'd30 ))
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
		else if(~tank_exit[4])
			tank_y[49:40]<= 10'd446;
		else
			begin
				case(direction_reg)
				4'b1000: begin
							if(tank_y[49:40] == 10'd4)
								tank_y[49:40]<=tank_y[49:40];
							else if( ( (tank_y[49:40]-10'd1-tank_y[30+:10])<10'd30 && absx43<10'd30 ) ||( (tank_y[49:40]-10'd1-tank_y[20+:10])<10'd30 && absx42<10'd30 ))
								tank_y[49:40]<=tank_y[49:40];
							else
								tank_y[49:40]<=tank_y[49:40]-10'd1;
						end
				4'b0100: begin
							if(tank_y[49:40]==10'd446)//10'd479-10'd29-1-3
								tank_y[49:40]<=tank_y[49:40];
							else if( ( (tank_y[30+:10]-tank_y[49:40]-10'd1)<10'd30 && absx43<10'd30 ) ||( (tank_y[20+:10]-tank_y[49:40]-10'd1)<10'd30 && absx42<10'd30 ))
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
			tank_x[39:30]<= 10'd400;
		else if(~tank_exit[3])
			tank_x[30+:10]<= 10'd400;
		else
			begin
				case(tank_direction[7:6])
				2'b00: tank_x[39:30]<=tank_x[39:30];
				2'b01: tank_x[39:30]<=tank_x[39:30];
				2'b10: begin
							if(tank_x[39:30]==10'd6)
								tank_x[39:30]<=tank_x[39:30];
							else if( ( (tank_x[30+:10]-10'd1-tank_x[40+:10])<10'd30 && absy43<10'd30 ) ||( (tank_x[30+:10]-10'd1-tank_x[20+:10])<10'd30 && absy32<10'd30 ))
								tank_x[30+:10]<=tank_x[30+:10];
							else
								tank_x[30+:10]<=tank_x[30+:10]-10'd1;
						end
						
				2'b11: begin
							if(tank_x[39:30] == 10'd606)//10'd639-10'd29-1-3
								tank_x[39:30]<=tank_x[39:30];
							else if( ( (tank_x[40+:10]-tank_x[30+:10]-10'd1)<10'd30 && absy43<10'd30 ) ||( (tank_x[20+:10]-tank_x[30+:10]-10'd1)<10'd30 && absy32<10'd30 ))
								tank_x[30+:10]<=tank_x[30+:10];
							else
								tank_x[30+:10]<=tank_x[30+:10]+10'd1;
						end
				
				endcase
			end	
	end	
//----------------------------------------------------------------------TANK_1 Y
always@(posedge clk_f,negedge rst_n)
	begin
		if(~rst_n)
			tank_y[39:30]<= 10'd4;
		else if(~tank_exit[3])
			tank_y[30+:10]<= 10'd4;
		else
//			tank_y[39:30]<= 10'd4;
			begin
				case(tank_direction[7:6])
				2'b00: begin
							if(tank_y[39:30] == 10'd4)
								tank_y[39:30]<=tank_y[39:30];
							else if( ( (tank_y[30+:10]-10'd1-tank_y[40+:10])<10'd30 && absx43<10'd30 ) ||( (tank_y[30+:10]-10'd1-tank_y[20+:10])<10'd30 && absx32<10'd30 ))
								tank_y[30+:10]<=tank_y[30+:10];
							else
								tank_y[30+:10]<=tank_y[30+:10]-10'd1;
						end
				2'b01: begin
							if(tank_y[39:30]==10'd446)//10'd479-10'd29-1-3
								tank_y[39:30]<=tank_y[39:30];
							else if( ( (tank_y[40+:10]-tank_y[30+:10]-10'd1)<10'd30 && absx43<10'd30 ) ||( (tank_y[20+:10]-tank_y[30+:10]-10'd1)<10'd30 && absx32<10'd30 ))
								tank_y[30+:10]<=tank_y[30+:10];
							else
								tank_y[30+:10]<=tank_y[30+:10]+10'd1;
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
			tank_x[29:20]<= 10'd200;
		else if(~tank_exit[2])
			tank_x[20+:10]<= 10'd200;
		else
			begin
				case(tank_direction[5:4])
				2'b00: tank_x[29:20]<=tank_x[29:20];
				2'b01: tank_x[29:20]<=tank_x[29:20];
				2'b10: begin
							if(tank_x[29:20]==10'd6)
								tank_x[29:20]<=tank_x[29:20];
							else if( ( (tank_x[20+:10]-10'd1-tank_x[40+:10])<10'd30 && absy42<10'd30 ) ||( (tank_x[20+:10]-10'd1-tank_x[30+:10])<10'd30 && absy32<10'd30 ))
								tank_x[20+:10]<=tank_x[20+:10];
							else
								tank_x[20+:10]<=tank_x[20+:10]-10'd1;
						end
						
				2'b11: begin
							if(tank_x[29:20] == 10'd606)//10'd639-10'd29-1-3
								tank_x[29:20]<=tank_x[29:20];
							else if( ( (tank_x[40+:10]-tank_x[20+:10]-10'd1)<10'd30 && absy42<10'd30 ) ||( (tank_x[30+:10]-tank_x[20+:10]-10'd1)<10'd30 && absy32<10'd30 ))
								tank_x[20+:10]<=tank_x[20+:10];
							else
								tank_x[20+:10]<=tank_x[20+:10]+10'd1;
						end
				
				endcase
			end	
	end	
//----------------------------------------------------------------------TANK_2 Y
always@(posedge clk_f,negedge rst_n) 
	begin
		if(~rst_n)
			tank_y[29:20]<= 10'd4;
		else if(~tank_exit[2])
			tank_y[20+:10]<= 10'd4;
		else
//			tank_y[29:20]<= 10'd4;
			begin
				case(tank_direction[5:4])
				2'b00: begin
							if(tank_y[29:20] == 10'd4)
								tank_y[29:20]<=tank_y[29:20];
							else if( ( (tank_y[20+:10]-10'd1-tank_y[40+:10])<10'd30 && absx42<10'd30 ) ||( (tank_y[20+:10]-10'd1-tank_y[30+:10])<10'd30 && absx32<10'd30 ))
								tank_y[20+:10]<=tank_y[20+:10];
							else
								tank_y[20+:10]<=tank_y[20+:10]-10'd1;
						end
				2'b01: begin
							if(tank_y[29:20]==10'd446)//10'd479-10'd29-1-3
								tank_y[29:20]<=tank_y[29:20];
							else if( ( (tank_y[40+:10]-tank_y[20+:10]-10'd1)<10'd30 && absx42<10'd30 ) ||( (tank_y[30+:10]-tank_y[20+:10]-10'd1)<10'd30 && absx32<10'd30 ))
								tank_y[20+:10]<=tank_y[20+:10];
							else
								tank_y[20+:10]<=tank_y[20+:10]+10'd1;
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
		else if(~tank_exit[4] && x_pos>=200 && x_pos<10'd400 &&  y_pos>=10'd200 && y_pos<10'd300)
			begin
				red<=rgb[23:16];
				green<=rgb[15:8];
				blue<=rgb[7:0];
			end
			
//		else if(!tank_exit[4])
//			begin
//				red<={8{1'b1}};
//				green<=8'b0;
//				blue<=8'b0;
//			end
		else if(x_pos==10'd1 || x_pos==10'd639 || y_pos==10'd0 || y_pos==10'd479)//边框
			begin
				red<={8{1'b1}};
				green<=8'b0;
				blue<=8'b0;
			end
		else if(tank_exit[4] && tank_direction[8+:2]==2'b00 &&(((x_pos-tank_x[49:40])>=10'd12 && (x_pos-tank_x[49:40])<=10'd17 && (y_pos-tank_y[49:40])>=10'd0 &&(y_pos-tank_y[49:40])<=10'd11) || 
						((x_pos-tank_x[49:40])>=10'd5 && (x_pos-tank_x[49:40])<=10'd24 && (y_pos-tank_y[49:40])>=10'd12 &&(y_pos-tank_y[49:40])<=10'd29) ))//up0
			begin
				if(damage)
					begin
						red={8{1'b1}};
						green=8'b0;
						blue=8'b0;
					end
				else
					begin
						red={8{1'b1}};
						green={8{1'b1}};
						blue=8'b0;
					end
						
			end
		else if(tank_exit[4] && tank_direction[8+:2]==2'b01 && (((x_pos-tank_x[49:40])>=10'd12 && (x_pos-tank_x[49:40])<=10'd17 && (y_pos-tank_y[49:40])>=10'd18 &&(y_pos-tank_y[49:40])<=10'd29) || 
						((x_pos-tank_x[49:40])>=10'd5 && (x_pos-tank_x[49:40])<=10'd24 && (y_pos-tank_y[49:40])>=10'd0 &&(y_pos-tank_y[49:40])<=10'd17) ))//down0
			begin
//				red={8{1'b1}};
//				green={8{1'b1}};
//				blue=8'b0;
				if(damage)
					begin
						red={8{1'b1}};
						green=8'b0;
						blue=8'b0;
					end
				else
					begin
						red={8{1'b1}};
						green={8{1'b1}};
						blue=8'b0;
					end
			end
		else if(tank_exit[4] && tank_direction[8+:2]==2'b10 && (((x_pos-tank_x[49:40])>=10'd0 && (x_pos-tank_x[49:40])<=10'd11 && (y_pos-tank_y[49:40])>=10'd12 &&(y_pos-tank_y[49:40])<=10'd17) || 
						((x_pos-tank_x[49:40])>=10'd12 && (x_pos-tank_x[49:40])<=10'd29 && (y_pos-tank_y[49:40])>=10'd5 &&(y_pos-tank_y[49:40])<=10'd24) ))//left0
			begin
				if(damage)
					begin
						red={8{1'b1}};
						green=8'b0;
						blue=8'b0;
					end
				else
					begin
						red={8{1'b1}};
						green={8{1'b1}};
						blue=8'b0;
					end 
			end
		else if(tank_exit[4] && tank_direction[8+:2]==2'b11 &&(((x_pos-tank_x[49:40])>=10'd18 && (x_pos-tank_x[49:40])<=10'd29 && (y_pos-tank_y[49:40])>=10'd12 &&(y_pos-tank_y[49:40])<=10'd17) || 
						((x_pos-tank_x[49:40])>=10'd0 && (x_pos-tank_x[49:40])<=10'd17 && (y_pos-tank_y[49:40])>=10'd5 &&(y_pos-tank_y[49:40])<=10'd24) ) )//right0
			begin
				if(damage)
					begin
						red={8{1'b1}};
						green=8'b0;
						blue=8'b0;
					end
				else
					begin
						red={8{1'b1}};
						green={8{1'b1}};
						blue=8'b0;
					end
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
				red=8'b0;
				green={8{1'b1}};
				blue=8'b0;
			end
		else if(tank_exit[2] && tank_direction[4+:2]==2'b01 && (((x_pos-tank_x[29:20])>=10'd12 && (x_pos-tank_x[29:20])<=10'd17 && (y_pos-tank_y[29:20])>=10'd18 &&(y_pos-tank_y[29:20])<=10'd29) || 
						((x_pos-tank_x[29:20])>=10'd5 && (x_pos-tank_x[29:20])<=10'd24 && (y_pos-tank_y[29:20])>=10'd0 &&(y_pos-tank_y[29:20])<=10'd17) ))//down1
			begin
				red=8'b0;
				green={8{1'b1}};
				blue=8'b0;
			end
		else if(tank_exit[2] && tank_direction[4+:2]==2'b10 && (((x_pos-tank_x[29:20])>=10'd0 && (x_pos-tank_x[29:20])<=10'd11 && (y_pos-tank_y[29:20])>=10'd12 &&(y_pos-tank_y[29:20])<=10'd17) || 
						((x_pos-tank_x[29:20])>=10'd12 && (x_pos-tank_x[29:20])<=10'd29 && (y_pos-tank_y[29:20])>=10'd5 &&(y_pos-tank_y[29:20])<=10'd24) ))//left1
			begin
				red=8'b0;
				green={8{1'b1}};
				blue=8'b0;
			end
		else if(tank_exit[2] && tank_direction[4+:2]==2'b11 &&(((x_pos-tank_x[29:20])>=10'd18 && (x_pos-tank_x[29:20])<=10'd29 && (y_pos-tank_y[29:20])>=10'd12 &&(y_pos-tank_y[29:20])<=10'd17) || 
						((x_pos-tank_x[29:20])>=10'd0 && (x_pos-tank_x[29:20])<=10'd17 && (y_pos-tank_y[29:20])>=10'd5 &&(y_pos-tank_y[29:20])<=10'd24) ) )//right1
			begin
				red=8'b0;
				green={8{1'b1}};
				blue=8'b0;
			end
		//bullet0
		else if(bullet_exit[24] && (x_pos-bullet_x[240+:10])>=10'd0 && (x_pos-bullet_x[240+:10])<=10'd2 && (y_pos-bullet_y[240+:10])>=10'd0 && (y_pos-bullet_y[240+:10])<=10'd2)//right1
			begin
				red={8{1'b1}};
				green={8{1'b1}};
				blue={8{1'b1}};
			end
		else if(bullet_exit[23] && (x_pos-bullet_x[230+:10])>=10'd0 && (x_pos-bullet_x[230+:10])<=10'd2 && (y_pos-bullet_y[230+:10])>=10'd0 && (y_pos-bullet_y[230+:10])<=10'd2)//right1
			begin
				red={8{1'b1}};
				green={8{1'b1}};
				blue={8{1'b1}};
			end
		else if(bullet_exit[22] && (x_pos-bullet_x[220+:10])>=10'd0 && (x_pos-bullet_x[220+:10])<=10'd2 && (y_pos-bullet_y[220+:10])>=10'd0 && (y_pos-bullet_y[220+:10])<=10'd2)//right1
			begin
				red={8{1'b1}};
				green={8{1'b1}};
				blue={8{1'b1}};
			end
		else if(bullet_exit[21] && (x_pos-bullet_x[210+:10])>=10'd0 && (x_pos-bullet_x[210+:10])<=10'd2 && (y_pos-bullet_y[210+:10])>=10'd0 && (y_pos-bullet_y[210+:10])<=10'd2)//right1
			begin
				red={8{1'b1}};
				green={8{1'b1}};
				blue={8{1'b1}};
			end
		else if(bullet_exit[19] && (x_pos-bullet_x[190+:10])>=10'd0 && (x_pos-bullet_x[190+:10])<=10'd2 && (y_pos-bullet_y[190+:10])>=10'd0 && (y_pos-bullet_y[190+:10])<=10'd2)//right1
			begin
				red={8{1'b1}};
				green=8'b0;
				blue=8'b0;
			end
		else if(bullet_exit[18] && (x_pos-bullet_x[180+:10])>=10'd0 && (x_pos-bullet_x[180+:10])<=10'd2 && (y_pos-bullet_y[180+:10])>=10'd0 && (y_pos-bullet_y[180+:10])<=10'd2)//right1
			begin
				red={8{1'b1}};
				green=8'b0;
				blue=8'b0;
			end
		else if(bullet_exit[17] && (x_pos-bullet_x[170+:10])>=10'd0 && (x_pos-bullet_x[170+:10])<=10'd2 && (y_pos-bullet_y[170+:10])>=10'd0 && (y_pos-bullet_y[170+:10])<=10'd2)//right1
			begin
				red={8{1'b1}};
				green=8'b0;
				blue=8'b0;
			end
		else if(bullet_exit[16] && (x_pos-bullet_x[160+:10])>=10'd0 && (x_pos-bullet_x[160+:10])<=10'd2 && (y_pos-bullet_y[160+:10])>=10'd0 && (y_pos-bullet_y[160+:10])<=10'd2)//right1
			begin
				red={8{1'b1}};
				green=8'b0;
				blue=8'b0;
			end
		else if(bullet_exit[14] && (x_pos-bullet_x[140+:10])>=10'd0 && (x_pos-bullet_x[140+:10])<=10'd2 && (y_pos-bullet_y[140+:10])>=10'd0 && (y_pos-bullet_y[140+:10])<=10'd2)//right1
			begin
				red=8'b0;
				green={8{1'b1}};
				blue=8'b0;
			end
		else if(bullet_exit[13] && (x_pos-bullet_x[130+:10])>=10'd0 && (x_pos-bullet_x[130+:10])<=10'd2 && (y_pos-bullet_y[130+:10])>=10'd0 && (y_pos-bullet_y[130+:10])<=10'd2)//right1
			begin
				red=8'b0;
				green={8{1'b1}};
				blue=8'b0;
			end
		else if(bullet_exit[12] && (x_pos-bullet_x[120+:10])>=10'd0 && (x_pos-bullet_x[120+:10])<=10'd2 && (y_pos-bullet_y[120+:10])>=10'd0 && (y_pos-bullet_y[120+:10])<=10'd2)//right1
			begin
				red=8'b0;
				green={8{1'b1}};
				blue=8'b0;
			end
		else if(bullet_exit[11] && (x_pos-bullet_x[110+:10])>=10'd0 && (x_pos-bullet_x[110+:10])<=10'd2 && (y_pos-bullet_y[110+:10])>=10'd0 && (y_pos-bullet_y[110+:10])<=10'd2)//right1
			begin
				red=8'b0;
				green={8{1'b1}};
				blue=8'b0;
			end
		else if(~tank_exit[3] && (((x_pos-tank_x[39:30])>=10'd12 && (x_pos-tank_x[39:30])<=10'd17 && (y_pos-tank_y[39:30])>=10'd18 &&(y_pos-tank_y[39:30])<=10'd29) || 
						((x_pos-tank_x[39:30])>=10'd5 && (x_pos-tank_x[39:30])<=10'd24 && (y_pos-tank_y[39:30])>=10'd0 &&(y_pos-tank_y[39:30])<=10'd17) ))
			begin
				red<=enemy1_rebirth;
				green<=enemy1_rebirth;
				blue<=enemy1_rebirth;
			end
		else if(~tank_exit[2] && (((x_pos-tank_x[29:20])>=10'd12 && (x_pos-tank_x[29:20])<=10'd17 && (y_pos-tank_y[29:20])>=10'd18 &&(y_pos-tank_y[29:20])<=10'd29) || 
						((x_pos-tank_x[29:20])>=10'd5 && (x_pos-tank_x[29:20])<=10'd24 && (y_pos-tank_y[29:20])>=10'd0 &&(y_pos-tank_y[29:20])<=10'd17) ))
			begin
				red<=enemy2_rebirth;
				green<=enemy2_rebirth;
				blue<=enemy2_rebirth;
			end
			
		else
			begin
				red<=8'b0;
				green<=8'b0;
				blue<=8'b0;
			end
	end


endmodule 