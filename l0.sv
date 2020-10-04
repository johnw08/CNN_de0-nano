module layer_0(clk, rst_n, strt, tx_done, din, addr_inc, rd, dout_0, dout_1);
input clk, rst_n;
input strt;
input tx_done;
input [1:0] din[8:0];
output addr_inc;
output rd;
output [17:0] dout_0[3:0], dout_1[3:0];

reg wr;
reg rd;
reg [3:0] cnt_4;
reg [9:0] addr_ram_wr, addr_ram_rd;

reg [3:0] addr_rom;
wire [8:0] dout_rom_0[2:0], dout_rom_1[2:0], dout_rom_2[1:0];

wire [1:0] din_mult[2:0];
wire [17:0] dout_mult_0, dout_mult_1;
wire [17:0] dout_add_0, dout_add_1;
wire [17:0] dout_relu_0, dout_relu_1;

reg addr_inc_r;
reg addr_din_inc;
reg addr_din_clr;
reg dout_temp_clr;
reg dout_temp_inc;
reg [3:0] addr_din;
reg [17:0] dout_temp_0, dout_temp_1;
wire [17:0] accum_0, accum_1;


typedef enum reg {IDLE, BUSY} state_t;
state_t state, nxt_state;

l0_ram l0_ram_0(.clk(clk), .rst_n(rst_n), .wr(wr), .addr_wr(addr_ram_wr)
              , .din(dout_relu_0), .rd(rd), .addr_rd(addr_ram_rd)
              , .dout(dout_0));
l0_ram l0_ram_1(.clk(clk), .rst_n(rst_n), .wr(wr), .addr_wr(addr_ram_wr)
              , .din(dout_relu_1), .rd(rd), .addr_rd(addr_ram_rd)
              , .dout(dout_1));

l0_rom_0 l0_weight_0(.clk(clk), .addr(addr_rom), .dout(dout_rom_0));
l0_rom_1 l0_weight_1(.clk(clk), .addr(addr_rom), .dout(dout_rom_1));
l0_rom_2 l0_bias(.clk(clk), .dout(dout_rom_2));

l0_mult l0_mult_0(.din(din_mult), .weight(dout_rom_0), .dout(dout_mult_0));
l0_mult l0_mult_1(.din(din_mult), .weight(dout_rom_1), .dout(dout_mult_1));

l0_add l0_bias_0(.din(accum_0), .bias(dout_rom_2[0]), .dout(dout_add_0));
l0_add l0_bias_1(.din(accum_1), .bias(dout_rom_2[1]), .dout(dout_add_1));

l0_relu l0_relu_0(.din(dout_add_0), .dout(dout_relu_0));
l0_relu l0_relu_1(.din(dout_add_1), .dout(dout_relu_1));

//assign din_mult = {din[addr_din + 4'h2], din[addr_din + 4'h1], din[addr_din]};
assign din_mult[0] = din[addr_din];
assign din_mult[1] = din[addr_din + 4'h1];
assign din_mult[2] = din[addr_din + 4'h2];

assign accum_0 = dout_temp_0 + dout_mult_0;
assign accum_1 = dout_temp_1 + dout_mult_1;

assign addr_inc = addr_inc_r;

assign rd = addr_ram_rd < addr_ram_wr;

always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    addr_ram_wr <= 10'h0;
  else if (tx_done)
    addr_ram_wr <= 10'h0;
  else if (wr)
    addr_ram_wr <= addr_ram_wr + 10'h1;
end

always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    cnt_4 <= 4'h0;
  else if (tx_done)
    cnt_4 <= 4'h0;
  else if (rd)
    cnt_4 <= cnt_4 == 4'hC ? 4'h0 : cnt_4 + 1'h1;
end

always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    addr_ram_rd <= 10'h01B;
  else if (tx_done)
    addr_ram_rd <= 10'h01B;
  else if (rd)
    addr_ram_rd <= cnt_4 == 4'hC ? (addr_ram_rd + 10'h1C) : (addr_ram_rd + 10'h2);
end

always @(posedge clk, negedge rst_n) begin
  if (!rst_n) begin
    dout_temp_0 <= 18'h0;
    dout_temp_1 <= 18'h0;
  end
  else if (dout_temp_clr) begin
    dout_temp_0 <= 18'h0;
    dout_temp_1 <= 18'h0;
  end
  else if (dout_temp_inc) begin
    dout_temp_0 <= accum_0;
    dout_temp_1 <= accum_1;
  end
end

always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    addr_din <= 4'h0;
  else if (addr_din_clr)
    addr_din <= 4'h0;
  else if (addr_din_inc)
    addr_din <= addr_din + 4'h3;
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
  addr_rom = 4'h0;
  addr_din_inc = 0;
  addr_din_clr = 0;
  dout_temp_clr = 0;
  dout_temp_inc = 0;
  addr_inc_r = 0;
  wr = 0;

  case(state)
    IDLE: begin
      if (strt) begin
        nxt_state = BUSY;
        addr_rom = 4'h3;
        addr_din_inc = 1;
        dout_temp_inc = 1;
      end
    end
    default: begin
      if (addr_din == 4'h6) begin
        addr_din_clr = 1;
        dout_temp_clr = 1;
        addr_inc_r = 1;
        wr = 1;
      end
      else begin
        nxt_state = BUSY;
        addr_rom = 4'h6;
        addr_din_inc = 1;
        dout_temp_inc = 1;
      end
    end
  endcase
end



endmodule
