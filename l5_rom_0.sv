module l5_rom_0(clk, addr, dout);
input clk;
input [9:0] addr;
output reg [8:0] dout[31:0];

reg [8:0] rom[639:0];
integer i;

initial begin
  $readmemb("l5_Weight.txt", rom);
end

always @(posedge clk) begin
  for (i = 0; i < 32; i++) begin
    dout[i] <= rom[addr + i];
  end
end

endmodule
