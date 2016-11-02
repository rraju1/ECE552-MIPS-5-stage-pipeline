module PC (clk,rst_n,halt, newPC ,wr_en,PC);
	
	input clk,rst_n,halt,wr_en;

	input [15:0] newPC;
	
	output [15:0] PC;

	reg [15:0] PC_reg;

	always@(posedge clk)	begin
		if(~rst_n)
			PC_reg <= 0;
		else begin
			if(wr_en)begin
				if(halt)
					PC_reg <= PC_reg;
				else 
					PC_reg <= newPC;				
			end 
		end
	end

	assign PC = PC_reg;

endmodule
