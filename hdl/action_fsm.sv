`timescale 1ns / 1ps
`default_nettype none
`include "hdl/types.svh"

module action_fsm(
    input wire clk_pixel_in,
    input wire rst_in,
    input wire block_in,
    input wire lunge_in,
    input wire ir_in_valid,
    input location_t player_location_in,
    input data_t opponent_data_in,
    input wire syncer_in_valid,
    output data_t player_data_out,
    output data_t opponent_data_out,
    output logic data_out_valid
  );

  data_t player_data;
  data_t opponent_data;

  logic in_attack;

  logic sabers_colliding;

  saber_collision_detector coll_inst(
    .clk_pixel_in(clk_pixel_in),
    .rst_in(rst_in),
    .is_attacking(in_attack),
    .opponent_is_blocking(opponent_data.saber_state==2'b1),
    .player_x(player_data.location.saber_x),
    .player_y(player_data.location.saber_y),
    .opponent_x(opponent_data.location.saber_x),
    .opponent_y(opponent_data.location.saber_y),
    .is_colliding(sabers_colliding)
  );

  logic attack_intersecting;

  intersection_detector int_inst(
    .saber_start_x(player_data.saber_start_x),
    .saber_start_y(player_data.saber_start_y),
    .saber_current_x(player_data.location.saber_x),
    .saber_current_y(player_data.location.saber_y),
    .opponent(opponent_data.location),
    .is_intersecting(attack_intersecting)
  );

  typedef enum {
    REST, BLOCK, LUNGE, ATTACK, SCORE, RECOVER
  } state_t;

  state_t curr_state;

  always_ff @(posedge clk_pixel_in) begin
    if (rst_in) begin
      curr_state <= REST;
      in_attack <= 0;
      player_data <= 0;
      opponent_data <= 0;
    end else begin
      if (opponent_data_in_valid) begin
        opponent_data <= opponent_data_in;
      end

      if (player_location_in_valid) begin
        player_data.location <= player_location_in;
      end

      case (curr_state)
        REST: begin
          if (block_in) begin
            state <= BLOCK;
          end else if (lunge_in) begin
            state <= LUNGE;
          end
        end
        BLOCK: begin
          if (!block_in) begin
            state <= REST;
          end
        end
        LUNGE: begin
          
        end
        ATTACK: begin
          in_attack <= 1'b1;
          if (lunge_in == 0 && attack_intersecting) begin
            state <= SCORE;
          end else if (sabers_colliding || lunge_in == 0) begin
            state <= RECOVER;
          end
        end
        SCORE: begin
          // Increment score
          state <= RECOVER;
        end
        RECOVER:;
      endcase
    end
  end
  
endmodule

`default_nettype wire
