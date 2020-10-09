module cnn_core(clk, rst_n, strt, tx_done, din, bsy, trmt, dout);
  input clk, rst_n;
  input strt;
  input tx_done;
  input din;
  output bsy;
  output trmt;
  output [7:0] dout;

  wire rdy_l0;
  wire bsy_in_l0;
  wire [17:0] dout_l0_0, dout_l0_1;
  layer_0 conv_0(.clk(clk),.rst_n(rst_n),.strt(strt),.din(din),.tx_done(tx_done),
                .bsy_out(bsy),.bsy_in(bsy_in_l0),.rdy(rdy_l0),.dout_0(dout)
                ,.dout_1(dout_l0_1));
/*
  wire [17:0] dout_l0_0[3:0], dout_l0_1[3:0];
  wire rd_l0;

  wire [17:0] dout_l1[17:0];
  wire rd_l1;
  wire addr_rd_inc_l1;

  wire rd_l2;
  wire [17:0] dout_l2_0[3:0], dout_l2_1[3:0], dout_l2_2[3:0], dout_l2_3[3:0];

  wire rd_l3;
  wire addr_rd_inc_l3;
  wire [17:0] dout_l3[3:0];

  wire rd_l4;
  wire [17:0] dout_l4[63:0];

  layer_0 conv_0(.clk(clk),.rst_n(rst_n),.strt(strt),.din(din),.addr_inc(addr_inc)
                ,.tx_done(tx_done),.rd(rd_l0),.dout_0(dout_l0_0),.dout_1(dout_l0_1));

  layer_1 max_0(.clk(clk), .rst_n(rst_n), .strt(rd_l0), .din_0(dout_l0_0)
              , .din_1(dout_l0_1), .tx_done(tx_done), .addr_rd_inc(addr_rd_inc_l1)
              , .rd(rd_l1), .dout(dout_l1));

  layer_2 conv_1(.clk(clk), .rst_n(rst_n), .strt(rd_l1), .din(dout_l1)
               , .tx_done(tx_done), .rd(rd_l2), .addr_rd_inc(addr_rd_inc_l1)
               , .dout_0(dout_l2_0), .dout_1(dout_l2_1), .dout_2(dout_l2_2)
               , .dout_3(dout_l2_3));

  layer_3 max_1(.clk(clk), .rst_n(rst_n), .strt(rd_l2), .din_0(dout_l2_0)
              , .din_1(dout_l2_1), .din_2(dout_l2_2), .din_3(dout_l2_3)
              , .tx_done(tx_done), .addr_rd_inc(addr_rd_inc_l3), .rd(rd_l3)
              , .dout(dout_l3));

  layer_4 dense_4(.clk(clk), .rst_n(rst_n), .strt(rd_l3), .din(dout_l3), .tx_done(tx_done)
                , .dout(dout_l4), .addr_rd_inc(addr_rd_inc_l3), .rd(rd_l4));

  layer_5 out(.clk(clk), .rst_n(rst_n), .strt(rd_l4), .din(dout_l4), .tx_done(tx_done)
               , .rd(trmt), .dout(dout));

*/
endmodule
