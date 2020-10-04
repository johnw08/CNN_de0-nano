module cnn_ram_input(clk, rst_n, en, rd, din, addr_wr, addr_rd, dout);
  input clk, rst_n, en, rd;
  input [7:0] din;
  input [9:0] addr_wr;
  input [9:0] addr_rd;
  output [1:0] dout[8:0];

  reg [1:0] ram[783:0];

  always@(posedge clk) begin
    if (en) begin
      ram[addr_wr] <= {din[0], din[0]};
      ram[addr_wr + 10'h001] <= {din[1], din[1]};
      ram[addr_wr + 10'h002] <= {din[2], din[2]};
      ram[addr_wr + 10'h003] <= {din[3], din[3]};
      ram[addr_wr + 10'h004] <= {din[4], din[4]};
      ram[addr_wr + 10'h005] <= {din[5], din[5]};
      ram[addr_wr + 10'h006] <= {din[6], din[6]};
      ram[addr_wr + 10'h007] <= {din[7], din[7]};
    end
  end

  assign dout[0] = ram[addr_rd - 10'h03A];
  assign dout[1] = ram[addr_rd - 10'h039];
  assign dout[2] = ram[addr_rd - 10'h038];
  assign dout[3] = ram[addr_rd - 10'h01E];
  assign dout[4] = ram[addr_rd - 10'h01D];
  assign dout[5] = ram[addr_rd - 10'h01C];
  assign dout[6] = ram[addr_rd - 10'h002];
  assign dout[7] = ram[addr_rd - 10'h001];
  assign dout[8] = ram[addr_rd];

endmodule
