module enermy1bullet(//[39:30]
input clk_f,
input rst_n,
input shoot,
input wire [4:0] tank_exit,
input [1:0] tank_direction,
input bullet_exit_front,
input [49:0] tank_x,
input [49:0] tank_y,
input [5:0] bullet_counter,
input [79:0] other_bullet_x,
input [79:0] other_bullet_y,
input [7:0] otherbullet_exit,
output reg bullet_exit,
output reg bullet_exit_reg,
output reg [1:0] bullet_direction,
output reg [9:0] bullet_x,
output reg [9:0] bullet_y
);

always@(posedge clk_f,negedge rst_n)//每秒采样一次，检测是不是可以产生新的子弹
//还需要做碰撞后消失
	begin
		if(~rst_n)
			bullet_exit<=1'b0;
		else if(~tank_exit[3])
			bullet_exit<=1'b0;
		else if(bullet_exit && (bullet_x==10'd3 || bullet_x==10'd636 || bullet_y == 10'd1 || bullet_y == 10'd476 || //其实这里应该可以写作bullet_exit的，用reg反而会会带来一个周期的延迟，虽然无所谓
		(tank_exit[4]&& ((bullet_x)<tank_x[40+:10]+10'd30 )&&((bullet_x)>=tank_x[40+:10])&& ((bullet_y)<tank_y[40+:10]+10'd30 ) && ((bullet_y)>=tank_y[40+:10] ))||
		(tank_exit[2]&& ((bullet_x)<tank_x[20+:10]+10'd30 )&&((bullet_x)>=tank_x[20+:10])&& ((bullet_y)<tank_y[20+:10]+10'd30 ) && ((bullet_y)>=tank_y[20+:10] ))||
					(otherbullet_exit[7]&& (  (bullet_x>=other_bullet_x[79:70] &&(bullet_x-other_bullet_x[79:70])<10'd2)||(bullet_x<other_bullet_x[79:70] &&(other_bullet_x[79:70]-bullet_x)<10'd2) )&&( (bullet_y>=other_bullet_y[79:70] &&(bullet_y-other_bullet_y[79:70])<10'd2)|| (bullet_y<other_bullet_y[79:70] &&(other_bullet_y[79:70]-bullet_y)<10'd2)))||
					(otherbullet_exit[6]&& (  (bullet_x>=other_bullet_x[69:60] &&(bullet_x-other_bullet_x[69:60])<10'd2)||(bullet_x<other_bullet_x[69:60] &&(other_bullet_x[69:60]-bullet_x)<10'd2) )&&( (bullet_y>=other_bullet_y[69:60] &&(bullet_y-other_bullet_y[69:60])<10'd2)|| (bullet_y<other_bullet_y[69:60] &&(other_bullet_y[69:60]-bullet_y)<10'd2)))||
					(otherbullet_exit[5]&& (  (bullet_x>=other_bullet_x[59:50] &&(bullet_x-other_bullet_x[59:50])<10'd2)||(bullet_x<other_bullet_x[59:50] &&(other_bullet_x[59:50]-bullet_x)<10'd2) )&&( (bullet_y>=other_bullet_y[59:50] &&(bullet_y-other_bullet_y[59:50])<10'd2)|| (bullet_y<other_bullet_y[59:50] &&(other_bullet_y[59:50]-bullet_y)<10'd2)))||
					(otherbullet_exit[4]&& (  (bullet_x>=other_bullet_x[49:40] &&(bullet_x-other_bullet_x[49:40])<10'd2)||(bullet_x<other_bullet_x[49:40] &&(other_bullet_x[49:40]-bullet_x)<10'd2) )&&( (bullet_y>=other_bullet_y[49:40] &&(bullet_y-other_bullet_y[49:40])<10'd2)|| (bullet_y<other_bullet_y[49:40] &&(other_bullet_y[49:40]-bullet_y)<10'd2)))||
					(otherbullet_exit[3]&& (  (bullet_x>=other_bullet_x[39:30] &&(bullet_x-other_bullet_x[39:30])<10'd2)||(bullet_x<other_bullet_x[39:30] &&(other_bullet_x[39:30]-bullet_x)<10'd2) )&&( (bullet_y>=other_bullet_y[39:30] &&(bullet_y-other_bullet_y[39:30])<10'd2)|| (bullet_y<other_bullet_y[39:30] &&(other_bullet_y[39:30]-bullet_y)<10'd2)))||
					(otherbullet_exit[2]&& (  (bullet_x>=other_bullet_x[29:20] &&(bullet_x-other_bullet_x[29:20])<10'd2)||(bullet_x<other_bullet_x[29:20] &&(other_bullet_x[29:20]-bullet_x)<10'd2) )&&( (bullet_y>=other_bullet_y[29:20] &&(bullet_y-other_bullet_y[29:20])<10'd2)|| (bullet_y<other_bullet_y[29:20] &&(other_bullet_y[29:20]-bullet_y)<10'd2)))||
					(otherbullet_exit[1]&& (  (bullet_x>=other_bullet_x[19:10] &&(bullet_x-other_bullet_x[19:10])<10'd2)||(bullet_x<other_bullet_x[19:10] &&(other_bullet_x[19:10]-bullet_x)<10'd2) )&&( (bullet_y>=other_bullet_y[19:10] &&(bullet_y-other_bullet_y[19:10])<10'd2)|| (bullet_y<other_bullet_y[19:10] &&(other_bullet_y[19:10]-bullet_y)<10'd2)))||
					(otherbullet_exit[0]&& (  (bullet_x>=other_bullet_x[9:0] &&(bullet_x-other_bullet_x[9:0])<10'd2)||(bullet_x<other_bullet_x[9:0] &&(other_bullet_x[9:0]-bullet_x)<10'd2) )&&( (bullet_y>=other_bullet_y[9:0] &&(bullet_y-other_bullet_y[9:0])<10'd2)|| (bullet_y<other_bullet_y[9:0] &&(other_bullet_y[9:0]-bullet_y)<10'd2)))

		))
			bullet_exit<=1'b0;
		else if(shoot && bullet_exit_front && ~bullet_exit &&bullet_counter==6'd60)
			bullet_exit<=1'b1;
		//else if(shoot && bullet_exit[24] && ~bullet_exit[23])
		//	bullet_exit[23]<=1'b1;
	end
	



always@(posedge clk_f,negedge rst_n)//用来判断是不是有新子弹的产生
begin
	if(~rst_n)
		bullet_exit_reg<=1'b1;
	else
		bullet_exit_reg<= bullet_exit;			
end

//----------------------------------------------------------------------BULLET_0 direction------------------
always@(posedge clk_f, negedge rst_n)
	if(~rst_n)
		bullet_direction<=2'b0;
	else if(!bullet_exit)
		bullet_direction<= tank_direction;
		
//----------------------------------------------------------------------BULLET_0 X
always@(posedge clk_f,negedge rst_n)
	if(~rst_n)
		bullet_x<=10'd30;
	else if(!bullet_exit)
		begin
			case(tank_direction)
				2'b00:	bullet_x<=tank_x[30+:10]+10'd14;
				2'b01:	bullet_x<=tank_x[30+:10]+10'd14;
				2'b10:	bullet_x<=tank_x[30+:10]-10'd3;
				2'b11:	bullet_x<=tank_x[30+:10]+10'd30;
			endcase
		end	
	else if(bullet_exit)
		begin
			case(bullet_direction)
				2'b00: bullet_x<=bullet_x;
				2'b01: bullet_x<=bullet_x;
				2'b10: begin
					if(bullet_x>10'd6)
						bullet_x<=bullet_x-10'd3;
					else
						bullet_x<=10'd3;
					end
				
				2'b11: begin
							if(bullet_x < 10'd633)//10'd639-10'd2-1
								bullet_x<=bullet_x+10'd3;
							else
								bullet_x<=10'd636;
						end
				
				endcase
		end
//----------------------------------------------------------------------BULLET_0 Y
always@(posedge clk_f,negedge rst_n)
	if(~rst_n)
		bullet_y<=10'd30;
	else if(!bullet_exit)
			case(tank_direction)
				2'b00:	bullet_y<=tank_y[30+:10]-10'd3;
				2'b01:	bullet_y<=tank_y[30+:10]+10'd30;
				2'b10:	bullet_y<=tank_y[30+:10]+10'd14;
				2'b11:	bullet_y<=tank_y[30+:10]+10'd14;
			endcase
		
	else if(bullet_exit)
		begin
			case(bullet_direction)
				2'b00: begin
							if(bullet_y >10'd4)//10'd479-10'd2-1
								bullet_y<=bullet_y-10'd3;
							else
								bullet_y<=10'd1;
						end
				2'b01: begin
							if(bullet_y<10'd473)
								bullet_y<=bullet_y+10'd3;
							else
								bullet_y<=10'd476;
						end
				2'b10: bullet_y<=bullet_y;
				2'b11: bullet_y<=bullet_y;
				endcase
		end
	


endmodule