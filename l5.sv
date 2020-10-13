module layer_5(clk, rst_n, strt, din, tx_done, trmt, dout);
input clk, rst_n;
input strt;
input tx_done;
input signed [17:0] din[15:0];
output trmt;
output [7:0] dout;

reg cnt_10_inc;
reg [3:0] cnt_10;
always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    cnt_10 <= 4'h0;
  else if (tx_done)
    cnt_10 <= 4'h0;
  else if (cnt_10_inc)
    cnt_10 <= cnt_10 + 4'h1;
end

reg [5:0] addr_rd;
reg [8:0] dout_rom[15:0];
l5_rom_w #(.file("l5_W0.txt")) l5_rom_w0(.clk(clk), .addr_rd(addr_rd), .dout(dout_rom[0]));
l5_rom_w #(.file("l5_W1.txt")) l5_rom_w1(.clk(clk), .addr_rd(addr_rd), .dout(dout_rom[1]));
l5_rom_w #(.file("l5_W2.txt")) l5_rom_w2(.clk(clk), .addr_rd(addr_rd), .dout(dout_rom[2]));
l5_rom_w #(.file("l5_W3.txt")) l5_rom_w3(.clk(clk), .addr_rd(addr_rd), .dout(dout_rom[3]));
l5_rom_w #(.file("l5_W4.txt")) l5_rom_w4(.clk(clk), .addr_rd(addr_rd), .dout(dout_rom[4]));
l5_rom_w #(.file("l5_W5.txt")) l5_rom_w5(.clk(clk), .addr_rd(addr_rd), .dout(dout_rom[5]));
l5_rom_w #(.file("l5_W6.txt")) l5_rom_w6(.clk(clk), .addr_rd(addr_rd), .dout(dout_rom[6]));
l5_rom_w #(.file("l5_W7.txt")) l5_rom_w7(.clk(clk), .addr_rd(addr_rd), .dout(dout_rom[7]));
l5_rom_w #(.file("l5_W8.txt")) l5_rom_w8(.clk(clk), .addr_rd(addr_rd), .dout(dout_rom[8]));
l5_rom_w #(.file("l5_W9.txt")) l5_rom_w9(.clk(clk), .addr_rd(addr_rd), .dout(dout_rom[9]));
l5_rom_w #(.file("l5_W10.txt")) l5_rom_w10(.clk(clk), .addr_rd(addr_rd), .dout(dout_rom[10]));
l5_rom_w #(.file("l5_W11.txt")) l5_rom_w11(.clk(clk), .addr_rd(addr_rd), .dout(dout_rom[11]));
l5_rom_w #(.file("l5_W12.txt")) l5_rom_w12(.clk(clk), .addr_rd(addr_rd), .dout(dout_rom[12]));
l5_rom_w #(.file("l5_W13.txt")) l5_rom_w13(.clk(clk), .addr_rd(addr_rd), .dout(dout_rom[13]));
l5_rom_w #(.file("l5_W14.txt")) l5_rom_w14(.clk(clk), .addr_rd(addr_rd), .dout(dout_rom[14]));
l5_rom_w #(.file("l5_W15.txt")) l5_rom_w15(.clk(clk), .addr_rd(addr_rd), .dout(dout_rom[15]));

reg addr_rd_inc;
always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    addr_rd <= 6'h0;
  else if (tx_done)
    addr_rd <= 6'h0;
  else if (addr_rd_inc)
    addr_rd <= addr_rd + 6'h1;
end

wire signed [17:0] dout_rom_ex[15:0];
wire signed [35:0] mult[15:0];
genvar i;
generate
  for (i = 0; i < 16; i = i + 1) begin
    assign dout_rom_ex[i] = {{9{dout_rom[i][8]}}, dout_rom[i][8:0]};
    assign mult[i] = din[i] * dout_rom_ex[i];
  end
endgenerate

wire [35:0] sum;
assign sum = mult[0] + mult[1] + mult[2] + mult[3] + mult[4] + mult[5]
            + mult[6] + mult[7] + mult[8] + mult[9] + mult[10] + mult[11]
            + mult[12] + mult[13] + mult[14] + mult[15];

wire [8:0] dout_bias;
l5_rom_b l5_rom_b(.clk(clk), .addr_rd(cnt_10), .dout(dout_bias));

reg temp_init;
reg [35:0] temp;
wire [35:0] accum;
assign accum = temp + sum;
always @(posedge clk) begin
  if (temp_init)
    temp <= 36'h0;
  else
    temp <= accum;
end

wire signed [35:0] bias;
assign bias = accum + {{27{dout_bias[8]}}, dout_bias[8:0]};

wire signed [35:0] relu;
assign relu = bias > 0 ? bias : 36'h0;

wire greater;
reg update;
reg [3:0] digit_max;
always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    digit_max <= 4'h0;
  else if (tx_done)
    digit_max <= 4'h0;
  else if (update && greater)
    digit_max <= cnt_10;
end

