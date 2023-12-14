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

module low_line_sprite #(
    parameter COLOR=24'hFF_FF_FF)(
  input wire clk_in, //
  input wire rst_in,
  input wire [10:0] hcount_in,
  input wire [9:0] vcount_in,
  input wire [10:0] x1_in,
  input wire [10:0] x2_in,
  input wire [9:0] y1_in,
  input wire [9:0] y2_in,
  input wire line_active,
  output logic [7:0] red_out,
  output logic [7:0] green_out,
  output logic [7:0] blue_out
  );

  logic signed [11:0] dx, dy, D;
  logic yi;
  logic [10:0] x;
  logic [9:0] y;
  assign dx = $signed(x2_in) - $signed(x1_in);
  assign dy = (y2_in > y1_in) ? $signed(y2_in) - $signed(y1_in) : $signed(y1_in) - $signed(y2_in);
  assign yi = (y2_in > y1_in) ? 1 : 0;

  always_comb begin
    if (hcount_in == x && vcount_in == y && line_active == 1) begin
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
        if (hcount_in == x && vcount_in == y) begin
            red_out <= line_active ? COLOR[23:16] : 0;
            green_out <= line_active ? COLOR[15:8] : 0;
            blue_out <= line_active ? COLOR[7:0] : 0;
            x <= x + 1;
            if ($signed(D) > 0) begin
                y <= (yi) ? y + 1 : y - 1;
                D <= $signed(D) + ($signed(dy) <<< 1) - ($signed(dx) <<< 1);
            end else begin
                D <= $signed(D) + ($signed(dy) <<< 1);
            end
        end else begin
            red_out <= 0;
            green_out <= 0;
            blue_out <= 0;
        end
        if (x > x2_in) begin
            x <= x1_in;
            y <= y1_in;
            D <= ($signed(dy) <<< 1) - $signed(dx);
        end
    end
  end

endmodule


module high_line_sprite #(
    parameter COLOR=24'hFF_FF_FF)(
  input wire clk_in, //
  input wire rst_in,
  input wire [10:0] hcount_in,
  input wire [9:0] vcount_in,
  input wire [10:0] x1_in,
  input wire [10:0] x2_in,
  input wire [9:0] y1_in,
  input wire [9:0] y2_in,
  input wire line_active,
  output logic [7:0] red_out,
  output logic [7:0] green_out,
  output logic [7:0] blue_out
  );

  logic signed [11:0] dx, dy, D;
  logic xi;
  logic [10:0] x;
  logic [9:0] y;
  assign dy = $signed(y2_in) - $signed(y1_in);
  assign dx = (x2_in > x1_in) ? $signed(x2_in) - $signed(x1_in) : $signed(x1_in) - $signed(x2_in);
  assign xi = (x2_in > x1_in) ? 1 : 0;

//   always_comb begin
//     if (hcount_in == x && vcount_in == y && line_active == 1) begin
//         red_out = COLOR[23:16];
//         green_out = COLOR[15:8];
//         blue_out = COLOR[7:0];
//     end else begin
//         red_out = 0;
//         green_out = 0;
//         blue_out = 0;
//     end
//   end

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
        x <= x1_in;
        y <= y1_in;
        D <= ($signed(dx) <<< 1) - $signed(dy);
    end else begin
        if (vcount_in == y && hcount_in == x) begin
            red_out <= line_active ? COLOR[23:16]: 0;
            green_out <= line_active ? COLOR[15:8]: 0;
            blue_out <= line_active ? COLOR[7:0]: 0;
            y <= y + 1;
            if ($signed(D) > 0) begin
                x <= (xi) ? x + 1 : x - 1;
                D <= $signed(D) + ($signed(dx) <<< 1) - ($signed(dy) <<< 1);
            end else begin
                D <= $signed(D) + ($signed(dx) <<< 1);
            end
        end else begin
            red_out <= 0;
            green_out <= 0;
            blue_out <= 0;
        end
        if (y > y2_in) begin
            x <= x1_in;
            y <= y1_in;
            D <= ($signed(dx) <<< 1) - $signed(dy);
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
  input wire line_active,
  output logic [23:0] color_out
  );

  logic [10:0] xmax, xmin;
  logic [9:0] ymax, ymin;
  logic [23:0] low_color, high_color;
  logic high_valid;

  low_line_sprite low (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x1_in(xmin),
    .x2_in(xmax),
    .y1_in((x1_in == xmin) ? y1_in : y2_in),
    .y2_in((x2_in == xmax) ? y2_in : y1_in),
    .line_active(line_active),
    .red_out(low_color[23:16]),
    .green_out(low_color[15:8]),
    .blue_out(low_color[7:0])
  );

  high_line_sprite high (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x1_in((y1_in == ymin) ? x1_in : x2_in),
    .x2_in((y2_in == ymax) ? x2_in : x1_in),
    .y1_in(ymin),
    .y2_in(ymax),
    .line_active(line_active),
    .red_out(high_color[23:16]),
    .green_out(high_color[15:8]),
    .blue_out(high_color[7:0])
  );
  always_ff @(posedge clk_in) begin
    xmax <= (x1_in > x2_in) ? x1_in : x2_in;
    ymax <= (y1_in > y2_in) ? y1_in : y2_in;
    xmin <= (x1_in > x2_in) ? x2_in : x1_in;
    ymin <= (y1_in > y2_in) ? y2_in : y1_in;
    high_valid <= ((ymax - ymin) > (xmax - xmin)) ? 1 : 0;
  end
  always_comb begin
    color_out = (high_valid) ? high_color : low_color;
  end
endmodule
