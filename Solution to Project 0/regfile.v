module regfile (
		readAdr1,readAdr2,readData1,readData2,
		writeEn,writeAdr,writeData);

	
	input [3:0] readAdr1,readAdr2;
	
	input writeEn;
	input [3 :0] writeAdr;
	input [15:0] writeData;	
	
	output [15:0] readData1,readData2;

	

	reg [15:0] rf [0:15];

	always @(*)	begin
		if(writeEn)	begin
			#1; rf[writeAdr] = writeData;
			rf[0] = 0;
		end
		
	end
	assign readData1 = rf[readAdr1];
	assign readData2 = rf[readAdr2];
	integer i;
	initial begin 
		for(i=0;i<=15;i=i+1)
			rf[i] = 0;
	end
endmodule
