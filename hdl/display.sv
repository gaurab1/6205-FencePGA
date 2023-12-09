`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)
`include "types.svh"

module display_module_1 (
  input wire clk_in,
  input wire rst_in,
  input wire camera_sw,
  input wire [23:0] camera_pixel_in,
  input wire [10:0] hcount_in,
  input wire [9:0] vcount_in,
  input wire nf_in,
  input data_t player_data,
  input data_t opponent_data,
  output logic [23:0] pixel_out
);
  
  logic border;
  logic [23:0] player_box, player_saber, opponent_box, opponent_saber;

  transparent_block_sprite player(
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in((player_data.location.rect_x>>1) - player_data.location.rect_x_2),
    .y_in((player_data.location.rect_y>>1) - player_data.location.rect_y_2),
    .xmax_in(player_data.location.rect_x_2),
    .ymax_in(player_data.location.rect_y_2),
    .red_out(player_box[23:16]),
    .green_out(player_box[15:8]),
    .blue_out(player_box[7:0]));

  trace_display playersaber(
  .clk_in(clk_in),
  .rst_in(rst_in),
  .nf_in(nf_in),
  .hcount_in(hcount_in),
  .vcount_in(vcount_in),
  .x_in(player_data.location.saber_x),
  .y_in(player_data.location.saber_y),
  .color_out(player_saber));

  fixed_block_sprite opponentsaber(
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in(opponent_data.location.saber_x),
    .y_in(opponent_data.location.saber_y),
    .red_out(opponent_saber[23:16]),
    .green_out(opponent_saber[15:8]),
    .blue_out(opponent_saber[7:0])
  );

  block_sprite opp(
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in((opponent_data.location.rect_x>>1) - opponent_data.location.rect_x_2),
    .y_in((opponent_data.location.rect_y>>1) - opponent_data.location.rect_y_2),
    .xmax_in(opponent_data.location.rect_x_2),
    .ymax_in(opponent_data.location.rect_y_2),
    .red_out(opponent_box[23:16]),
    .green_out(opponent_box[15:8]),
    .blue_out(opponent_box[7:0]));

  display_module_mux lol (
    .game_border_in(border),
    .camera_pixel_in(camera_sw ? camera_pixel_in : 0),
    .player_box_in(player_box),
    .opponent_box_in(opponent_box),
    .player_saber_in(player_saber),
    .opponent_saber_in(opponent_saber),
    .pixel_out(pixel_out)
  );

  assign border = (hcount_in == 960 && vcount_in <= 640) || (vcount_in == 640 && hcount_in <= 960);

endmodule

`default_nettype wire
