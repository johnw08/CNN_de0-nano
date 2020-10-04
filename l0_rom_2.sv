module l0_rom_2 (clk, dout);
  input clk;
  output reg [8:0] dout[1:0];

  reg [8:0] rom[1:0];

  initial begin
    $readmemb("l0_Weight_bias.txt", rom);
  end

  always @(posedge clk) begin
    dout[0] <= rom[0];
    dout[1] <= rom[1];
  end

endmodule // l0_rom_3
