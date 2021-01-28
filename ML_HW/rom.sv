module rom (clk, addr_rd, dout);
  parameter file = "";
  parameter ADDR_WIDTH;
  parameter DATA_WIDTH;
  input clk;
  input [ADDR_WIDTH-1:0] addr_rd;
  output reg [DATA_WIDTH-1:0] dout;

  reg [DATA_WIDTH-1:0] rom[2**ADDR_WIDTH-1:0];

  initial begin
    $readmemb(file, rom);
  end

  always @(posedge clk) begin
    dout <= rom[addr_rd];
  end

endmodule
