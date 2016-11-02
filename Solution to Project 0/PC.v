module PC (clk,rst_n,halt, newPC , updatePC , increamentPC,PC);
	
	input clk,rst_n,halt;

	input updatePC , increamentPC;
	input [15:0] newPC;
	
	output [15:0] PC;

	reg [15:0] PC_reg;

	always@(posedge clk)	begin
		if(~rst_n)
			PC_reg <= 0;
		else begin
			if(halt)
				PC_reg <= PC_reg;
			else if(increamentPC)
				PC_reg <= PC_reg +1;
			else if(updatePC)
				PC_reg <= newPC;
		end
	end

	assign PC = PC_reg;

endmodule
