module cnn_core(clk, rst_n, strt, tx_done, din, bsy, trmt, dout);
  input clk, rst_n;
  input strt;
  input tx_done;
  input din;
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

  layer_0 conv_0(.clk(clk),.rst_n(rst_n),.strt(strt),.din(din),.tx_done(tx_done),
                .bsy_out(bsy),.rdy(rdy_l0),.dout_0(dout_l0_0),.dout_1(dout_l0_1));

  layer_1 max_0(.clk(clk), .rst_n(rst_n), .strt(rdy_l0), .din_0(dout_l0_0)
              , .din_1(dout_l0_1), .tx_done(tx_done), .bsy_in(bsy_in_l1)
              , .rdy(rdy_l1), .dout_0(dout_l1_0), .dout_1(dout_l1_1));

  layer_2 conv_1(.clk(clk), .rst_n(rst_n), .strt(rdy_l1), .tx_done(tx_done)
               , .din_0(dout_l1_0), .din_1(dout_l1_1), .bsy_out(bsy_in_l1)
               , .dout(dout_l2), .rdy(rdy_l2));

  layer_3 max_1(.clk(clk), .rst_n(rst_n), .strt(rdy_l2), .din(dout_l2)
               , .tx_done(tx_done), .rdy(rdy_l3), .dout(dout_l3));

  layer_4 dense(.clk(clk), .rst_n(rst_n), .strt(rdy_l3), .din(dout_l3)
              , .tx_done(tx_done), .dout(dout_l4), .rdy(rdy_l4));

  layer_5 out(.clk(clk), .rst_n(rst_n), .strt(rdy_l4), .din(dout_l4)
               , .tx_done(tx_done), .trmt(trmt), .dout(dout));

//  assign dout = dout_l4[0] + dout_l4[1] + dout_l4[2] + dout_l4[3] + dout_l4[4] + dout_l4[5]
//					+ dout_l4[6] + dout_l4[7] + dout_l4[8] + dout_l4[9] + dout_l4[10] + dout_l4[11]
//					+ dout_l4[12] + dout_l4[13] + dout_l4[14] + dout_l4[15];
//


				  /* +
  wire [17:0] dout_l0_0[3:0], dout_l0_1[3:0];
  wire rd_l0;

  wire [17:0] dout_l1[17:
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
