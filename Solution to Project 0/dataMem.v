module dataMem( adr,readData,writeEn,writeData );
	
	input [15:0] adr;
	input [15:0] writeData;
	input writeEn;
	output reg [15:0]	readData;

	reg [15:0] mem [0:(1<<15)];
	
	always @ (*) begin
	
		if(writeEn) begin
			#1; mem[adr] = writeData;
		end

		readData = mem[adr];
		
	end

	integer i;
	initial begin 
		for(i=0;i<(1<<15);i=i+1)
			mem[i] = 0;
	end

endmodule 
