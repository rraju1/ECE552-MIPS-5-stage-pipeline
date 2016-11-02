module satAdder #(parameter WIDTH = 8)(input signed [WIDTH-1:0] a,b,output reg signed [WIDTH-1:0] out , output overFlowFlag);


	wire [WIDTH-1:0] s;
	assign s = a+b;
	assign overFlowFlag = ((a[WIDTH-1])&(b[WIDTH-1])&(~s[WIDTH-1])) | 
			      ((~a[WIDTH-1])&(~b[WIDTH-1])&(s[WIDTH-1]));

	always@(*) begin
		if(overFlowFlag)
			out = (a[WIDTH-1]) ? -(1<<15) : (1<<15)-1 ;
		else
			out = s;

	end

endmodule
