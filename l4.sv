module layer_4(clk, rst_n, strt, din, tx_done, dout, rdy, trmt, q);
input clk, rst_n;
input strt;
input tx_done;
input signed [17:0] din;
output [17:0] dout[15:0];
output rdy;
output trmt;
output [35:0] q;

reg wr;
reg [1:0] addr_wr, addr_rd;
wire [1:0] addr_rd_ram; 
wire [35:0] din_ram[15:0];
wire [35:0] dout_ram[15:0];

l4_ram l4_ram_0(.clk(clk), .wr(wr), .addr_wr(addr_wr), .addr_rd(addr_rd_ram), .din(din_ram[0]), .dout(dout_ram[0]));
l4_ram l4_ram_1(.clk(clk), .wr(wr), .addr_wr(addr_wr), .addr_rd(addr_rd_ram), .din(din_ram[1]), .dout(dout_ram[1]));
l4_ram l4_ram_2(.clk(clk), .wr(wr), .addr_wr(addr_wr), .addr_rd(addr_rd_ram), .din(din_ram[2]), .dout(dout_ram[2]));
l4_ram l4_ram_3(.clk(clk), .wr(wr), .addr_wr(addr_wr), .addr_rd(addr_rd_ram), .din(din_ram[3]), .dout(dout_ram[3]));
l4_ram l4_ram_4(.clk(clk), .wr(wr), .addr_wr(addr_wr), .addr_rd(addr_rd_ram), .din(din_ram[4]), .dout(dout_ram[4]));
l4_ram l4_ram_5(.clk(clk), .wr(wr), .addr_wr(addr_wr), .addr_rd(addr_rd_ram), .din(din_ram[5]), .dout(dout_ram[5]));
l4_ram l4_ram_6(.clk(clk), .wr(wr), .addr_wr(addr_wr), .addr_rd(addr_rd_ram), .din(din_ram[6]), .dout(dout_ram[6]));
l4_ram l4_ram_7(.clk(clk), .wr(wr), .addr_wr(addr_wr), .addr_rd(addr_rd_ram), .din(din_ram[7]), .dout(dout_ram[7]));
l4_ram l4_ram_8(.clk(clk), .wr(wr), .addr_wr(addr_wr), .addr_rd(addr_rd_ram), .din(din_ram[8]), .dout(dout_ram[8]));
l4_ram l4_ram_9(.clk(clk), .wr(wr), .addr_wr(addr_wr), .addr_rd(addr_rd_ram), .din(din_ram[9]), .dout(dout_ram[9]));
l4_ram l4_ram_10(.clk(clk), .wr(wr), .addr_wr(addr_wr), .addr_rd(addr_rd_ram), .din(din_ram[10]), .dout(dout_ram[10]));
l4_ram l4_ram_11(.clk(clk), .wr(wr), .addr_wr(addr_wr), .addr_rd(addr_rd_ram), .din(din_ram[11]), .dout(dout_ram[11]));
l4_ram l4_ram_12(.clk(clk), .wr(wr), .addr_wr(addr_wr), .addr_rd(addr_rd_ram), .din(din_ram[12]), .dout(dout_ram[12]));
l4_ram l4_ram_13(.clk(clk), .wr(wr), .addr_wr(addr_wr), .addr_rd(addr_rd_ram), .din(din_ram[13]), .dout(dout_ram[13]));
l4_ram l4_ram_14(.clk(clk), .wr(wr), .addr_wr(addr_wr), .addr_rd(addr_rd_ram), .din(din_ram[14]), .dout(dout_ram[14]));
l4_ram l4_ram_15(.clk(clk), .wr(wr), .addr_wr(addr_wr), .addr_rd(addr_rd_ram), .din(din_ram[15]), .dout(dout_ram[15]));

//genvar n;
//generate
//	for (n = 0; n < 16; n = n + 1) begin: dout_g
//		assign dout[n] = dout_ram[n][17:0];
//	end
//endgenerate


