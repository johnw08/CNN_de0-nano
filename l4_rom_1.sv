module l4_rom_1 (clk, addr, dout);
input clk;
input [5:0] addr;
output reg [8:0] dout[15:0];

reg [8:0] rom[63:0];

initial begin
  $readmemb("l4_Weight_bias.txt", rom);
end

always @(posedge clk) begin
  dout[0] <= rom[addr];
  dout[1] <= rom[addr + 13'h1];
  dout[2] <= rom[addr + 13'h2];
  dout[3] <= rom[addr + 13'h3];
  dout[4] <= rom[addr + 13'h4];
  dout[5] <= rom[addr + 13'h5];
  dout[6] <= rom[addr + 13'h6];
  dout[7] <= rom[addr + 13'h7];
  dout[8] <= rom[addr + 13'h8];
  dout[9] <= rom[addr + 13'h9];
  dout[10] <= rom[addr + 13'hA];
  dout[11] <= rom[addr + 13'hB];
  dout[12] <= rom[addr + 13'hC];
  dout[13] <= rom[addr + 13'hD];
  dout[14] <= rom[addr + 13'hE];
  dout[15] <= rom[addr + 13'hF];
end

endmodule
