module flag_register(input clk,rst_n ,input iZ,iN,iV , input [3:0] opcode , output reg N,Z,V);

	always@(posedge clk) begin
		if(~rst_n)
			{N,Z,V} <= 0;
		else begin
			if(opcode == 3'b0000 || opcode == 3'b0010)
				{V,N} <= {iV,iN};
			if(opcode[3] == 0)
				{Z} <= {iZ};
		end
	end


endmodule
