module l4_ram(clk, wr, addr_wr, addr_rd, din, dout);
input clk;
input wr;
input [1:0] addr_wr;
input [1:0] addr_rd;
input [35:0] din;
output reg [35:0] dout;

reg [35:0] ram[3:0];

always @(posedge clk) begin
  if (wr)
    ram[addr_wr] <= din;
  dout <= ram[addr_rd];
end

endmodule
