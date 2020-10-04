module layer_2(clk, rst_n, strt, din, tx_done, rd, addr_rd_inc, dout_0, dout_1, dout_2, dout_3);
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


assign din_mult = {din[addr_din + 5'h2], din[addr_din + 5'h1], din[addr_din]};

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

endmodule
