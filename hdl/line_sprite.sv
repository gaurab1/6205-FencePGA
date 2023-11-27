module line_sprite #(
  parameter COLOR=24'hFF_FF_FF)(
  input wire [10:0] hcount_in,
  input wire [9:0] vcount_in,
  input wire [10:0] x1_in,
  input wire [10:0] x2_in,
  input wire [9:0]  y1_in,
  input wire [9:0]  y2_in,
  output logic [7:0] red_out,
  output logic [7:0] green_out,
  output logic [7:0] blue_out);

  logic in_sprite;
  logic [20:0] left_mul, right_mul;
  assign left_mul = x2_in*y1_in + hcount_in*y2_in + vcount_in*x1_in;
  assign right_mul = x1_in*y2_in + hcount_in*y1_in + vcount_in*x2_in;
  assign in_sprite = (((hcount_in >= x1_in && hcount_in <= x2_in) || (hcount_in >= x2_in && hcount_in <= x1_in)) &&
                      ((vcount_in >= y1_in && vcount_in <= y2_in) || (vcount_in >= y2_in && vcount_in <= y1_in)) &&
                      ((((left_mul + 100) >= right_mul) && (left_mul <= (right_mul + 100)))));

  assign in_sprite_gray = (((hcount_in >= x1_in && hcount_in <= x2_in) || (hcount_in >= x2_in && hcount_in <= x1_in)) &&
                      ((vcount_in >= y1_in && vcount_in <= y2_in) || (vcount_in >= y2_in && vcount_in <= y1_in)) &&
                      ((((left_mul + 250) >= right_mul) && (left_mul <= (right_mul + 250)))));
  always_comb begin
    if (in_sprite)begin
      red_out = COLOR[23:16];
      green_out = COLOR[15:8];
      blue_out = COLOR[7:0];
    end else if (in_sprite_gray) begin
      red_out = COLOR[23:16]>>1;
      green_out = COLOR[15:8]>>1;
      blue_out = COLOR[7:0]>>1;
    end else begin
      red_out = 0;
      green_out = 0;
      blue_out = 0;
    end
  end
endmodule