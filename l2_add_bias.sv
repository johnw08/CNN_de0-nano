module l2_add_bias (din, bias, dout);
input [35:0] din;
input [8:0] bias;
output [35:0] dout;

assign dout = din + {{27{bias[8]}}, bias[8:0]};

endmodule
