module block_sprite #(COLOR=24'hFF_00_00)(
  input wire [10:0] hcount_in,
  input wire [9:0] vcount_in,
  input wire [11:0] x_in,
  input wire [10:0]  y_in,
  input wire [11:0] xmax_in,
  input wire [10:0]  ymax_in,
  output logic [7:0] red_out,
  output logic [7:0] green_out,
  output logic [7:0] blue_out);

  logic in_sprite;
  assign in_sprite = ((((hcount_in + xmax_in) >= (x_in << 1)) && hcount_in < (xmax_in)) &&
                        (((vcount_in + ymax_in) >= (y_in << 1)) && vcount_in < (ymax_in)));
  always_comb begin
    if (in_sprite)begin
      red_out = COLOR[23:16];
      green_out = COLOR[15:8];
      blue_out = COLOR[7:0];
    end else begin
      red_out = 0;
      green_out = 0;
      blue_out = 0;
    end
  end
endmodule

module fixed_block_sprite #(
  parameter WIDTH=15, HEIGHT=15, COLOR=24'hFF_FF_FF)(
  input wire [10:0] hcount_in,
  input wire [9:0] vcount_in,
  input wire [10:0] x_in,
  input wire [9:0]  y_in,
  output logic [7:0] red_out,
  output logic [7:0] green_out,
  output logic [7:0] blue_out);

  logic in_sprite;
  assign in_sprite = ((hcount_in >= x_in && hcount_in < (x_in + WIDTH)) &&
                      (vcount_in >= y_in && vcount_in < (y_in + HEIGHT)));
  always_comb begin
    if (in_sprite)begin
      red_out = COLOR[23:16];
      green_out = COLOR[15:8];
      blue_out = COLOR[7:0];
    end else begin
      red_out = 0;
      green_out = 0;
      blue_out = 0;
    end
  end
endmodule

module transparent_block_sprite #(COLOR=24'h00_FF_00)(
  input wire [10:0] hcount_in,
  input wire [9:0] vcount_in,
  input wire [11:0] x_in,
  input wire [10:0]  y_in,
  input wire [11:0] xmax_in,
  input wire [10:0]  ymax_in,
  output logic [7:0] red_out,
  output logic [7:0] green_out,
  output logic [7:0] blue_out);

  logic in_sprite;
  assign in_sprite = (((hcount_in + xmax_in) >= (x_in << 1)) && hcount_in <= xmax_in && ((vcount_in + ymax_in) == (y_in << 1) || vcount_in == ymax_in)) ||
                        (((vcount_in + ymax_in) >= (y_in << 1)) && vcount_in <= ymax_in && ((hcount_in + xmax_in) == (x_in << 1) || hcount_in == xmax_in));
  always_comb begin
    if (in_sprite)begin
      red_out = COLOR[23:16];
      green_out = COLOR[15:8];
      blue_out = COLOR[7:0];
    end else begin
      red_out = 0;
      green_out = 0;
      blue_out = 0;
    end
  end
endmodule

module circle_sprite #(
  parameter RADIUS=12, COLOR=24'hFF_FF_FF)(
  input wire [10:0] hcount_in,
  input wire [9:0] vcount_in,
  input wire [10:0] x_in,
  input wire [9:0]  y_in,
  output logic [7:0] red_out,
  output logic [7:0] green_out,
  output logic [7:0] blue_out);

  logic in_sprite;
  assign in_sprite = (((hcount_in - x_in)*(hcount_in - x_in) + (vcount_in - y_in)*(vcount_in - y_in)) < RADIUS*RADIUS);

  always_comb begin
    if (in_sprite)begin
      red_out = COLOR[23:16];
      green_out = COLOR[15:8];
      blue_out = COLOR[7:0];
    end else begin
      red_out = 0;
      green_out = 0;
      blue_out = 0;
    end
  end
endmodule

module transparent_triangle_sprite #(COLOR=24'hFF_FF_FF)(
  input wire clk_in,
  input wire rst_in,
  input wire [10:0] hcount_in,
  input wire [9:0] vcount_in,
  input wire [10:0] x1_in,
  input wire [9:0]  y1_in,
  input wire [10:0] x2_in,
  input wire [9:0]  y2_in,
  input wire [10:0] x3_in,
  input wire [9:0]  y3_in,
  output logic [7:0] red_out,
  output logic [7:0] green_out,
  output logic [7:0] blue_out
);
  logic [7:0] red1, blue1, green1, red2, blue2, green2, red3, blue3, green3;

  line_sprite line1(
    .clk_in(clk_in), //
    .rst_in(rst_in),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x1_in(x1_in),
    .x2_in(x2_in),
    .y1_in(y1_in),
    .y2_in(y2_in),
    .red_out(red1),
    .green_out(green1),
    .blue_out(blue1));

  line_sprite line2(
    .clk_in(clk_in), //
    .rst_in(rst_in),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x1_in(x3_in),
    .x2_in(x2_in),
    .y1_in(y3_in),
    .y2_in(y2_in),
    .red_out(red2),
    .green_out(green2),
    .blue_out(blue2));

  line_sprite line3(
    .clk_in(clk_in), //
    .rst_in(rst_in),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x1_in(x1_in),
    .x2_in(x3_in),
    .y1_in(y1_in),
    .y2_in(y3_in),
    .red_out(red3),
    .green_out(green3),
    .blue_out(blue3));

  assign red_out = red1 ? red1 : red2 ? red2 : red3 ? red3 : 0;
  assign green_out = green1 ? green1 : green2 ? green2 : green3 ? green3 : 0;
  assign blue_out = blue1 ? blue1 : blue2 ? blue2 : blue3 ? blue3 : 0;
endmodule
