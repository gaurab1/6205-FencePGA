module display_health #(COLOR = 24'hFF_FF_FF)(
    input logic clk_in,
    input logic rst_in,
    input logic [10:0] hcount_in,
    input logic [9:0] vcount_in,
    input logic [10:0] x_in,
    input logic [9:0] y_in,
    input logic [2:0] health,
    output logic [23:0] color_out
);
    logic [23:0] outline_color, filled_color;
    logic [8:0] product;

    assign color_out = filled_color ? filled_color : outline_color;
    transparent_block_sprite #(.COLOR(COLOR)) health_outline (
      .hcount_in(hcount_in),
      .vcount_in(vcount_in),
      .x_in(x_in + 100), 
      .y_in(y_in + 8),
      .xmax_in(x_in + 200), 
      .ymax_in(y_in + 16), 
      .red_out(outline_color[23:16]),
      .green_out(outline_color[15:8]),
      .blue_out(outline_color[7:0])
    );

    minmax_block_sprite #(.COLOR(COLOR)) health_move (
      .hcount_in(hcount_in),
      .vcount_in(vcount_in),
      .xmin_in(x_in), 
      .ymin_in(y_in),
      .xmax_in(health*40 + x_in), 
      .ymax_in(y_in + 16), 
      .red_out(filled_color[23:16]),
      .green_out(filled_color[15:8]),
      .blue_out(filled_color[7:0])
    );

    // always_ff @(posedge clk_in) begin
    //     if (rst_in) begin
    //         product <= x_in;
    //     end else begin
    //         product <= health*20 + x_in;
    //     end
    // end

endmodule