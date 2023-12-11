`timescale 1ns / 1ps
`default_nettype none

module attack_logic (
    input wire clk_pixel_in,
    input wire rst_in,
    input wire [31:0] decoded_ir_in,
    input wire decoded_ir_in_valid,
    input location_t location_in,
    input wire location_in_valid,
    input wire [2:0] pmod_in,
    output logic [2:0] pmod_out,
    output data_t player_data_out,
    output data_t opponent_data_out,
    output logic data_out_valid
  );
  parameter BLOCK_CODE = 32'hDEADBEEF;
  parameter LUNGE_CODE = 32'h20FACADE;

  data_t fsm_player_data;
  logic player_scored;
  logic fsm_player_data_valid;

  location_t player_location;
  logic player_location_valid;

  logic self_started;
  logic opponent_started;

  
  always_ff @(posedge clk_pixel_in) begin
    if (rst_in) begin
      self_started <= 0;
    end else if (decoded_ir_in == 32'h20DF_5BA4 || decoded_ir_in == 32'h20DF_5AA5) begin
      self_started <= 1'b1;
    end
  end

  state_transmitter transmitter_inst(
    .clk_pixel_in(clk_pixel_in),
    .rst_in(rst_in),
    .self_started_in(self_started),
    .opponent_started_in(opponent_started),
    .old_player_data_in(fsm_player_data),
    .player_scored_in(player_scored),
    .old_player_data_in_valid(fsm_player_data_valid),
    .location_in(location_in),
    .location_in_valid(location_in_valid),
    .data_out(pmod_out[0]),
    .data_clk_out(pmod_out[1]),
    .sel_out(pmod_out[2]),
    .location_out(player_location),
    .location_out_valid(player_location_valid)
  );
  
  data_t opponent_data;
  logic opponent_scored;
  logic syncer_data_valid;
  location_t syncer_player_location;

  logic data_line, data_clk, select;

  synchronizer s1( 
    .clk_in(clk_pixel_in),
    .rst_in(rst_in),
    .us_in(pmod_in[0]),
    .s_out(data_line)
  );
 
  synchronizer s2( 
    .clk_in(clk_pixel_in),
    .rst_in(rst_in),
    .us_in(pmod_in[1]),
    .s_out(data_clk)
  );
 
  synchronizer s3( 
    .clk_in(clk_pixel_in),
    .rst_in(rst_in),
    .us_in(pmod_in[2]),
    .s_out(select)
  );

  syncer syncer_inst(
    .clk_pixel_in(clk_pixel_in),
    .rst_in(rst_in),
    .location_in(player_location),
    .location_in_valid(player_location_valid),
    .data_in(data_line),
    .data_clk_in(data_clk),
    .sel_in(select),
    .player_location_out(syncer_player_location),
    .opponent_data_out(opponent_data),
    .opponent_scored_out(opponent_scored),
    .data_out_valid(syncer_data_valid),
    .opponent_started_out(opponent_started)
  );

  action_fsm action_fsm_inst(
    .clk_pixel_in(clk_pixel_in),
    .rst_in(rst_in),
    .block_in(decoded_ir_in==BLOCK_CODE),
    .lunge_in(decoded_ir_in==LUNGE_CODE),
    .ir_in_valid(decoded_ir_in_valid),
    .player_location_in(syncer_player_location),
    .opponent_data_in(opponent_data),
    .opponent_scored_in(opponent_scored),
    .syncer_in_valid(syncer_data_valid),
    .player_data_out(fsm_player_data),
    .player_scored_out(player_scored),
    .opponent_data_out(opponent_data_out),
    .data_out_valid(fsm_player_data_valid)
  );

  assign data_out_valid = fsm_player_data_valid;
  assign player_data_out = fsm_player_data;

endmodule

`default_nettype wire
