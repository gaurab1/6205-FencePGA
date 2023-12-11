module start_display(
    input wire clk_in,
    input wire rst_in,
    input wire [10:0] hcount_in,
    input wire [9:0] vcount_in,
    output wire [23:0] display_out
);
    logic [23:0] block_color, triangle_color, arrow1_color;
    assign display_out = triangle_color ? triangle_color : block_color ? block_color : 0;
    fixed_block_sprite #(.HEIGHT(100), .WIDTH(200), .COLOR(24'hF4_63_05)) playbutton(
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in(380),
    .y_in(500),
    .red_out(block_color[23:16]),
    .green_out(block_color[15:8]),
    .blue_out(block_color[7:0])
  );

//   fixed_block_sprite #(.HEIGHT(50), .WIDTH(10)) arrow(
//     .hcount_in(hcount_in),
//     .vcount_in(vcount_in),
//     .x_in(475),
//     .y_in(525),
//     .red_out(arrow1_color[23:16]),
//     .green_out(arrow1_color[15:8]),
//     .blue_out(arrow1_color[7:0])
//   );
    
    // transparent_triangle_sprite play(
    //     .clk_in(clk_in),
    //     .rst_in(rst_in),
    //     .hcount_in(hcount_in),
    //     .vcount_in(vcount_in),
    //     .x1_in(400),
    //     .y1_in(100),
    //     .x2_in(600),
    //     .y2_in(300),
    //     .x3_in(400),
    //     .y3_in(500),
    //     .red_out(triangle_color[23:16]),
    //     .green_out(triangle_color[15:8]),
    //     .blue_out(triangle_color[7:0])
    // );

    // line_sprite lol (
    //     .clk_in(clk_in),
    //     .rst_in(rst_in),
    //     .x1_in(300),
    //     .x2_in(400),
    //     .y1_in(100),
    //     .y2_in(200),
    //     .red_out(triangle_color[23:16]),
    //     .green_out(triangle_color[15:8]),
    //     .blue_out(triangle_color[7:0])
    // );
endmodule