wire [8:0] dout_rom[15:0];
reg [8:0] addr_rd_rom;
l4_rom_0 l4_rom_0(.clk(clk), .addr_rd(addr_rd_rom), .dout(dout_rom[0]));
l4_rom_1 l4_rom_1(.clk(clk), .addr_rd(addr_rd_rom), .dout(dout_rom[1]));
l4_rom_2 l4_rom_2(.clk(clk), .addr_rd(addr_rd_rom), .dout(dout_rom[2]));
l4_rom_3 l4_rom_3(.clk(clk), .addr_rd(addr_rd_rom), .dout(dout_rom[3]));
l4_rom_4 l4_rom_4(.clk(clk), .addr_rd(addr_rd_rom), .dout(dout_rom[4]));
l4_rom_5 l4_rom_5(.clk(clk), .addr_rd(addr_rd_rom), .dout(dout_rom[5]));
l4_rom_6 l4_rom_6(.clk(clk), .addr_rd(addr_rd_rom), .dout(dout_rom[6]));
l4_rom_7 l4_rom_7(.clk(clk), .addr_rd(addr_rd_rom), .dout(dout_rom[7]));
l4_rom_8 l4_rom_8(.clk(clk), .addr_rd(addr_rd_rom), .dout(dout_rom[8]));
l4_rom_9 l4_rom_9(.clk(clk), .addr_rd(addr_rd_rom), .dout(dout_rom[9]));
l4_rom_10 l4_rom_10(.clk(clk), .addr_rd(addr_rd_rom), .dout(dout_rom[10]));
l4_rom_11 l4_rom_11(.clk(clk), .addr_rd(addr_rd_rom), .dout(dout_rom[11]));
l4_rom_12 l4_rom_12(.clk(clk), .addr_rd(addr_rd_rom), .dout(dout_rom[12]));
l4_rom_13 l4_rom_13(.clk(clk), .addr_rd(addr_rd_rom), .dout(dout_rom[13]));
l4_rom_14 l4_rom_14(.clk(clk), .addr_rd(addr_rd_rom), .dout(dout_rom[14]));
l4_rom_15 l4_rom_15(.clk(clk), .addr_rd(addr_rd_rom), .dout(dout_rom[15]));

reg addr_rom_inc;
always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    addr_rd_rom <= 9'h0;
  else if (tx_done)
    addr_rd_rom <= 9'h0;
  else if (addr_rom_inc)
    addr_rd_rom <= addr_rd_rom + 9'h1;
end

wire signed [17:0] dout_rom_ex[15:0];
genvar i;
generate
  for (i = 0; i < 16; i = i + 1) begin: dout_rom_ex_g
    assign dout_rom_ex[i] = {{9{dout_rom[i][8]}}, dout_rom[i][8:0]};
  end
endgenerate

reg cnt_100_inc;
reg [6:0] cnt_100;
always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    cnt_100 <= 7'h0;
  else if (tx_done)
    cnt_100 <= 7'h0;
  else if (cnt_100_inc)
    cnt_100 <= cnt_100 + 7'h1;
end


wire signed [35:0] mult[15:0];
wire [35:0] accum[15:0];
genvar j;
generate
  for (j = 0; j < 16; j = j + 1) begin: mult_g
    assign mult[j] = din * dout_rom_ex[j];
    assign accum[j] = cnt_100 == 7'h0 ? mult[j] : mult[j] + dout_ram[j];
  end
endgenerate

reg [1:0] addr_rd_bias;
wire [8:0] dout_bias[15:0];
l4_rom_b0 l4_rom_b0(.clk(clk), .addr_rd(addr_rd_bias), .dout(dout_bias[0]));
l4_rom_b1 l4_rom_b1(.clk(clk), .addr_rd(addr_rd_bias), .dout(dout_bias[1]));
l4_rom_b2 l4_rom_b2(.clk(clk), .addr_rd(addr_rd_bias), .dout(dout_bias[2]));
l4_rom_b3 l4_rom_b3(.clk(clk), .addr_rd(addr_rd_bias), .dout(dout_bias[3]));
l4_rom_b4 l4_rom_b4(.clk(clk), .addr_rd(addr_rd_bias), .dout(dout_bias[4]));
l4_rom_b5 l4_rom_b5(.clk(clk), .addr_rd(addr_rd_bias), .dout(dout_bias[5]));
l4_rom_b6 l4_rom_b6(.clk(clk), .addr_rd(addr_rd_bias), .dout(dout_bias[6]));
l4_rom_b7 l4_rom_b7(.clk(clk), .addr_rd(addr_rd_bias), .dout(dout_bias[7]));
l4_rom_b8 l4_rom_b8(.clk(clk), .addr_rd(addr_rd_bias), .dout(dout_bias[8]));
l4_rom_b9 l4_rom_b9(.clk(clk), .addr_rd(addr_rd_bias), .dout(dout_bias[9]));
l4_rom_b10 l4_rom_b10(.clk(clk), .addr_rd(addr_rd_bias), .dout(dout_bias[10]));
l4_rom_b11 l4_rom_b11(.clk(clk), .addr_rd(addr_rd_bias), .dout(dout_bias[11]));
l4_rom_b12 l4_rom_b12(.clk(clk), .addr_rd(addr_rd_bias), .dout(dout_bias[12]));
l4_rom_b13 l4_rom_b13(.clk(clk), .addr_rd(addr_rd_bias), .dout(dout_bias[13]));
l4_rom_b14 l4_rom_b14(.clk(clk), .addr_rd(addr_rd_bias), .dout(dout_bias[14]));
l4_rom_b15 l4_rom_b15(.clk(clk), .addr_rd(addr_rd_bias), .dout(dout_bias[15]));

