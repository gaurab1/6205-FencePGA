module block_sprite #(
  parameter WIDTH=128, HEIGHT=128, COLOR=24'hFF_FF_FF)(
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