module EXMEMreg(clk,reset,wr_EXMEM,EXMEMclear,IDEXMemRead,IDEXMemWrite,IDEXMemtoReg,IDEXRegWrite,
		alu_out,wrDataIn,rd_in,IDEXopcode,nextPC,PCjump,newPC,PCsrc,EXMEMmemRead,EXMEMmemWrite,EXMEMmemtoReg,EXMEMRegWrite,
		dataAddr,wrDataOut,rd_out,EXMEMopcode);

input clk,reset,wr_EXMEM,EXMEMclear,IDEXMemRead,IDEXMemWrite,IDEXMemtoReg,IDEXRegWrite,PCjump;
input [3:0] rd_in,IDEXopcode;
input [15:0] alu_out,wrDataIn,nextPC;

output EXMEMmemRead,EXMEMmemWrite,EXMEMmemtoReg,EXMEMRegWrite,PCsrc;
output [3:0] rd_out,EXMEMopcode;
output [15:0] dataAddr,wrDataOut,newPC;

reg MemRead,MemWrite,MemtoReg,RegWrite,willPCjump;
reg [3:0] rd,opcode;
reg [15:0] outPC,inA,inB;

always@(posedge clk,reset)begin
	if(~reset)begin
		MemRead<=1'b0;
		MemWrite<=1'b0;
		MemtoReg<=1'b0;
		RegWrite<=1'b0;
		inA<=16'h0000;
		inB<=16'h0000;	
		rd<=4'b0000;
		outPC<=16'h0000;
		willPCjump<=1'b0;
		opcode<=4'h0;
	end else if(EXMEMclear) begin
		MemRead<=1'b0;
		MemWrite<=1'b0;
		MemtoReg<=1'b0;
		RegWrite<=1'b0;
		inA<=16'h0000;
		inB<=16'h0000;	
		rd<=4'b0000;
		outPC<=16'h0000;
		willPCjump<=1'b0;
		opcode<=4'h0;
	end else if(wr_EXMEM) begin
		MemRead<=IDEXMemRead;
		MemWrite<=IDEXMemWrite;
		MemtoReg<=IDEXMemtoReg;
		RegWrite<=IDEXRegWrite;
		inA<=alu_out;
		inB<=wrDataIn;
		rd<=rd_in;
		outPC<=nextPC;
		willPCjump<=PCjump;
		opcode<=IDEXopcode;
	end
end

assign EXMEMmemRead = MemRead;
assign EXMEMmemWrite = MemWrite;
assign EXMEMmemtoReg = MemtoReg;
assign EXMEMRegWrite = RegWrite;
assign dataAddr = inA;
assign wrDataOut = inB;
assign rd_out = rd;
assign newPC = outPC;
assign PCsrc = willPCjump;
assign EXMEMopcode = opcode;

endmodule
