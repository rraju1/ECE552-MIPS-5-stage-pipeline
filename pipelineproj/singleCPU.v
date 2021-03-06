module singleCPU (input clk,input rst_n , output [15:0] pc,output halt);

	//keep
	wire[15:0] PC;
	assign pc = PC;
	wire aluN,aluZ,aluV;
	wire N,Z,V;

	wire [15:0] instruction;
	wire [15:0] rf_wrData; 
	wire [15:0] rf_data1,rf_data2;

	wire [15:0] alu_outData;



	//control signals for the PC
	reg updatePC,haltpc;
	reg[15:0] newPC;
	wire [15:0] inPC,EXMEMpc;
	wire PCwr;
	//updateOC will come from hazard control and newPC will come from EXMEM
	wire [3:0] EXMEMopcode,MEMWBopcode;//halt
	
	PC inspc (.clk(clk),.rst_n(rst_n),.halt(haltpc),.newPC(inPC),.wr_en(PCwr),.PC(PC));
	
	//control signals for IM
	wire IMen;
	IM insIM(.clk(clk),.addr(PC),.rd_en(IMen),.instr(instruction));

	//control signals for the IFID pipeline register
	wire wrIFID,IFIDclear;
	wire [15:0] instruct,IFIDpc;
	IFIDreg insIFID(.clk(clk),.reset(rst_n),.wr_IFID(wrIFID),.IFIDclear(IFIDclear),.inputIM(instruction),
			.nextPC(PC+1'b1),.instruct(instruct),.newPC(IFIDpc));//need current PC +1
	//control signals for controller
	wire [3:0] opcode;
	wire MemWrite,MemRead,RegWrite,MemtoDist;
	controller inscontrol(.instruct(instruct),.MemWrite(MemWrite),.MemRead(MemRead),.RegWrite(RegWrite),.MemtoDist(MemtoDist),.opcode(opcode));
	
	//control for the register file
	wire [3:0] MEMWBrd;
	wire MEMWBRegWrite;

	wire[3:0] rf_addr1, rf_addr2;
	assign rf_addr1 = ((instruct[15:12] == 4'b1010)) ? instruct[11:8] : instruct[7:4];
	assign rf_addr2 =  ((instruct[15:12] == 4'b1001)) ? instruct[11:8] : instruct[3:0];
	assign halt = (MEMWBopcode==4'b1111)? 1:0;

	rf rfIns (.clk(clk),.p0_addr(rf_addr1),
		  .p1_addr(rf_addr2),
		  .p0(rf_data1),
		  .p1(rf_data2),
		  .re0(1'b1),.re1(1'b1),//for power not functionality?
		  .dst_addr(MEMWBrd),
		  .dst(rf_wrData), //should be data from MemtoReg mux
		  .we(MEMWBRegWrite), //regwrite from MEMWB reg
		  .hlt(halt));

	//control signals for IDEX
	wire wrIDEX,IDEXclear,IDEXMemRead,IDEXMemWrite,IDEXMemtoReg,IDEXRegWrite;
	wire [15:0] IDEXpc,readData1out,readData2out;
	wire [3:0] shiftamt,IDEXrs,IDEXrt,IDEXrd,IDEXopcode,rd_in_or_15;
	wire [2:0] branchcondout;
	wire [8:0] branchoffout;
	wire [11:0] calloffsetout;

	assign rd_in_or_15 = (instruct[15:12] == 4'b1101) ? 4'd15 : instruct[11:8]; //choose rd as 15 if instruc is call or else pass regualr rd 
	//re-evaluate how rt is chosen
	IDEXreg insIDEXreg (.clk(clk),.reset(rst_n),.wr_IDEX(wrIDEX),.IDEXclear(IDEXclear),.IDEXopcode(opcode),.contbranchcond(instruct[11:9]),
			.contbranchoff(instruct[8:0]),.contcalloff(instruct[11:0]),.contMemRead(MemRead),.contMemWrite(MemWrite),.contMemtoReg(MemtoDist),
			.contRegWrite(RegWrite),.contimmed(instruct[3:0]),.readDat1(rf_data1),.readDat2(rf_data2),.nextPC(IFIDpc),
			.rs_in(((instruct[15:12] == 4'b1010)) ? instruct[11:8] : instruct[7:4]),.rt_in(instruct[3:0]),.rd_in(rd_in_or_15),.opcodeOut(IDEXopcode),.newPC(IDEXpc),
			.branchcondout(branchcondout),.branchoffout(branchoffout),.calloffsetout(calloffsetout),.IDEXMemRead(IDEXMemRead),.IDEXMemWrite(IDEXMemWrite),.IDEXMemtoReg(IDEXMemtoReg),
			.IDEXRegWrite(IDEXRegWrite),.shiftamt(shiftamt),.readData1out(readData1out),.readData2out(readData2out),.rs_out(IDEXrs),.rt_out(IDEXrt),.rd_out(IDEXrd));

	//control signals for forwarding unit
	wire EXMEMRegWrite;
	wire [3:0] EXMEMrd;
	wire [1:0] forA, forB;
	forwardUnit fwdUnitIns (.IDEXrs(IDEXrs),.IDEXrt(IDEXrt),.EXMEMrd(EXMEMrd),.EXMEMregWrite(EXMEMRegWrite),.MEMWBrd(MEMWBrd),
				.MEMWBregWrite(MEMWBRegWrite),.forA(forA),.forB(forB));
	//signals for mux to input of alu
	wire [15:0] EXMEMout,inputEXMEMdata,alu1Input,alu2Input;
	assign alu1Input = (forA == 2'b10)? EXMEMout : (forA == 2'b01)? rf_wrData : readData1out;
	assign alu2Input =  (forB == 2'b10)? EXMEMout : (forB == 2'b01)? rf_wrData : readData2out;


	ALU 		alu	(.in1(alu1Input),.in2(alu2Input), .imm(shiftamt) ,  .opcode(IDEXopcode[2:0]) , 
				 .out(alu_outData) , .N(aluN),.Z(aluZ),.V(aluV));
		
	
	flag_register	flgReg 	(.clk(clk),.rst_n(rst_n) ,.iZ(aluZ),.iN(aluN),.iV(aluV) , .opcode(IDEXopcode) , .N(N),.Z(Z),.V(V));

	assign inputEXMEMdata = (IDEXopcode == 4'b1011)? {{(16-8){branchoffout[7]}},branchoffout[7:0]}: //for LLB, didn't pass instruction so pass 8 lower bits of branch offset
				(IDEXopcode == 4'b1010)? {branchoffout[7:0] , readData1out[7:0]}: // for LHB
				(IDEXopcode == 4'b1000)? alu1Input + { {(16-3){shiftamt[3]}} , shiftamt[3:0] }:// for lw
				(IDEXopcode == 4'b1001)? alu1Input + { {(16-3){shiftamt[3]}} , shiftamt[3:0] }:
				(IDEXopcode == 4'b1101)? IDEXpc : //call
				alu_outData; //alu_output data

	//route branch into EXMEM pipeline
	reg branchConditionIsTrue; //check if branch is true
	//mux for choosing address for PC
	always@(*) begin
		updatePC	= 0;
		newPC		= 0;
		haltpc		= 0;
		//option branch cond.
		case(IDEXopcode) 
			4'b1100: begin// B instruction
				if(branchConditionIsTrue) begin
					updatePC	= 1;
					newPC		= IDEXpc + branchoffout; 
				end
			end
			4'b1101: begin//Call instruction
				updatePC	= 1;
				newPC		= IDEXpc + calloffsetout; 
			end
			4'b1110: begin//ret instruction
				updatePC	= 1;
				newPC		= readData1out; 
			end
			4'b1111: haltpc = 1;
		endcase
		
	end

	//keep this for branch think this is okay
	always@(*) begin
		branchConditionIsTrue = 0;
		casex(    {N,Z,V , branchcondout}) // rows of table 1
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
	
	//signals for EXMEMreg
	wire wrEXMEM,EXMEMclear,PCsrc,EXMEMmemRead,EXMEMmemWrite,EXMEMmemtoReg;
	
	wire[15:0] dataMemWrData;

	EXMEMreg EXMEMIns (.clk(clk),.reset(rst_n),.wr_EXMEM(wrEXMEM),.EXMEMclear(EXMEMclear),.IDEXMemRead(IDEXMemRead),.IDEXMemWrite(IDEXMemWrite),
			   .IDEXMemtoReg(IDEXMemtoReg),.IDEXRegWrite(IDEXRegWrite),.alu_out(inputEXMEMdata),.wrDataIn(alu2Input),.rd_in(IDEXrd),.IDEXopcode(IDEXopcode),
			   .nextPC(newPC),.PCjump(updatePC),.newPC(EXMEMpc),.PCsrc(PCsrc),.EXMEMmemRead(EXMEMmemRead),.EXMEMmemWrite(EXMEMmemWrite),
			   .EXMEMmemtoReg(EXMEMmemtoReg),.EXMEMRegWrite(EXMEMRegWrite),.dataAddr(EXMEMout),.wrDataOut(dataMemWrData),.rd_out(EXMEMrd),.EXMEMopcode(EXMEMopcode));

	//signals for Data Memory
	wire [15:0] dtMemReadData; 
	DM 	dtMem	(.clk(clk),.addr(EXMEMout),.re(EXMEMmemRead),.we(EXMEMmemWrite),.wrt_data(dataMemWrData),.rd_data(dtMemReadData));

	//signals for MEMWBreg
	wire wrMEMWB,MEMWBclear,MEMWBMemtoReg;
	wire [15:0] alu_res, dataMemresl;
	
	MEMWBreg MEMWBregIns (.clk(clk),.reset(rst_n),.wr_MEMWB(wrMEMWB),.MEMWBclear(MEMWBclear),.EXMEMmemtoReg(EXMEMmemtoReg),
			      .EXMEMRegWrite(EXMEMRegWrite),.alu_out(EXMEMout),.dataMemOut(dtMemReadData),.rd_in(EXMEMrd),.EXMEMopcode(EXMEMopcode),
			       .MEMWBMemtoReg(MEMWBMemtoReg),.MEMWBRegWrite(MEMWBRegWrite),.dataAddr(alu_res),.wrDataOut(dataMemresl),.rd_out(MEMWBrd),.MEMWBopcode(MEMWBopcode));

	//route back to reg file
	assign rf_wrData = (MEMWBMemtoReg)? dataMemresl : alu_res;

	// detection unit
	HazardDec HazDecIns (.IFIDrs(((instruct[15:12] == 4'b1010)) ? instruct[11:8] : instruct[7:4]),
			     .IFIDrt(((instruct[15:12] == 4'b1001)) ? instruct[11:8] : instruct[3:0]),
			     .IDEXrd(IDEXrd),.PCsrc(PCsrc),.IDEXMemRead(IDEXMemRead),.IDEXRegWrite(IDEXRegWrite),
		 	     .IM_read(IMen),.wr_pc(PCwr),.IFID_clear(IFIDclear),.wr_IFID(wrIFID),.IDEX_clear(IDEXclear),.wr_IDEX(wrIDEX),
		 	     .EXMEM_clear(EXMEMclear),.wr_EXMEM(wrEXMEM),.MEMWB_clear(MEMWBclear),.wr_MEMWB(wrMEMWB));

	assign inPC = (PCsrc)? EXMEMpc : PC + 1'b1;

endmodule
