`timescale 1ns / 1ps
`default_nettype none
`include "hdl/types.svh"

module action_fsm(
    input wire clk_pixel_in,
    input wire rst_in,
    input wire block_in,
    input wire lunge_in,
    input wire release_in,
    input wire ir_in_valid,
    input location_t player_location_in,
    input data_t opponent_data_in,
    input wire opponent_scored_in,
    input wire syncer_in_valid,
    output data_t player_data_out,
    output logic player_scored_out,
    output data_t opponent_data_out,
    output logic data_out_valid
  );

  localparam IN_REST = 2'b00;
  localparam IN_ATTACK = 2'b01;
  localparam IN_BLOCK = 2'b10;
  localparam IN_RECOVER = 2'b11;

  localparam FPS = 60;

  data_t player_data;
  logic player_scored;
  data_t opponent_data;
  logic opponent_scored;

  logic state_started;
  logic state_done;

  logic block, lunge, released; // because release is a keyword

  logic [5:0] second_counter;

  logic in_attack;

  logic sabers_colliding;

  saber_collision_detector coll_inst(
    .clk_pixel_in(clk_pixel_in),
    .rst_in(rst_in),
    .opponent_is_blocking(opponent_data.saber_state==IN_BLOCK),
    .player_x(player_data.location.saber_x),
    .player_y(player_data.location.saber_y),
    .opponent_x(opponent_data.location.saber_x),
    .opponent_y(opponent_data.location.saber_y),
    .is_colliding(sabers_colliding)
  );

  logic attack_intersecting;

  intersection_detector int_inst(
    .saber_start_x(player_data.saber_attack_x),
    .saber_start_y(player_data.saber_attack_y),
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
      block <= 0;
      lunge <= 0;
      released <= 0;
      state_started <= 0;
      state_done <= 0;
      player_scored <= 0;
      player_data <= 89'b101_00000000000_0000000000_00000010000_0000010000_10000000000_1000000000_00_10101010101_0101010101;
      opponent_scored <= 0;
      opponent_data <= 89'b101_00000000000_0000000000_00000010000_0000010000_10000000000_1000000000_00_10101010101_0101010101;
      second_counter <= 0;
    end else begin
      if (syncer_in_valid) begin
        player_data.location <= player_location_in;
        opponent_data <= opponent_data_in;
        opponent_scored <= opponent_scored_in;
        state_started <= 1'b1;
      end

      if (ir_in_valid) begin
        block <= block_in;
        lunge <= lunge_in;
        released <= release_in;
      end

      if (state_started) begin
        case (curr_state)
          REST: begin
            player_data.saber_state <= IN_REST;
            in_attack <= 0;
            if (block) begin
              curr_state <= BLOCK;
              player_data.saber_attack_x <= 0;
              player_data.saber_attack_y <= 0;
            end else if (lunge) begin
              curr_state <= LUNGE;
              player_data.saber_attack_x <= player_data.location.saber_x;
              player_data.saber_attack_y <= player_data.location.saber_y;
            end else begin
              player_data.saber_attack_x <= 0;
              player_data.saber_attack_y <= 0;
            end
          end
          BLOCK: begin
            player_data.saber_state <= IN_BLOCK;
            if (released || lunge) begin
              curr_state <= REST;
            end
          end
          LUNGE: begin
            player_data.saber_state <= IN_ATTACK;
            curr_state <= ATTACK;
          end
          ATTACK: begin
            in_attack <= 1'b1;
            if (released && attack_intersecting) begin
              curr_state <= SCORE;
            end else if (sabers_colliding) begin
              if (ir_in_valid == 0) begin
                lunge <= 0;
              end
              curr_state <= RECOVER;
            end else if (released || block) begin
              curr_state <= RECOVER;
            end
          end
          SCORE: begin
            player_data.saber_state <= IN_RECOVER;
            player_scored <= 1'b1;
            curr_state <= RECOVER;
          end
          RECOVER: begin
            player_data.saber_state <= IN_RECOVER;
            if (second_counter >= FPS) begin
              second_counter <= 0;
              curr_state <= REST;
            end else begin
              second_counter <= second_counter + 1;
            end
          end
        endcase
        state_started <= 0;
        state_done <= 1'b1;
      end

      if (state_done) begin
        if (opponent_scored) begin
          player_data.health <= player_data.health - 1;
        end

        player_data_out <= player_data;
        opponent_data_out <= opponent_data;
        player_scored_out <= player_scored;
        player_scored <= 0;
        data_out_valid <= 1'b1;
        state_done <= 0;
      end else begin
        data_out_valid <= 0;
      end
    end
  end
  
endmodule

`default_nettype wire
