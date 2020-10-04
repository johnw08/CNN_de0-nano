module cnn(clk, RST_n, RX, TX, rx_data, rx_rdy);
  input clk;
  input RST_n;
  input RX;
  output TX;
  input rx_rdy;
  input [7:0] rx_data;

  wire rst_n;
  wire tx_done, trmt;
  //wire rx_rdy;
  //wire [7:0] rx_data;
  wire [7:0] tx_data;

  wire [1:0] conv_data[8:0];
  reg wr;
  reg [4:0] addr_rd_cnt;
  reg [9:0] addr_wr;
  reg [9:0] addr_rd;
  wire [9:0] addr_rd_inc;
  wire addr_rd_mod;
  wire rd;
  wire bsy;
  wire addr_inc;


  rst_synch irst_synch(.RST_n(RST_n),.clk(clk),.rst_n(rst_n));

/*
  UART uart(.clk(clk),.rst_n(rst_n),.RX(RX),.TX(TX),.rx_rdy(rx_rdy)
              ,.clr_rx_rdy(rx_rdy),.rx_data(rx_data),.trmt(trmt)
              ,.tx_data(tx_data),.tx_done(tx_done));*/

  cnn_ram_input ram_input(.clk(clk),.rst_n(rst_n),.en(rx_rdy),.rd(rd)
              ,.din(rx_data),.addr_wr(addr_wr),.addr_rd(addr_rd)
              ,.dout(conv_data));

  cnn_core core(.clk(clk),.rst_n(rst_n),.strt(rd),.din(conv_data)
              ,.trmt(trmt),.dout(tx_data),.addr_inc(addr_inc),.tx_done(tx_done));

  assign addr_rd_mod = addr_rd_cnt == 5'h19;
  assign addr_rd_inc = addr_rd_mod ? addr_rd + 10'h3 : addr_rd + 10'h1;

  assign rd = addr_rd < addr_wr;

  always @(posedge clk, negedge rst_n) begin
    if (!rst_n | tx_done)
      addr_wr <= 10'h0;
    else if (rx_rdy)
      addr_wr <= addr_wr + 10'h008;
  end

  always @(posedge clk, negedge rst_n) begin
    if (!rst_n | tx_done)
      addr_rd_cnt <= 5'h0;
    else if (addr_inc)
      addr_rd_cnt <= addr_rd_mod ? 5'h0 : addr_rd_cnt + 5'h1;
  end

  always @(posedge clk, negedge rst_n) begin
    if (!rst_n | tx_done)
      addr_rd <= 10'h03A;
    else if (addr_inc)
      addr_rd <= addr_rd_inc;
  end





endmodule
