`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module display_module (
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
  
  logic border;
  logic [23:0] player_box, player_saber, opponent_box, opponent_saber;

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

  fixed_block_sprite playersaber(
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in(player_saber_x_in),
    .y_in(player_saber_y_in),
    .red_out(player_saber[23:16]),
    .green_out(player_saber[15:8]),
    .blue_out(player_saber[7:0])
  );

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

  display_module_mux lol (
    .game_border_in(border),
    .player_box_in(player_box),
    .opponent_box_in(opponent_box),
    .player_saber_in(player_saber),
    .opponent_saber_in(opponent_saber),
    .pixel_out(pixel_out)
  );

  assign border = (hcount_in == 960 && vcount_in <= 640) || (vcount_in == 640 && hcount_in <= 960);

endmodule

`default_nettype wire
