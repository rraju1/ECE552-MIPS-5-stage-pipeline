module HazardDec(IFIDrs,IFIDrt,IDEXrd,PCsrc,IDEXMemRead,IDEXRegWrite,
		 IM_read,wr_pc,IFID_clear,wr_IFID,IDEX_clear,wr_IDEX,
		 EXMEM_clear,wr_EXMEM,MEMWB_clear,wr_MEMWB);

input PCsrc,IDEXMemRead,IDEXRegWrite;
input [3:0] IFIDrs,IFIDrt,IDEXrd;

output wr_pc,IM_read,IFID_clear,wr_IFID,IDEX_clear,wr_IDEX,
	 EXMEM_clear,wr_EXMEM,MEMWB_clear,wr_MEMWB;

reg jump, IMread, IFflush, IFwr, IDflush, IDwr,
	EXflush, EXwr, MEMflush,MEMwr;

initial begin
		#25
		jump = 1'b1; //enable all writes
		IMread = 1'b1;
		IFwr = 1'b1;
end 

//be on alert for any signal
always @ (PCsrc,IDEXMemRead,IDEXRegWrite,IFIDrs,IFIDrt,IDEXrd)
begin
	//check for control hazard first
	if(PCsrc)begin
	/* Need to flush IFID and IDEX pipelines
	   Disable writes to EXMEM just to ensure data from IDEX can't access that register
	   Let MEMWB register propogate values
	*/
		jump = 1'b1;
		IMread = 1'b1;
		IFflush = 1'b1;
		IDflush = 1'b1;
		MEMwr = 1'b1;
		EXwr = 1'b0;
	/* Next deal with Load Use Hazards
	   In this case, stall the pipeline for 1 cycle based on IDEX.MemRead		
	*/
	end else if(IDEXMemRead && IDEXRegWrite && ((IFIDrs == IDEXrd)||(IFIDrt==IDEXrd)))begin
	// Stall the pipeline
		EXwr = 1'b1;
		MEMwr = 1'b1;
		jump = 1'b0;//stall PC
		IFwr = 1'b0;
		IDflush = 1'b1; //flush IDEX
		IMread = 1'b0;
	end else begin
	// Normal operation
	// Note: EX hazards that are not load use will be handled by forwarding unit
		IFflush = 1'b0; //want to deassert all clear signals in case of no hazards
		IDflush = 1'b0;
		EXflush = 1'b0;
		MEMflush = 1'b0;
		jump = 1'b1; //enable all writes
		IMread = 1'b1;
		IFwr = 1'b1;
		IDwr = 1'b1;
		EXwr = 1'b1;
		MEMwr = 1'b1;
	end
end

assign wr_pc = jump;//control sig to write to PC
assign IM_read = IMread; //control for IM 
assign IFID_clear = IFflush; //flush instruction in IF phase
assign wr_IFID = IFwr; 
assign IDEX_clear = IDflush;
assign wr_IDEX = IDwr;
assign EXMEM_clear = EXflush;
assign wr_EXMEM = EXwr;
assign MEMWB_clear = MEMflush;
assign wr_MEMWB = MEMwr;

endmodule 
