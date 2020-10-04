module l0_rom_1 (clk, addr, dout);
  input clk;
  input [3:0] addr;
  output reg [8:0] dout[2:0];

  reg [8:0] rom[8:0];

  initial begin
    $readmemb("l0_Weight_1.txt", rom);
  end

  always @(posedge clk) begin
    dout[0] <= rom[addr];
    dout[1] <= rom[addr + 4'h1];
    dout[2] <= rom[addr + 4'h2];
  end

endmodule // l0_rom_1
