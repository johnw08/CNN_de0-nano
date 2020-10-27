module l0_rom_b (clk, dout_0, dout_1);
  input clk;
  output reg [8:0] dout_0, dout_1;

  reg [8:0] rom[1:0];

  initial begin
    $readmemb("l0_B.txt", rom);
  end

  always @(posedge clk) begin
    dout_0 <= rom[0];
    dout_1 <= rom[1];
  end

endmodule // l0_rom_3
