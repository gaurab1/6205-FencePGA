`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module display_module_mux (
  input wire game_border_in,
  input wire [23:0] player_box_in,
  input wire [23:0] opponent_box_in,
  input wire [23:0] player_saber_in,
  input wire [23:0] opponent_saber_in,
  output logic [23:0] pixel_out
);
 // assign pixel_out = 24'hFFFFFF;
 assign pixel_out = game_border_in ? 24'hFFFFFF: (player_box_in != 0) ? player_box_in : opponent_box_in;
endmodule

`default_nettype wire
