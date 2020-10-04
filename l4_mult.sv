module l4_mult(din, weight, dout);
input signed [17:0] din;
input signed [8:0] weight[15:0];
output [35:0] dout[15:0];
wire signed [17:0] prod[15:0];
genvar i, j;

generate
  for (i = 0; i < 16; i++) begin: prod_for
    assign prod[i] = din * weight[i];
  end
endgenerate

generate
  for (j = 0; j < 16; j++) begin: dout_for
    assign dout[j] = {{18{prod[j][17]}}, prod[j][17:0]};
  end
endgenerate


endmodule
