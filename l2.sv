module layer_2(clk, rst_n, strt, tx_done, din_0, din_1, bsy_out, dout_0, dout_1, dout_2, dout_3, trmt
);
input clk, rst_n;
input strt;
input tx_done;
input signed [17:0] din_0;
input signed [17:0] din_1;
output reg bsy_out;
output [17:0] dout_0, dout_1, dout_2, dout_3;
output trmt;

reg wr;
reg [6:0] addr_wr, addr_rd;
wire [17:0] relu_0, relu_1, relu_2, relu_3;

l2_ram l2_ram_0(.clk(clk), .wr(wr), .addr_wr(addr_wr), .addr_rd(addr_rd)
              , .din(relu_0), .dout(dout_0));
l2_ram l2_ram_1(.clk(clk), .wr(wr), .addr_wr(addr_wr), .addr_rd(addr_rd)
              , .din(relu_1), .dout(dout_1));
l2_ram l2_ram_2(.clk(clk), .wr(wr), .addr_wr(addr_wr), .addr_rd(addr_rd)
              , .din(relu_2), .dout(dout_2));
l2_ram l2_ram_3(.clk(clk), .wr(wr), .addr_wr(addr_wr), .addr_rd(addr_rd)
              , .din(relu_3), .dout(dout_3));

reg addr_wr_inc;
always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    addr_wr <= 7'h0;
  else if (tx_done)
    addr_wr <= 7'h0;
  else if (addr_wr_inc)
    addr_wr <= addr_wr + 7'h1;
end

reg [3:0] addr_rd_w;
wire [8:0] dout_rom_00, dout_rom_01, dout_rom_10, dout_rom_11;
wire [8:0] dout_rom_20, dout_rom_21, dout_rom_30, dout_rom_31;

l2_rom_00 l2_rom_00(.clk(clk), .addr_rd(addr_rd_w), .dout(dout_rom_00));
l2_rom_01 l2_rom_01(.clk(clk), .addr_rd(addr_rd_w), .dout(dout_rom_01));
l2_rom_10 l2_rom_10(.clk(clk), .addr_rd(addr_rd_w), .dout(dout_rom_10));
l2_rom_11 l2_rom_11(.clk(clk), .addr_rd(addr_rd_w), .dout(dout_rom_11));
l2_rom_20 l2_rom_20(.clk(clk), .addr_rd(addr_rd_w), .dout(dout_rom_20));
l2_rom_21 l2_rom_21(.clk(clk), .addr_rd(addr_rd_w), .dout(dout_rom_21));
l2_rom_30 l2_rom_30(.clk(clk), .addr_rd(addr_rd_w), .dout(dout_rom_30));
l2_rom_31 l2_rom_31(.clk(clk), .addr_rd(addr_rd_w), .dout(dout_rom_31));

wire [8:0] dout_bias_0, dout_bias_1, dout_bias_2, dout_bias_3;
l2_rom_bias l2_rom_bias(.clk(clk), .dout_0(dout_bias_0), .dout_1(dout_bias_1)
		, .dout_2(dout_bias_2), .dout_3(dout_bias_3));

wire signed [17:0] w_00;
wire signed [17:0] w_01;
wire signed [17:0] w_10;
wire signed [17:0] w_11;
wire signed [17:0] w_20;
wire signed [17:0] w_21;
wire signed [17:0] w_30;
wire signed [17:0] w_31;
assign w_00 = {{9{dout_rom_00[8]}}, dout_rom_00[8:0]};
assign w_01 = {{9{dout_rom_01[8]}}, dout_rom_01[8:0]};
assign w_10 = {{9{dout_rom_10[8]}}, dout_rom_10[8:0]};
assign w_11 = {{9{dout_rom_11[8]}}, dout_rom_11[8:0]};
assign w_20 = {{9{dout_rom_20[8]}}, dout_rom_20[8:0]};
assign w_21 = {{9{dout_rom_21[8]}}, dout_rom_21[8:0]};
assign w_30 = {{9{dout_rom_30[8]}}, dout_rom_30[8:0]};
assign w_31 = {{9{dout_rom_31[8]}}, dout_rom_31[8:0]};

wire signed [35:0] mult_00;
wire signed [35:0] mult_01;
wire signed [35:0] mult_10;
wire signed [35:0] mult_11;
wire signed [35:0] mult_20;
wire signed [35:0] mult_21;
wire signed [35:0] mult_30;
wire signed [35:0] mult_31;
assign mult_00 = din_0 * w_00;
assign mult_01 = din_1 * w_01;
assign mult_10 = din_0 * w_10;
assign mult_11 = din_1 * w_11;
assign mult_20 = din_0 * w_20;
assign mult_21 = din_1 * w_21;
assign mult_30 = din_0 * w_30;
assign mult_31 = din_1 * w_31;

wire [35:0] sum_0, sum_1, sum_2, sum_3;
assign sum_0 = mult_00 + mult_01;
assign sum_1 = mult_10 + mult_11;
assign sum_2 = mult_20 + mult_21;
assign sum_3 = mult_30 + mult_31;

