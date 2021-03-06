/*
  Fully connected layer
*/
module layer_4(clk, rst_n, strt, din, tx_done, dout, rdy);
input clk, rst_n;
input strt;
input tx_done;
input signed [17:0] din;
output [17:0] dout[15:0];
output rdy;

reg wr;
reg [1:0] addr_wr;
wire [1:0] addr_rd;
wire [1:0] addr_rd_ram;
wire [35:0] din_ram[15:0];
wire [35:0] dout_ram[15:0];

genvar a;
generate
  for (a = 0; a < 16; a = a + 1) begin: l4_ram
    ram #(.ADDR_WIDTH(2), .DATA_WIDTH(36)) l4_ram(.clk(clk), .wr(wr)
        , .addr_wr(addr_wr), .addr_rd(addr_rd), .din(din_ram[a])
        , .dout(dout_ram[a]));
  end
endgenerate

genvar n;
generate
	for (n = 0; n < 16; n = n + 1) begin: dout_g
		assign dout[n] = dout_ram[n][17:0];
	end
endgenerate

wire [8:0] dout_rom[15:0];
reg [8:0] addr_rd_rom;
rom #(.file("./ml_params/l4_weight_0.txt"), .ADDR_WIDTH(9), .DATA_WIDTH(9)) l4_rom_w0(.clk(clk), .addr_rd(addr_rd_rom), .dout(dout_rom[0]));
rom #(.file("./ml_params/l4_weight_1.txt"), .ADDR_WIDTH(9), .DATA_WIDTH(9)) l4_rom_w1(.clk(clk), .addr_rd(addr_rd_rom), .dout(dout_rom[1]));
rom #(.file("./ml_params/l4_weight_2.txt"), .ADDR_WIDTH(9), .DATA_WIDTH(9)) l4_rom_w2(.clk(clk), .addr_rd(addr_rd_rom), .dout(dout_rom[2]));
rom #(.file("./ml_params/l4_weight_3.txt"), .ADDR_WIDTH(9), .DATA_WIDTH(9)) l4_rom_w3(.clk(clk), .addr_rd(addr_rd_rom), .dout(dout_rom[3]));
rom #(.file("./ml_params/l4_weight_4.txt"), .ADDR_WIDTH(9), .DATA_WIDTH(9)) l4_rom_w4(.clk(clk), .addr_rd(addr_rd_rom), .dout(dout_rom[4]));
rom #(.file("./ml_params/l4_weight_5.txt"), .ADDR_WIDTH(9), .DATA_WIDTH(9)) l4_rom_w5(.clk(clk), .addr_rd(addr_rd_rom), .dout(dout_rom[5]));
rom #(.file("./ml_params/l4_weight_6.txt"), .ADDR_WIDTH(9), .DATA_WIDTH(9)) l4_rom_w6(.clk(clk), .addr_rd(addr_rd_rom), .dout(dout_rom[6]));
rom #(.file("./ml_params/l4_weight_7.txt"), .ADDR_WIDTH(9), .DATA_WIDTH(9)) l4_rom_w7(.clk(clk), .addr_rd(addr_rd_rom), .dout(dout_rom[7]));
rom #(.file("./ml_params/l4_weight_8.txt"), .ADDR_WIDTH(9), .DATA_WIDTH(9)) l4_rom_w8(.clk(clk), .addr_rd(addr_rd_rom), .dout(dout_rom[8]));
rom #(.file("./ml_params/l4_weight_9.txt"), .ADDR_WIDTH(9), .DATA_WIDTH(9)) l4_rom_w9(.clk(clk), .addr_rd(addr_rd_rom), .dout(dout_rom[9]));
rom #(.file("./ml_params/l4_weight_10.txt"), .ADDR_WIDTH(9), .DATA_WIDTH(9)) l4_rom_w10(.clk(clk), .addr_rd(addr_rd_rom), .dout(dout_rom[10]));
rom #(.file("./ml_params/l4_weight_11.txt"), .ADDR_WIDTH(9), .DATA_WIDTH(9)) l4_rom_w11(.clk(clk), .addr_rd(addr_rd_rom), .dout(dout_rom[11]));
rom #(.file("./ml_params/l4_weight_12.txt"), .ADDR_WIDTH(9), .DATA_WIDTH(9)) l4_rom_w12(.clk(clk), .addr_rd(addr_rd_rom), .dout(dout_rom[12]));
rom #(.file("./ml_params/l4_weight_13.txt"), .ADDR_WIDTH(9), .DATA_WIDTH(9)) l4_rom_w13(.clk(clk), .addr_rd(addr_rd_rom), .dout(dout_rom[13]));
rom #(.file("./ml_params/l4_weight_14.txt"), .ADDR_WIDTH(9), .DATA_WIDTH(9)) l4_rom_w14(.clk(clk), .addr_rd(addr_rd_rom), .dout(dout_rom[14]));
rom #(.file("./ml_params/l4_weight_15.txt"), .ADDR_WIDTH(9), .DATA_WIDTH(9)) l4_rom_w15(.clk(clk), .addr_rd(addr_rd_rom), .dout(dout_rom[15]));

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
rom #(.file("./ml_params/l4_bias_0.txt"), .ADDR_WIDTH(2), .DATA_WIDTH(9)) l4_rom_b0(.clk(clk), .addr_rd(addr_rd_bias), .dout(dout_bias[0]));
rom #(.file("./ml_params/l4_bias_1.txt"), .ADDR_WIDTH(2), .DATA_WIDTH(9)) l4_rom_b1(.clk(clk), .addr_rd(addr_rd_bias), .dout(dout_bias[1]));
rom #(.file("./ml_params/l4_bias_2.txt"), .ADDR_WIDTH(2), .DATA_WIDTH(9)) l4_rom_b2(.clk(clk), .addr_rd(addr_rd_bias), .dout(dout_bias[2]));
rom #(.file("./ml_params/l4_bias_3.txt"), .ADDR_WIDTH(2), .DATA_WIDTH(9)) l4_rom_b3(.clk(clk), .addr_rd(addr_rd_bias), .dout(dout_bias[3]));
rom #(.file("./ml_params/l4_bias_4.txt"), .ADDR_WIDTH(2), .DATA_WIDTH(9)) l4_rom_b4(.clk(clk), .addr_rd(addr_rd_bias), .dout(dout_bias[4]));
rom #(.file("./ml_params/l4_bias_5.txt"), .ADDR_WIDTH(2), .DATA_WIDTH(9)) l4_rom_b5(.clk(clk), .addr_rd(addr_rd_bias), .dout(dout_bias[5]));
rom #(.file("./ml_params/l4_bias_6.txt"), .ADDR_WIDTH(2), .DATA_WIDTH(9)) l4_rom_b6(.clk(clk), .addr_rd(addr_rd_bias), .dout(dout_bias[6]));
rom #(.file("./ml_params/l4_bias_7.txt"), .ADDR_WIDTH(2), .DATA_WIDTH(9)) l4_rom_b7(.clk(clk), .addr_rd(addr_rd_bias), .dout(dout_bias[7]));
rom #(.file("./ml_params/l4_bias_8.txt"), .ADDR_WIDTH(2), .DATA_WIDTH(9)) l4_rom_b8(.clk(clk), .addr_rd(addr_rd_bias), .dout(dout_bias[8]));
rom #(.file("./ml_params/l4_bias_9.txt"), .ADDR_WIDTH(2), .DATA_WIDTH(9)) l4_rom_b9(.clk(clk), .addr_rd(addr_rd_bias), .dout(dout_bias[9]));
rom #(.file("./ml_params/l4_bias_10.txt"), .ADDR_WIDTH(2), .DATA_WIDTH(9)) l4_rom_b10(.clk(clk), .addr_rd(addr_rd_bias), .dout(dout_bias[10]));
rom #(.file("./ml_params/l4_bias_11.txt"), .ADDR_WIDTH(2), .DATA_WIDTH(9)) l4_rom_b11(.clk(clk), .addr_rd(addr_rd_bias), .dout(dout_bias[11]));
rom #(.file("./ml_params/l4_bias_12.txt"), .ADDR_WIDTH(2), .DATA_WIDTH(9)) l4_rom_b12(.clk(clk), .addr_rd(addr_rd_bias), .dout(dout_bias[12]));
rom #(.file("./ml_params/l4_bias_13.txt"), .ADDR_WIDTH(2), .DATA_WIDTH(9)) l4_rom_b13(.clk(clk), .addr_rd(addr_rd_bias), .dout(dout_bias[13]));
rom #(.file("./ml_params/l4_bias_14.txt"), .ADDR_WIDTH(2), .DATA_WIDTH(9)) l4_rom_b14(.clk(clk), .addr_rd(addr_rd_bias), .dout(dout_bias[14]));
rom #(.file("./ml_params/l4_bias_15.txt"), .ADDR_WIDTH(2), .DATA_WIDTH(9)) l4_rom_b15(.clk(clk), .addr_rd(addr_rd_bias), .dout(dout_bias[15]));

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