reg signed [35:0] dout_max;
always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    dout_max <= 36'h0;
  else if (tx_done)
    dout_max <= 36'h0;
  else if (update && greater)
    dout_max <= relu;
end

assign greater = relu > dout_max;

typedef enum reg [2:0] {IDLE, ONE, TWO, THREE, FOUR} state_t;
state_t state, nxt_state;
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
  addr_rd_inc = 0;
  cnt_10_inc = 0;
  temp_init = 0;
  update = 0;

  case (state)
    IDLE: begin
      if (strt) begin
        nxt_state = ONE;
        addr_rd_inc = 1;
        temp_init = 1;
      end
    end
    ONE: begin
      nxt_state = TWO;
      addr_rd_inc = 1;
    end
    TWO: begin
      nxt_state = THREE;
      addr_rd_inc = 1;
    end
    THREE: begin
      nxt_state = FOUR;
      addr_rd_inc = 1;
    end
    default: begin
      if (cnt_10 == 4'hA)
        nxt_state = FOUR;
      else begin
        nxt_state = ONE;
        addr_rd_inc = 1;
        temp_init = 1;
        cnt_10_inc = 1;
        update = 1;
      end
    end
  endcase
end

assign trmt = cnt_10 == 4'hA;
assign dout = {{4'b0}, digit_max[3:0]};

/*
input clk, rst_n;
input strt;
input tx_done;
input [17:0] din[63:0];
output rd;
output [7:0] dout;


reg addr_rom_inc;
reg [9:0] addr_rom_0;
wire [8:0] dout_rom_0[31:0];
wire [8:0] dout_rom_1[9:0];

wire [17:0] din_mult[31:0];
wire [35:0] dout_mult;
wire [35:0] dout_add;
wire signed [17:0] dout_relu;

reg addr_inc;
reg addr_cnt_2;
reg [3:0] addr_cnt_10;
reg [5:0] addr_cnt_64;
reg [3:0] max_index;
reg signed [17:0] max_val;
reg [35:0] temp;
wire update;
wire [35:0] accum;

genvar i;

typedef enum reg [1:0] {IDLE, WAIT, BUSY} state_t;
state_t state, nxt_state;

l5_rom_0 l5_Weight(.clk(clk), .addr(addr_rom_0), .dout(dout_rom_0));

l5_rom_1 l5_bias(.clk(clk), .dout(dout_rom_1));

l5_mult l5_mult(.din(din_mult), .weight(dout_rom_0), .dout(dout_mult));

l5_add l5_add_bias(.din(accum), .bias(dout_rom_1[addr_cnt_10]), .dout(dout_add));

l5_relu l5_relu(.din(dout_add), .dout(dout_relu));

assign rd = addr_cnt_10 == 4'hA;

assign update = addr_cnt_2 == 1'h1 && dout_relu > max_val;

assign accum = temp + dout_mult;

assign dout = {{4'h0}, max_index[3:0]};

generate
  for (i = 0; i < 32; i++) begin: din_mult_for
    assign din_mult[i] = din[addr_cnt_64 + i];
  end
endgenerate


always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    max_index <= 4'h0;
  else if (tx_done)
    max_index <= 4'h0;
  else if (update)
    max_index <= addr_cnt_10;
end

always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    max_val <= 18'h0;
  else if (tx_done)
    max_val <= 18'h0;
  else if (update)
    max_val <= dout_relu;
end

always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    temp <= 36'h0;
  else if (tx_done)
    temp <= 36'h0;
  else if (addr_inc)
    temp <= dout_mult;
end

always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    addr_rom_0 <= 10'h0;
  else if (tx_done)
    addr_rom_0 <= 10'h0;
  else if (addr_rom_inc)
    addr_rom_0 <= addr_rom_0 + 10'h20;
end

always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    addr_cnt_2 <= 1'h0;
  else if (tx_done)
    addr_cnt_2 <= 1'h0;
  else if (addr_inc)
    addr_cnt_2 <= addr_cnt_2 + 1'h1;
end

always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    addr_cnt_10 <= 4'h0;
  else if (tx_done)
    addr_cnt_10 <= 4'h0;
  else if (addr_inc && addr_cnt_2 == 1'h1)
    addr_cnt_10 <= addr_cnt_10 + 4'h1;
end

always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    addr_cnt_64 <= 6'h0;
  else if (tx_done)
    addr_cnt_64 <= 6'h0;
  else if (addr_inc)
    addr_cnt_64 <= addr_cnt_64 + 6'h20;
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
  addr_inc = 0;
  addr_rom_inc = 0;

  case(state)
    IDLE: begin
      if (strt) begin
        nxt_state = WAIT;
        addr_rom_inc = 1;
      end
    end
    WAIT: begin
      nxt_state = BUSY;
      addr_inc = 1;
      addr_rom_inc = 1;
    end
    default: begin
      nxt_state = BUSY;
      if (addr_cnt_10 < 4'hA) begin
        addr_inc = 1;
        addr_rom_inc = 1;
      end
    end
  endcase
end
*/
endmodule
