`timescale 1ns / 1ps
`default_nettype none
`include "hdl/types.svh"

module action_fsm_tb();
  logic clk_in;
  logic rst_in;

  // inputs from ir
  logic block_in, lunge_in, ir_in_valid;

  // inputs from syncer
  location_t player_location_in;
  data_t opponent_data_in;
  logic opponent_scored_in;
  logic syncer_in_valid;

  // outputs to print
  data_t player_data_out, opponent_data_out;
  logic player_scored_out;
  logic data_out_valid;

  action_fsm fsm_inst(
    .clk_pixel_in(clk_in),
    .rst_in(rst_in),
    .block_in(block_in),
    .lunge_in(lunge_in),
    .ir_in_valid(ir_in_valid),
    .player_location_in(player_location_in),
    .opponent_data_in(opponent_data_in),
    .opponent_scored_in(opponent_scored_in),
    .syncer_in_valid(syncer_in_valid),
    .player_data_out(player_data_out),
    .player_scored_out(player_scored_out),
    .opponent_data_out(opponent_data_out),
    .data_out_valid(data_out_valid)
  );

  always begin
      #5;  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
      clk_in = !clk_in;
  end
  //initial block...this is our test simulation
  initial begin
    $dumpfile("action_fsm.vcd"); //file to store value change dump (vcd)
    $dumpvars(0, action_fsm_tb);
    $display("Starting Sim"); //print nice message at start
    clk_in = 0;
    rst_in = 0;
    syncer_in_valid = 0;
    ir_in_valid = 0;
    #10;
    rst_in = 1;
    #10;
    rst_in = 0;
    #10;
    #100;
    block_in = 0;
    lunge_in = 0;
    ir_in_valid = 1'b1;
    #10;
    ir_in_valid = 0;

    #100;
    player_location_in = 63'b11100100001_1111111010_11100011111_0101011101_10101010101_0101010101;
    opponent_data_in = 89'b101_00000100001_1010101010_11111011111_0101010101_10101010101_0101010101_00_10101010101_0101010101;
    opponent_scored_in = 0;
    syncer_in_valid = 1'b1;
    #10;
    syncer_in_valid = 0;

    #100;
    block_in = 0;
    lunge_in = 1'b1;
    ir_in_valid = 1'b1;
    #10;
    ir_in_valid = 0;

    #100;
    player_location_in = 63'b00000000100_0000000100_11100011111_0101011101_00000000000_0000000100;
    opponent_data_in = 89'b101_00000000001_0000000001_00000011111_0000010101_00000000000_0000000000_00_10101010101_0101010101;
    opponent_scored_in = 0;
    syncer_in_valid = 1'b1;
    #10;
    syncer_in_valid = 0;

    #100;
    block_in = 0;
    lunge_in = 1'b1;
    ir_in_valid = 1'b1;
    #10;
    ir_in_valid = 0;

    #100;
    player_location_in = 63'b11100100001_1111111010_11100011111_0101011101_10101010101_0000000100;
    opponent_data_in = 89'b101_00000000001_0000000001_00011000000_0100000000_10101010101_0101010101_00_10101010101_0101010101;
    opponent_scored_in = 0;
    syncer_in_valid = 1'b1;
    #10;
    syncer_in_valid = 0;

    #100;
    block_in = 0;
    lunge_in = 0;
    ir_in_valid = 1'b1;
    #10;
    ir_in_valid = 0;

    #100;
    player_location_in = 63'b11100100001_1111111010_11100011111_0101011101_10101010101_0000000100;
    opponent_data_in = 89'b101_00000000001_0000000001_00011000000_0100000000_10101010101_0101010101_00_10101010101_0101010101;
    opponent_scored_in = 0;
    syncer_in_valid = 1'b1;
    #10;
    syncer_in_valid = 0;

    #100;
    syncer_in_valid = 1'b1;
    #10;
    syncer_in_valid = 0;

    #100000;


    $display("Finishing Sim"); //print nice message at end
    $finish;
  end
endmodule
`default_nettype wire
