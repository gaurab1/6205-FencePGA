module start_display(
    input wire clk_in,
    input wire rst_in,
    input wire [23:0] img_sprite_in,
    input wire [10:0] hcount_in,
    input wire [9:0] vcount_in,
    output wire [23:0] display_out
);
    logic [23:0] block_color, triangle_color, arrow1_color, arrow2_color, arrow3_color, arrow4_color;
    assign display_out = img_sprite_in ? img_sprite_in : arrow1_color ? arrow1_color : arrow2_color ? arrow2_color : arrow3_color ? arrow3_color: arrow4_color? arrow4_color: block_color ? block_color : 0;
    // assign display_out = line_color_1;
    fixed_block_sprite #(.HEIGHT(100), .WIDTH(200), .COLOR(24'hF4_63_05)) playbutton(
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in(380),
    .y_in(500),
    .red_out(block_color[23:16]),
    .green_out(block_color[15:8]),
    .blue_out(block_color[7:0])
  );

  fixed_block_sprite #(.HEIGHT(60), .WIDTH(10)) arrow1(
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in(460),
    .y_in(520),
    .red_out(arrow1_color[23:16]),
    .green_out(arrow1_color[15:8]),
    .blue_out(arrow1_color[7:0])
  );

  fixed_block_sprite #(.HEIGHT(45), .WIDTH(10)) arrow2(
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in(470),
    .y_in(528),
    .red_out(arrow2_color[23:16]),
    .green_out(arrow2_color[15:8]),
    .blue_out(arrow2_color[7:0])
  );

  fixed_block_sprite #(.HEIGHT(30), .WIDTH(10)) arrow3(
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in(480),
    .y_in(535),
    .red_out(arrow3_color[23:16]),
    .green_out(arrow3_color[15:8]),
    .blue_out(arrow3_color[7:0])
  );

  fixed_block_sprite #(.HEIGHT(15), .WIDTH(10)) arrow4(
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in(490),
    .y_in(542),
    .red_out(arrow4_color[23:16]),
    .green_out(arrow4_color[15:8]),
    .blue_out(arrow4_color[7:0])
  );

endmodule