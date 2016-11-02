module IDEXreg(clk,reset,wr_IDEX,IDEXclear,IDEXopcode,contbranchcond,contbranchoff,
		contcalloff,contMemRead,contMemWrite,contMemtoReg,contRegWrite,
		contimmed,readDat1,readDat2,nextPC,rs_in,rt_in,rd_in,opcodeOut,newPC,branchcondout,
		branchoffout,calloffsetout,IDEXMemRead,IDEXMemWrite,IDEXMemtoReg,
		IDEXRegWrite,shiftamt,readData1out,readData2out,rs_out,rt_out,rd_out);

input clk, reset,wr_IDEX,IDEXclear,contMemRead,contMemWrite,contMemtoReg,contRegWrite;
input [3:0] contimmed,IDEXopcode,rs_in,rt_in,rd_in;
input [2:0] contbranchcond;
input [8:0] contbranchoff;
input [11:0] contcalloff; 
input [15:0] readDat1,readDat2,nextPC;

output IDEXMemRead,IDEXMemWrite,IDEXMemtoReg,IDEXRegWrite;
output [3:0] opcodeOut,shiftamt,rs_out,rt_out,rd_out;
output [8:0] branchoffout;
output [2:0] branchcondout;
output [11:0] calloffsetout;
output [15:0] newPC,readData1out,readData2out;

reg MemRead,MemWrite,MemtoReg,RegWrite;
reg [3:0] opcode,shftamt,rs,rt,rd;
reg [8:0] branchoffset;
reg [2:0] branchcond;
reg [11:0] calloffset;
reg [15:0] outPC,inA,inB;

always@(posedge clk,reset)begin
	if(~reset)begin
		MemRead<=1'b0;
		MemWrite<=1'b0;
		MemtoReg<=1'b0;
		RegWrite<=1'b0;
		opcode<=4'b0000;
		shftamt<=4'b0000;
		branchoffset<=9'b000000000;
		branchcond<=3'b000;
		calloffset<=12'h000;
		inA<=16'h0000;
		inB<=16'h0000;	
		outPC<=16'h0000;
		rs<=4'b0000;
		rt<=4'b0000;
		rd<=4'b0000;
	end else if(IDEXclear) begin
		MemRead<=1'b0;
		MemWrite<=1'b0;
		MemtoReg<=1'b0;
		RegWrite<=1'b0;
		opcode<=4'b0000;
		shftamt<=4'b0000;
		branchoffset<=9'b000000000;
		branchcond<=3'b000;
		calloffset<=12'h000;
		inA<=16'h0000;
		inB<=16'h0000;	
		outPC<=16'h0000;
		rs<=4'b0000;
		rt<=4'b0000;
		rd<=4'b0000;
	end else if(wr_IDEX) begin
		MemRead<=contMemRead;
		MemWrite<=contMemWrite;
		MemtoReg<=contMemtoReg;
		RegWrite<=contRegWrite;
		opcode<=IDEXopcode;
		shftamt<=contimmed;
		branchoffset<=contbranchoff;
		branchcond<=contbranchcond;
		calloffset<=contcalloff;
		inA<=readDat1;
		inB<=readDat2;	
		outPC<=nextPC;
		rs<=rs_in;
		rt<=rt_in;
		rd<=rd_in;
	end
end

assign newPC = outPC;
assign IDEXMemRead = MemRead;
assign IDEXMemWrite = MemWrite;
assign IDEXMemtoReg = MemtoReg;
assign IDEXRegWrite = RegWrite;
assign opcodeOut = opcode;
assign shiftamt = shftamt;
assign branchoffout = branchoffset;
assign branchcondout = branchcond;
assign calloffsetout = calloffset;
assign readData1out = inA;
assign readData2out = inB;
assign rs_out = rs;
assign rt_out = rt;
assign rd_out = rd;

endmodule 