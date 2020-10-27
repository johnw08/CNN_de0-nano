module l2_rom_b (clk, dout_0, dout_1, dout_2, dout_3);
  input clk;
  output reg [8:0] dout_0;
  output reg [8:0] dout_1;
  output reg [8:0] dout_2;
  output reg [8:0] dout_3;

  reg [8:0] rom[3:0];

  initial begin
    $readmemb("l2_B.txt", rom);
  end

  always @(posedge clk) begin
    dout_0 <= rom[0];
    dout_1 <= rom[1];
    dout_2 <= rom[2];
    dout_3 <= rom[3];
  end

endmodule
