`timescale 1ns / 1ps
`default_nettype none
`include "hdl/types.svh"

module syncer(
    input wire clk_pixel_in,
    input wire rst_in,
    input location_t location_in,
    input wire location_in_valid,
    input wire data_in,
    input wire data_clk_in,
    input wire sel_in,
    output location_t player_location_out,
    output logic opponent_scored_out,
    output data_t opponent_data_out,
    output logic data_out_valid,
    output logic opponent_started_out
  );

  logic player_location_received;
  logic opponent_data_received;
  location_t player_location;
  logic opponent_scored;
  data_t opponent_data;
  logic opponent_data_valid;

  logic opponent_started;

  assign opponent_started_out = opponent_started;

  spi_rx #(
    .DATA_WIDTH($bits(data_t)+1)
  ) spi_rx_inst ( 
    .clk_in(clk_pixel_in),
    .rst_in(rst_in),
    .data_in(data_in),
    .data_clk_in(data_clk_in),
    .sel_in((opponent_started == 1'b1)? sel_in: 1'b1),
    .data_out({opponent_data, opponent_scored}),
    .new_data_out(opponent_data_valid)
  );

  always_ff @(posedge clk_pixel_in) begin
    if (rst_in) begin
      player_location_received <= 0;
      opponent_data_received <= 0;
      player_location <= 0;
      data_out_valid <= 0;
      opponent_started <= 0;
    end else if (opponent_started == 0) begin
      if (data_clk_in == 1'b1) begin
        opponent_started <= 1'b1;
      end
    end else begin
      if (player_location_received && opponent_data_received) begin
        data_out_valid <= 1'b1;
        player_location_out <= player_location;
        opponent_data_out <= opponent_data;
        opponent_scored_out <= opponent_scored;
        player_location_received <= 0;
        opponent_data_received <= 0;
      end else if (player_location_received) begin
        if (opponent_data_valid) begin
          opponent_data_received <= 1'b1;
        end
        data_out_valid <= 0;
      end else begin
        if (opponent_data_valid) begin
          opponent_data_received <= 1'b1;
        end
        if (location_in_valid) begin
          player_location_received <= 1'b1;
          player_location <= location_in;
        end
        data_out_valid <= 0;
      end
    end
  end
  
endmodule

`default_nettype wire
