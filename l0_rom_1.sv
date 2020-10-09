module l0_rom_1 (clk, addr_rd, dout);
  input clk;
  input [3:0] addr_rd;
  output reg [8:0] dout;

  reg [8:0] rom[15:0];

  initial begin
    $readmemb("l0_Weight_1.txt", rom);
  end

  always @(posedge clk) begin
    dout <= rom[addr_rd];
  end

endmodule
