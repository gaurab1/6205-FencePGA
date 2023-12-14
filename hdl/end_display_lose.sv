module end_display_lose (
    input [10:0] hcount_in,
    input [9:0] vcount_in,
    output [23:0] color_out
);
  logic [23:0] block_color, arrow1_color, arrow2_color;
  assign color_out = arrow2_color ? arrow2_color : arrow1_color ? arrow1_color : block_color;
  fixed_block_sprite #(.HEIGHT(200), .WIDTH(200), .COLOR(24'hF4_63_05)) playbutton(
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in(380),
    .y_in(220),
    .red_out(block_color[23:16]),
    .green_out(block_color[15:8]),
    .blue_out(block_color[7:0])
  );

  fixed_block_sprite #(.HEIGHT(100), .WIDTH(20)) arrow2(
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in(440),
    .y_in(270),
    .red_out(arrow1_color[23:16]),
    .green_out(arrow1_color[15:8]),
    .blue_out(arrow1_color[7:0])
  );

  fixed_block_sprite #(.HEIGHT(20), .WIDTH(80)) arrow1(
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in(440),
    .y_in(370),
    .red_out(arrow2_color[23:16]),
    .green_out(arrow2_color[15:8]),
    .blue_out(arrow2_color[7:0])
  );

endmodule

module end_display_win (
    input [10:0] hcount_in,
    input [9:0] vcount_in,
    output [23:0] color_out
);
  logic [23:0] block_color, arrow1_color, arrow2_color, arrow3_color, arrow4_color;
  assign color_out = arrow4_color ? arrow4_color : arrow3_color ? arrow3_color : arrow2_color ? arrow2_color : arrow1_color ? arrow1_color : block_color;
  fixed_block_sprite #(.HEIGHT(200), .WIDTH(200), .COLOR(24'hF4_63_05)) playbutton(
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in(380),
    .y_in(220),
    .red_out(block_color[23:16]),
    .green_out(block_color[15:8]),
    .blue_out(block_color[7:0])
  );

  fixed_block_sprite #(.HEIGHT(100), .WIDTH(20)) arrow1(
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in(420),
    .y_in(270),
    .red_out(arrow1_color[23:16]),
    .green_out(arrow1_color[15:8]),
    .blue_out(arrow1_color[7:0])
  );

  fixed_block_sprite #(.HEIGHT(50), .WIDTH(20)) arrow2(
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in(470),
    .y_in(325),
    .red_out(arrow2_color[23:16]),
    .green_out(arrow2_color[15:8]),
    .blue_out(arrow2_color[7:0])
  );

  fixed_block_sprite #(.HEIGHT(100), .WIDTH(20)) arrow3(
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in(520),
    .y_in(270),
    .red_out(arrow3_color[23:16]),
    .green_out(arrow3_color[15:8]),
    .blue_out(arrow3_color[7:0])
  );

  fixed_block_sprite #(.HEIGHT(20), .WIDTH(120)) arrow4(
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in(420),
    .y_in(370),
    .red_out(arrow4_color[23:16]),
    .green_out(arrow4_color[15:8]),
    .blue_out(arrow4_color[7:0])
  );

endmodule

