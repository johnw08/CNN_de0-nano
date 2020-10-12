module l4_rom_b4 (clk, addr_rd, dout);
input clk;
input [1:0] addr_rd;
output reg [8:0] dout;

reg [8:0] rom[3:0];

initial begin
  $readmemb("l4_Weight_bias_4.txt", rom);
end

always @(posedge clk) begin
  dout <= rom[addr_rd];
end

endmodule