reg [1:0] addr_rd_pre;
always_comb begin
  nxt_state_wr = INI;
  addr_wr = 2'h0;
  addr_rd_pre = 2'h0;
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
        addr_rd_pre = 2'h0;
      end
    end
    ONE: begin
      nxt_state_wr = TWO;
      addr_rd_bias = 2'h1;
      addr_rom_inc = 1;
      addr_wr = 2'h0;
      addr_rd_pre = 2'h1;
      wr = 1;
    end
    TWO: begin
      nxt_state_wr = THREE;
      addr_rd_bias = 2'h2;
      addr_rom_inc = 1;
      addr_wr = 2'h1;
      addr_rd_pre = 2'h2;
      wr = 1;
    end
    THREE: begin
      nxt_state_wr = FOUR;
      addr_rd_bias = 2'h3;
      addr_rom_inc = 1;
      addr_wr = 2'h2;
      addr_rd_pre = 2'h3;
      wr = 1;
    end
    default: begin
      cnt_100_inc = 1;
      addr_wr = 2'h3;
      wr = 1;
    end
  endcase
end


// Read DATA
assign rdy = cnt_100 == 7'h64;

typedef enum reg [2:0] {I, O, TW, TH, F} state_rd_t;
state_rd_t state_rd, nxt_state_rd;
always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    state_rd <= I;
  else if (tx_done)
    state_rd <= I;
  else
    state_rd <= nxt_state_rd;
end

reg [1:0]addr_rd_suc;
always_comb begin
		nxt_state_rd = I;
		addr_rd_suc = 2'h0;

		case(state_rd)
			I: begin
				if (rdy) begin
					nxt_state_rd = O;
					addr_rd_suc = 2'h0;
				end
			end
			O: begin
				nxt_state_rd = TW;
				addr_rd_suc = 2'h1;
			end
			TW:begin
				nxt_state_rd = TH;
				addr_rd_suc = 2'h2;

			end
			TH: begin
				nxt_state_rd = F;
				addr_rd_suc = 2'h3;
			end
			default: begin
        nxt_state_rd = I;
			end
		endcase
end

assign addr_rd = cnt_100 >= 7'h64 ? addr_rd_suc : addr_rd_pre;


endmodule
