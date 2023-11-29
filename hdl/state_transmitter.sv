`timescale 1ns / 1ps
`default_nettype none
`include "hdl/types.svh"

module state_transmitter(
    input wire clk_pixel_in,
    input wire rst_in,
    input data_t old_player_data_in,
    input wire old_player_data_in_valid,
    input location_t location_in,
    input wire location_in_valid,
    input wire data_out,
    input wire data_clk_out,
    input wire sel_out,
    output data_t location_out,
    output logic location_out_valid
  );

  data_t old_player_data;
  location_t location;
  data_t new_player_data;

  logic fsm_data_received;
  logic location_data_received;

  always_comb begin
    new_player_data = old_player_data;
    new_player_data.location = location;
  end

  always_ff @(posedge clk_pixel_in) begin
    if (rst_in) begin
      fsm_data_received <= 0;  
      location_data_received <= 0;
      location_out_valid <= 0;
    end else begin
      if (old_player_data_in_valid) begin
        fsm_data_received <= 1'b1;
        old_player_data <= old_player_data_in;
      end

      if (location_in_valid) begin
        location_data_received <= 1'b1;
        location <= location_in;
        location_out <= location_in;
        location_out_valid <= 1'b1;
      end else begin
        location_out_valid <= 0;
      end
    end
  end

  spi_tx #(
    .DATA_WIDTH($bits(data_t)),
    .DATA_PERIOD(100)
  ) spi_tx_inst (
    .clk_in(clk_pixel_in),
    .rst_in(rst_in),
    .data_in(new_player_data_in),
    .trigger_in(fsm_data_received && location_data_received),
    .data_out(data_out),
    .data_clk_out(data_clk_out),
    .sel_out(sel_out)
  );

  always_ff @(posedge clk_pixel_in) begin
    if (fsm_data_received && location_data_received && sel_out) begin
      fsm_data_received <= 0;
      location_data_received <= 0;
    end
  end
  
  
endmodule

`default_nettype wire