reg temp_clr;
reg [35:0] temp_0, temp_1, temp_2, temp_3;
always @(posedge clk) begin
  if (temp_clr) begin
    temp_0 <= 36'h0;
    temp_1 <= 36'h0;
    temp_2 <= 36'h0;
    temp_3 <= 36'h0;
  end
  else begin
    temp_0 <= temp_0 + sum_0;
    temp_1 <= temp_1 + sum_1;
    temp_2 <= temp_2 + sum_2;
    temp_3 <= temp_3 + sum_3;
  end
end

wire signed [35:0] bias_0;
wire signed [35:0] bias_1;
wire signed [35:0] bias_2;
wire signed [35:0] bias_3;
assign bias_0 = temp_0 + {{27{dout_bias_0[8]}}, dout_bias_0[8:0]};
assign bias_1 = temp_1 + {{27{dout_bias_1[8]}}, dout_bias_1[8:0]};
assign bias_2 = temp_2 + {{27{dout_bias_2[8]}}, dout_bias_2[8:0]};
assign bias_3 = temp_3 + {{27{dout_bias_3[8]}}, dout_bias_3[8:0]};

assign relu_0 = bias_0 > 0 ? bias_0[17:0] : 18'h0;
assign relu_1 = bias_1 > 0 ? bias_1[17:0] : 18'h0;
assign relu_2 = bias_2 > 0 ? bias_2[17:0] : 18'h0;
assign relu_3 = bias_3 > 0 ? bias_3[17:0] : 18'h0;

reg addr_rd_w_inc;
reg addr_rd_w_clr;
always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    addr_rd_w <= 4'h0;
  else if (addr_rd_w_clr)
    addr_rd_w <= 4'h0;
  else if (addr_rd_w_inc)
    addr_rd_w <= addr_rd_w + 4'h1;
end

typedef enum reg {IDLE, BUSY} state_wr_t;
state_wr_t state_wr, nxt_state_wr;

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
  addr_wr_inc = 0;
  addr_rd_w_inc = 0;
  addr_rd_w_clr = 0;
  temp_clr = 0;
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
        addr_rd_w_clr = 1;
        addr_wr_inc = 1;
        wr = 1;
      end
      else begin
        addr_rd_w_inc = 1;
        nxt_state_wr = BUSY;
      end
    end
   endcase
end


assign trmt = addr_wr == 7'h79;


