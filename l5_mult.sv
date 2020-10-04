module l5_mult(din, weight, dout);
input signed [17:0] din[31:0];
input signed [8:0] weight[31:0];
output [35:0] dout;

wire signed [35:0] prod[31:0];

genvar i;

generate
  for (i = 0; i < 32; i++) begin: prod_for
  	assign prod[i] = din[i] * weight[i];
  end
endgenerate

assign dout = prod[0] + prod[1] + prod[2] + prod[3] + prod[4] +
prod[5] + prod[6] + prod[7] + prod[8] + prod[9] + prod[10] +
prod[11] + prod[12] + prod[13] + prod[14] + prod[15] + prod[16] +
prod[17] + prod[18] + prod[19] + prod[20] + prod[21] + prod[22] +
prod[23] + prod[24] + prod[25] + prod[26] + prod[27] + prod[28] +
prod[29] + prod[30] + prod[31];

endmodule
