`timescale 1ns / 1ps
`default_nettype none

module attack_logic (
    input wire clk_pixel_in,
    input wire rst_in,
    input wire [31:0] decoded_ir_in,
    input wire decoded_ir_in_valid,
    input location_t location_in,
    input location_t location_in_valid,
    output data_t player_data_out,
    output data_t opponent_data_out,
    output logic data_out_valid
  );
  parameter BLOCK_CODE = 32'hDEADBEEF;
  parameter LUNGE_CODE = 32'h20FACADE;

  data_t fsm_player_data;
  logic fsm_player_data_valid;

  location_t player_location;
  logic player_location_valid;

  state_transmitter transmitter_inst(
    .clk_pixel_in(clk_pixel_in),
    .rst_in(rst_in),
    .old_player_data_in(fsm_player_data),
    .old_player_data_in_valid(fsm_player_data_valid),
    .location_in(location_in),
    .location_in_valid(location_in_valid),
    .location_out(player_location),
    .location_out_valid(player_location_valid)
  );

  location_t player_location;
  data_t opponent_data;
  logic syncer_data_valid;

  syncer syncer_inst(
    .clk_pixel_in(clk_pixel_in),
    .rst_in(rst_in),
    .location_in(player_location),
    .location_in_valid(player_location_valid),
    .opponent_data_in(),
    .opponent_data_in_valid(),
    .player_location_out(player_location),
    .opponent_data_out(opponent_data),
    .data_out_valid(syncer_data_valid)
  );

  action_fsm action_fsm_inst(
    .clk_pixel_in(clk_pixel_in),
    .rst_in(rst_in),
    .block_in(decoded_ir_in==BLOCK_CODE),
    .lunge_in(decoded_ir_in==LUNGE_CODE),
    .ir_valid_in(decoded_ir_in_valid),
    .player_location_in(player_location),
    .opponent_data_in(opponent_data),
    .syncer_data_in_valid(syncer_data_valid),
    .player_data_out(fsm_player_data),
    .opponent_data_out(opponent_data_out),
    .data_out_valid(fsm_player_data_valid)
  );

  assign data_out_valid = fsm_player_data_valid;
  assign player_data_out = fsm_player_data;

endmodule

`default_nettype wire
