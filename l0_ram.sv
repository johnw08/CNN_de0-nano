module l0_ram (clk, wr, addr_wr, addr_rd, din, dout);
input clk;
input wr;
input [9:0] addr_wr;
input [9:0] addr_rd;
input [17:0] din;
output reg [17:0] dout;

reg [17:0] ram[675:0];

always @(posedge clk) begin
  if (wr)
    ram[addr_wr] <= din;
  dout <= ram[addr_rd];
end

/*
assign dout[0] = ram[addr_rd - 10'h1B];
assign dout[1] = ram[addr_rd - 10'h1A];
assign dout[2] = ram[addr_rd - 10'h01];
assign dout[3] = ram[addr_rd];
*/
endmodule
