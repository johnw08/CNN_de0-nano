/*
  Output layer
*/
module layer_5(clk, rst_n, strt, din, tx_done, trmt, dout, addr);
input clk, rst_n;
input strt;
input tx_done;
input signed [17:0] din[15:0];
input [9:0] addr;
output trmt;
output [7:0] dout;

reg cnt_10_inc;
reg [3:0] cnt_10;
always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    cnt_10 <= 4'h0;
  else if (trmt)
    cnt_10 <= 4'h0;
  else if (cnt_10_inc)
    cnt_10 <= cnt_10 + 4'h1;
end

reg [5:0] addr_rd;
reg [8:0] dout_rom[15:0];
rom #(.file("l5_W0.txt"), .ADDR_WIDTH(6), .DATA_WIDTH(9)) l5_rom_w0(.clk(clk), .addr_rd(addr_rd), .dout(dout_rom[0]));
rom #(.file("l5_W1.txt"), .ADDR_WIDTH(6), .DATA_WIDTH(9)) l5_rom_w1(.clk(clk), .addr_rd(addr_rd), .dout(dout_rom[1]));
rom #(.file("l5_W2.txt"), .ADDR_WIDTH(6), .DATA_WIDTH(9)) l5_rom_w2(.clk(clk), .addr_rd(addr_rd), .dout(dout_rom[2]));
rom #(.file("l5_W3.txt"), .ADDR_WIDTH(6), .DATA_WIDTH(9)) l5_rom_w3(.clk(clk), .addr_rd(addr_rd), .dout(dout_rom[3]));
rom #(.file("l5_W4.txt"), .ADDR_WIDTH(6), .DATA_WIDTH(9)) l5_rom_w4(.clk(clk), .addr_rd(addr_rd), .dout(dout_rom[4]));
rom #(.file("l5_W5.txt"), .ADDR_WIDTH(6), .DATA_WIDTH(9)) l5_rom_w5(.clk(clk), .addr_rd(addr_rd), .dout(dout_rom[5]));
rom #(.file("l5_W6.txt"), .ADDR_WIDTH(6), .DATA_WIDTH(9)) l5_rom_w6(.clk(clk), .addr_rd(addr_rd), .dout(dout_rom[6]));
rom #(.file("l5_W7.txt"), .ADDR_WIDTH(6), .DATA_WIDTH(9)) l5_rom_w7(.clk(clk), .addr_rd(addr_rd), .dout(dout_rom[7]));
rom #(.file("l5_W8.txt"), .ADDR_WIDTH(6), .DATA_WIDTH(9)) l5_rom_w8(.clk(clk), .addr_rd(addr_rd), .dout(dout_rom[8]));
rom #(.file("l5_W9.txt"), .ADDR_WIDTH(6), .DATA_WIDTH(9)) l5_rom_w9(.clk(clk), .addr_rd(addr_rd), .dout(dout_rom[9]));
rom #(.file("l5_W10.txt"), .ADDR_WIDTH(6), .DATA_WIDTH(9)) l5_rom_w10(.clk(clk), .addr_rd(addr_rd), .dout(dout_rom[10]));
rom #(.file("l5_W11.txt"), .ADDR_WIDTH(6), .DATA_WIDTH(9)) l5_rom_w11(.clk(clk), .addr_rd(addr_rd), .dout(dout_rom[11]));
rom #(.file("l5_W12.txt"), .ADDR_WIDTH(6), .DATA_WIDTH(9)) l5_rom_w12(.clk(clk), .addr_rd(addr_rd), .dout(dout_rom[12]));
rom #(.file("l5_W13.txt"), .ADDR_WIDTH(6), .DATA_WIDTH(9)) l5_rom_w13(.clk(clk), .addr_rd(addr_rd), .dout(dout_rom[13]));
rom #(.file("l5_W14.txt"), .ADDR_WIDTH(6), .DATA_WIDTH(9)) l5_rom_w14(.clk(clk), .addr_rd(addr_rd), .dout(dout_rom[14]));
rom #(.file("l5_W15.txt"), .ADDR_WIDTH(6), .DATA_WIDTH(9)) l5_rom_w15(.clk(clk), .addr_rd(addr_rd), .dout(dout_rom[15]));

reg addr_rd_inc;
always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    addr_rd <= 6'h0;
  else if (trmt)
    addr_rd <= 6'h0;
  else if (addr_rd_inc)
    addr_rd <= addr_rd + 6'h1;
end

wire signed [17:0] dout_rom_ex[15:0];
wire signed [35:0] mult[15:0];
genvar i;
generate
  for (i = 0; i < 16; i = i + 1) begin: mult_g
    assign dout_rom_ex[i] = {{9{dout_rom[i][8]}}, dout_rom[i][8:0]};
    assign mult[i] = din[i] * dout_rom_ex[i];
  end
endgenerate

wire [35:0] sum;
assign sum = mult[0] + mult[1] + mult[2] + mult[3] + mult[4] + mult[5]
            + mult[6] + mult[7] + mult[8] + mult[9] + mult[10] + mult[11]
            + mult[12] + mult[13] + mult[14] + mult[15];

wire [8:0] dout_bias;
rom #(.file("l5_B.txt"), .ADDR_WIDTH(4), .DATA_WIDTH(9)) l5_rom_b(.clk(clk)
    , .addr_rd(cnt_10), .dout(dout_bias));

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
assign bias = temp + {{27{dout_bias[8]}}, dout_bias[8:0]};

wire signed [35:0] relu;
assign relu = bias > 0 ? bias : 36'h0;

wire greater;
reg update;
reg [3:0] digit_max;
always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    digit_max <= 4'h0;
  else if (trmt)
    digit_max <= 4'h0;
  else if (update && greater)
    digit_max <= cnt_10;
end

reg signed [35:0] dout_max;
always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    dout_max <= 36'h0;
  else if (trmt)
    dout_max <= 36'h0;
  else if (update && greater)
    dout_max <= relu;
end

assign greater = relu > dout_max;

typedef enum reg [2:0] {IDLE, ONE, TWO, THREE, FOUR, FIVE} state_t;
state_t state, nxt_state;
always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    state <= IDLE;
  else if (trmt)
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
      if (cnt_10 == 4'hA) begin
        nxt_state = ONE;
      end
		  else begin
			   nxt_state = TWO;
			   addr_rd_inc = 1;
		  end
    end
    TWO: begin
      nxt_state = THREE;
      addr_rd_inc = 1;
    end
    THREE: begin
      nxt_state = FOUR;
      addr_rd_inc = 1;
    end
    FOUR: begin
      nxt_state = FIVE;
    end
    default: begin
      nxt_state = ONE;
      addr_rd_inc = 1;
      update = 1;
      temp_init = 1;
      cnt_10_inc = 1;
    end
  endcase
end

assign trmt = cnt_10 == 4'hA && addr == 10'h310;
assign dout = {{4'b0}, digit_max[3:0]};
endmodule
