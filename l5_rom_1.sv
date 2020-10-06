module l5_rom_1(clk, dout);
input clk;
output reg [8:0] dout[9:0];

reg [8:0] rom[9:0];
integer i;

initial begin
  $readmemb("l5_Weights_bias.txt", rom);
end

always @(posedge clk) begin
  for (i = 0; i < 10; i++) begin
    dout[i] <= rom[i];
  end
end

endmodule
