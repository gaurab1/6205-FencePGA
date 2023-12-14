`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module display_module_mux (
  input wire clk_in,
  input wire game_border_in,
  input wire [23:0] camera_pixel_in,
  input wire start_display,
  input wire [23:0] start_in,
  input wire [23:0] player_box_in,
  input wire [23:0] opponent_box_in,
  input wire [23:0] player_saber_in,
  input wire [23:0] opponent_saber_in,
  input wire [23:0] player_health_in,
  input wire [23:0] opponent_health_in,
  input wire [23:0] player_line_in,
  input wire [23:0] opponent_line_in,
  input wire end_lose_in,
  input wire [23:0] end_lose_screen,
  input wire end_win_in,
  input wire [23:0] end_win_screen,
  output logic [23:0] pixel_out
);
 // assign pixel_out = 24'hFFFFFF;
 logic [23:0] game_border_delayed, camera_pixel_delayed, start_display_delayed, start_delayed, player_box_delayed, opponent_box_delayed, player_saber_delayed, opponent_saber_delayed, player_health_delayed, opponent_health_delayed, player_line_delayed, opponent_line_delayed, lose_delay;
 always_ff @(posedge clk_in) begin
  game_border_delayed <= game_border_in;
  camera_pixel_delayed <= camera_pixel_in;
  start_display_delayed <= start_display;
  start_delayed <= start_in;
  player_box_delayed <= player_box_in;
  opponent_box_delayed <= opponent_box_in;
  player_saber_delayed <= player_saber_in;
  opponent_saber_delayed <= opponent_saber_in;
  player_health_delayed <= player_health_in;
  opponent_health_delayed <= opponent_health_in;
  player_line_delayed <= player_line_in;
  opponent_line_delayed <= opponent_line_in;
  lose_delay <= end_lose_in;

 end
 // assign pixel_out = end_win_screen;
 assign pixel_out = game_border_delayed ? 24'hFFFFFF: player_saber_delayed ? player_saber_delayed : (end_lose_in) ? (end_lose_screen? end_lose_screen: 0) : (end_win_in) ? (end_win_screen? end_win_screen: 0) : (start_display_delayed) ? (start_delayed? start_delayed: 0) : player_health_delayed ? player_health_delayed : opponent_health_delayed ? opponent_health_delayed : player_line_delayed ? player_line_delayed : opponent_line_delayed ? opponent_line_delayed : opponent_saber_delayed ? opponent_saber_delayed : (player_box_delayed != 0) ? player_box_delayed : opponent_box_delayed ? opponent_box_delayed : camera_pixel_delayed ? camera_pixel_delayed : 0;
endmodule

`default_nettype wire
