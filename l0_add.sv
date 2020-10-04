module l0_add (din, bias, dout);
input [17:0] din;
input [8:0] bias;
output [17:0] dout;

assign dout = din + {{9{bias[8]}}, bias[8:0]};

endmodule // l0_add
