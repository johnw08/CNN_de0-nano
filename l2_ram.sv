module l2_ram (clk, wr, addr_wr, addr_rd, din, dout);
input clk;
input wr;
input [6:0] addr_wr;
input [6:0] addr_rd;
input [17:0] din;
output reg [17:0] dout;

reg [17:0] ram[120:0];

always @(posedge clk) begin
  if (wr)
    ram[addr_wr] <= din;
  dout <= ram[addr_rd];
end

endmodule
