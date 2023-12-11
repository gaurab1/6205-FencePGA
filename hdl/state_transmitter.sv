`timescale 1ns / 1ps
`default_nettype none
`include "hdl/types.svh"

module state_transmitter(
    input wire clk_pixel_in,
    input wire rst_in,
    input wire self_started_in,
    input wire opponent_started_in,
    input data_t old_player_data_in,
    input wire player_scored_in,
    input wire old_player_data_in_valid,
    input location_t location_in,
    input wire location_in_valid,
    output logic data_out,
    output logic data_clk_out,
    output logic sel_out,
    output location_t location_out,
    output logic location_out_valid
  );

  data_t old_player_data;
  logic player_scored;
  location_t location;
  data_t new_player_data;

  logic fsm_data_received;
  logic location_data_received;

  logic clk_output;

  always_comb begin
    new_player_data = old_player_data;
    new_player_data.location = location;
  end

  always_ff @(posedge clk_pixel_in) begin
    if (rst_in) begin
      fsm_data_received <= 1'b1;   // Init to 1 for the program start case
      old_player_data <= 89'b101_00000000000_0000000000_00000000001_0000000001_10000000000_1000000000_00_10101010101_0101010101;
      player_scored <= 0;
      location_data_received <= 0;
      location_out_valid <= 0;
      data_clk_out <= 0;
    end else if (self_started_in == 0) begin
      data_clk_out <= 0;
    end else if (opponent_started_in == 0) begin
      data_clk_out <= 1'b1;
    end else if (fsm_data_received && location_data_received && sel_out) begin
      fsm_data_received <= 0;
      location_data_received <= 0;
      data_clk_out <= clk_output;
    end else begin
      if (old_player_data_in_valid) begin
        fsm_data_received <= 1'b1;
        old_player_data <= old_player_data_in;
        player_scored <= player_scored_in;
      end

      if (location_in_valid) begin
        location_data_received <= 1'b1;
        location <= location_in;
        location_out <= location_in;
        location_out_valid <= 1'b1;
      end else begin
        location_out_valid <= 0;
      end
      data_clk_out <= clk_output;
    end
  end

  spi_tx #(
    .DATA_WIDTH($bits(data_t)+1),
    .DATA_PERIOD(100)
  ) spi_tx_inst (
    .clk_in(clk_pixel_in),
    .rst_in(rst_in),
    .data_in({new_player_data, player_scored}),
    .trigger_in(fsm_data_received && location_data_received && self_started_in && opponent_started_in),
    .data_out(data_out),
    .data_clk_out(clk_output),
    .sel_out(sel_out)
  );
  
endmodule

`default_nettype wire
