module tb();

reg clk;
reg w[783:0];
reg [17:0] l0_q0[675:0], l0_q1[675:0];
reg [17:0] l1_q0[168:0], l1_q1[168:0];
reg [17:0] l2_q0[120:0], l2_q1[120:0], l2_q2[120:0], l2_q3[120:0];
// reg [17:0] l3_q0[24:0], l3_q1[24:0], l3_q2[24:0], l3_q3[24:0];
reg [17:0] l3_q[99:0];
reg [17:0] l4_q[63:0];
reg rst, rx;
reg [7:0] rx_data;
reg rx_rdy;
reg [10:0]a;
wire tx;
cnn iDUT(.clk(clk), .RST_n(rst), .RX(rx), .TX(tx), .rx_data(rx_data), .rx_rdy(rx_rdy));

always #1 clk = ~clk;

initial begin
$readmemb("cnn_img_0.txt", w);
$readmemb("l0_q0.txt", l0_q0);
$readmemb("l0_q1.txt", l0_q1);
$readmemb("l1_q0.txt", l1_q0);
$readmemb("l1_q1.txt", l1_q1);
$readmemb("l2_q0.txt", l2_q0);
$readmemb("l2_q1.txt", l2_q1);
$readmemb("l2_q2.txt", l2_q2);
$readmemb("l2_q3.txt", l2_q3);
// $readmemb("l3_q0.txt", l3_q0);
// $readmemb("l3_q1.txt", l3_q1);
// $readmemb("l3_q2.txt", l3_q2);
// $readmemb("l3_q3.txt", l3_q3);
$readmemb("l3_q.txt", l3_q);
$readmemb("l4_q.txt", l4_q);
clk = 0;
rx_rdy = 0;
@(negedge clk)
rst = 0;
@(negedge clk) rst = 1;
repeat(20) @(negedge clk);

for (int j = 0; j < 10; j++) begin
for (int i = 0; i < 98; i++) begin
	rx_data[0] = w[i*8];
	rx_data[1] = w[i*8 + 1];
	rx_data[2] = w[i*8 + 2];
	rx_data[3] = w[i*8 + 3];
	rx_data[4] = w[i*8 + 4];
	rx_data[5] = w[i*8 + 5];
	rx_data[6] = w[i*8 + 6];
	rx_data[7] = w[i*8 + 7];

	rx_rdy = 1;
	@(negedge clk) rx_rdy = 0;
	repeat(50) @(negedge clk);
end

@(posedge iDUT.trmt) begin
	$display("%d", iDUT.tx_data);
	//$stop();
end
repeat(300) @(negedge clk);
end
$stop();

