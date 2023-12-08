`timescale 1ns / 1ps
`default_nettype none
`include "hdl/types.svh"

module transmitter_tb();
  localparam DATA_WIDTH = $bits(data_t);

  logic clk_in;
  logic rst_in;

  // inputs from previous state of fsm
  data_t old_player_data_in;
  logic player_scored_in;
  logic old_player_data_in_valid;

  // inputs from bounding box module
  location_t location_in;
  logic location_in_valid;

  // outputs to print
  logic data_out, data_clk_out, sel_out;
  location_t location_out;
  logic location_out_valid;

  state_transmitter transmitter_inst(
    .clk_pixel_in(clk_in),
    .rst_in(rst_in),
    .old_player_data_in(old_player_data_in),
    .player_scored_in(player_scored_in),
    .old_player_data_in_valid(old_player_data_in_valid),
    .location_in(location_in),
    .location_in_valid(location_in_valid),
    .data_out(data_out),
    .data_clk_out(data_clk_out),
    .sel_out(sel_out),
    .location_out(location_out),
    .location_out_valid(location_out_valid)
  );

  always begin
      #5;  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
      clk_in = !clk_in;
  end
  //initial block...this is our test simulation
  initial begin
    $dumpfile("transmitter.vcd"); //file to store value change dump (vcd)
    $dumpvars(0, transmitter_tb);
    $display("Starting Sim"); //print nice message at start
    clk_in = 0;
    rst_in = 0;
    old_player_data_in_valid = 0;
    player_scored_in = 0;
    #10;
    rst_in = 1;
    #10;
    rst_in = 0;
    #10;
    old_player_data_in = 89'b101_00000100001_1010101010_11111011111_0101010101_10101010101_0101010101_00_10101010101_0101010101;
    old_player_data_in_valid = 1'b1;
    #10;
    old_player_data_in_valid = 0;
    
    location_in = 63'b10010100001_1110101010_11111011111_0111010101_10101110101_0101010101;
    location_in_valid = 1'b1;
    #10;
    location_in_valid = 0;

    #100000;

    location_in = 63'b11111101111_1110101010_11111011111_0111010101_10101110101_0101010101;
    location_in_valid = 1'b1;
    #10;
    location_in_valid = 0;
    #100;
    old_player_data_in = 89'b111_10010100001_1110101010_11111011111_0111010101_10101110101_0101010101_00_10101010101_0101010101;
    old_player_data_in_valid = 1'b1;
    player_scored_in = 1'b1;
    #10;
    old_player_data_in_valid = 0;
    #100000;

    old_player_data_in = 89'b100_10010100001_1110101010_11111011111_0111010101_10101110101_0101010101_00_10101010101_0101010101;
    old_player_data_in_valid = 1'b1;
    player_scored_in = 0;
    #10;
    old_player_data_in_valid = 0;
    #1000;
    location_in = 63'b11111110001_1110101010_11111011111_0111010101_10101110101_0101010101;
    location_in_valid = 1'b1;
    #10;
    location_in_valid = 0;

    #100000;

    #100;

    $display("Finishing Sim"); //print nice message at end
    $finish;
  end
endmodule
`default_nettype wire
