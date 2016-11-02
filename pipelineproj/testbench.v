module testbench();

	// Clock Generator instantiation
	wire clk;
	wire reset_n;
	clockGenerator clkGenInst(.clk(clk) , .reset_n(reset_n));


	wire halt;
	singleCPU dut(.clk(clk) , .rst_n(reset_n) , .halt(halt),.pc());
	
	initial begin
		#50;
		@(posedge halt)
		
		$writememh("dump.v",dut.rfIns.mem);
		$stop;
	end

endmodule
