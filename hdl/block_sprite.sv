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
  parameter WIDTH=3, HEIGHT=3, COLOR=24'hFF_FF_FF)(
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