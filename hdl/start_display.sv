module start_display(
    input wire clk_in,
    input wire rst_in,
    input wire [10:0] hcount_in,
    input wire [9:0] vcount_in,
    output wire [23:0] display_out
);
    logic [23:0] block_color;
    assign display_out = block_color ? block_color : 0;
    fixed_block_sprite #(.HEIGHT(100), .WIDTH(200)) playbutton(
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in(300),
    .y_in(300),
    .red_out(block_color[23:16]),
    .green_out(block_color[15:8]),
    .blue_out(block_color[7:0])
  );

endmodule