module l2_mult (din, weight, dout);
input signed [17:0] din[2:0];
input signed [8:0] weight[2:0];
output [35:0] dout;

wire signed [35:0] m0, m1, m2;

assign m0 = din[0] * weight[0];
assign m1 = din[1] * weight[1];
assign m2 = din[2] * weight[2];

assign dout = m0 + m1 + m2;

endmodule 
