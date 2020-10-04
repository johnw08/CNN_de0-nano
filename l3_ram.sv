module l3_ram(clk, rst_n, wr, addr_wr, din, rd, addr_rd, dout);
input clk, rst_n;
input wr;
input rd;
input [4:0] addr_wr, addr_rd;
input [17:0] din;
output [17:0] dout;

reg [17:0] ram[24:0];

always @(posedge clk) begin
  if (wr)
    ram[addr_wr] <= din;
end

assign dout = rd ? ram[addr_rd] : 18'hXXXXX;
endmodule
