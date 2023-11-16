`timescale 1ns / 1ps
`default_nettype none
`include "hdl/types.svh"

module spi_data_decoder(
    input wire [88:0] data_in,
    output data_t data_out
  );

  data_out.health_out = data_in[88:86];
  data_out.rect_x_out = data_in[85:75];
  data_out.rect_y_out = data_in[74:65];
  data_out.rect_w_out = data_in[64:54];
  data_out.rect_h_out = data_in[53:44];
  data_out.saber_x_out = data_in[43:33];
  data_out.saber_y_out = data_in[32:23];
  data_out.saber_state_out = data_in[22:21];
  data_out.saber_attack_x_out = data_in[20:10];
  data_out.saber_attack_y_out = data_in[9:0];
  
endmodule

`default_nettype wire
