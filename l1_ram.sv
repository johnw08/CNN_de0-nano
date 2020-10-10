module l1_ram(clk, wr, addr_wr, addr_rd,  din, dout);
  input clk;
  input wr;
  input [7:0] addr_wr;
  input [7:0] addr_rd;
  input [17:0] din;
  output reg [17:0] dout;

  reg [17:0] ram[168:0];

  always @(posedge clk) begin
    if (wr)
      ram[addr_wr] <= din;
    dout <= ram[addr_rd];
  end
/*
  assign dout[0] = ram[addr_rd - 8'h1C];
  assign dout[1] = ram[addr_rd - 8'h1B];
  assign dout[2] = ram[addr_rd - 8'h1A];
  assign dout[3] = ram[addr_rd - 8'h0F];
  assign dout[4] = ram[addr_rd - 8'h0E];
  assign dout[5] = ram[addr_rd - 8'h0D];
  assign dout[6] = ram[addr_rd - 8'h02];
  assign dout[7] = ram[addr_rd - 8'h01];
  assign dout[8] = ram[addr_rd];
*/
endmodule