/*
for (int i = 0; i < 784; i++) begin
	if(w[i] !== iDUT.input_ram.ram[i])begin
		$display("Error: %h, %h, %d", w[i], iDUT.input_ram.ram[i], i);
		$stop();
	end
end

a = 0;
for (int i = 0; i < 766; i++) begin
	if (l0_q0[i] !== iDUT.core.conv_0.l0_ram_0.ram[i])begin
		$display("Error: %h, %h", l0_q0[i], iDUT.core.conv_0.l0_ram_0.ram[i]);
		$display("%d", i);
		//$display("%d", j);
		a = a + 1;
		$stop();
	end
	if (l0_q1[i] !== iDUT.core.conv_0.l0_ram_1.ram[i])begin
		$display("Error: %h, %h", l0_q1[i], iDUT.core.conv_0.l0_ram_1.ram[i]);
		$display("%d", i);
		a = a + 1;
		$stop();
	end
end

for (int i = 0; i < 169; i++) begin
	if (l1_q0[i] !== iDUT.core.max_0.l1_ram_0.ram[i])begin
		$display("Error: %h, %h", l1_q0[i], iDUT.core.max_0.l1_ram_0.ram[i]);
		$display("%d", i);
		a = a + 1;
		$stop();
	end
        if (l1_q1[i] !== iDUT.core.max_0.l1_ram_1.ram[i])begin
		$display("Error: %h, %h", l1_q1[i], iDUT.core.max_0.l1_ram_1.ram[i]);
		$display("%d", i);
		a = a + 1;
		$stop();
	end
end

for (int i = 0; i < 121; i++) begin
	if (l2_q0[i] !== iDUT.core.conv_1.l2_ram_0.ram[i])begin
		$display("Error: %h, %h", l2_q0[i], iDUT.core.conv_1.l2_ram_0.ram[i]);
		$display("%d", i);
		a = a + 1;
		$stop();
	end
	if (l2_q1[i] !== iDUT.core.conv_1.l2_ram_1.ram[i])begin
		$display("Error: %h, %h", l2_q1[i], iDUT.core.conv_1.l2_ram_1.ram[i]);
		$display("%d", i);
		a = a + 1;
		$stop();
	end
	if (l2_q2[i] !== iDUT.core.conv_1.l2_ram_2.ram[i])begin
		$display("Error: %h, %h", l2_q2[i], iDUT.core.conv_1.l2_ram_2.ram[i]);
		$display("%d", i);
		a = a + 1;
		$stop();
	end
	if (l2_q3[i] !== iDUT.core.conv_1.l2_ram_3.ram[i])begin
		$display("Error: %h, %h", l2_q3[i], iDUT.core.conv_1.l2_ram_3.ram[i]);
		$display("%d", i);
		a = a + 1;
		$stop();
	end
end


for (int i = 0; i < 100; i++) begin
  if (l3_q[i] !== iDUT.core.max_1.l3_ram.ram[i]) begin
    $display("Error: %h, %h", l3_q[i], iDUT.core.max_1.l3_ram.ram[i]);
    $display("%d", i);
    a = a + 1;
    $stop();
  end
end


for (int i = 0; i < 4; i++) begin
  if (l4_q[i*16] !== iDUT.core.dense.l4_ram_0.ram[i]) begin
    $display("%d", i);
    $display("%d, %d", l4_q[i*16], iDUT.core.dense.l4_ram_0.ram[i]);
    //$stop();
  end
  if (l4_q[i*16+1] !== iDUT.core.dense.l4_ram_1.ram[i]) begin
    $display("%d", i);
    $display("%d, %d", l4_q[63], iDUT.core.dense.l4_ram_15.ram[3]);
    $stop();
  end
  if (l4_q[i*16+2] !== iDUT.core.dense.l4_ram_2.ram[i]) begin
    $stop();
  end
  if (l4_q[i*16+3] !== iDUT.core.dense.l4_ram_3.ram[i]) begin
    $stop();
  end
  if (l4_q[i*16+4] !== iDUT.core.dense.l4_ram_4.ram[i]) begin
    $stop();
  end
  if (l4_q[i*16+5] !== iDUT.core.dense.l4_ram_5.ram[i]) begin
    $stop();
  end
  if (l4_q[i*16+6] !== iDUT.core.dense.l4_ram_6.ram[i]) begin
    $stop();
  end
  if (l4_q[i*16+7] !== iDUT.core.dense.l4_ram_7.ram[i]) begin
    $stop();
  end
  if (l4_q[i*16+8] !== iDUT.core.dense.l4_ram_8.ram[i]) begin
    $stop();
  end
  if (l4_q[i*16+9] !== iDUT.core.dense.l4_ram_9.ram[i]) begin
    $stop();
  end
  if (l4_q[i*16+10] !== iDUT.core.dense.l4_ram_10.ram[i]) begin
    $stop();
  end
  if (l4_q[i*16+11] !== iDUT.core.dense.l4_ram_11.ram[i]) begin
    $stop();
  end
  if (l4_q[i*16+12] !== iDUT.core.dense.l4_ram_12.ram[i]) begin
    $stop();
  end
  if (l4_q[i*16+13] !== iDUT.core.dense.l4_ram_13.ram[i]) begin
    $stop();
  end
  if (l4_q[i*16+14] !== iDUT.core.dense.l4_ram_14.ram[i]) begin
    $stop();
  end
  if (l4_q[i*16+15] !== iDUT.core.dense.l4_ram_15.ram[i]) begin
    $stop();
  end
end


if (iDUT.trmt === 1'b1) begin
	if (iDUT.tx_data !== 8'h0)begin
		$display("label: 5, predict: %d", iDUT.tx_data);
		$stop();
	end
end


$display("%d", a);
//$display("%d, %d", l4_q[43], iDUT.core.dense_4.l4_ram.ram[43][17:0]);
$display("%d, %d",l3_q[50], iDUT.core.max_1.l3_ram.ram[50]);
$display("%d", iDUT.tx_data);
$display("Success");
$stop();

*/
end
endmodule
