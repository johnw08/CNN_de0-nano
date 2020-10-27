module layer_1(clk, rst_n, strt, din_0, din_1, tx_done, bsy_in, rdy, dout_0, dout_1);
input clk, rst_n;
input strt;
input bsy_in;
input tx_done;
input signed [17:0] din_0;
input signed [17:0] din_1;
output rdy;
output [17:0] dout_0, dout_1;

wire [17:0] comp_0, comp_1;
reg wr;
reg [7:0] addr_wr, addr_rd;

// l1_ram l1_ram_0(.clk(clk), .wr(wr), .addr_wr(addr_wr), .addr_rd(addr_rd)
//               , .din(comp_0), .dout(dout_0));
//
// l1_ram l1_ram_1(.clk(clk), .wr(wr), .addr_wr(addr_wr), .addr_rd(addr_rd)
//               , .din(comp_1), .dout(dout_1));

ram #(.ADDR_WIDTH(8), .DATA_WIDTH(18)) l1_ram_0(.clk(clk), .wr(wr)
    , .addr_wr(addr_wr), .addr_rd(addr_rd), .din(comp_0), .dout(dout_0));

ram #(.ADDR_WIDTH(8), .DATA_WIDTH(18)) l1_ram_1(.clk(clk), .wr(wr)
    , .addr_wr(addr_wr), .addr_rd(addr_rd), .din(comp_1), .dout(dout_1));

reg addr_wr_inc;
always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    addr_wr <= 8'h0;
  else if (tx_done)
    addr_wr <= 8'h0;
  else if (addr_wr_inc)
    addr_wr <= addr_wr + 8'h1;
end

reg temp_clr;
reg signed [17:0] temp_0;
reg signed [17:0] temp_1;
assign comp_0 = din_0 > temp_0 ? din_0 : temp_0;
assign comp_1 = din_1 > temp_1 ? din_1 : temp_1;
always @ (posedge clk) begin
  if (temp_clr) begin
    temp_0 <= 18'h0;
    temp_1 <= 18'h0;
  end
  else begin
    temp_0 <= comp_0;
    temp_1 <= comp_1;
  end
end

typedef enum reg [2:0] {IDLE, ONE, TWO, THREE, FOUR} state_wr_t;
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
 temp_clr = 0;
 wr = 0;

 case (state_wr)
  IDLE: begin
    if (strt) begin
      nxt_state_wr = ONE;
      temp_clr = 1;
    end
  end
  ONE: begin
    nxt_state_wr = TWO;
  end
  TWO: begin
    nxt_state_wr = THREE;
  end
  THREE: begin
    nxt_state_wr = FOUR;
  end
  default: begin
    addr_wr_inc = 1;
    wr = 1;
  end
 endcase
end


// Read DATA
reg [3:0] cnt_10;
reg addr_rd_inc;
always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    cnt_10 <= 4'h0;
  else if (tx_done)
    cnt_10 <= 4'h0;
  else if (addr_rd_inc)
    cnt_10 <= cnt_10 == 4'hA ? 4'h0 : cnt_10 + 4'h1;
end

reg [7:0] addr_rd_ram;
assign rdy = addr_rd_ram < addr_wr;
always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    addr_rd_ram <= 8'h1C;
  else if (tx_done)
    addr_rd_ram <= 8'h1C;
  else if (addr_rd_inc)
    addr_rd_ram <=  cnt_10 == 4'hA ? addr_rd_ram + 8'h3 : addr_rd_ram + 8'h1;
end

