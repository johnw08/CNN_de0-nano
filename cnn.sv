// module cnn(clk, RST_n, RX, TX, LED);
module cnn(clk, RST_n, RX, TX, rx_data, rx_rdy);
  input clk;
  input RST_n;
  input RX;
  output TX;
  // output [7:0] LED;
  input rx_rdy;
  input [7:0] rx_data;

  wire rst_n;
  wire tx_done;
  wire trmt;
  wire rx_rdy;
  wire [7:0] rx_data;
  wire [7:0] tx_data;

  reg wr;
  wire dout_ram;
  wire din_ram;
  reg [9:0] addr_wr;
  reg [9:0] addr_rd;

  //Write data
  reg cnt_8_inc;
  reg addr_wr_inc;
  reg [7:0] dout_rx;
  reg [2:0] cnt_8;

  //Read data
  wire bsy;
  reg addr_rd_inc;
  reg rd_rdy;
  reg [9:0] addr_rd_ram;

  typedef enum reg {IDLE, DATA} state_wr_t;
  state_wr_t state_wr, nxt_state_wr;

  typedef enum reg [3:0] {INI, ONE, TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT, NINE} state_rd_t;
  state_rd_t state_rd, nxt_state_rd;

  rst_synch irst_synch(.RST_n(RST_n),.clk(clk),.rst_n(rst_n));
/*

  UART uart(.clk(clk),.rst_n(rst_n),.RX(RX),.TX(TX),.rx_rdy(rx_rdy)
              ,.clr_rx_rdy(rx_rdy),.rx_data(rx_data),.trmt(trmt)
              ,.tx_data(tx_data),.tx_done(tx_done));
*/
  cnn_ram_input input_ram(.clk(clk),.wr(wr),.din(din_ram),.addr_wr(addr_wr)
                         ,.addr_rd(addr_rd),.dout(dout_ram));

  cnn_core core(.clk(clk),.rst_n(rst_n),.strt(rd_rdy),.din(dout_ram)
              ,.trmt(trmt),.dout(tx_data),.bsy(bsy),.tx_done(tx_done));

  /*
    Write Data
  */
  assign din_ram = dout_rx[cnt_8];

  always @(posedge clk, negedge rst_n) begin
    if (!rst_n)
      addr_wr <= 10'h0;
    else if (tx_done)
      addr_wr <= 10'h0;
    else if (addr_wr_inc)
      addr_wr <= addr_wr + 10'h1;
  end

  always @(posedge clk) begin
    if (rx_rdy)
      dout_rx <= rx_data;
  end

  always @(posedge clk, negedge rst_n) begin
    if (!rst_n)
      cnt_8 <= 3'h0;
    else if (tx_done)
      cnt_8 <= 3'h0;
    else if (cnt_8_inc)
      cnt_8 <= cnt_8 + 3'h1;
  end

  // state machine for input to ram
  always @(posedge clk, negedge rst_n) begin
    if (!rst_n)
      state_wr <= IDLE;
    else if (tx_done)
      state_wr <= IDLE;
    else
      state_wr <= nxt_state_wr;
  end

  always_comb begin
    nxt_state_wr = IDLE;
    wr = 0;
    cnt_8_inc = 0;
    addr_wr_inc = 0;

    case(state_wr)
      IDLE:  begin
        if (rx_rdy) begin
          nxt_state_wr = DATA;
        end
      end
      default: begin
        cnt_8_inc = 1;
        addr_wr_inc = 1;
        wr = 1;
        if (cnt_8 != 3'h7)
          nxt_state_wr = DATA;
      end
    endcase
  end

  /*
    Read DATA
  */
  reg [4:0] cnt_26;

  assign rd_rdy = addr_rd_ram < addr_wr;

  always @(posedge clk, negedge rst_n) begin
    if (!rst_n)
      cnt_26 <= 5'h0;
    else if (tx_done)
      cnt_26 <= 5'h0;
    else if (addr_rd_inc)
      cnt_26 <= cnt_26 == 5'h19 ? 5'h0 : cnt_26 + 5'h1;
  end

  always @(posedge clk, negedge rst_n) begin
    if (!rst_n)
      addr_rd_ram <= 10'h03A;
    else if (tx_done)
      addr_rd_ram <= 10'h03A;
    else if (addr_rd_inc)
      addr_rd_ram <= cnt_26 == 5'h19 ? addr_rd_ram + 10'h3 : addr_rd_ram + 10'h1;
  end

  always @(posedge clk, negedge rst_n) begin
    if (!rst_n)
      state_rd <= INI;
    else if (tx_done)
      state_rd <= INI;
    else
      state_rd <= nxt_state_rd;
  end

  always_comb begin
    nxt_state_rd = INI;
    addr_rd_inc = 0;
	  addr_rd = 10'h0;

    case(state_rd)
      INI: begin
        if (rd_rdy && !bsy) begin
          nxt_state_rd = ONE;
          addr_rd = addr_rd_ram - 10'h03A;
        end
      end
      ONE: begin
        nxt_state_rd = TWO;
        addr_rd = addr_rd_ram - 10'h039;
      end
      TWO: begin
        nxt_state_rd = THREE;
        addr_rd = addr_rd_ram - 10'h038;
      end
      THREE: begin
        nxt_state_rd = FOUR;
        addr_rd = addr_rd_ram - 10'h01E;
      end
      FOUR: begin
        nxt_state_rd = FIVE;
        addr_rd = addr_rd_ram - 10'h01D;
      end
      FIVE: begin
        nxt_state_rd = SIX;
        addr_rd = addr_rd_ram - 10'h01C;
      end
      SIX: begin
        nxt_state_rd = SEVEN;
        addr_rd = addr_rd_ram - 10'h002;
      end
      SEVEN: begin
        nxt_state_rd = EIGHT;
        addr_rd = addr_rd_ram - 10'h001;
      end
      EIGHT: begin
        nxt_state_rd = NINE;
        addr_rd = addr_rd_ram;
      end
      NINE: begin
        addr_rd_inc = 1;
      end
    endcase
  end


  assign LED = 8'hFF;
  /*
  assign addr_rd_mod = addr_rd_cnt == 5'h19;
  assign addr_rd_inc = addr_rd_mod ? addr_rd + 10'h3 : addr_rd + 10'h1;

  assign rd = addr_rd < addr_wr;

  always @(posedge clk, negedge rst_n) begin
    if (!rst_n)
      addr_wr <= 10'h0;
	  else if (tx_done)
		  addr_wr <= 10'h0;
    else if (rx_rdy)
      addr_wr <= addr_wr + 10'h008;
  end

  always @(posedge clk, negedge rst_n) begin
    if (!rst_n)
      addr_rd_cnt <= 5'h0;
    else if (tx_done)
      addr_rd_cnt <= 5'h0;
    else if (addr_inc)
      addr_rd_cnt <= addr_rd_mod ? 5'h0 : addr_rd_cnt + 5'h1;
  end

  always @(posedge clk, negedge rst_n) begin
    if (!rst_n)
      addr_rd <= 10'h03A;
    else if (tx_done)
      addr_rd <= 10'h03A;
    else if (addr_inc)
      addr_rd <= addr_rd_inc;
  end

*/



endmodule
