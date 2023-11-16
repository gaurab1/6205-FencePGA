`timescale 1ns / 1ps
`default_nettype none

module spi_data_encoder(
    input wire [2:0] health_in,
    input wire [10:0] rect_x_in,
    input wire [9:0] rect_y_in,
    input wire [10:0] rect_w_in,
    input wire [9:0] rect_h_in,
    input wire [10:0] saber_x_in,
    input wire [9:0] saber_y_in,
    input wire [1:0] saber_state_in,
    input wire [10:0] saber_attack_x_in,
    input wire [9:0] saber_attack_y_in,
    output data_t data_out
  );

  assign data_out = `{health_in,
                    rect_x_in, rect_y_in, rect_w_in, rect_h_in,
                    saber_x_in, saber_y_in,
                    saber_state_in, saber_attack_x_in, saber_attack_y_in};
  
endmodule

`default_nettype wire