wire signed [35:0] bias[15:0];
wire [35:0] relu[15:0];
genvar k;
generate
  for (k = 0; k < 16; k = k + 1) begin: bias_g
    assign bias[k] = accum[k] + {{27{dout_bias[k][8]}}, dout_bias[k][8:0]};
    assign relu[k] = bias[k] > 0 ? bias[k] : 36'h0;
  end
endgenerate

genvar m;
generate
  for (m = 0; m < 16; m = m + 1) begin: din_ram_g
    assign din_ram[m] = cnt_100 == 7'h63 ? relu[m] : accum[m];
  end
endgenerate

typedef enum reg [2:0] {INI, ONE, TWO, THREE, FOUR} state_wr_t;
state_wr_t state_wr, nxt_state_wr;
always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    state_wr <= INI;
  else if (tx_done)
    state_wr <= INI;
  else
    state_wr <= nxt_state_wr;
end

always_comb begin
  nxt_state_wr = INI;
  addr_wr = 2'h0;
  addr_rd = 2'h0;
  addr_rd_bias = 2'h0;
  addr_rom_inc = 0;
  cnt_100_inc = 0;
  wr = 0;

  case(state_wr)
    INI: begin
      if (strt) begin
        nxt_state_wr = ONE;
        addr_rd_bias = 2'h0;
        addr_rom_inc = 1;
        addr_rd = 2'h0;
      end
    end
    ONE: begin
      nxt_state_wr = TWO;
      addr_rd_bias = 2'h1;
      addr_rom_inc = 1;
      addr_wr = 2'h0;
      addr_rd = 2'h1;
      wr = 1;
    end
    TWO: begin
      nxt_state_wr = THREE;
      addr_rd_bias = 2'h2;
      addr_rom_inc = 1;
      addr_wr = 2'h1;
      addr_rd = 2'h2;
      wr = 1;
    end
    THREE: begin
      nxt_state_wr = FOUR;
      addr_rd_bias = 2'h3;
      addr_rom_inc = 1;
      addr_wr = 2'h2;
      addr_rd = 2'h3;
      wr = 1;
    end
    default: begin
      cnt_100_inc = 1;
      addr_wr = 2'h3;
      wr = 1;
    end
  endcase
end

wire [35:0] sum;
reg temp_inc;
reg [35:0] temp;
always@(posedge clk, negedge rst_n) begin
	if (!rst_n) 
		temp <= 36'h0;
	else if (temp_inc)
		temp <= sum + temp;
end

assign q = temp;

reg a;
reg a_inc;
always@(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		a <= 0;
	end
	else if (a_inc)
		a<= 1;
end

assign trmt = cnt_100 >= 7'h64 && a == 1;

assign sum = dout_ram[0]+dout_ram[1]+
dout_ram[2]+dout_ram[3]+dout_ram[4]+dout_ram[5]+dout_ram[6]+dout_ram[7]+dout_ram[8]+dout_ram[9]+dout_ram[10]+
dout_ram[11]+dout_ram[12]+dout_ram[13]+dout_ram[14]+dout_ram[15];
typedef enum reg [2:0] {I, O, TW, TH, F} s_t;
s_t state, nxt_state;
always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    state <= I;
  else if (tx_done)
    state <= I;
  else
    state <= nxt_state;
end
reg [1:0]addr;
always_comb begin
		nxt_state = I;
		temp_inc = 0;
		a_inc = 0;
		addr = 2'h0;
		case(state)
			I: begin
				if (cnt_100 == 7'h64) begin
					nxt_state = O;
					addr = 2'h0;
				end
			end
			O: begin
				nxt_state = TW;
				addr = 2'h1;
				temp_inc = 1;
			end
			TW:begin
				nxt_state = TH;
				addr = 2'h2;
				temp_inc = 1;
			
			end
			TH: begin
				nxt_state = F;
				addr = 2'h3;
				temp_inc = 1;
			end
			default: begin
				temp_inc = 1;
				a_inc = 1;
				
			end
		endcase
end

assign addr_rd_ram = cnt_100 >= 7'h64 ? addr : addr_rd;


/*
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

*/

endmodule
