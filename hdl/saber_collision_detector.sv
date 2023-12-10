`timescale 1ns / 1ps
`default_nettype none

module saber_collision_detector(
    input wire clk_pixel_in,
    input wire rst_in,
    input wire is_attacking,
    input wire opponent_is_blocking,
    input wire [10:0] player_x,
    input wire [9:0] player_y,
    input wire [10:0] opponent_x,
    input wire [9:0] opponent_y,
    output logic is_colliding
  );

  assign is_colliding = 0;
  
endmodule

`default_nettype wire