typedef enum reg [3:0] {INI, ON, TW, TH, FO, FI, SI, SE, EI, NI} state_rd_t;
state_rd_t state_rd, nxt_state_rd;
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
  addr_rd = 8'h0;

  case(state_rd)
    INI: begin
      if (rdy && !bsy_in) begin
        nxt_state_rd = ON;
        addr_rd = addr_rd_ram - 8'h1C;
      end
    end
    ON: begin
      nxt_state_rd = TW;
      addr_rd = addr_rd_ram - 8'h1B;
    end
    TW: begin
      nxt_state_rd = TH;
      addr_rd = addr_rd_ram - 8'h1A;
    end
    TH: begin
      nxt_state_rd = FO;
      addr_rd = addr_rd_ram - 8'h0F;
    end
    FO: begin
      nxt_state_rd = FI;
      addr_rd = addr_rd_ram - 8'h0E;
    end
    FI: begin
      nxt_state_rd = SI;
      addr_rd = addr_rd_ram - 8'h0D;
    end
    SI: begin
      nxt_state_rd = SE;
      addr_rd = addr_rd_ram - 8'h02;
    end
    SE: begin
      nxt_state_rd = EI;
      addr_rd = addr_rd_ram - 8'h01;
    end
    EI: begin
      nxt_state_rd = NI;
      addr_rd = addr_rd_ram;
    end
    default: begin
      addr_rd_inc = 1;
    end
   endcase
end

/*
  input clk, rst_n;
  input strt;
  input tx_done;
  input addr_rd_inc;
  input signed [17:0] din_0[3:0];
  input signed [17:0] din_1[3:0];
  output rd;
  output [17:0] dout[17:0];

  reg [7:0] addr_wr, addr_rd;
  wire [7:0] addr_rd_nxt;
  wire signed [17:0] din_0_max, din_1_max;
  wire [17:0] dout_0[8:0], dout_1[8:0];

  wire [17:0] din_0_max_01, din_0_max_23;
  wire [17:0] din_1_max_01, din_1_max_23;

  reg [3:0] addr_rd_cnt;
  wire addr_rd_mod;

  l1_ram l1_ram_0(.clk(clk), .wr(strt), .addr_wr(addr_wr), .din(din_0_max)
                , .addr_rd(addr_rd), .dout(dout_0));
  l1_ram l1_ram_1(.clk(clk), .wr(strt), .addr_wr(addr_wr), .din(din_1_max)
                , .addr_rd(addr_rd), .dout(dout_1));

  assign din_0_max_01 = din_0[0] > din_0[1] ? din_0[0] : din_0[1];
  assign din_0_max_23 = din_0[2] > din_0[3] ? din_0[2] : din_0[3];
  assign din_0_max = din_0_max_01 > din_0_max_23 ? din_0_max_01 : din_0_max_23;

  assign din_1_max_01 = din_1[0] > din_1[1] ? din_1[0] : din_1[1];
  assign din_1_max_23 = din_1[2] > din_1[3] ? din_1[2] : din_1[3];
  assign din_1_max = din_1_max_01 > din_1_max_23 ? din_1_max_01 : din_1_max_23;

  assign rd = addr_rd < addr_wr;
  assign addr_rd_mod = addr_rd_cnt == 4'hA;
  assign addr_rd_nxt = addr_rd_mod ? addr_rd + 8'h3 : addr_rd + 8'h1;


  genvar i;
  generate
  	for (i = 0; i < 9; i=i+1) begin: dout_for
  		assign dout[i] = dout_0[i];
  		assign dout[i+9] = dout_1[i];
  	end
  endgenerate

  always @(posedge clk, negedge rst_n) begin
    if (!rst_n)
      addr_wr <= 8'h0;
	 else if (tx_done)
		addr_wr <= 8'h0;
    else if (strt)
      addr_wr <= addr_wr + 8'h1;
  end

  always @(posedge clk, negedge rst_n) begin
    if (!rst_n)
      addr_rd_cnt <= 4'h0;
    else if (tx_done)
      addr_rd_cnt <= 4'h0;
    else if (addr_rd_inc)
      addr_rd_cnt <= addr_rd_mod ? 4'h0 : addr_rd_cnt + 4'h1;
  end

  always @(posedge clk, negedge rst_n) begin
    if (!rst_n)
      addr_rd <= `8'h1C`;
    else if (tx_done)
      addr_rd <= 8'h1C;
    else if (addr_rd_inc)
      addr_rd <= addr_rd_nxt;
  end

*/
endmodule
