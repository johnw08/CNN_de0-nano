module layer_4(clk, rst_n, strt, din, tx_done, dout, addr_rd_inc, rd);
input clk, rst_n;
input strt;
input tx_done;
input [17:0] din[3:0];
output [17:0] dout[63:0];
output reg addr_rd_inc;
output rd;

reg wr, rd;
reg [35:0] din_ram[15:0];
wire [35:0] dout_ram[15:0];

reg addr_rom_inc;
reg [12:0] addr_rom_0;
reg [5:0] addr_rom_1;
wire [8:0] dout_rom_0[15:0];
wire [8:0] dout_rom_1[15:0];


reg [1:0] addr_din;
wire [17:0] din_mult;
wire [35:0] dout_mult[15:0];
wire [35:0] dout_add[15:0];
wire [35:0] dout_relu[15:0];

reg addr_inc;
reg [1:0] addr_cnt_4_din, addr_cnt_4_ram;
reg [4:0] addr_cnt_25;
reg [5:0] addr_cnt_64, addr_cnt_64_rom;
wire [35:0] accum[15:0];
wire last;
genvar i;

typedef enum reg [1:0]{IDLE, WAIT, BUSY} state_t;
state_t state, nxt_state;


l4_ram l4_ram(.clk(clk), .wr(wr), .addr_wr(addr_cnt_64)
            , .din(din_ram), .dout(dout), .dout_wr(dout_ram));

l4_rom_0 l4_Weight(.clk(clk), .addr(addr_rom_0), .dout(dout_rom_0));

l4_rom_1 l4_bias(.clk(clk), .addr(addr_rom_1), .dout(dout_rom_1));

l4_mult l4_mult(.din(din_mult), .weight(dout_rom_0), .dout(dout_mult));

l4_add l4_add_bias(.din(accum), .bias(dout_rom_1), .dout(dout_add));

l4_relu l4_relu(.din(dout_add), .dout(dout_relu));


assign din_ram = last ? dout_relu : accum;

assign din_mult = din[addr_cnt_4_din];

generate
  for (i = 0; i < 16; i++) begin: accum_for
    assign accum[i] = dout_ram[i] + dout_mult[i];
  end
endgenerate

assign last = addr_cnt_25 == 5'h18 && addr_cnt_4_din == 2'h3;

assign rd = addr_cnt_25 == 5'h19;

always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    addr_rom_0 <= 13'h0;
  else if (tx_done)
    addr_rom_0 <= 13'h0;
  else if (addr_rom_inc)
    addr_rom_0 <= addr_rom_0 + 13'h10;
end

always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    addr_rom_1 <= 6'h0;
  else if (tx_done)
    addr_rom_1 <= 6'h0;
  else if (addr_rom_inc)
    addr_rom_1 <= addr_rom_1 + 6'h10;
end

always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    addr_cnt_4_din <= 2'h0;
  else if (tx_done)
    addr_cnt_4_din <= 2'h0;
  else if (addr_inc && addr_cnt_4_ram == 2'h3)
    addr_cnt_4_din <= addr_cnt_4_din + 2'h1;
end

always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    addr_cnt_64 <= 6'h0;
  else if (tx_done)
    addr_cnt_64 <= 6'h0;
  else if (addr_inc)
    addr_cnt_64 <= addr_cnt_64 + 6'h10;
end

always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    addr_cnt_4_ram <= 2'h0;
  else if (tx_done)
    addr_cnt_4_ram <= 2'h0;
  else if (addr_inc)
    addr_cnt_4_ram <= addr_cnt_4_ram + 2'h1;
end

always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    addr_cnt_25 <= 5'h0;
  else if (tx_done)
    addr_cnt_25 <= 5'h0;
  else if (addr_rd_inc)
    addr_cnt_25 <= addr_cnt_25 + 5'h1;
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
  addr_rd_inc = 0;
  addr_rom_inc = 0;
  wr = 0;
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
      wr = 1;
    end
    default: begin
      addr_inc = 1;
      wr = 1;
      if (addr_cnt_4_din == 2'h3 && addr_cnt_4_ram == 2'h3)
        addr_rd_inc = 1;
      else begin
        nxt_state = BUSY;
        addr_rom_inc = 1;
      end
    end
  endcase
end



endmodule
