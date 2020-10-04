module layer_1(clk, rst_n, strt, din_0, din_1, tx_done, addr_rd_inc, rd, dout);
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
    if (addr_rd_inc)
      addr_rd_cnt <= addr_rd_mod ? 4'h0 : addr_rd_cnt + 4'h1;
  end

  always @(posedge clk, negedge rst_n) begin
    if (!rst_n)
      addr_rd <= 8'h1C;
    else if (tx_done)
      addr_rd <= 8'h1C;
    else if (addr_rd_inc)
      addr_rd <= addr_rd_nxt;
  end


endmodule
