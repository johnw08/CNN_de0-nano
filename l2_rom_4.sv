module l2_rom_4 (clk, dout);
  input clk;
  output reg [8:0] dout[3:0];

  reg [8:0] rom[3:0];

  initial begin
    $readmemb("l2_Weight_bias.txt", rom);
  end

  always @(posedge clk) begin
    dout[0] <= rom[0];
    dout[1] <= rom[1];
    dout[2] <= rom[2];
    dout[3] <= rom[3];
  end

endmodule
