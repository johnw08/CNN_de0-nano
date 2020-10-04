module l0_relu (din, dout);
  input signed [17:0] din;
  output [17:0] dout;

  assign dout = din > 0 ? din : 18'h0;
endmodule // relu
