module cnn_core(clk, rst_n, strt, tx_done, din, bsy, trmt, dout, addr);
  input clk, rst_n;
  input strt;
  input tx_done;
  input din;
  input [9:0] addr;
  output bsy;
  output trmt;
  output [7:0] dout;

  wire rdy_l0;
  wire [17:0] dout_l0_0, dout_l0_1;

  wire bsy_in_l1;
  wire rdy_l1;
  wire [17:0] dout_l1_0, dout_l1_1;

  wire rdy_l2;
  wire [17:0] dout_l2;

  wire rdy_l3;
  wire [17:0] dout_l3;

  wire rdy_l4;
  wire [17:0] dout_l4[15:0];

  layer_0 conv_0(.clk(clk),.rst_n(rst_n),.strt(strt),.din(din),.tx_done(trmt),
                .bsy_out(bsy),.rdy(rdy_l0),.dout_0(dout_l0_0),.dout_1(dout_l0_1));

  layer_1 max_0(.clk(clk), .rst_n(rst_n), .strt(rdy_l0), .din_0(dout_l0_0)
              , .din_1(dout_l0_1), .tx_done(trmt), .bsy_in(bsy_in_l1)
              , .rdy(rdy_l1), .dout_0(dout_l1_0), .dout_1(dout_l1_1));

  layer_2 conv_1(.clk(clk), .rst_n(rst_n), .strt(rdy_l1), .tx_done(trmt)
               , .din_0(dout_l1_0), .din_1(dout_l1_1), .bsy_out(bsy_in_l1)
               , .dout(dout_l2), .rdy(rdy_l2));

  layer_3 max_1(.clk(clk), .rst_n(rst_n), .strt(rdy_l2), .din(dout_l2)
               , .tx_done(trmt), .rdy(rdy_l3), .dout(dout_l3));

  layer_4 dense(.clk(clk), .rst_n(rst_n), .strt(rdy_l3), .din(dout_l3)
              , .tx_done(trmt), .dout(dout_l4), .rdy(rdy_l4));

  layer_5 out(.clk(clk), .rst_n(rst_n), .strt(rdy_l4), .din(dout_l4)
               , .tx_done(tx_done), .trmt(trmt), .dout(dout), .addr(addr));

endmodule
