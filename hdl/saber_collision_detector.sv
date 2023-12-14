`timescale 1ns / 1ps
`default_nettype none

module saber_collision_detector(
    input wire clk_pixel_in,
    input wire rst_in,
    input wire opponent_is_blocking,
    input wire [10:0] player_x,
    input wire [9:0] player_y,
    input wire [10:0] opponent_x,
    input wire [9:0] opponent_y,
    output logic is_colliding
  );

  logic [11:0] x_diff;
  logic [9:0] y_diff;

  always_comb begin
    is_colliding = opponent_is_blocking;
    
    x_diff = (player_x > opponent_x)? player_x - opponent_x: opponent_x - player_x;
    y_diff = (player_y > opponent_y)? player_y - opponent_y: opponent_y - player_y;

    is_colliding = is_colliding && (x_diff + y_diff <= 11'd30);
  end
endmodule

`default_nettype wire
