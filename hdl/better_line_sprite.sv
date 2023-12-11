module better_line #(
    parameter COLOR=24'hFF_FF_FF)(
  input wire clk_in, //
  input wire rst_in,
  input wire [10:0] hcount_in,
  input wire [9:0] vcount_in,
  input wire [10:0] x1_in,
  input wire [10:0] x2_in,
  input wire [9:0] y1_in,
  input wire [9:0] y2_in,
  output logic [7:0] red_out,
  output logic [7:0] green_out,
  output logic [7:0] blue_out
  );

  logic signed [10:0] dx, dy, D;
  logic [10:0] x;
  logic [9:0] y;
  assign dx = $signed(x2_in) - $signed(x1_in);
  assign dy = $signed(y2_in) - $signed(y1_in);

  always_comb begin
    if (hcount_in == x && vcount_in == y) begin
        red_out = COLOR[23:16];
        green_out = COLOR[15:8];
        blue_out = COLOR[7:0];
    end else begin
        red_out = 0;
        green_out = 0;
        blue_out = 0;
    end
  end

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
        x <= x1_in;
        y <= y1_in;
        D <= ($signed(dy) <<< 1) - $signed(dx);
    end else begin
        if (hcount_in == x) begin
            x <= x + 1;
            if ($signed(D) > 0) begin
                y <= y + 1;
                D <= $signed(D) - ($signed(dx) <<< 1);
            end else begin
                D <= $signed(D) + ($signed(dy) <<< 1);
            end
        end
        if (x > x2_in) begin
            x <= x1_in;
            y <= y1_in;
            D <= ($signed(dy) <<< 1) - $signed(dx);
        end
    end
  end

endmodule

module line_sprite #(
    parameter COLOR=24'hFF_FF_FF)(
  input wire clk_in, //
  input wire rst_in,
  input wire [10:0] hcount_in,
  input wire [9:0] vcount_in,
  input wire [10:0] x1_in,
  input wire [10:0] x2_in,
  input wire [9:0] y1_in,
  input wire [9:0] y2_in,
  output logic [7:0] red_out,
  output logic [7:0] green_out,
  output logic [7:0] blue_out
  );

  logic signed [11:0] dx, dy, D;
  logic yi;
  logic [10:0] x;
  logic [9:0] y;
  assign dx = $signed(x2_in - x1_in);
  assign dy = (y2_in > y1_in) ? $signed(y2_in - y1_in) : $signed(y1_in - y2_in);
  assign yi = (y2_in > y1_in) ? 1 : 0;

  always_comb begin
    if (hcount_in == x && vcount_in == y) begin
        red_out = COLOR[23:16];
        green_out = COLOR[15:8];
        blue_out = COLOR[7:0];
    end else begin
        red_out = 0;
        green_out = 0;
        blue_out = 0;
    end
  end

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
        x <= x1_in;
        y <= y1_in;
        D <= ($signed(dy) <<< 1) - $signed(dx);
    end else begin
        if (hcount_in == x) begin
            x <= x + 1;
            if ($signed(D) > 0) begin
                y <= (yi) ? y + 1 : y - 1;
                D <= $signed(D) + ($signed(dy) <<< 1) - ($signed(dx) <<< 1);
            end else begin
                D <= $signed(D) + ($signed(dy) <<< 1);
            end
        end
        if (x > x2_in) begin
            x <= x1_in;
            y <= y1_in;
            D <= ($signed(dy) <<< 1) - $signed(dx);
        end
    end
  end

endmodule

module bad_line_sprite #(
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

  logic in_sprite, in_sprite_gray;
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