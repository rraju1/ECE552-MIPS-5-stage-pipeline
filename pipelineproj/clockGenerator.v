module clockGenerator(clk,reset_n);
	output reg clk,reset_n;
	initial begin 
		clk 	= 	0;
		forever #5 clk = ~clk;
	end	

	initial begin
		reset_n = 0;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		reset_n =1;
	end

endmodule
