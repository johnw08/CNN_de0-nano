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

assign dout[0] = rd ? ram[addr_rd - 7'h0C] : 18'hXXXX;
assign dout[1] = rd ? ram[addr_rd - 7'h0B] : 18'hXXXX;
assign dout[2] = rd ? ram[addr_rd - 7'h01] : 18'hXXXX;
assign dout[3] = rd ? ram[addr_rd] : 18'hXXXX;

endmodule
