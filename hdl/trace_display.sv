module trace_display (
  input wire clk_in,
  input wire rst_in,
  input wire nf_in,
  input wire [10:0] hcount_in,
  input wire [9:0] vcount_in,
  input wire [11:0] x_in,
  input wire [10:0]  y_in,
  output logic [23:0] color_out);

  logic [10:0] prev_hcounts [4:0];
  logic [9:0] prev_vcounts [4:0];
  logic [23:0] color [4:0];

  fixed_block_sprite saber0(
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in(prev_hcounts[0]),
    .y_in(prev_vcounts[0]),
    .red_out(color[0][23:16]),
    .green_out(color[0][15:8]),
    .blue_out(color[0][7:0])
  );

    fixed_block_sprite #(.HEIGHT(12), .WIDTH(12), .COLOR(24'hBB_BB_BB)) saber1 (
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in(prev_hcounts[1]),
    .y_in(prev_vcounts[1]),
    .red_out(color[1][23:16]),
    .green_out(color[1][15:8]),
    .blue_out(color[1][7:0])
  );

    fixed_block_sprite #(.HEIGHT(9), .WIDTH(9), .COLOR(24'h99_99_99)) saber2 (
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in(prev_hcounts[2]),
    .y_in(prev_vcounts[2]),
    .red_out(color[2][23:16]),
    .green_out(color[2][15:8]),
    .blue_out(color[2][7:0])
  );

    fixed_block_sprite #(.HEIGHT(6), .WIDTH(6), .COLOR(24'h77_77_77)) saber3 (
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in(prev_hcounts[3]),
    .y_in(prev_vcounts[3]),
    .red_out(color[3][23:16]),
    .green_out(color[3][15:8]),
    .blue_out(color[3][7:0])
  );

    fixed_block_sprite #(.HEIGHT(3), .WIDTH(3), .COLOR(24'h44_44_44)) saber4 (
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in(prev_hcounts[3]),
    .y_in(prev_vcounts[3]),
    .red_out(color[3][23:16]),
    .green_out(color[3][15:8]),
    .blue_out(color[3][7:0])
  );

endmodule