`timescale 1ns / 1ps
`default_nettype none
`include "hdl/types.svh"

module syncer(
    input wire clk_pixel_in,
    input wire rst_in,
    input location_t location_in,
    input wire location_in_valid,
    output location_t player_location_out,
    output data_t opponent_data_out,
    output logic data_out_valid
  );

  logic player_location_received;
  logic opponent_data_received;
  location_t player_location;
  data_t opponent_data;

  spi_rx #(
    .DATA_WIDTH($bits(data_t))
  ) spi_rx_inst ( 
    .clk_in(clk_pixel_in),
    .rst_in(rst_in),
    .data_in(),
    .data_clk_in(),
    .sel_in(),
    .data_out(opponent_data),
    .new_data_out(opponent_data_valid)
  );

  always_ff @(posedge clk_pixel_in) begin
    if (rst_in) begin
      player_location_received <= 0;
      opponent_data_received <= 0;
      player_location <= 0;
      opponent_data <= 0;
      data_out_valid <= 0;
    end else begin
      if (player_location_received && opponent_data_received) begin
        data_out_valid <= 1'b1;
        player_location_out <= player_location;
        opponent_data_out <= opponent_data;
        player_location_received <= 0;
        opponent_data_received <= 0;
      end else if (player_location_received) begin
        if (opponent_data_valid) begin
          opponent_data_received <= 1'b1; 
        end
      end else if (opponent_data_received) begin
        if (location_in_valid) begin
          player_location_received <= 1'b1;
          player_location <= location_in;  
        end
      end
    end
  end
  
endmodule

`default_nettype wire
