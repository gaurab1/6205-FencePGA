module trace_display (
  input wire clk_in,
  input wire rst_in,
  input wire nf_in,
  input wire [10:0] hcount_in,
  input wire [9:0] vcount_in,
  input wire [11:0] x_in,
  input wire [10:0]  y_in,
  output logic [23:0] color_out);

  logic [10:0] prev_hcounts [5:0];
  logic [9:0] prev_vcounts [5:0];
  logic [23:0] color [5:0];

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

    fixed_block_sprite #(.HEIGHT(4), .WIDTH(4), .COLOR(24'h44_44_44)) saber4 (
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in(prev_hcounts[4]),
    .y_in(prev_vcounts[4]),
    .red_out(color[4][23:16]),
    .green_out(color[4][15:8]),
    .blue_out(color[4][7:0])
  );

    fixed_block_sprite #(.HEIGHT(2), .WIDTH(2), .COLOR(24'h22_22_22)) saber5 (
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in(prev_hcounts[5]),
    .y_in(prev_vcounts[5]),
    .red_out(color[5][23:16]),
    .green_out(color[5][15:8]),
    .blue_out(color[5][7:0])
  );
  assign color_out = color[0] ? color[0] : color[1] ? color[1] : color[2] ? color[2] : color[3] ? color[3] : color[4] ? color[4] : 0;
  always_ff @(posedge clk_in) begin
    if (rst_in) begin
        for (int i=0; i<6;i++) begin
            prev_hcounts[i] <= 0;
            prev_vcounts[i] <= 0;
        end
    end else begin
        if (nf_in) begin
            prev_hcounts[0] <= x_in;
            prev_vcounts[0] <= y_in;
            for (int i=1; i<6; i = i+1)begin
                prev_hcounts[i] <= prev_hcounts[i-1];
                prev_vcounts[i] <= prev_vcounts[i-1];
            end
        end
    end

  end

endmodule