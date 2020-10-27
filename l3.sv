module layer_3(clk, rst_n, strt, din, tx_done, bsy_in, rdy, dout);
input clk, rst_n;
input strt;
input tx_done;
input bsy_in;
input signed [17:0] din;
output rdy;
output [17:0] dout;

reg wr;
reg [6:0] addr_wr, addr_rd;
wire [17:0] dout;
wire [17:0] comp;

ram #(.ADDR_WIDTH(7), .DATA_WIDTH(18)) l3_ram(.clk(clk), .wr(wr)
    , .addr_wr(addr_wr), .addr_rd(addr_rd), .din(comp), .dout(dout));

reg addr_wr_inc;
always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    addr_wr <= 7'h0;
  else if (tx_done)
    addr_wr <= 7'h0;
  else if (addr_wr_inc)
    addr_wr <= addr_wr + 7'h1;
end

reg temp_clr;
reg signed [17:0] temp;
assign comp = din > temp ? din : temp;
always @ (posedge clk) begin
  if (temp_clr) begin
    temp <= 18'h0;
  end
  else begin
    temp <= comp;
  end
end

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
  addr_wr_inc = 0;
  temp_clr = 0;
  wr = 4'h0;

  case(state_wr)
    INI: begin
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
      wr = 1;
      addr_wr_inc = 1;
    end
  endcase
end

// Read DATA
reg addr_rd_inc;
always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    addr_rd <= 7'h0;
  else if (tx_done)
    addr_rd <= 7'h0;
  else if (addr_rd_inc)
    addr_rd <= addr_rd + 7'h1;
end

assign rdy = addr_rd < addr_wr;

typedef enum reg [2:0]{IDLE, ON, TW, TH, FO} state_rd_t;
state_rd_t state_rd, nxt_state_rd;
always @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    state_rd <= IDLE;
  else if (tx_done)
    state_rd <= IDLE;
  else
    state_rd <= nxt_state_rd;
end

always_comb begin
  nxt_state_rd = IDLE;
  addr_rd_inc = 0;

  case(state_rd)
    IDLE: begin
      if (rdy) begin
        nxt_state_rd = ON;
      end
    end
    ON: begin
      nxt_state_rd = TW;
    end
    TW: begin
      nxt_state_rd = TH;
    end
    TH: begin
      nxt_state_rd = FO;
    end
    default: begin
      addr_rd_inc = 1;
    end
  endcase
end
endmodule
