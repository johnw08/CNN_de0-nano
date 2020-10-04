module l4_relu(din, dout);
input signed [35:0] din[15:0];
output [35:0] dout[15:0];

genvar i;

generate
  for (i = 0; i < 16; i++) begin: dout_for
    assign dout[i] = din[i] > 0 ? din[i] : 36'h0;
  end
endgenerate

endmodule
