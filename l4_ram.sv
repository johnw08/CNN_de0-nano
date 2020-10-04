module l4_ram(clk, wr, addr_wr, din, dout, dout_wr);
input clk;
input wr;
input [5:0] addr_wr;
input [35:0] din[15:0];
output [17:0] dout[63:0];
output [35:0] dout_wr[15:0];

reg [35:0] ram[63:0];
genvar i, j;

initial begin
  $readmemb("l4_ram.txt", ram);
end

always @(posedge clk) begin
  if (wr) begin
    ram[addr_wr] <= din[0];
    ram[addr_wr + 6'h1] <= din[1];
    ram[addr_wr + 6'h2] <= din[2];
    ram[addr_wr + 6'h3] <= din[3];
    ram[addr_wr + 6'h4] <= din[4];
    ram[addr_wr + 6'h5] <= din[5];
    ram[addr_wr + 6'h6] <= din[6];
    ram[addr_wr + 6'h7] <= din[7];
    ram[addr_wr + 6'h8] <= din[8];
    ram[addr_wr + 6'h9] <= din[9];
    ram[addr_wr + 6'hA] <= din[10];
    ram[addr_wr + 6'hB] <= din[11];
    ram[addr_wr + 6'hC] <= din[12];
    ram[addr_wr + 6'hD] <= din[13];
    ram[addr_wr + 6'hE] <= din[14];
    ram[addr_wr + 6'hF] <= din[15];
  end
end

generate
  for (i = 0; i < 64; i++) begin: dout_for
    assign dout[i] = ram[i][17:0];
  end
endgenerate

generate
  for (j = 0; j < 16; j++) begin: dout_wr_for
    assign dout_wr[j] = ram[addr_wr + j];
  end
endgenerate




endmodule
