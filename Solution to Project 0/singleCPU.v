module singleCPU (input clk,input rst_n , output [15:0] pc,output reg halt);


	wire[15:0] PC;
	assign pc = PC;
	wire aluN,aluZ,aluV;
	wire N,Z,V;

	wire [15:0] instruction;

	wire rf_wrEn;
	reg [15:0] rf_wrData; 
	wire [15:0] rf_data1,rf_data2;

	wire [15:0] alu_outData;

	instructionMem 	insMem	(.readAdr(PC),.readData(instruction));
	

	assign rf_wrEn = ((instruction[15] == 0) | (instruction[15:13] == 3'b101) | (instruction[15:12] == 4'b1101))&(rst_n); // Write enable signal

	regfile 	rf	(.readAdr1( ((instruction[15:12] == 4'b1010)) ? instruction[11:8] : instruction[7:4] ),
				 .readAdr2( ((instruction[15:12] == 4'b1001)) ? instruction[11:8] : instruction[3:0] ),
				 .readData1(rf_data1),
				 .readData2(rf_data2),
				 .writeEn(rf_wrEn),
				 .writeAdr((instruction[15:12] == 4'b1101)? 4'd15:instruction[11:8]),
				 .writeData(rf_wrData));
	
	ALU 		alu	(.in1(rf_data1),.in2(rf_data2), .imm(instruction[3:0]) ,  .opcode(instruction[14:12]) , 
				 .out(alu_outData) , .N(aluN),.Z(aluZ),.V(aluV));
		
	
	flag_register	flgReg 	(.clk(clk),.rst_n(rst_n) ,.iZ(aluZ),.iN(aluN),.iV(aluV) , .opcode(instruction[15:12]) , .N(N),.Z(Z),.V(V));
	

	wire [15:0] dtMemAdr;
	wire [15:0] dtMemReadData; 
	assign dtMemAdr =  rf_data1 + { {(16-3){instruction[3]}} , instruction[3:0] };


	dataMem 	dtMem	(.adr(dtMemAdr),.readData(dtMemReadData),.writeEn((instruction[15:12] == 4'b1001)),.writeData(rf_data2));
	
	reg [15:0] 	newPC;
	reg updatePC,increamentPC;
	reg branchConditionIsTrue;
	PC 		inspc	(.clk(clk),.rst_n(rst_n),.halt(halt), .newPC(newPC) , 
			   	 .updatePC(updatePC&(rst_n)) , .increamentPC(increamentPC&(rst_n)),.PC(PC));
	always@(*) begin
		increamentPC 	= 1;
		updatePC	= 0;
		newPC		= 0;
		halt		= 0;
		case(instruction[15:12]) 
			4'b1100: begin// B instruction
				if(branchConditionIsTrue) begin
					increamentPC 	= 0;
					updatePC	= 1;
					newPC		= PC+1+{ {(16-9){instruction[8]}} , instruction[8:0] }; 
				end
			end
			4'b1101: begin//Call instruction
				increamentPC 	= 0;
				updatePC	= 1;
				newPC		= PC+1+{ {(16-12){instruction[11]}} , instruction[11:0] }; 
			end
			4'b1110: begin//ret instruction
				increamentPC 	= 0;
				updatePC	= 1;
				newPC		= rf_data1; 
			end
			4'b1111: halt = 1;
		endcase
		
	end
	always@(*) begin
		branchConditionIsTrue = 0;
		casex(    {N,Z,V , instruction[11:9]}) // rows of table 1
			{3'bx0x, 3'b000}, 			//Not Equal (Z = 0) 
			{3'bx1x, 3'b001}, 			//Equal (Z = 1) 
			{3'b00x, 3'b010}, 			//Greater Than (Z = N = 0) 
			{3'b1xx, 3'b011}, 			//Less Than (N = 1)  
			{3'bx1x, 3'b100},{3'b00x, 3'b100},	//Greater Than or Equal (Z = 1 or Z = N = 0) 
			{3'b1xx, 3'b101},{3'bx1x, 3'b101},	//Less Than or Equal ( N = 1 or Z = 1) 
			{3'bxx1, 3'b110}, 			//Overflow (V = 1) 
			{3'bxxx, 3'b111}: 			//Unconditional 
			 branchConditionIsTrue = 1;
		endcase
		
	end
	 
	// TODO: generate the write data signal for the register file
	always@(*) begin
		rf_wrData = 0;
		casex(instruction[15:12])
			4'b0xxx: rf_wrData = alu_outData; 					// Arithmetic
			4'b1011: rf_wrData = {{(16-8){instruction[7]}},instruction[7:0]}; 	// LLB
			4'b1010: rf_wrData = {instruction[7:0] , rf_data1[7:0]}; 		// LHB
			4'b1000: rf_wrData = dtMemReadData;					// LW
			4'b1101: rf_wrData = PC+1;						// Call
		endcase
	end

endmodule
