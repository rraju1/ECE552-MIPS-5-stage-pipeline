module MEMWBreg(clk,reset,wr_MEMWB,MEMWBclear,EXMEMmemtoReg,EXMEMRegWrite,
		alu_out,dataMemOut,rd_in,EXMEMopcode,MEMWBMemtoReg,MEMWBRegWrite,
		dataAddr,wrDataOut,rd_out,MEMWBopcode);

input clk,reset,wr_MEMWB,MEMWBclear,EXMEMmemtoReg,EXMEMRegWrite;
input [3:0] rd_in,EXMEMopcode;
input [15:0] alu_out,dataMemOut;

output MEMWBMemtoReg,MEMWBRegWrite;
output [3:0] rd_out,MEMWBopcode;
output [15:0] dataAddr,wrDataOut;

reg MemtoReg,RegWrite;
reg [3:0] rd,opcode;
reg [15:0] inA,inB;

always@(posedge clk,reset)begin
	if(~reset)begin
		MemtoReg<=1'b0;
		RegWrite<=1'b0;
		inA<=16'h0000;
		inB<=16'h0000;	
		rd<=4'b0000;
		opcode<=4'h0;
	end else if(MEMWBclear) begin
		MemtoReg<=1'b0;
		RegWrite<=1'b0;
		inA<=16'h0000;
		inB<=16'h0000;	
		rd<=4'b0000;
		opcode<=4'h0;
	end else if(wr_MEMWB) begin
		MemtoReg<=EXMEMmemtoReg;
		RegWrite<=EXMEMRegWrite;
		inA<=alu_out;
		inB<=dataMemOut;
		rd<=rd_in;
		opcode<=EXMEMopcode;
	end
end

assign MEMWBMemtoReg = MemtoReg;
assign MEMWBRegWrite = RegWrite;
assign dataAddr = inA;
assign wrDataOut = inB;
assign rd_out = rd;
assign MEMWBopcode = opcode;

endmodule
