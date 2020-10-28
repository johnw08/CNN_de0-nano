module rst_synch(RST_n, clk, rst_n);

	input clk, RST_n;
	
	output rst_n;

	reg ff_1, ff_2;
	
	always @(negedge clk, negedge RST_n)
		if(!RST_n)
			ff_1 <= 1'b0;
		else
			ff_1 <= 1'b1;
	
	always @(negedge clk, negedge RST_n)
		if(!RST_n)
			ff_2 <= 1'b0;
		else
			ff_2 <= ff_1;
	
	assign rst_n = ff_2;

endmodule