module l2_ram (clk, rst_n, wr, addr_wr, din, rd, addr_rd, dout);
input clk, rst_n;
input wr;
input rd;
input [6:0] addr_wr;
input [6:0] addr_rd;
input [17:0] din;
output [17:0] dout[3:0];

reg [17:0] ram[120:0];

always @(posedge clk) begin
  if (wr)
    ram[addr_wr] <= din;
end

assign dout[0] = ram[addr_rd - 7'h0C];
assign dout[1] = ram[addr_rd - 7'h0B];
assign dout[2] = ram[addr_rd - 7'h01];
assign dout[3] = ram[addr_rd];

endmodule
