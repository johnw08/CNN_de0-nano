module l5_relu(din, dout);
input signed [35:0] din;
output [17:0] dout;

assign dout = din > 0 ? din[17:0] : 18'h0;

endmodule
