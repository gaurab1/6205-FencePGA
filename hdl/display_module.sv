`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module display_module (
  input wire clk_in,
  input wire rst_in,
  input wire [23:0] img_sprite_in,
  input wire [31:0] ir_in,
  input wire start_screen,
  input wire camera_sw,
  input wire [23:0] camera_pixel_in,
  input wire [10:0] hcount_in,
  input wire [9:0] vcount_in,
  input wire nf_in,
  input wire [11:0] player_box_x_in,
  input wire [10:0] player_box_y_in,
  input wire [11:0] player_box_xmax_in,
  input wire [10:0] player_box_ymax_in,
  input wire [11:0] player_saber_x_in,
  input wire [10:0] player_saber_y_in,
  input wire [11:0] opponent_box_x_in,
  input wire [10:0] opponent_box_y_in,
  input wire [11:0] opponent_box_xmax_in,
  input wire [10:0] opponent_box_ymax_in,
  input wire [11:0] opponent_saber_x_in,
  input wire [10:0] opponent_saber_y_in,
  output logic [23:0] pixel_out
);
  
  logic border, display_start;
  logic [23:0] player_box, player_saber, opponent_box, opponent_saber, show_start;

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
        display_start <= 1;
    end else if (ir_in == 32'h20DF_5BA4 || ir_in == 32'h20DF_5AA5) begin
        display_start <= 0;
    end
  end


  transparent_block_sprite player(
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in(player_box_x_in),
    .y_in(player_box_y_in),
    .xmax_in(player_box_xmax_in),
    .ymax_in(player_box_ymax_in),
    .red_out(player_box[23:16]),
    .green_out(player_box[15:8]),
    .blue_out(player_box[7:0]));

//   fixed_block_sprite playersaber(
//     .hcount_in(hcount_in),
//     .vcount_in(vcount_in),
//     .x_in(player_saber_x_in),
//     .y_in(player_saber_y_in),
//     .red_out(player_saber[23:16]),
//     .green_out(player_saber[15:8]),
//     .blue_out(player_saber[7:0])
//   );

  trace_display playersaber(
  .clk_in(clk_in),
  .rst_in(rst_in),
  .nf_in(nf_in),
  .hcount_in(hcount_in),
  .vcount_in(vcount_in),
  .x_in(player_saber_x_in),
  .y_in(player_saber_y_in),
  .color_out(player_saber));

  fixed_block_sprite opponentsaber(
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in(opponent_saber_x_in),
    .y_in(opponent_saber_y_in),
    .red_out(opponent_saber[23:16]),
    .green_out(opponent_saber[15:8]),
    .blue_out(opponent_saber[7:0])
  );

  block_sprite opp(
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in(opponent_box_x_in),
    .y_in(opponent_box_y_in),
    .xmax_in(opponent_box_xmax_in),
    .ymax_in(opponent_box_ymax_in),
    .red_out(opponent_box[23:16]),
    .green_out(opponent_box[15:8]),
    .blue_out(opponent_box[7:0]));

  start_display menu (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .img_sprite_in(img_sprite_in),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .display_out(show_start)
  );

  display_module_mux lol (
    .game_border_in(border),
    .camera_pixel_in(camera_sw ? camera_pixel_in : 0),
    .start_display(display_start),
    .start_in(show_start),
    .player_box_in(player_box),
    .opponent_box_in(opponent_box),
    .player_saber_in(player_saber),
    .opponent_saber_in(opponent_saber),
    .pixel_out(pixel_out)
  );

  assign border = (hcount_in == 960 && vcount_in <= 640) || (vcount_in == 640 && hcount_in <= 960);

endmodule

`default_nettype wire
