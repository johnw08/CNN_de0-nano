module ram(clk, wr, din, addr_wr, addr_rd, dout);
  parameter ADDR_WIDTH;
  parameter DATA_WIDTH;
  input clk;
  input wr;
  input [ADDR_WIDTH-1:0] addr_wr;
  input [ADDR_WIDTH-1:0] addr_rd;
  input [DATA_WIDTH-1:0] din;
  output reg [DATA_WIDTH-1:0] dout;

  reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];

  always @(posedge clk) begin
    if (wr)
      ram[addr_wr] <= din;
    dout <= ram[addr_rd];
  end

endmodule
