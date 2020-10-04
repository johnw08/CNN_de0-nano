module l4_add(din, bias, dout);
input [35:0] din[15:0];
input [8:0] bias[15:0];
output [35:0] dout[15:0];
genvar i;

generate
  for (i = 0; i < 16; i++) begin: dout_for
    assign dout[i] = din[i] + {{27{bias[i][8]}}, bias[i][8:0]};
  end
endgenerate

endmodule
