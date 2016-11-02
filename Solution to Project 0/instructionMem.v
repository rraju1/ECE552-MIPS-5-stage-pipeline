module instructionMem( readAdr,readData);
	
	input [15:0] readAdr;
	output reg [15:0]	readData;

	reg [15:0] mem [0:(1<<15)];
	
	always @ (*) begin
		readData = mem[readAdr];
	end

	integer i;
	initial begin 
		for(i=0;i<(1<<15);i=i+1)
			mem[i] = 0;
		$readmemb("instruction.list", mem);
	end

endmodule 
