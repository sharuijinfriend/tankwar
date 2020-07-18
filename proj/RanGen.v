module RanGen(
    input               rst_n,    /*rst_n is necessary to prevet locking up*/
    input               clk,      /*clock signal*/
//    input               load,     /*load seed to rand_num,active high */
//    input      [7:0]    seed,     
    output reg [7:0]    rand_num  /*random number output*/
);
reg [1:0] rand_counter;

always@(posedge clk or negedge rst_n)
	begin
		if(~rst_n)
			rand_counter<= 2'b0;
		else if(rand_counter ==2'b01)
			rand_counter<= 2'b00;
		else 
			rand_counter<= rand_counter+2'b1;
	end
	

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        rand_num    <=8'd200;
//    else if(load)
//        rand_num <=seed;    /*load the initial value when load is active*/
    else if(rand_counter == 2'b01)
        begin
            rand_num[0] <= rand_num[7]^rand_num[2];
            rand_num[1] <= rand_num[0]^rand_num[3];
            rand_num[2] <= rand_num[1]^rand_num[4];
            rand_num[3] <= rand_num[2]^rand_num[5];
            rand_num[4] <= rand_num[3]^rand_num[6];
            rand_num[5] <= rand_num[4]^rand_num[7];
            rand_num[6] <= rand_num[5]^rand_num[0];
            rand_num[7] <= rand_num[6];
        end
            
end
endmodule