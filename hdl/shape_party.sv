module shape_party(
  input wire clk_in, //
  input wire rst_in,
  input wire [10:0] hcount_in,
  input wire [9:0] vcount_in,
  input wire nf_in,
  input wire data_in,
  input wire data_clk_in,
  input wire sel_in,
  output logic [7:0] red_out,
  output logic [7:0] green_out,
  output logic [7:0] blue_out
  );
  localparam BOX_DIM = 128;
  localparam CIRC_RAD = 64;
  localparam WIDTH = 1280;
  localparam HEIGHT = 720;
 
  logic [7:0] box_r, box_g, box_b;
 
  logic [10:0] box_x;
  logic [9:0] box_y;
  logic [20:0] spi_out;
  logic new_data_out;
 
  block_sprite #(
  .WIDTH(BOX_DIM), .HEIGHT(BOX_DIM),.COLOR(24'hFF_7F_00))
  bs(
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in(box_x),
    .y_in(box_y),
    .red_out(red_out),
    .green_out(green_out),
    .blue_out(blue_out));

  spi_rx #(
    .DATA_WIDTH(21))
  receive (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .data_in(data_in),
    .data_clk_in(data_clk_in),
    .sel_in(sel_in),
    .data_out(spi_out),
    .new_data_out(new_data_out)
  );

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
        box_x <= 320;
        box_y <= 180;
    end else begin
        if (new_data_out) begin
          box_x <= spi_out[20:10];
          box_y <= spi_out[9:0];
        end
    end
  end




endmodule //shape_party