/*
input clk, rst_n;
input strt;
input [17:0] din[17:0];
input tx_done;
output rd;
output addr_rd_inc;
output [17:0] dout_0[3:0], dout_1[3:0], dout_2[3:0], dout_3[3:0];

reg wr;
reg [2:0] addr_ram_rd_mod;
reg [2:0] addr_ram_rd_cnt;
reg [6:0] addr_ram_wr;
reg [6:0] addr_ram_rd;

reg [4:0] addr_rom;
wire [8:0] dout_rom_0[2:0], dout_rom_1[2:0], dout_rom_2[2:0], dout_rom_3[2:0];
wire [8:0] dout_rom_4[3:0];

reg addr_din_clr;
reg addr_din_inc;
reg [4:0] addr_din;
wire [17:0] din_mult[2:0];
wire [35:0] dout_mult_0, dout_mult_1, dout_mult_2, dout_mult_3;

wire [35:0] dout_add_0, dout_add_1, dout_add_2, dout_add_3;
wire [17:0] dout_relu_0, dout_relu_1, dout_relu_2, dout_relu_3;

reg addr_rd_inc_r;
reg addr_wr_inc;
reg temp_clr;
reg temp_inc;
reg [35:0] temp_0, temp_1, temp_2, temp_3;
wire [35:0] accum_0, accum_1, accum_2, accum_3;

typedef enum reg {IDLE, BUSY} state_t;
state_t state, nxt_state;

l2_ram l2_ram_0(.clk(clk), .rst_n(rst_n), .wr(wr), .addr_wr(addr_ram_wr)
              , .din(dout_relu_0), .rd(rd), .addr_rd(addr_ram_rd), .dout(dout_0));
l2_ram l2_ram_1(.clk(clk), .rst_n(rst_n), .wr(wr), .addr_wr(addr_ram_wr)
              , .din(dout_relu_1), .rd(rd), .addr_rd(addr_ram_rd), .dout(dout_1));
l2_ram l2_ram_2(.clk(clk), .rst_n(rst_n), .wr(wr), .addr_wr(addr_ram_wr)
              , .din(dout_relu_2), .rd(rd), .addr_rd(addr_ram_rd), .dout(dout_2));
l2_ram l2_ram_3(.clk(clk), .rst_n(rst_n), .wr(wr), .addr_wr(addr_ram_wr)
              , .din(dout_relu_3), .rd(rd), .addr_rd(addr_ram_rd), .dout(dout_3));


l2_rom_0 l2_Weight_0(.clk(clk), .addr(addr_rom), .dout(dout_rom_0));
l2_rom_1 l2_Weight_1(.clk(clk), .addr(addr_rom), .dout(dout_rom_1));
l2_rom_2 l2_Weight_2(.clk(clk), .addr(addr_rom), .dout(dout_rom_2));
l2_rom_3 l2_Weight_3(.clk(clk), .addr(addr_rom), .dout(dout_rom_3));
l2_rom_4 l2_bias(.clk(clk), .dout(dout_rom_4));

l2_mult l2_mult_0(.din(din_mult), .weight(dout_rom_0), .dout(dout_mult_0));
l2_mult l2_mult_1(.din(din_mult), .weight(dout_rom_1), .dout(dout_mult_1));
l2_mult l2_mult_2(.din(din_mult), .weight(dout_rom_2), .dout(dout_mult_2));
l2_mult l2_mult_3(.din(din_mult), .weight(dout_rom_3), .dout(dout_mult_3));

l2_add l2_bias_0(.din(accum_0), .bias(dout_rom_4[0]), .dout(dout_add_0));
l2_add l2_bias_1(.din(accum_1), .bias(dout_rom_4[1]), .dout(dout_add_1));
l2_add l2_bias_2(.din(accum_2), .bias(dout_rom_4[2]), .dout(dout_add_2));
l2_add l2_bias_3(.din(accum_3), .bias(dout_rom_4[3]), .dout(dout_add_3));

l2_relu l2_relu_0(.din(dout_add_0), .dout(dout_relu_0));
l2_relu l2_relu_1(.din(dout_add_1), .dout(dout_relu_1));
l2_relu l2_relu_2(.din(dout_add_2), .dout(dout_relu_2));
l2_relu l2_relu_3(.din(dout_add_3), .dout(dout_relu_3));

assign din_mult[0] = din[addr_din];
assign din_mult[1] = din[addr_din + 5'h1];
assign din_mult[2] = din[addr_din + 5'h2];

assign accum_0 = temp_0 + dout_mult_0;
assign accum_1 = temp_1 + dout_mult_1;
assign accum_2 = temp_2 + dout_mult_2;
assign accum_3 = temp_3 + dout_mult_3;

assign addr_rd_inc = addr_rd_inc_r;

assign rd = (addr_ram_rd < addr_ram_wr) && (addr_ram_rd_cnt < 3'h5);

always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    addr_din <= 5'h0;
  else if (addr_din_clr)
    addr_din <= 5'h0;
  else if (addr_din_inc)
    addr_din <= addr_din + 5'h3;
end

always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    addr_ram_wr <= 7'h0;
  else if (tx_done)
    addr_ram_wr <= 7'h0;
  else if (addr_wr_inc)
    addr_ram_wr <= addr_ram_wr + 7'h1;
end

always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    addr_ram_rd <= 7'hC;
  else if (tx_done)
    addr_ram_rd <= 7'hC;
  else if (rd)
    addr_ram_rd <= (addr_ram_rd_mod == 3'h4) ? (addr_ram_rd + 7'hE) : addr_ram_rd + 7'h2;
end

always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    addr_ram_rd_mod <= 3'h0;
  else if (tx_done)
    addr_ram_rd_mod <= 3'h0;
  else if (rd)
    addr_ram_rd_mod <= (addr_ram_rd_mod == 3'h4) ? 3'h0 : addr_ram_rd_mod + 3'h1;
end

always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    addr_ram_rd_cnt <= 3'h0;
  else if (tx_done)
    addr_ram_rd_cnt <= 3'h0;
  else if (rd && (addr_ram_rd_mod == 3'h4))
    addr_ram_rd_cnt <= addr_ram_rd_cnt + 3'h1;
end

always @(posedge clk, negedge rst_n) begin
  if (!rst_n) begin
    temp_0 <= 36'h0;
    temp_1 <= 36'h0;
    temp_2 <= 36'h0;
    temp_3 <= 36'h0;
  end
  else if (temp_clr) begin
    temp_0 <= 36'h0;
    temp_1 <= 36'h0;
    temp_2 <= 36'h0;
    temp_3 <= 36'h0;
  end
  else if (temp_inc) begin
    temp_0 <= accum_0;
    temp_1 <= accum_1;
    temp_2 <= accum_2;
    temp_3 <= accum_3;
  end

end

always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    state <= IDLE;
  else if (tx_done)
    state <= IDLE;
  else
    state <= nxt_state;
end

always_comb begin
  nxt_state = IDLE;
  addr_din_inc = 0;
  addr_din_clr = 0;
  addr_rd_inc_r = 0;
  addr_wr_inc = 0;
  temp_clr = 0;
  temp_inc = 0;
  addr_rom = 5'h0;
  wr = 0;
  case(state)
    IDLE: begin
      if (strt) begin
        nxt_state = BUSY;
        addr_din_inc = 1;
        temp_inc = 1;
        addr_rom = 5'h3;
      end
    end
    default: begin
      if (addr_din == 5'hF) begin
        addr_din_clr = 1;
        addr_rd_inc_r = 1;
        addr_wr_inc = 1;
        temp_clr = 1;
        wr = 1;
      end
      else begin
        nxt_state = BUSY;
        addr_din_inc = 1;
        temp_inc = 1;
        addr_rom = addr_din + 5'h3;
      end
    end
  endcase
end
*/
endmodule
