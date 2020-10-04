module layer_5(clk, rst_n, strt, din, tx_done, rd, dout);
input clk, rst_n;
input strt;
input tx_done;
input [17:0] din[63:0];
output rd;
output [7:0] dout;


reg addr_rom_inc;
reg [9:0] addr_rom_0;
wire [8:0] dout_rom_0[31:0];
wire [8:0] dout_rom_1[10:0];

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

endmodule
