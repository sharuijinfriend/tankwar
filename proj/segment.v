//module segment(
//input [3:0] seg_ori,
//output reg [0:6] seg
//);
//
//always @(*)
//	begin
//			case(seg_ori)
//			0		:seg=7'b1111110;
//			1		:seg=7'b0110000;
//			2		:seg=7'b1101101;
//			3		:seg=7'b1111001;
//			4		:seg=7'b0110011;
//			5		:seg=7'b1011011;
//			6		:seg=7'b1011111;
//			7		:seg=7'b1110000;
//			8		:seg=7'b1111111;
//			9		:seg=7'b1111011;
//			default :seg=7'b1111111;
//			endcase
//	end
//endmodule 
module segment(
input [3:0] seg_ori,
output reg [6:0] seg
);

always @(*)
	begin
			case(seg_ori)
			0		:seg=7'b1000000;
			1		:seg=7'b1111001;
			2		:seg=7'b0100100;
			3		:seg=7'b0110000;
			4		:seg=7'b0011001;
			5		:seg=7'b0010010;
			6		:seg=7'b0000010;
			7		:seg=7'b1111000;
			8		:seg=7'b0000000;
			9		:seg=7'b0010000;
			default :seg=7'b1111111;
			endcase
	end
endmodule 