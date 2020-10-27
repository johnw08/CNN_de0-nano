module l4_rom_b (clk, addr_rd, dout);
input clk;
input [1:0] addr_rd;
output reg [8:0] dout;
parameter file = "";

reg [8:0] rom[3:0];

initial begin
  $readmemb(file, rom);
end

always @(posedge clk) begin
  dout <= rom[addr_rd];
end

endmodule
