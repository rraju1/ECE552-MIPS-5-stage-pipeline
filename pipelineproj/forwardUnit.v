module forwardUnit(IDEXrs,IDEXrt,EXMEMrd,EXMEMregWrite,
		   MEMWBrd,MEMWBregWrite,forA,forB);

input EXMEMregWrite,MEMWBregWrite;
input [3:0] IDEXrs,IDEXrt,EXMEMrd,MEMWBrd;

output [1:0] forA,forB;

//check the conditions if need to forward data and set the forwarding signal accordingly for rs (port 1 of ALU)
assign forA = (EXMEMregWrite && (EXMEMrd != 4'b0000) && (EXMEMrd==IDEXrs))? 10 :
	      (MEMWBregWrite && (MEMWBrd != 4'b0000) && (MEMWBrd==IDEXrs))? 01 : 00;
//check the conditions if need to forward data and set the forwarding signal accordingly for rt (port 2 of ALU)
assign forB = (EXMEMregWrite && (EXMEMrd != 4'b0000) && (EXMEMrd==IDEXrt))? 10 :
	      (MEMWBregWrite && (MEMWBrd != 4'b0000) && (MEMWBrd==IDEXrt))? 01 : 00;


endmodule
