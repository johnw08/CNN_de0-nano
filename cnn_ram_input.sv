module cnn_ram_input(clk, wr, din, addr_wr, addr_rd, dout);
  input clk;
  input wr;
  input din;
  input [9:0] addr_wr;
  input [9:0] addr_rd;
  output reg dout;

  reg ram[783:0];

  always @(posedge clk) begin
    if (wr)
      ram[addr_wr] <= din;
    dout <= ram[addr_rd];
  end

endmodule
