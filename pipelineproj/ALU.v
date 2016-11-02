module ALU(input [15:0] in1,in2, input [3:0] imm , input [2:0] opcode , output reg [15:0] out , output N,Z,output reg V);

	wire [7:0] outUp8 , outDwn8;
	satAdder#(8) 	paddsbUp(.a(in1[15:8]) , .b(in2[15:8]) , .out(outUp8 ) , .overFlowFlag()),
			paddsbDw(.a(in1[7:0]) , .b(in2[7:0]) , .out(outDwn8) , .overFlowFlag());

	wire [15:0] 	satAddOut , satSubOut;
	wire 		satAddV   , satSubV;
	satAdder#(16)	add(.a(in1) , .b(in2) , .out(satAddOut) , .overFlowFlag(satAddV)) , 
			sub(.a(in1) , .b(-in2) , .out(satSubOut) , .overFlowFlag(satSubV));

	always@(*)	begin
		out 	= 0;
		V 	= 0;
		case(opcode)	
			0: begin
				out 	= satAddOut;
				V 	= satAddV;
			end
			1: begin
				out 	={outUp8 , outDwn8};
			end
			2: begin
				out 	= satSubOut;
				V 	= satSubV;
			end
			3: begin
				out 	= ~(in1 & in2);
			end
			4: begin
				out 	= (in1 ^ in2);
			end
			5: begin
				out 	= (in1 <<imm);
			end
			6: begin
				out 	= (in1 >>imm);
			end
			7: begin
				out 	= (in1 >>>imm);
			end
		endcase

	end


	assign Z = out == 0;
	assign N = out[15] == 1;

endmodule
