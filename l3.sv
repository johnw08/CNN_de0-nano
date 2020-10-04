module layer_3(clk, rst_n, strt, din_0, din_1, din_2, din_3, tx_done, addr_rd_inc, rd, dout);
input clk, rst_n;
input strt;
input tx_done;
input addr_rd_inc;
input signed [17:0] din_0[3:0], din_1[3:0], din_2[3:0], din_3[3:0];
output rd;
output [17:0] dout[3:0];

reg [4:0] addr_ram_wr, addr_ram_rd;
reg [17:0] dout_ram_0, dout_ram_1, dout_ram_2, dout_ram_3;
wire [17:0] din_0_max, din_1_max, din_2_max, din_3_max;
wire signed [17:0] din_0_max_01, din_0_max_23;
wire signed [17:0] din_1_max_01, din_1_max_23;
wire signed [17:0] din_2_max_01, din_2_max_23;
wire signed [17:0] din_3_max_01, din_3_max_23;

l3_ram l3_ram_0(.clk(clk), .rst_n(rst_n), .wr(strt), .addr_wr(addr_ram_wr)
              , .din(din_0_max), .rd(rd), .addr_rd(addr_ram_rd)
              , .dout(dout_ram_0));
l3_ram l3_ram_1(.clk(clk), .rst_n(rst_n), .wr(strt), .addr_wr(addr_ram_wr)
              , .din(din_1_max), .rd(rd), .addr_rd(addr_ram_rd)
              , .dout(dout_ram_1));
l3_ram l3_ram_2(.clk(clk), .rst_n(rst_n), .wr(strt), .addr_wr(addr_ram_wr)
              , .din(din_2_max), .rd(rd), .addr_rd(addr_ram_rd)
              , .dout(dout_ram_2));
l3_ram l3_ram_3(.clk(clk), .rst_n(rst_n), .wr(strt), .addr_wr(addr_ram_wr)
              , .din(din_3_max), .rd(rd), .addr_rd(addr_ram_rd)
              , .dout(dout_ram_3));

assign dout = {dout_ram_3, dout_ram_2, dout_ram_1, dout_ram_0};

assign din_0_max_01 = din_0[0] > din_0[1] ? din_0[0] : din_0[1];
assign din_0_max_23 = din_0[2] > din_0[3] ? din_0[2] : din_0[3];
assign din_0_max = din_0_max_01 > din_0_max_23 ? din_0_max_01 : din_0_max_23;

assign din_1_max_01 = din_1[0] > din_1[1] ? din_1[0] : din_1[1];
assign din_1_max_23 = din_1[2] > din_1[3] ? din_1[2] : din_1[3];
assign din_1_max = din_1_max_01 > din_1_max_23 ? din_1_max_01 : din_1_max_23;

assign din_2_max_01 = din_2[0] > din_2[1] ? din_2[0] : din_2[1];
assign din_2_max_23 = din_2[2] > din_2[3] ? din_2[2] : din_2[3];
assign din_2_max = din_2_max_01 > din_2_max_23 ? din_2_max_01 : din_2_max_23;

assign din_3_max_01 = din_3[0] > din_3[1] ? din_3[0] : din_3[1];
assign din_3_max_23 = din_3[2] > din_3[3] ? din_3[2] : din_3[3];
assign din_3_max = din_3_max_01 > din_3_max_23 ? din_3_max_01 : din_3_max_23;

assign rd = addr_ram_rd < addr_ram_wr;

always @(posedge clk, negedge rst_n) begin
  if (!rst_n || tx_done)
    addr_ram_wr <= 5'h0;
  else if (strt)
    addr_ram_wr <= addr_ram_wr + 5'h1;
end

always @(posedge clk, negedge rst_n) begin
  if (!rst_n || tx_done)
    addr_ram_rd <= 5'h0;
  else if (addr_rd_inc)
    addr_ram_rd <= addr_ram_rd + 5'h1;
end

endmodule
