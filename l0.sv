module layer_0(clk, rst_n, strt, tx_done, din, bsy_out, rdy, dout_0, dout_1);
input clk, rst_n;
input strt;
input tx_done;
input din;
output reg bsy_out;
output rdy;
output [17:0] dout_0, dout_1;

reg wr;
reg [9:0] addr_wr, addr_rd;
wire [17:0] din_ram_0, din_ram_1;

reg [3:0] addr_rd_w;
wire signed [8:0] dout_w_0;
wire signed [8:0] dout_w_1;

wire [8:0] dout_bias_0, dout_bias_1;

reg addr_wr_inc;
reg addr_rd_w_clr;
reg addr_rd_w_inc;
reg temp_clr;
reg [17:0] temp_0, temp_1;
wire signed [8:0] din_ex;
wire signed [17:0] mult_0, mult_1;
wire signed [17:0] add_0, add_1;


typedef enum reg {IDLE, BUSY} state_wr_t;
state_wr_t state_wr, nxt_state_wr;

ram #(.ADDR_WIDTH(10), .DATA_WIDTH(18)) l0_ram_0(.clk(clk), .wr(wr)
    , .addr_wr(addr_wr), .din(din_ram_0), .addr_rd(addr_rd), .dout(dout_0));

ram #(.ADDR_WIDTH(10), .DATA_WIDTH(18)) l0_ram_1(.clk(clk), .wr(wr)
    , .addr_wr(addr_wr), .din(din_ram_1), .addr_rd(addr_rd), .dout(dout_1));

// l0_rom_w #(.file("l0_W0.txt")) l0_rom_w0(.clk(clk), .addr_rd(addr_rd_w), .dout(dout_w_0));
// l0_rom_w #(.file("l0_W1.txt")) l0_rom_w1(.clk(clk), .addr_rd(addr_rd_w), .dout(dout_w_1));

rom #(.file("l0_W0.txt"), .ADDR_WIDTH(4), .DATA_WIDTH(9)) l0_rom_w0(.clk(clk), .addr_rd(addr_rd_w), .dout(dout_w_0));
rom #(.file("l0_W1.txt"), .ADDR_WIDTH(4), .DATA_WIDTH(9)) l0_rom_w1(.clk(clk), .addr_rd(addr_rd_w), .dout(dout_w_1));

l0_rom_b l0_rom_b(.clk(clk), .dout_0(dout_bias_0), .dout_1(dout_bias_1));

assign din_ex = {{8{din}}, din};

assign mult_0 = din_ex * dout_w_0;
assign mult_1 = din_ex * dout_w_1;

assign add_0 = temp_0 + {{9{dout_bias_0[8]}}, dout_bias_0[8:0]};
assign add_1 = temp_1 + {{9{dout_bias_1[8]}}, dout_bias_1[8:0]};

assign din_ram_0 = add_0 > 0 ? add_0 : 18'h0;
assign din_ram_1 = add_1 > 0 ? add_1 : 18'h0;

always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    addr_wr <= 10'h0;
  else if (tx_done)
    addr_wr <= 10'h0;
  else if (addr_wr_inc)
    addr_wr <= addr_wr + 10'h1;
end

always @(posedge clk, negedge rst_n) begin
  if (!rst_n) begin
    temp_0 <= 18'h0;
    temp_1 <= 18'h0;
  end
  else if (temp_clr) begin
    temp_0 <= 18'h0;
    temp_1 <= 18'h0;
  end
  else begin
    temp_0 <= temp_0 + mult_0;
    temp_1 <= temp_1 + mult_1;
  end
end

always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    addr_rd_w <= 4'h0;
  else if (addr_rd_w_clr)
    addr_rd_w <= 4'h0;
  else if (addr_rd_w_inc)
    addr_rd_w <= addr_rd_w + 4'h1;
end

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
  addr_rd_w_clr = 0;
  addr_rd_w_inc = 0;
  temp_clr = 0;
  addr_wr_inc = 0;
  wr = 0;
  bsy_out = 0;

  case(state_wr)
    IDLE: begin
      if (strt) begin
        nxt_state_wr = BUSY;
        addr_rd_w_inc = 1;
        temp_clr = 1;
      end
    end
    default: begin
      bsy_out = 1;
      if (addr_rd_w == 4'hA) begin
        addr_wr_inc = 1;
        addr_rd_w_clr = 1;
        wr = 1;
      end
      else begin
        nxt_state_wr = BUSY;
        addr_rd_w_inc = 1;
      end
    end
  endcase
end

/*
  Read DATA
*/

reg addr_rd_inc;
reg [3:0] cnt_13;
reg [9:0] addr_rd_ram;
typedef enum reg [2:0] {INI, ONE, TWO, THREE, FOUR} state_rd_t;
state_rd_t state_rd, nxt_state_rd;

assign trmt = addr_rd_ram == 10'h02A3 && addr_rd_inc==1;

assign rdy = addr_rd_ram < addr_wr;

always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    cnt_13 <= 4'h0;
  else if (addr_rd_inc)
    cnt_13 <= cnt_13 == 4'hC ? 4'h0 : cnt_13 + 4'h1;
end

always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    addr_rd_ram <= 10'h01B;
  else if (tx_done)
    addr_rd_ram <= 10'h01B;
  else if (addr_rd_inc)
    addr_rd_ram <= cnt_13 == 4'hC ? addr_rd_ram + 10'h1C : addr_rd_ram + 10'h2;
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
      if (rdy) begin
        nxt_state_rd = ONE;
        addr_rd = addr_rd_ram - 10'h1B;
      end
    end
    ONE: begin
      nxt_state_rd = TWO;
      addr_rd = addr_rd_ram - 10'h1A;
    end
    TWO: begin
      nxt_state_rd = THREE;
      addr_rd = addr_rd_ram - 10'h01;
    end
    THREE: begin
      nxt_state_rd = FOUR;
      addr_rd = addr_rd_ram;
    end
    default: begin
      addr_rd_inc = 1;
    end
  endcase
end

endmodule
