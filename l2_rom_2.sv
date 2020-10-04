module l2_rom_2 (clk, addr, dout);
  input clk;
  input [4:0] addr;
  output reg [8:0] dout[2:0];

  reg [8:0] rom[17:0];

  initial begin
    $readmemb("l2_Weight_2.txt", rom);
  end

  always @(posedge clk) begin
    dout[0] <= rom[addr];
    dout[1] <= rom[addr + 5'h1];
    dout[2] <= rom[addr + 5'h2];
  end

endmodule
